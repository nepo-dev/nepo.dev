---
title: 'Turning bloated mobile interfaces into CLIs'
author:
- Juan Antonio Nepormoseno Rosales
date: 2020-09-14
abstract:
 On how to use a Man-in-the-Middle proxy to reverse engineer an otherwise hidden Android App API, and what to do with that. This is not a post about app development.
---

Say, have you ever tried that "new cool app" but it lacked some feature that would've really sold it to you?
Perhaps you didn't understand the UI? Is that even your fault?
Maybe your phone even struggled to run it because it's really poorly optimized.
And that download size... omg, it's taking up how much space!?

Wouldn't it be nice to extend or improve that app?
Well, with it being closed source as it is that might be an utopian dream,
but we might still have a chance at making our lives easier by reverse engineering it and consuming its API directly.

## Overview

What we are going to do is force an Android emulator to send all its network traffic through us.
Then, we will trick it into thinking we are the server it's trying to reach and that it can trust us.
This way, we will be able to understand the encrypted HTTPS messages the app sends and receives.
This is what is known as a **"Man in the Middle attack"** in cybersecurity (MITM from now on).

[Drawing of man in the middle]

When we are able to understand what app and backend are saying to each other,
we will begin investigating the (now exposed) API.
When we're done, we might even have the chance to automate our daily app usage into a script.
That way we won't even have to open the app again.

This article will be split in 3 parts:

* Setting up the tools and emulator
* Configuring the MITM proxy
* Investigating the API and automating

## Setting up emulator and app

### Install the tools

If you don't have the Android platform tools, we will install them now. I'm using Arch, so I will use these AUR packages:

* https://aur.archlinux.org/android-sdk.git
* https://aur.archlinux.org/android-sdk-platform-tools.git

You can install them like

```sh
git clone https://aur.archlinux.org/android-sdk.git
cd android-sdk
makepkg -si
cd ..
git clone https://aur.archlinux.org/android-sdk-platform-tools.git
cd android-sdk-platform-tools
makepkg -si
```

It shouldn't be too difficult to find out how to install them on another platform.
For instance, if you're on Ubuntu, you can just do:

```sh
sudo apt update && sudo apt install android-sdk
```

On Mac (assuming you have Brew installed):

```sh
brew tap caskroom/cask
brew cask install android-sdk
```

### Install the system image

Once we have the tools we need, we can download the system image.
Since we want to download an app from the Play Store,
we will need that the image we use includes the Google API.
We want to find a an image containing "google\_apis", but not "google\_apis\_playstore".
Why not get the one that comes with the Play Store pre-installed?
Well, those are production builds and you won't be able to root them,
and we will need rooting them later.

I chose the "android-25" one, but you can choose another one if you want.

```sh
sdkmanager --list | grep "google_apis" #select another image from this list if you want
sudo sdkmanager --install "system-images;android-25;google_apis;x86_64"
```

### Create the AVD

After accepting the license and waiting for the download to finish, we can finally create our AVD.

```sh
avdmanager create avd --name "mitm-emulator" --package "system-images;android-25;google_apis;x86_64"
```

And open it with:

```sh
emulator -avd mitm-emulator &
```

### Installing Google Play

