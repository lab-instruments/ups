# -----------------------------------------------------------------------------
#  Setup Script
# -----------------------------------------------------------------------------
VIVADO_PTH=~/tools/Xilinx/Vivado/2018.2
VIVADO_EXE=${VIVADO_PTH}/bin/vivado
VIVADO_BRD=${VIVADO_PTH}/data/boards/board_files

# -----------------------------------------------------------------------------
#  Script Checks
# -----------------------------------------------------------------------------
source ${VIVADO_PTH}/settings64.sh

# -----------------------------------------------------------------------------
#  Run Scripts
# -----------------------------------------------------------------------------
# ${VIVADO_EXE} -mode batch -nojournal -nolog -notrace -source ./etc/cksum.tcl -tclargs -x ./bin/eeprom.bin
${VIVADO_EXE} -mode batch -nojournal -nolog -notrace -source ../fpga/proj/ups.tcl

