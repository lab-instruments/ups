#!/bin/bash

# ------------------------------------------------------------------------------
#  Name   :  Top Level UPS Card Creation Script
#  Author :  Mike DeLong
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  Setup Script
# ------------------------------------------------------------------------------
source ./utils.sh
source ./setup.sh

# ------------------------------------------------------------------------------
#  Setup Build Paths
# ------------------------------------------------------------------------------
BD=`realpath ../build`
SD=`realpath ../build/sdk`
LD=`realpath ../build/log`
DD=`realpath ../deploy`
CDY=`realpath ../yocto`
CDB=`realpath ../buildroot`

# ------------------------------------------------------------------------------
#  Setup Build Directories
# ------------------------------------------------------------------------------
# Check Build Dir
if [ ! -d ${DD} ]; then
    echo "Deploy directory doesn't exist .. Exit."
    exit 1
fi

# Clear Log Dir
if [ ! -d ${LD} ]; then
    mkdir ${LD}
else
    rm -rf ${LD}
    mkdir ${LD}
fi

# ------------------------------------------------------------------------------
#  Parse Script Params
# ------------------------------------------------------------------------------
# Usage Print
function usage() {
    echo
    echo " Card Top Level Script Usage"
    echo "   card.sh --card_dev=<DEV> --log_dir=<DIR>"
    echo "     log_dir    :  Location to write log file            {default=.}"
    echo "     card_dev   :  Location 0f SD Card                   {default=NONE}"
    echo
}

# Start Scripts
printf "   * Card Creation Script\n"

# Argument Defaults
LOG_DIR=`pwd`
DEV=""

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

        --card_dev=*)
            DEV="${i#*=}"
            shift
            ;;

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done

# Check if Card Dev is Defined
if [ -z ${DEV} ]; then
    echo "Card DEV not defined .. Exit."
    exit 1
fi

# Run Card Formatter
sudo ./card-format.sh --card_dev="${DEV}" --log_dir="${LD}"

# Run Card Creators
sudo ./card-create.sh --card_dev="${DEV}" --log_dir="${LD}" --deploy_dir="${DD}" --bootgen="${BOOTG}"

