---
title: 'Reverse engineer an Android App's API'
author:
- Juan Antonio Nepormoseno Rosales
date: 2020-08-12
abstract:
 On how to use a Man-in-the-Middle proxy to snoop around an otherwise hidden App traffic, and what to do with that
---

# Reverse engineering for better (CLI) interfaces

Say, have you ever had a conversation with someone that recommended you this "new cool app"? In some cases you might have even been interested by what that product has to offer you. But it all falls flat when you try it and you are greeted by a slow, complex interface and an unoptimized app size that takes up more real state in your memory than it should. Wouldn't it be nice to just consume the raw data and avoid that bloated UI altogether? Well, that might be a utopic dream, but at least we can automate some of the most painful tasks.

## Overview

What we are going to do is reverse engineer the API this app uses so that we can automate querying and filtering.

This article will be split in 3 parts:

* Setting up emulator and app
* Setting up the proxy
* Investigating the API and automation

### What you will need

* **Android platform tools (avd, emulator, etc.):** to generate HTTP traffic that consumes the target API.
* **[OpenGapps](https://opengapps.org/):** to install the app we want to investigate.
* **[mitmproxy](https://github.com/mitmproxy/mitmproxy) ([official page](https://mitmproxy.org)):** to read the HTTP traffic coming out of the emulator.
* **[jq](https://github.com/stedolan/jq) ([official page](https://stedolan.github.io/jq/)):** to filter the data coming from the API.

## Setting up emulator and app

### Create the AVD

System image (needs Google API so that we can install Play Store)
Open avd
$ANDROID_HOME/tools/android avd &
Create virtual device

### Installing Google Play

Download the Open GApps file for your system image from [https://opengapps.org/]. You can extract it with:

```sh
unzip open_gapps-x86_64-6.0-pico-20170304.zip 'Core/*'
rm Core/setup*
lzip -d Core/*.lz
for f in $(ls Core/*.tar); do
  tar -x --strip-components 2 -f $f
done
```

Then run an emulator and install the packages:

```sh
emulator @android6 -writable-system &
# wait for emulator to load
adb remount
adb push etc /system
adb push framework /system
adb push app /system
adb push priv-app /system
# restart
adb shell stop
adb shell start
```

Now you can open the Play Store, log in and install the target app normally.

## Setting up the proxy

### Install the Certificate Authority

Launch the emulator and unlock it to have root privileges.

```sh
emulator -avd test-proxy -writable-system &
adb root
adb remount
```

Now we need to find our certificate file. If you are using Linux, it will usually be in the `~/.mitmproxy/` folder.

```sh
CA="~/.mitmproxy/mitmproxy-ca-cert.pem"
```

We just need to copy that file into the emulator's trusted CAs folder, but it needs to be named with a special value. The filename must be the hash of the certificate itself. You can calculate it with the following command:

```sh
HASH=$(openssl x509 -noout -subject_hash_old -in "$CA")
```

Since mitmproxy uses the same certificate for everybody, the value should be `c8750f0d`, so you can skip this step and just use that value. You can always come back and recalculate the value if it does not work 😛

So you can just do:

```sh
adb push "$CA" /system/etc/security/cacerts/$HASH.0
```

If you try to load a website now, it should load correctly and you should see traffic being detected by mitmproxy. Congratulations!

Don't forget to unroot the device before proceeding.

```sh
adb unroot
```

## Exploitation

### Investigating the API

Use app
See what appears in mitmproxy
If you're lucky, it will use json instead of protobuf.

enter `w` you will enter export mode. If you then type `export.clip curl @focus` to copy curl request to clipboard

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

This article is just an amalgamation of information I found online. I would like to thank the writers of those articles.

If you want to know more about this topic, I encourage you to follow these links and search for more information.

* Export curl from mitmproxy, Marc Betts (2019 Jul 20): [https://howdoitestthat.com/export-curl-from-mitm-proxy/]
* Setting up mitmproxy for Android emulator, Jonathan Lipps (2019 Apr 3): [https://appiumpro.com/editions/63-capturing-android-emulator-network-traffic-with-appium]
* Installing Open GApps, Daishi Kato (2017 Mar 6): [https://medium.com/@dai_shi/installing-google-play-services-on-an-android-studio-emulator-fffceb2c28a1]
* Why you need a Google API image, "oenpelli" on StackOverflow (2014 Jul 18): [https://stackoverflow.com/a/24817495]

// Ideas
;
;
In my case, this app has random offers and I want to find the nearest.
