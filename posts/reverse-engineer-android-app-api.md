---
title: 'API discovery in Android Apps and task automation'
author:
- Juan Antonio Nepormoseno Rosales
date: 2020-09-14 #started 2020-09-14?
abstract:
 On how to use a Man-in-the-Middle proxy to reverse engineer an otherwise hidden Android App API, and what to do with that. This is not a post about app development.
---

I often find myself needing to use an Android app and getting annoyed because:

* It lacks simple quality of life features like filtering, searching, automating actions, etc.
* It is really poorly optimized and it takes too long to load or is extremelly laggy.
* It doesn't show a lot of information in screen, since images and buttons have to be BIG for a smartphone app. Or, the contrary, the interactable elements are too small or don't work well, so the UX is terrible.
* It takes up too much space on my phone's storage.

Has this ever happened to you?
I would love to extend or improve that app,
but with most apps being closed source that might be an utopian dream.
In any case, we can still attempt to make our lives easier by automating our usage.
And for that, we can reverse engineer this app and consume its API directly in a script.

## Overview

> **Summary:** We will perform a MITM attack by installing a custom CA in an Android emualtor. If you understand that, go to the next section already.

//TODO ^this begs for a link!!!!!!!!!!!!!!!!!

What we are going to do is force an Android emulator to send all its network traffic through us.
Then, we will trick it into thinking we are the server it's trying to reach and that it can trust us.
This way, we will be able to understand the encrypted HTTPS messages the app sends and receives.
This is what is known as a **"Man in the Middle attack"** in cybersecurity (MITM from now on).

[Drawing of man in the middle]

When we are able to understand what app and backend are saying to each other,
we will begin investigating the (now exposed) API.
If we're lucky, we might even have the chance to automate our daily app usage into a script.
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

You can install them like:

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

On Mac (assuming you have [Brew](https://brew.sh/) installed):

```sh
brew tap caskroom/cask
brew cask install android-sdk
```

### Install the system image

Once we have the tools we need, we can download the system image.
Since we want to download an app from the Play Store,
we will need that the image we use includes the Google API.
We want to find a an image containing "google\_apis", but not "google\_apis\_playstore".
Why not get the one that comes with the Play Store pre-installed, you ask?
Well, those are production builds and you won't be able to root them.
We will need rooting them later.

//TODO review this. Here I refer to the reader as "you", but in the exploitation I'm talking about "we"

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

```sh
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

It seems on Ubuntu you will need to install pip and then install mitmproxy using pip.

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

Don't forget to unroot the device before you continue.

```sh
adb unroot
```

## Exploitation

### Investigating the API

To begin, let's just use the app normally.
Create an account with username and password
(avoid authenticating with Google or Facebook for now,
you don't want to deal with OAuth).
Log in, search and browse some items...
We just want to generate some HTTP traffic
so that we can inspect it later.

Now we can go back to our terminal
and check the messages mitmproxy caught.
We have to locate the traffic from the target app.
To do so, just browse the captured requests list
and see if any URL matches the app's domain.
Alternatively, you could look for endpoints
that match actions you performed
(like a login, search, etc.).

If you're lucky,
your target API will use a
human-readable document format
like JSON or XML, instead of protobuf.
We are lucky and 2good2go uses JSON.







[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: CONTINUE FROM HERE!!!]
[NOTE: Es muy fácil, mira:

1. Abre el emulador: emulator -avd mitm-emulator
2. Enciende mitmproxy: mitmproxy
3. Crea la cuenta con uwait o un throwaway mail.
4. Haz una búsqueda, saca captura de app + mitmproxy.
5. Copia 2 o 3 curls de la búsqueda  y testea que funciona en terminal.
6. Guarda el resultado en un archivo de texto.

No necesitas más. Hacer el script lo puedes hacer luego.
Si el emulador no te funciona en Linux, prueba en Mac]

[response.png]

This means we can easily replicate that request in the terminal.

Enter `w`. You will enter export mode.
If you then type `export.clip curl @focus`,
your request will be replicated as a curl command
and it will be copied to your clipboard.
You can then paste it on your terminal to see if it works.

### Automating queries

From this point on,
it's just like a matter of exploring
and seeing what can you do
with the endpoints you discover.
It's just like learning a regular API.

For example,
I wanted to automate a search for a restaurant.
It has to be near me (<1km),
it cannot be a bakery and
I just want to know the name, price and pickup time.

```sh
function get_store_list() {
  curl https://x.x.x.x/get_store_list?...
}

result=$(get_store_list \
| jq '.groupings[].discover_bucket.items[]' # get all stores
| jq 'select(.distance < 1)' # filter out stores further than 1 km away
| jq 'select(.item.item_category != "BAKED_GOODS")' # filter out unwanted store categories
| jq '(.store.store_name +
    " // € " + (.item.price.minor_units/100 | tostring) +
    " // "+ .pickup_interval.start)' # print only the wanted data
| sort | uniq) # sort and show only unique results

notify-send -t 20000 "$result" # send a notification in Linux desktop
# or
termux-notification --content "$result" # send a notification in Android's Termux
```

This shows a simple list like this one as a notification:

```plaintext
store_name_1 // € price // time
store_name_2 // € price // time
store_name_3 // € price // time
store_name_4 // € price // time
```

It can be then saved as a script
and ran as a cron job
everyday at certain time (lunchtime?).
This will notify me about
available stores to get food from.

Do once.
Run forever.
Ok, run until the API changes,
but still it's less worrysome than
opening the app and searching manually.

## Links of interest

If you want to know more about this topic,
I encourage you to follow these links
and search for more information.

* Setting up mitmproxy for Android emulator, Jonathan Lipps (2019 Apr 3): [https://appiumpro.com/editions/63-capturing-android-emulator-network-traffic-with-appium]
* Installing Open GApps, Daishi Kato (2017 Mar 6): [https://medium.com/@dai_shi/installing-google-play-services-on-an-android-studio-emulator-fffceb2c28a1]
* Why you need a Google API image, "oenpelli" on StackOverflow (2014 Jul 18): [https://stackoverflow.com/a/24817495]
* mitmproxy docs: [https://docs.mitmproxy.org/stable/]
