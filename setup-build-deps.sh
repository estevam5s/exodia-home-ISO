#!/usr/bin/env bash

#####################################
#                                   #
#  CyberForge OS Dependencies       #
#  Author: CyberForge Team          #
#                                   #
#####################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}CyberForge OS - Dependencies Setup${NC}"
echo "=================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Use: sudo $0"
    exit 1
fi

echo -e "${YELLOW}Updating system...${NC}"
pacman -Syu --noconfirm

echo -e "${YELLOW}Installing build dependencies...${NC}"
pacman -S --noconfirm \
    archiso \
    git \
    wget \
    curl \
    qemu-desktop \
    dd \
    lsblk \
    base-devel

echo -e "${YELLOW}Setting up build environment...${NC}"
mkdir -p {work,out}

echo -e "${GREEN}Dependencies installed successfully!${NC}"
echo -e "${YELLOW}You can now run: sudo ./build-cyberforge.sh${NC}"