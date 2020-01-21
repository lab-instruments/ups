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
    echo " FPGA SDK Build Script Usage"
    echo "   build-fpga-sdk.sh --sdk_dir=<DIR> --log_dir=<DIR> --deploy_dir=<DIR>"
    echo "     sdk_dir    :  Location to build the FPGA SDK    {default=.}"
    echo "     log_dir    :  Location to write log file        {default=.}"
    echo "     deploy_dir :  Location to write output products {default=NONE}"
    echo
}

# Start Scripts
disp "FPGA SDK Build Script" 2

# Argument Defaults
LOG_DIR=`pwd`
SDK_DIR=`pwd`
DST_DIR=""

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

#         -e=*|--extension=*)
#             EXTENSION="${i#*=}"
#             shift # past argument=value
#             ;;

        --sdk_dir=*)
            SDK_DIR="${i#*=}"
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

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done

# Generate Paths
LOG=${LOG_DIR}/fpga-sdk.log
FSBL=${SDK_DIR}/fsbl/Debug/fsbl.elf

# Print U-BOOT Build Parameters
disp "Log Dir    :  ${LOG_DIR}" 3
disp "SDK Dir    :  ${SDK_DIR}" 3
disp "Deploy Dir :  ${SDK_DIR}" 3

# ------------------------------------------------------------------------------
#  Script Xilinx Tools
# ------------------------------------------------------------------------------
source ${XVIV}/settings64.sh

# ------------------------------------------------------------------------------
#  Clear Stale FSBL
# ------------------------------------------------------------------------------
rm ${FSBL}

# ------------------------------------------------------------------------------
#  Generate SDK/BSP/FSBL
# ------------------------------------------------------------------------------
${SDK_EXE} -batch -source sdk.tcl --sdk_dir ${SDK_DIR} &> ${LOG}

# ------------------------------------------------------------------------------
#  Check if Build Passed
# ------------------------------------------------------------------------------
if [ -f ${FSBL} ]; then

    # Copy File if Requested
    if [[ ${DST_DIR} != "" ]]; then
        if [ ! -d ${DST_DIR} ]; then
            mkdir ${DST_DIR}
        fi
        cp ${FSBL} ${DST_DIR}
    fi

    # Report Success
    disp "FPGA SDK Build Success" 3
    exit 0

else
    disp "FPGA SDK Build Failed" 3
    exit 1

fi
