# ------------------------------------------------------------------------------
#  Setup Script
# ------------------------------------------------------------------------------

# Source Utility Files
source ./utils.sh
source ./setup.sh

# ------------------------------------------------------------------------------
#  Parse Script Params
# ------------------------------------------------------------------------------
# Usage Print
function usage() {
    echo
    echo " FPGA HW Build Script Usage"
    echo "   build-fpga-hw.sh --sdk_dir=<DIR> --build_dir=<DIR> --log_dir=<DIR> --deploy_dir=<DIR> --board=<BOARD>"
    echo "     build_dir  :  Location to build the FPGA HW     {default=.}"
    echo "     sdk_dir    :  Location to build the FPGA SDK    {default=.}"
    echo "     log_dir    :  Location to write log file        {default=.}"
    echo "     deploy_dir :  Location to write output products {default=NONE}"
    echo "     board      :  Board type {coraz7/artyz7}        {default=coraz7}"
    echo
}

# Start Scripts
disp "FPGA HW Build Script" 2

# Argument Defaults
BUILD_DIR=`pwd`
LOG_DIR=`pwd`
SDK_DIR=`pwd`
DD=""
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

# Generate Paths
LOG=${LOG_DIR}/fpga-hw.log
INST=${BUILD_DIR}/fpga
BIT=${INST}/ups/ups.runs/impl_1/ups.bit

# Print U-BOOT Build Parameters
disp "Build Dir  :  ${INST}" 3
disp "Log Dir    :  ${LOG_DIR}" 3
disp "SDK Dir    :  ${SDK_DIR}" 3
disp "Deploy Dir :  ${DD}" 3
disp "Board      :  ${BOARD}" 3

# ------------------------------------------------------------------------------
#  Setup Xilinx Tools
# ------------------------------------------------------------------------------
source ${XVIV}/settings64.sh

# ------------------------------------------------------------------------------
#  Clear Stale Bitfile
# ------------------------------------------------------------------------------
if [ -f ${BIT} ]; then
    rm ${BIT}
fi

# ------------------------------------------------------------------------------
#  Generate  and Build Project
# ------------------------------------------------------------------------------
${VIV_EXE} -mode batch                                                        \
           -nojournal                                                         \
           -nolog                                                             \
           -notrace                                                           \
           -source ../fpga/proj/ups.tcl -tclargs --build_dir ${INST}          \
                                                 --board ${BOARD}             \
                                                 --sdk_dir ${SDK_DIR} &> ${LOG}

# ------------------------------------------------------------------------------
#  Check if Build Passed
# ------------------------------------------------------------------------------
if [ -f ${BIT} ]; then

    # Copy File if Requested
    if [[ ${DD} != "" ]]; then
        if [ ! -d ${DD} ]; then
            mkdir ${DD}
        fi
        cp ${BIT} ${DD}
    fi

    # Report Success
    disp "FPGA HW Build Success" 3
    exit 0

else
    disp "FPGA HW Build Failed" 3
    exit 1

fi
