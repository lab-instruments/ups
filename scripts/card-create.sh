#!/bin/bash

# ------------------------------------------------------------------------------
#  Parse Script Params
# ------------------------------------------------------------------------------
# Usage Print
function usage() {
    echo
    echo " Card Create Script Usage"
    echo "   card-create.sh --deploy_dir=<DIR> --card_dev=<DEV> --log_dir=<DIR>"
    echo "     log_dir    :  Location to write log file            {default=.}"
    echo "     deploy_dir :  Location to write output products     {default=NONE}"
    echo "     card_dev   :  Location of SD Card                   {default=NONE}"
    echo "     bootgen    :  Location Bootgen                      {default=NONE}"
    echo
}

# Start Scripts
printf "     - Card-Create Script\n"

# Argument Defaults
LOG_DIR=`pwd`
SD=""
DEV=""
BOOTG=""

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

#         -e=*|--extension=*)
#             EXTENSION="${i#*=}"
#             shift # past argument=value
#             ;;

        --card_dev=*)
            DEV="${i#*=}"
            shift
            ;;

        --log_dir=*)
            LOG_DIR="${i#*=}"
            shift
            ;;

        --deploy_dir=*)
            SD="${i#*=}"
            shift
            ;;

        --bootgen=*)
            BOOTG="${i#*=}"
            shift
            ;;

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done

# Setup Log
LOG=${LOG_DIR}/card-create.log
echo "" > ${LOG}

if [ "${BOOTG}" == "" ]; then
    exit 1
fi

# Generate BIF File
echo "the_ROM_image:"                > ./boot.bif
echo "{"                            >> ./boot.bif
echo "	[bootloader]${SD}/fsbl.elf" >> ./boot.bif
echo "	${SD}/ups.bit"              >> ./boot.bif
echo "	${SD}/u-boot.elf"           >> ./boot.bif
echo "}"                            >> ./boot.bif

# Build BOOT.BIN
$BOOTG -image ./boot.bif -o i BOOT.bin -w                           &>> ${LOG}

if [ ! -d /mnt/boot ]; then
    mkdir -p /mnt/boot
fi
mount /dev/${DEV}1 /mnt/boot

# if [ ! -d /mnt/rootfs ]; then
#     mkdir -p /mnt/rootfs
# fi
# mount /dev/${DEV}2 /mnt/rootfs
# cp ./BOOT.bin /mnt/rootfs/

cp ${SD}/rootfs.cpio.uboot      /mnt/boot/rootfs
cp ${SD}/uImage                 /mnt/boot
cp ${SD}/zynq-coraz7.dtb        /mnt/boot/devicetree.dtb
cp ./uEnv.txt                   /mnt/boot
cp ./BOOT.bin                   /mnt/boot

umount /dev/${DEV}1
# umount /dev/${DEV}2
