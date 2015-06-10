#!/bin/bash
# Generates Arch Linux packagified ruby gems
# Jacob Alexander - 2015

GEMS=('serialport' 'ffi' 'libusb')

mkdir -p gempkgs
cd gempkgs

# Go through the list of gems and create packages
pacgem ${GEMS[@]}
pacgem --create ${GEMS[@]}

