#!/bin/sh

# Create Log
LOG=/tmp/usb_update.log
echo ""                                                    >   ${LOG}
echo " -- USB UPDATE SCRIPT"                               >>  ${LOG}

# Timestamp
echo `date`                                                >>  ${LOG}
echo ""

# Get Number
SD_NUM=${1:3:1}

# Mount Location
MNT=/mnt/usb${SD_NUM}

# Logging
echo "USB mass storage device detected : $1"               >>  ${LOG}
echo "SD number                        : ${SD_NUM}"        >>  ${LOG}
echo "Mount location                   : ${MNT}"           >>  ${LOG}
echo ""

# ------------------------------------------------------------------------------
#  Mount
# ------------------------------------------------------------------------------
echo
echo "Attempt to mount /dev/$1 at ${MNT}"                  >>  ${LOG}

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
    echo "Update request file exists"                      >>  ${LOG}
    cp ${MNT}/files/* /mnt/BOOT/                           &>> ${LOG}

else
    echo "Update request file does not exist .. Exit"      >>  ${LOG}
    exit 0

fi

# Cleanup
umount /mnt/BOOT
umount ${MNT}
rm -rf /mnt/BOOT
rm -rf ${MNT}
