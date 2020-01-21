# ------------------------------------------------------------------------------
#  Setup Script
# ------------------------------------------------------------------------------
source ./utils.sh
source ./setup.sh

# ------------------------------------------------------------------------------
#  Parse Script Params
# ------------------------------------------------------------------------------
# Usage Print
function usage() {
    echo
    echo " Yocto Build Script Usage"
    echo "   build-yocto.sh --build_dir=<DIR> --log_dir=<DIR> --deploy_dir=<DIR>"
    echo "     build_dir  :  Location to build Yocto           {default=.}"
    echo "     log_dir    :  Location to write log file        {default=.}"
    echo "     deploy_dir :  Location to write output products {default=NONE}"
    echo "     conf_dir   :  Location for Yocto configuration  {default=NONE}"
    echo
}

# Start Scripts
disp "Yocto Build Script" 2

# Argument Defaults
LOG_DIR=`pwd`
BUILD_DIR=`pwd`
DST_DIR=""
CONF_DIR=""

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
            DD="${i#*=}"
            shift
            ;;

        --conf_dir=*)
            CD="${i#*=}"
            shift
            ;;

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done

# Check Configuration Files
if [ ! -f "${CD}/local.conf" ]; then
    echo " LOCAL.CONF not in configuration directory .. Exit"
    exit 1
fi

if [ ! -f "${CD}/bblayers.conf" ]; then
    echo " BBLAYERS.CONF not in configuration directory .. Exit"
    exit 1
fi

# Generate Paths
LOG=${LOG_DIR}/fpga-sdk.log
RFS=${BUILD_DIR}/fsbl/Debug/fsbl.elf
BD=${BUILD_DIR}/yocto

# Print U-BOOT Build Parameters
disp "Log Dir    :  ${LOG_DIR}" 3
disp "Build Dir  :  ${SDK_DIR}" 3
disp "Deploy Dir :  ${SDK_DIR}" 3

# ------------------------------------------------------------------------------
#  Script Xilinx Tools
# ------------------------------------------------------------------------------
source ${XVIV}/settings64.sh

# ------------------------------------------------------------------------------
#  Clean Stale Root File System
# ------------------------------------------------------------------------------
# rm ?

# ------------------------------------------------------------------------------
#  Get Yocto Poky Source and Checkout Branch
# ------------------------------------------------------------------------------
# Check if Repo Exists Already
if [ ! -d ${BD} ]; then
    git clone git://git.yoctoproject.org/poky ${BD}
    cd ${BD}
    git checkout rocko
else
    cd ${BD}
fi

# ------------------------------------------------------------------------------
#  Get Xilinx Meta Layer and Checkout Branch
# ------------------------------------------------------------------------------
# Check if Repo Exists Already
if [ ! -d "meta-xilinx" ]; then
    git clone https://github.com/Xilinx/meta-xilinx.git
    cd meta-xilinx/
    git checkout rel-v2018.2
    cd ..
fi

# ------------------------------------------------------------------------------
#  Setup Build
# ------------------------------------------------------------------------------
# Setup Build Environment
source oe-init-build-env
bitbake-layers add-layer "${BD}/meta-xilinx"

# Copy Configuration Files
cp ${CD}/bblayers.conf ./conf/
cp ${CD}/local.conf ./conf/

# Build
bitbake core-image-minimal





# ------------------------------------------------------------------------------
#  Check if Build Passed
# ------------------------------------------------------------------------------
#if [ -f ${FSBL} ]; then
#
#    # Copy File if Requested
#    if [[ ${DST_DIR} != "" ]]; then
#        if [ ! -d ${DST_DIR} ]; then
#            mkdir ${DST_DIR}
#        fi
#        cp ${FSBL} ${DST_DIR}
#    fi
#
#    # Report Success
#    disp "FPGA SDK Build Success" 3
#    exit 0
#
#else
#    disp "FPGA SDK Build Failed" 3
#    exit 1
#
#fi
#