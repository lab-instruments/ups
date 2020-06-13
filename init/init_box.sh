#!/bin/bash

# ------------------------------------------------------------------------------
#  First Time Box Setup
# ------------------------------------------------------------------------------
# Renew Packages
sudo apt update
sudo apt upgrade

# Install Packages
sudo apt install -y libncurses5                                                    # For Xilinx Install Hang Issue
sudo apt install -y build-essential                                                # Basic Build Tools -- You Need This
sudo apt install -y libssl-dev                                                     # For U-Boot Build
sudo apt install -y git
sudo apt install -y unzip
sudo apt install -y curl

# Install Code Repository
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt upgrade
sudo apt install code

# Create an area for the font to download to
mkdir -p /tmp/hasklig
cd /tmp/hasklig
wget https://github.com/i-tu/Hasklig/releases/download/1.1/Hasklig-1.1.zip
unzip Hasklig-1.1.zip
rm Hasklig-1.1.zip

# Install the font by moving the files to the correct place
cd /tmp
sudo mv hasklig /usr/share/fonts/opentype/.

# Re-cache the fonts
echo 'Re-caching fonts...'
sudo fc-cache -fv

# Install Vivado
./Xilinx_Vivado_SDK_Web_2018.2_0614_1954_Lin64.bin

# Get Digilent Board Files
git clone https://github.com/Digilent/vivado-boards.git
cp -r vivado-boards/new/board_files/cora-z7-10/ /local/tools/Xilinx/Vivado/2018.2/data/boards/board_files/

