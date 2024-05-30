#!/bin/bash

# Запуск Xephyr на дисплее :1 с разрешением 800x600
Xephyr -ac -br -noreset -screen 800x600 :1 -host-cursor&
XEPHYR_PID=$!

# sleep 1

export DISPLAY=:1

# xhost +

ruby ffi.rb