Download the Open GApps file for your system image from [https://opengapps.org/].
You can extract it with:

```sh
unzip open_gapps-*.zip 'Core/*'
rm Core/setup*
lzip -d Core/*.lz
for f in $(ls Core/*.tar); do
  tar -x --strip-components 2 -f $f
done
```

Then run your emulator and install the packages:

```sh
emulator -avd "mitm-emulator" -writable-system &
```

Wait for the loading to finish.
As soon as the home screen is shown,
you can copy the Open GApps folders to your system.

```
adb root
adb remount
adb push etc /system
adb push framework /system
adb push app /system
adb push priv-app /system
```

We can now restart the emulator.

```sh
adb shell stop
adb shell start
```

After the loading finished, you will see the Play Store in your home screen.
Now you can open it, log in and install the target app normally.

### Install the target app

This should be the easiest step.
Just login to the Play Store and download your target app.

Make sure you can open it before proceeding.

## Setting up the proxy

### Install MITM proxy

Now we will install and configure our proxy.
We will be using **[mitmproxy](https://mitmproxy.org)**, an MIT licensed open source tool built just for this.

It can easily be installed in Arch with:

```sh
pacman -Sy mitmproxy
```

It seems like on Ubuntu you will need to install pip and then install mitmproxy using pip.

```sh
sudo apt install python3-pip
sudo pip3 install mitmproxy
```

On Mac, just use brew:

```sh
brew install mitmproxy
```

To test it out, let's start the emulator
and open its settings by clicking on the 3 dots button.
Then, navigate to the **settings** section,
select the **Proxy tab**
and configure to use `http://0.0.0.0:8080` as a proxy,
like in the image below.

![]($BASE_URL$/imgs/reveng/emulator_proxy_config.png)

Run mitmproxy with no arguments, like this:

```sh
mitmproxy
```

We can now go back to the emulator and navigate anywhere.
You will see it's almost as if your device lost connection,
and if you try to use a web browser,
a warning about your connection not being private will appear.

![]($BASE_URL$/imgs/reveng/mitm_no_cert00.png){ height=400px }

This happens because mitmproxy signs HTTPS traffic with its own certificate.
Since the emulator doesn't trust that certificate, it won't even accept that response!
If you go to the terminal where you launched mitmproxy, you should see something like this.
Notice all the traffic is HTTP, there are no HTTPS messages.

![]($BASE_URL$/imgs/reveng/mitm_no_cert01.png)

![]($BASE_URL$/imgs/reveng/mitm_no_cert02.png)

To continue, we will need to make the emulator trust mitmproxy's Certificate Authority.

### Install the Certificate Authority

The way mitmproxy works is it has its own Certificate Authority.
It uses it to generate certificates on the fly for whatever
external resource the emulator asks for.
It then uses those certificates to encrypt the messages sent to it,
making it seem like the emulator is talking with the real server.
In reality, though, it is decrypting and encrypting all the messages,
so it knows **everything** the client and server are talking about.
And neither of them knows it is spying on them.

If you read the documention for mitmproxy you will see there are
official instructions on how to install the certificate on mobile devices:
you visit "`mitm.it`" in the browser, download the certificate and install it.
Then you can see HTTPS traffic normally... but just in the browser.

If we want to read HTTPS traffic from native apps,
we need to install it as a **system certificate**.
We will need root privileges for that.
So we will launch the emulator specifying:

```sh
emulator -avd mitm-emulator -writable-system &
adb root
adb remount
```

Now we need to find our certificate file.
If you are using Linux, it will be in the `~/.mitmproxy/` folder.
Let's save it to a variable named "CA":

```sh
CA="~/.mitmproxy/mitmproxy-ca-cert.pem"
```

We just need to copy that file into the emulator's trusted CAs folder,
but it needs to be named with a special value.
The filename must be the hash of the certificate itself.
You can calculate it with the following command:

```sh
HASH=$(openssl x509 -noout -subject_hash_old -in "$CA")
```

But since mitmproxy uses the same default certificate everywhere,
 we know the value should be `c8750f0d`, so you can skip this step and just use that value.
 You can always come back and recalculate the value if it does not work 😛

So you can just do:

```sh
adb push "$CA" /system/etc/security/cacerts/c8750f0d.0
```

If you try to load a website now, it should load correctly and you should see traffic being detected by mitmproxy.
Moreover, if you try to open the target app, you should see its traffic too!
Congratulations!

Don't forget to unroot the device before proceeding.

```sh
adb unroot
```

[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]


## Exploitation

### Investigating the API

To begin, let's just use the app normally.
Log in, search and browse some items...
We just want to generate some HTTP traffic
so that we can inspect it later.

Now we can go back to our terminal
and see what messages mitmproxy caught.
We are lucky and 2good2go uses JSON responses.

[response.png]

That means we can probably use
If you're lucky, it will use json instead of protobuf.

enter `w` you will enter export mode.
 If you then type `export.clip curl @focus` to copy curl request to clipboard

### Automating queries

```sh
curl asdasdasdasd > coso
cat coso | jq '.groupings[].discover_bucket.items[]' \
| jq 'select(.distance < 1)' #filter out stores further than 1 km away
| jq 'select(.item.item_category != "BAKED_GOODS")' #filter out unwanted store categories
| jq '(.store.store_name +
    " // € " + (.item.price.minor_units/100 | tostring) +
    " // "+ .pickup_interval.start)' # print only the wanted data
| sort | uniq # show only unique results
```

## End and thanks

This article is just an amalgamation of information I found online.
 I would like to thank the writers of those articles.

If you want to know more about this topic, I encourage you to follow these links and search for more information.

* Export curl from mitmproxy, Marc Betts (2019 Jul 20): [https://howdoitestthat.com/export-curl-from-mitm-proxy/]
* Setting up mitmproxy for Android emulator, Jonathan Lipps (2019 Apr 3): [https://appiumpro.com/editions/63-capturing-android-emulator-network-traffic-with-appium]
* Installing Open GApps, Daishi Kato (2017 Mar 6): [https://medium.com/@dai_shi/installing-google-play-services-on-an-android-studio-emulator-fffceb2c28a1]
* Why you need a Google API image, "oenpelli" on StackOverflow (2014 Jul 18): [https://stackoverflow.com/a/24817495]

// Ideas
;
;
In my case, this app has random offers and I want to find the nearest.







