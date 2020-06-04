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
    echo " Finalize Script Usage"
    echo "   finalize.sh --log_dir=<DIR> --deploy_dir=<DIR>"
    echo "     log_dir    :  Location to write log file            {default=.}"
    echo "     deploy_dir :  Location to write output products     {default=NONE}"
    echo
}

# Start Scripts
disp "Finalize Script" 2

# Argument Defaults
LOG_DIR=`pwd`

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

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
LOG=${LOG_DIR}/finalize.log
BOOTB=${DD}/BOOT.bin

# Print U-BOOT Build Parameters
disp "Log Dir    :  ${LOG_DIR}" 3
disp "Deploy Dir :  ${DD}" 3

# ------------------------------------------------------------------------------
#  Clean Build Artifacts
# ------------------------------------------------------------------------------
if [ -f ${BOOTB} ]; then
    rm ${BOOTB}
fi

# Clear Log
echo "" > ${LOG}

# ------------------------------------------------------------------------------
#  Generate BOOT.bin
# ------------------------------------------------------------------------------
if [ "${BOOTG}" == "" ]; then
    exit 1
fi

# Generate BIF File
echo "the_ROM_image:"                > ./boot.bif
echo "{"                            >> ./boot.bif
echo "	[bootloader]${DD}/fsbl.elf" >> ./boot.bif
echo "	${DD}/ups.bit"              >> ./boot.bif
echo "	${DD}/u-boot.elf"           >> ./boot.bif
echo "}"                            >> ./boot.bif

# Build BOOT.BIN
$BOOTG -image ./boot.bif -o i ${BOOTB} -w                            &>> ${LOG}

# Remove boot.bif
rm ./boot.bif

# ------------------------------------------------------------------------------
#  Check if Build Passed
# ------------------------------------------------------------------------------
BUILD_FAIL=0
if [ ! -f ${BOOTB} ]; then
    echo "No BOOT.BIN"
    BUILD_FAIL=1

fi

if [ ${BUILD_FAIL} -eq 0 ]; then
    # Report Success
    disp "Finalize Script Success" 3
    exit 0

else
    disp "Finalize Script Failed" 3
    exit 1

fi
