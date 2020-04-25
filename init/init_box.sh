#!/bin/bash

# ------------------------------------------------------------------------------
#  First Time Box Setup
# ------------------------------------------------------------------------------
sudo apt install libncurses5                                                    # For Xilinx Install Hang Issue
sudo apt install build-essential                                                # Basic Build Tools -- You Need This
sudo apt install libssl-dev                                                     # For U-Boot Build

# Get Digilent Board Files
git clone git@github.com:Digilent/vivado-boards.git
cp -r vivado-boards/new/board_files/cora-z7-10/ /local/tools/Xilinx/Vivado/2018.2/data/boards/board_files/

