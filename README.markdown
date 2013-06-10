# gfxStatus

This menu bar Mac OS X app shows the currently used graphics card by a Macbook Pro Retina. The card can be either Intel (in which case an "i" is displayed or Nvidia (in which case an "n" is displayed). 

The app simply checks every 20 seconds the output of `system_profiler SPDisplaysDataType` to figure out which is the currently used graphics card.

I was using https://github.com/codykrieger/gfxCardStatus until a Mountain Lion update broke this app and I could not run any apps that use discrete graphics.

I started from the NSSStatusItemExample at https://github.com/tjarratt/NSStatusItemExample ... many thanks, it was super useful.