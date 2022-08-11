# ------------------------------------------------------------------------------
#  Name   :  Top Level UPS Build Script
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
# Create Build Dir
if [ ! -d ${BD} ]; then
    mkdir ${BD}
fi

# Clear Deploy Dir
if [ ! -d ${DD} ]; then
    mkdir ${DD}
else
    rm -rf ${DD}
    mkdir ${DD}
fi

# Clear SDK Dir
if [ ! -d ${SD} ]; then
    mkdir ${SD}
else
    rm -rf ${SD}
    mkdir ${SD}
fi

# Clear Log Dir
if [ ! -d ${LD} ]; then
    mkdir ${LD}
else
    rm -rf ${LD}
    mkdir ${LD}
fi

# ------------------------------------------------------------------------------
#  Command Line Inputs
# ------------------------------------------------------------------------------
BUILD_UBOOT=0
BUILD_FPGA_HW=0
BUILD_FPGA_SW=0
BUILD_BR=0
FINALIZE=0
BUILD_ALL=1

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

        --build_uboot)
            BUILD_ALL=0
            BUILD_UBOOT=1
            shift
            ;;

        --build_fpga_hw)
            BUILD_ALL=0
            BUILD_FPGA_HW=1
            shift
            ;;

        --build_fpga_sw)
            BUILD_ALL=0
            BUILD_FPGA_SW=1
            shift
            ;;

        --build_br)
            BUILD_ALL=0
            BUILD_BR=1
            shift
            ;;

        --finalize)
            BUILD_ALL=0
            FINALIZE=1
            shift
            ;;

        *)
            echo "Incorrect Command Line Argument .. ${i}"
            exit 1
            ;;

    esac
done


# ------------------------------------------------------------------------------
#  Setup Paths
# ------------------------------------------------------------------------------
echo
echo
echo " --- Build UPS Hardware/Software System"
disp "Build Script Settings" 2
disp "BUILD DIR        :  ${BD}" 3
disp "DEPOLY DIR       :  ${DD}" 3
disp "SDK DIR          :  ${SD}" 3
disp "LOG DIR          :  ${LD}" 3
disp "BUILD ALL        :  ${BUILD_ALL}" 3
disp "BUILD UBOOT      :  ${BUILD_UBOOT}" 3
disp "BUILD FPGA HW    :  ${BUILD_FPGA_HW}" 3
disp "BUILD FPGA SW    :  ${BUILD_FPGA_SW}" 3
disp "BUILD BUILDROOT  :  ${BUILD_BR}" 3
disp "BUILD FINALIZE   :  ${FINALIZE}" 3
echo
disp "START BUILD" 3
echo

# ------------------------------------------------------------------------------
#  Build U-Boot
# ------------------------------------------------------------------------------
if [ $BUILD_ALL -eq 1 ] || [ $BUILD_UBOOT -eq 1 ]; then
    # Print Build Command
    disp "BUILD CMD: ./build-uboot.sh --build_dir=${BD} --log_dir=${LD} --deploy_dir=${DD} --board=\"coraz7\"" 2

    # Run Build Command
    ./build-uboot.sh --build_dir=${BD} --log_dir=${LD} --deploy_dir=${DD} --board="coraz7"

fi

# ------------------------------------------------------------------------------
#  Build FPGA Hardware
# ------------------------------------------------------------------------------
if [ $BUILD_ALL -eq 1 ] || [ $BUILD_FPGA_HW -eq 1 ]; then
    # Print Build Command
    disp "BUILD CMD: ./build-fpga-hw.sh --build_dir=${BD} --log_dir=${LD} --deploy_dir=${DD} --sdk_dir=${SD} --board=\"coraz7\"" 2

    # Run Build Command
    ./build-fpga-hw.sh --build_dir=${BD} --log_dir=${LD} --deploy_dir=${DD} --sdk_dir=${SD} --board="coraz7"

fi

# ------------------------------------------------------------------------------
#  Build FPGA SDK
# ------------------------------------------------------------------------------
if [ $BUILD_ALL -eq 1 ] || [ $BUILD_FPGA_SW -eq 1 ]; then
    # Print Build Command
    disp "BUILD CMD: ./build-fpga-sdk.sh --sdk_dir=${SD} --log_dir=${LD} --deploy_dir=${DD}" 2

    # Run Build Command
    ./build-fpga-sdk.sh --sdk_dir=${SD} --log_dir=${LD} --deploy_dir=${DD}

fi

# ------------------------------------------------------------------------------
#  Build FPGA SDK
# ------------------------------------------------------------------------------
if [ $BUILD_ALL -eq 1 ] || [ $BUILD_BR -eq 1 ]; then
    # Print Build Command
    disp "BUILD CMD: ./build-br.sh --build_dir=${BD} --conf_dir=${CDB} --log_dir=${LD} --deploy_dir=${DD}" 2

    # Run Build Command
    ./build-br.sh --build_dir=${BD} --conf_dir=${CDB} --log_dir=${LD} --deploy_dir=${DD}

fi

# ------------------------------------------------------------------------------
#  Run Finalize Script
# ------------------------------------------------------------------------------
if [ $BUILD_ALL -eq 1 ] || [ $FINALIZE -eq 1 ]; then
    # Print Build Command
    disp "BUILD CMD: ./finalize.sh --log_dir=${LD} --deploy_dir=${DD}" 2

    # Run Build Command
    ./finalize.sh --log_dir=${LD} --deploy_dir=${DD}

fi
