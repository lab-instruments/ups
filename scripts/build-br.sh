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
    echo " Buildroot Build Script Usage"
    echo "   build-br.sh --build_dir=<DIR> --log_dir=<DIR> --deploy_dir=<DIR>"
    echo "     build_dir  :  Location to build Buildroot           {default=.}"
    echo "     log_dir    :  Location to write log file            {default=.}"
    echo "     deploy_dir :  Location to write output products     {default=NONE}"
    echo "     conf_dir   :  Location for Buildroot configuration  {default=NONE}"
    echo
}

# Start Scripts
disp "Buildroot Build Script" 2

# Argument Defaults
LOG_DIR=`pwd`
BUILD_DIR=`pwd`
DST_DIR=""
CONF_DIR=""

# Parse Command Line Inputs
for i in "$@" ; do
    case $i in

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

# Generate Paths
LOG=${LOG_DIR}/buildroot.log
BD=${BUILD_DIR}/buildroot
RFS=${BD}/output/images/rootfs.cpio.uboot
UIM=${BD}/output/images/uImage

# Print U-BOOT Build Parameters
disp "Log Dir    :  ${LOG_DIR}" 3
disp "Build Dir  :  ${BD}" 3
disp "Config Dir :  ${CD}" 3
disp "Deploy Dir :  ${DD}" 3

# ------------------------------------------------------------------------------
#  Create Version File
# ------------------------------------------------------------------------------
# Create Version File
VER=${CD}/ovly/root/version

if [ -f ${VER} ]; then
    rm ${VER}
    touch ${VER}
else
    touch ${VER}
fi

# Generate Short Hash
HASH=`git rev-parse HEAD`
HASH_SHORT=${HASH:0:8}
echo ${HASH_SHORT}          >> ${VER}

# Look for Git Changes
if git diff-files --quiet ; then
    echo "CLEAN"            >> ${VER}
else
    echo "DIRTY"            >> ${VER}
fi

# Start Log
echo "" > ${LOG}

# ------------------------------------------------------------------------------
#  Get Buildroot Repo
# ------------------------------------------------------------------------------
# Check if Repo Exists Already
if [ ! -d ${BD} ]; then
    # Clone Git Repo
    git clone https://github.com/buildroot/buildroot.git ${BD}       &>> ${LOG}
    cd ${BD}

    # Copy Configuration Files
    cp ${CD}/zynq_cora_defconfig ${BD}/configs/

    # Setup Build
    make zynq_cora_defconfig                                         &>> ${LOG}

else
    cd ${BD}

fi


# ------------------------------------------------------------------------------
#  Build
# ------------------------------------------------------------------------------
# Build
make BR2_EXTERNAL_OVLY=${CD}                                         &>> ${LOG}

# ------------------------------------------------------------------------------
#  Check if Build Passed
# ------------------------------------------------------------------------------
BUILD_FAIL=0
if [ -f ${RFS} ]; then
    # Copy File if Requested
    if [[ ${DD} != "" ]]; then
        if [ ! -d ${DD} ]; then
            mkdir ${DD}
        fi
        cp ${RFS} ${DD}
    fi
else
    echo "No RFS"
    BUILD_FAIL=1
fi

if [ -f ${UIM} ]; then
    # Copy File if Requested
    if [[ ${DD} != "" ]]; then
        if [ ! -d ${DD} ]; then
            mkdir ${DD}
        fi
        cp ${UIM} ${DD}
    fi
else
    echo "No Kernel"
    BUILD_FAIL=1
fi

if [ ${BUILD_FAIL} -eq 0 ]; then
    # Report Success
    disp "Buildroot Build Success" 3
    exit 0

else
    disp "Buildroot Build Failed" 3
    exit 1

fi
