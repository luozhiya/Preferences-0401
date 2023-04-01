#!/bin/bash

# launch the screensaver in a window and leave it running in the
# background
# cube21 
# pacman 
/usr/lib/xscreensaver/cube21 &
# wait a bit for the window to come up
sleep 1
# make the window fullscreen
# wmctrl -r "Pacman: from the XScreenSaver" -b toggle,fullscreen
wmctrl -r "Cube21: from the XScreenSaver 6.06 distribution (11-Dec-2022)" -b toggle,fullscreen
