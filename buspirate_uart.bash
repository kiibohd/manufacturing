#!/bin/bash
# Jacob Alexander 2016
# Sets up a kiibohd debug uart, mostly used for bootloader debugging
# NOTE: Only tested with a buspirate on Linux

# Expected exported variables
# TODO

# NOTE: This requires a udev rule
#       See: https://wiki.archlinux.org/index.php/Bus_pirate
BUSPIRATE=/dev/buspirate
INSTANCE=buspirate

# Setup screen session
# Assumes /dev/buspirate is properly setup with udev
screen -dmS ${INSTANCE} ${BUSPIRATE} 115200 8N1

# Cleanup interface just in case there is junk in the cli
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015\015\015\015\015"
sleep 0.01
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015\015\015\015\015"
sleep 0.01

# Macro Selection
screen -Rd ${INSTANCE} -p0 -X stuff "m"
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Enter UART mode
screen -Rd ${INSTANCE} -p0 -X stuff "3"
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Set Baud rate to 115200
screen -Rd ${INSTANCE} -p0 -X stuff "9"
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Small delay to help the device
sleep 0.01

# Set 8 bit and no parity
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Set 1 stop bit
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Receive polarity Idle 1
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Open drain (H=Hi-Z, L=GND)
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"

# Small delay to help the device
sleep 0.01
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015\015\015\015\015"
sleep 0.01

# Set to a transparent UART bridge
screen -Rd ${INSTANCE} -p0 -X stuff "(1)"
screen -Rd ${INSTANCE} -p0 -X eval "stuff \015"
screen -Rd ${INSTANCE} -p0 -X stuff "y"

# Open up terminal
screen -r ${INSTANCE}

