#!/bin/bash

# ------------------------------------------------------------------------------
#  Name   :  Create USB Update Stick
#  Author :  Mike DeLong
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  Setup Script
# ------------------------------------------------------------------------------
source ./utils.sh
source ./setup.sh
source ${XSDK}/settings64.sh

# ------------------------------------------------------------------------------
#  Setup Build Paths
# ------------------------------------------------------------------------------
DD=`realpath ../deploy`

# Get Input Parameter
if [ -z $1 ]; then
    echo "USB Drive Does Not Exist ..."
    exit 1

fi

# Save Input
USB_ROOT=$1

# Generate BIF File
echo "the_ROM_image:"                > ./boot.bif
echo "{"                            >> ./boot.bif
echo "	[bootloader]${DD}/fsbl.elf" >> ./boot.bif
echo "	${DD}/ups.bit"              >> ./boot.bif
echo "	${DD}/u-boot.elf"           >> ./boot.bif
echo "}"                            >> ./boot.bif

# Build BOOT.BIN
$BOOTG -image ./boot.bif -o i BOOT.bin -w

# Create Indicator File
touch ${USB_ROOT}/update

# Create Directory and Copy Update Files
if [ ! -d /${USB_ROOT}/files ]; then
    mkdir ${USB_ROOT}/files
fi

# Copy File to USB Stick
cp ${DD}/rootfs.cpio.uboot      ${USB_ROOT}/files/rootfs
cp ${DD}/uImage                 ${USB_ROOT}/files
cp ${DD}/zynq-coraz7.dtb        ${USB_ROOT}/files/devicetree.dtb
cp ./uEnv.txt                   ${USB_ROOT}/files
cp ./BOOT.bin                   ${USB_ROOT}/files
