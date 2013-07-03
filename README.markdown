# lightMon

This menu bar Mac OS X app is very lightweight and simple way to monitor some basic stats about your Mac laptop.
The goal is give visual hints when your laptop is going to waste battery power (i.e., high CPU load or use of the discrete graphics card). 

The app is a:

1) lightweight CPU usage monitor. Simply get CPU load averaged over all cores and display it in the menu bar. 

2) a graphics card monitor: displays the currentluy used graphics card by a Macbook Pro Retina. The card can be either Intel (in which case an "i" is displayed or Nvidia (in which case an "n" is displayed).  

The app simply checks every 10 seconds the output of `system_profiler SPDisplaysDataType` to figure out which is the currently used graphics card.

I was using https://github.com/codykrieger/gfxCardStatus until a Mountain Lion update broke this app and I could not run any apps that use discrete graphics.

I started from the NSSStatusItemExample at https://github.com/tjarratt/NSStatusItemExample ... many thanks, it was super useful.

