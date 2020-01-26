# ------------------------------------------------------------------------------
#  UPS U-BOOT Build Script
# ------------------------------------------------------------------------------

# Source Utility Files
source ./utils.sh
source ./setup.sh

# Usage Print
function usage() {
    echo
    echo " U-Boot Script Usage"
    echo "   build-uboot.sh --build_dir=<DIR> --log_dir=<DIR> --deploy_dir=<DIR> --board=<BOARD>"
    echo "     build_dir  :  Location to build u-boot          {default=.}"
    echo "     log_dir    :  Location to write log file        {default=.}"
    echo "     deploy_dir :  Location to write output products {default=NONE}"
    echo "     board      :  Board type {coraz7/artyz7}        {default=coraz7}"
    echo
}

# Start Scripts
disp "U-BOOT Build Script" 2

# Argument Defaults
BUILD_DIR=`pwd`
LOG_DIR=`pwd`
DST_DIR=""
BOARD="coraz7"

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

#         -e=*|--extension=*)
#             EXTENSION="${i#*=}"
#             shift # past argument=value
#             ;;

        --build_dir=*)
            BUILD_DIR="${i#*=}"
            shift
            ;;

        --log_dir=*)
            LOG_DIR="${i#*=}"
            shift
            ;;

        --deploy_dir=*)
            DST_DIR="${i#*=}"
            shift
            ;;

        --board=*)
            BOARD="${i#*=}"
            shift
            ;;

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done

# Generate Log Path
LOG=${LOG_DIR}/uboot.log
INST=${BUILD_DIR}/uboot

# Print U-BOOT Build Parameters
disp "Build Dir  :  ${INST}" 3
disp "Log Dir    :  ${LOG}" 3

if [[ ${DST_DIR} != "" ]]; then
    DST=${DST_DIR}/u-boot.elf
    disp "Deploy Dir :  ${DST_DIR}" 3
fi

disp "Board      :  ${BOARD}" 3

# ------------------------------------------------------------------------------
#  Setup Xilinx Tools and Build Settings
# ------------------------------------------------------------------------------
source ${XSDK}/settings64.sh
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm

# ------------------------------------------------------------------------------
#  Start Log
# ------------------------------------------------------------------------------
echo "" > ${LOG}

# ------------------------------------------------------------------------------
#  Check Directory
#    Git checkout if it doesn't exist.  Clean if it does.
# ------------------------------------------------------------------------------
if [ ! -d ${INST} ]; then
    git clone https://github.com/mdelong20/u-boot-xlnx.git ${INST}   &>> ${LOG}
    cd ${INST}
    git checkout  xilinx-v2018.2-ups                                 &>> ${LOG}

else
    cd ${INST}
    rm -rf build

fi

# Select Build Type Based on Board
if [[ ${BOARD} == "coraz7" ]]; then
    make O=build zynq_coraz7_defconfig                               &>> ${LOG}
elif [[ ${BOARD} == "artyz7" ]]; then
    make O=build zynq_artyz7_defconfig                               &>> ${LOG}
else
    echo "Incorrect board type .. ${BOARD}"
    exit 1

fi
make O=build                                                         &>> ${LOG}

# Check if Build Passed
if [ -f 'build/u-boot' ]; then

    # Copy File if Requested
    if [[ ${DST_DIR} != "" ]]; then
        if [ ! -d ${DST_DIR} ]; then
            mkdir ${DST_DIR}
        fi
        cp build/u-boot ${DST}

        # Copy DTB File
        if [[ ${BOARD} == "coraz7" ]]; then
            cp build/arch/arm/dts/zynq-coraz7.dtb ${DST_DIR}
        elif [[ ${BOARD} == "artyz7" ]]; then
            cp build/arch/arm/dts/zynq-artyz7.dtb ${DST_DIR}
        fi
    fi

    # Report Success
    disp "U-BOOT Build Success" 3
    exit 0

else
    disp "U-BOOT Build Failed" 3
    exit 1

fi
