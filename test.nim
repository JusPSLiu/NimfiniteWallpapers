echo "test"

import winim
import std/[times, os]


var wallpaper1: LPCWSTR = "%OneDrive%/Pictures/Screenshots 1/Screenshot 2025-04-02 112249.png"
var wallpaper2: LPCWSTR = "%OneDrive%/Pictures/Screenshots 1/Screenshot 2025-10-06 151307.png"

var min_time_ms = 400
var lastTime: Time = getTime()
var currentTime: Time
var negativeCatchupTime: int = 0

proc calculatedSleep(sleepLen_ms : int): void =
    # calculate delay offset from delay of wallpaper change
    currentTime = getTime()
    let offsetSleeplen_ms = sleepLen_ms - (currentTime - lastTime).inMilliseconds + negativeCatchupTime
    # sleep using offset
    sleep(offsetSleeplen_ms)
    echo "\nSLEEPING FOR: "
    echo offsetSleeplen_ms
    # if this one frame took way too long, try to catch up if possible
    if (offsetSleeplen_ms < 0):
        negativeCatchupTime = min(offsetSleeplen_ms, negativeCatchupTime)
    else:
        negativeCatchupTime = 0
    # reset lastTime for next time
    lastTime = getTime()


for i in countup(0, 9):
    discard SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, wallpaper1, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE)
    calculatedSleep(min_time_ms)
    discard SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, wallpaper2, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE)
    calculatedSleep(min_time_ms)
