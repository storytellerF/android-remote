#!/bin/bash
set -e
adb connect redroid:5555
export DISPLAY=:1
scrcpy -s redroid:5555 --render-driver=software