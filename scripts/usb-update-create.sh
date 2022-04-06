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
#  Command Line Inputs Parse
# ------------------------------------------------------------------------------
# Default Params
FORCE=0

# Parse
while [[ $# -gt 0 ]]
do
    key="$1"

    # Force Update
    case $key in

        -u|--usb)
            shift
            USB_ROOT=$1
            shift
            ;;

        -f|--force)
            FORCE=1
            shift
            ;;

        # Unknown .. Error
        *)
            echo "Unknown input :  $key"
            exit 1
            ;;

    esac
done

# ------------------------------------------------------------------------------
#  Setup Build Paths
# ------------------------------------------------------------------------------
DD=`realpath ../deploy`

# Get Input Parameter
if [ -z ${USB_ROOT} ]; then
    echo "USB Drive Does Not Exist ..."
    exit 1
fi

# ------------------------------------------------------------------------------
#  Create BOOT
# ------------------------------------------------------------------------------
# Generate BIF File
echo "the_ROM_image:"                > ./boot.bif
echo "{"                            >> ./boot.bif
echo "	[bootloader]${DD}/fsbl.elf" >> ./boot.bif
echo "	${DD}/ups.bit"              >> ./boot.bif
echo "	${DD}/u-boot.elf"           >> ./boot.bif
echo "}"                            >> ./boot.bif

# Build BOOT.BIN
$BOOTG -image ./boot.bif -o i BOOT.bin -w

# ------------------------------------------------------------------------------
#  Create Version File
# ------------------------------------------------------------------------------
# Create Version File
VER=${USB_ROOT}/update

# Generate Short Hash
HASH=`git rev-parse HEAD`
HASH_SHORT=${HASH:0:8}
echo ${HASH_SHORT} > ${VER}

# Create Directory and Copy Update Files
if [ ! -d /${USB_ROOT}/files ]; then
    mkdir ${USB_ROOT}/files
fi

# ------------------------------------------------------------------------------
#  Create Force File
# ------------------------------------------------------------------------------
# Create Version File
FORCE_FILE=${USB_ROOT}/force

if [ ${FORCE} -eq 1 ]; then
    touch ${USB_ROOT}/force
fi

# ------------------------------------------------------------------------------
#  Copy File to USB Stick
# ------------------------------------------------------------------------------
# Create Directory and Copy Update Files
if [ ! -d /${USB_ROOT}/files ]; then
    mkdir ${USB_ROOT}/files
fi

# Copy Files
cp ${DD}/rootfs.cpio.uboot      ${USB_ROOT}/files/rootfs
cp ${DD}/uImage                 ${USB_ROOT}/files
cp ${DD}/zynq-coraz7.dtb        ${USB_ROOT}/files/devicetree.dtb
cp ./uEnv.txt                   ${USB_ROOT}/files
cp ./BOOT.bin                   ${USB_ROOT}/files
