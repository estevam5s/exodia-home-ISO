#!/usr/bin/env bash

#####################################
#                                   #
#  @author      : CyberForge Team   #
#  @description : Installation      #
#  Copyright   : CyberForge OS      #
#                                   #
#####################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                        CyberForge OS Installer                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}[INFO] CyberForge OS Build Environment Setup${NC}"
echo ""

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}[ERROR] This installer requires an Arch-based Linux distribution${NC}"
    echo -e "${YELLOW}[INFO] Please run this on Arch Linux, Manjaro, or other Arch derivative${NC}"
    exit 1
fi

# Install required packages
echo -e "${BLUE}[INFO] Installing required packages...${NC}"
sudo pacman -Syu --needed \
    archiso \
    base-devel \
    git \
    qemu-desktop \
    edk2-ovmf \
    wget \
    curl

# Create project directory
PROJECT_DIR="$HOME/cyberforge-build"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo -e "${GREEN}[OK] Setup completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "${BLUE}1.${NC} Copy all the source files to: $PROJECT_DIR/src/"
echo -e "${BLUE}2.${NC} Run: chmod +x build-cyberforge.sh"
echo -e "${BLUE}3.${NC} Run: ./build-cyberforge.sh"
echo ""
echo -e "${CYAN}Build directory created at: $PROJECT_DIR${NC}"