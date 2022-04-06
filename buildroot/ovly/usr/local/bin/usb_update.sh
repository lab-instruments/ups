#!/bin/sh

# Create Log
logger -t usb_update "Start USB update script"                               >>  ${LOG}

# Get Number
SD_NUM=${1:3:1}

# Mount Location
MNT=/mnt/usb${SD_NUM}

# Logging
logger -t usb_update "USB mass storage device detected : $1"
logger -t usb_update "SD number                        : ${SD_NUM}"
logger -t usb_update "Mount location                   : ${MNT}"

# ------------------------------------------------------------------------------
#  Mount
# ------------------------------------------------------------------------------
echo
logger -t usb_update "Attempt to mount /dev/$1 at ${MNT}"

# Check if USB Mount Directory Exists
if [ ! -d ${MNT} ]; then
    mkdir ${MNT}
fi

# Mount
mount /dev/$1 ${MNT}

# Check if BOOT Mount Directory Exists
if [ ! -d /mnt/BOOT ]; then
    mkdir /mnt/BOOT
fi

# Mount
mount /dev/mmcblk0p1 /mnt/BOOT

# ------------------------------------------------------------------------------
#  Update
# ------------------------------------------------------------------------------
# Check if Correct Structure Exists
if [ -f ${MNT}/update ]; then
    logger -t usb_update "Update request file exists"
else
    logger -t usb_update "Update request file does not exist .. Exit"
    exit 0
fi

# Check for the Version
USB_VER=`cat ${MNT}/update`
CUR_VER=$(head -n 1 /root/version)

if [ ${USB_VER} == ${CUR_VER} ]; then
    if [ -f ${MNT}/force ]; then
        logger -t usb_update "Git versions are equal but force is set"
    else
        logger -t usb_update "Git versions are equal .. skip update"
        exit 0
    fi
fi

cp ${MNT}/files/* /mnt/BOOT/

# Cleanup
umount /mnt/BOOT
umount ${MNT}
rm -rf /mnt/BOOT
rm -rf ${MNT}

logger -t usb_update Update complete
