---
layout: post
title: "Worried you'll forget charging your Mac's bluetooth mouse?"
published: true
tags: mac macos keyboard mouse magic battery python script 
---

Hey hey, guys! If you work with a Mac and you use bluetooth keyboard and mouse, you might have found yourself without battery on one of those devices. It's not my case, I'm so anxious about not having any of those devices available during the working day that I check the remaing charge obsessively.

To save time and to allow me to forget the battery, I have written a small python script that lists all the devices with battery. It also prints a nice bar with colors besides every device on the list. An almost depleted bar in red means you HAVE to charge the device or it will run out of battery, while a full bar in green is satisfying to see.

You can find it in my ["Notes and scripts" repo](https://github.com/Edearth/Notes-and-scripts/blob/master/command_line_tools/apple/battery_life_bluetooth_devices/print_battery_life.py) if you want to try it out.

The script finds out about attached devices using the 'ioreg' application and parsing the data with regex to recover name and battery percent. I have it in my bash_profile to see the battery percent every time I open a new terminal. 

I hope you find it useful. It made me worry less about forgetting to charge my mouse, for sure!
