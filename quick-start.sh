#!/usr/bin/env bash

#####################################
#                                   #
#  CyberForge OS Quick Start        #
#  Author: CyberForge Team          #
#                                   #
#####################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
echo "  ▄████▄▓██   ██▓ ▄▄▄▄   ▓█████  ██▀███    █████▒▒█████   ██▀███    ▄████ ▓█████ "
echo " ▒██▀ ▀█ ▒██  ██▒▓█████▄ ▓█   ▀ ▓██ ▒ ██▒▓██   ▒▒██▒  ██▒▓██ ▒ ██▒ ██▒ ▀█▒▓█   ▀ "
echo " ▒▓█    ▄ ▒██ ██░▒██▒ ▄██▒███   ▓██ ░▄█ ▒▒████ ░▒██░  ██▒▓██ ░▄█ ▒▒██░▄▄▄░▒███   "
echo " ▒▓▓▄ ▄██▒░ ▐██▓░▒██░█▀  ▒▓█  ▄ ▒██▀▀█▄  ░▓█▒  ░▒██   ██░▒██▀▀█▄  ░▓█  ██▓▒▓█  ▄ "
echo " ▒ ▓███▀ ░░ ██▒▓░░▓█  ▀█▓░▒████▒░██▓ ▒██▒░▒█░   ░ ████▓▒░░██▓ ▒██▒░▒▓███▀▒░▒████▒"
echo -e "${NC}"

echo -e "${GREEN}Welcome to CyberForge OS Quick Start!${NC}"
echo "====================================="
echo ""
echo -e "${YELLOW}This will automatically:${NC}"
echo "  1. Install all dependencies"
echo "  2. Download security tools"
echo "  3. Build the CyberForge OS ISO"
echo "  4. Create bootable USB script"
echo ""
echo -e "${RED}Requirements:${NC}"
echo "  • Arch Linux or Arch-based distro"
echo "  • At least 8GB free space"
echo "  • Root/sudo access"
echo "  • Internet connection"
echo ""

read -p "$(echo -e ${CYAN}"Continue? (y/n): "${NC})" confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Check if we're on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Error: This script requires Arch Linux or Arch-based distribution${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting automated build process...${NC}"

# Install dependencies
echo -e "${BLUE}[1/4] Installing dependencies...${NC}"
sudo bash setup-build-deps.sh

# Make scripts executable
chmod +x build-cyberforge.sh

# Start build
echo -e "${BLUE}[2/4] Starting ISO build...${NC}"
sudo ./build-cyberforge.sh

echo -e "${GREEN}Quick start completed!${NC}"