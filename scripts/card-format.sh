#!/bin/bash

# ------------------------------------------------------------------------------
#  Parse Script Params
# ------------------------------------------------------------------------------
# Usage Print
function usage() {
    echo
    echo " Card Create Script Usage"
    echo "   card-create.sh --card_dev=<DEV> --log_dir=<DIR>"
    echo "     log_dir    :  Location to write log file            {default=.}"
    echo "     card_dev   :  Location 0f SD Card                   {default=NONE}"
    echo
}

# Start Scripts
printf "   * Card-Format Script\n"

# Argument Defaults
LOG_DIR=`pwd`
CARD_DEV=""

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

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done

if [ "${DEV}" != "" ]; then
    # Format Card
    dd if=/dev/zero of=${DEV} bs=1024 count=1
    BYTES=`fdisk -l ${DEV} | grep 'Disk \/dev' | awk '{print $5}'`
    echo ${BYTES}
    CYL=$((${BYTES}/8225280))
    echo ${CYL}

    (
        echo x       # Expert Mode
        echo h       # Set Number of Heads
        echo 255     # 255 Heads
        echo s       # Set Number of Sectors
        echo 63      # 63 Sectors
        echo c       # Set Number of Cylinders
        echo ${CYL}  # Calculated Number of Cylinders
        echo r       # Goto Regular Mode
        echo n       # New Partition
        echo p       # Primary Type
        echo 1       # Set Partition Number
        echo 2048    # Set First Sector
        echo +200M   # Set Size
        echo n       # New Partition
        echo p       # Primary Type
        echo 2       # Set Partition Number
        echo         # Default First Sector
        echo         # Default Size
        echo a
        echo 1
        echo t
        echo 1
        echo c
        echo t
        echo 2
        echo 83
        echo p
        echo w
    ) | fdisk ${DEV}

    mkfs.vfat -F 32 -n boot ${DEV}1
    mkfs.ext4 -L rootfs ${DEV}2

else
    printf "     - Card DEV Not Defined .. Exit\n"
    exit 1

fi
