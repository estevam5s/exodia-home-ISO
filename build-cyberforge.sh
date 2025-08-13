#!/usr/bin/env bash

#####################################
#                                   #
#  @author      : CyberForge Team   #
#  @description : Build CyberForge  #
#  Copyright   : CyberForge OS      #
#                                   #
#####################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"
BUILD_DATE=$(date +%Y%m%d)
ISO_NAME="cyberforge-security-${BUILD_DATE}-x86_64.iso"

# Functions
print_banner() {
    echo -e "${RED}"
    echo "  ▄████▄▓██   ██▓ ▄▄▄▄   ▓█████  ██▀███    █████▒▒█████   ██▀███    ▄████ ▓█████ "
    echo " ▒██▀ ▀█ ▒██  ██▒▓█████▄ ▓█   ▀ ▓██ ▒ ██▒▓██   ▒▒██▒  ██▒▓██ ▒ ██▒ ██▒ ▀█▒▓█   ▀ "
    echo " ▒▓█    ▄ ▒██ ██░▒██▒ ▄██▒███   ▓██ ░▄█ ▒▒████ ░▒██░  ██▒▓██ ░▄█ ▒▒██░▄▄▄░▒███   "
    echo " ▒▓▓▄ ▄██▒░ ▐██▓░▒██░█▀  ▒▓█  ▄ ▒██▀▀█▄  ░▓█▒  ░▒██   ██░▒██▀▀█▄  ░▓█  ██▓▒▓█  ▄ "
    echo " ▒ ▓███▀ ░░ ██▒▓░░▓█  ▀█▓░▒████▒░██▓ ▒██▒░▒█░   ░ ████▓▒░░██▓ ▒██▒░▒▓███▀▒░▒████▒"
    echo " ░ ░▒ ▒  ░ ██▒▒▒ ░▒▓███▀▒░░ ▒░ ░░ ▒▓ ░▒▓░ ▒ ░   ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ░▒   ▒ ░░ ▒░ ░"
    echo "   ░  ▒  ▓██ ░▒░ ▒░▒   ░  ░ ░  ░  ░▒ ░ ▒░ ░       ░ ▒ ▒░   ░▒ ░ ▒░  ░   ░  ░ ░  ░"
    echo " ░       ▒ ▒ ░░   ░    ░    ░     ░░   ░  ░ ░   ░ ░ ░ ▒    ░░   ░ ░ ░   ░    ░   "
    echo " ░ ░     ░ ░      ░         ░  ░   ░                ░ ░     ░           ░    ░  ░"
    echo -e "${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    CyberForge OS ISO Builder${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
}

check_requirements() {
    echo -e "${YELLOW}[INFO] Checking requirements...${NC}"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}[ERROR] This script should not be run as root!${NC}"
        exit 1
    fi
    
    # Check if archiso is installed
    if ! pacman -Q archiso &>/dev/null; then
        echo -e "${RED}[ERROR] archiso is not installed!${NC}"
        echo -e "${YELLOW}[INFO] Installing archiso...${NC}"
        sudo pacman -S --needed archiso
    fi
    
    # Check available disk space (need at least 10GB)
    AVAILABLE_SPACE=$(df "$PWD" | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=10485760  # 10GB in KB
    
    if [[ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]]; then
        echo -e "${RED}[ERROR] Insufficient disk space! Need at least 10GB${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[OK] All requirements met${NC}"
}

prepare_directories() {
    echo -e "${YELLOW}[INFO] Preparing build directories...${NC}"
    
    # Create work and output directories
    mkdir -p "$WORK_DIR" "$OUT_DIR"
    
    # Clean previous builds
    if [[ -d "$WORK_DIR" ]]; then
        sudo rm -rf "$WORK_DIR"/*
    fi
    
    echo -e "${GREEN}[OK] Directories prepared${NC}"
}

setup_archiso_profile() {
    echo -e "${YELLOW}[INFO] Setting up archiso profile...${NC}"
    
    # Copy archiso profile as base
    cp -r /usr/share/archiso/configs/releng/* "$SCRIPT_DIR/"
    
    # Apply our custom configurations (all the files we created above)
    # This assumes all the modified files are already in place in the src/ directory
    
    echo -e "${GREEN}[OK] Archiso profile configured${NC}"
}

build_iso() {
    echo -e "${YELLOW}[INFO] Building CyberForge OS ISO...${NC}"
    echo -e "${BLUE}[INFO] This may take 30-60 minutes depending on your system...${NC}"
    
    # Run mkarchiso
    sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$SCRIPT_DIR/src"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[SUCCESS] ISO build completed!${NC}"
        
        # Find and rename the ISO
        ISO_FILE=$(find "$OUT_DIR" -name "*.iso" -type f | head -1)
        if [[ -n "$ISO_FILE" ]]; then
            NEW_ISO_PATH="$OUT_DIR/$ISO_NAME"
            mv "$ISO_FILE" "$NEW_ISO_PATH"
            echo -e "${GREEN}[INFO] ISO saved as: $NEW_ISO_PATH${NC}"
            
            # Show ISO size
            ISO_SIZE=$(du -h "$NEW_ISO_PATH" | cut -f1)
            echo -e "${CYAN}[INFO] ISO size: $ISO_SIZE${NC}"
            
            # Generate checksums
            echo -e "${YELLOW}[INFO] Generating checksums...${NC}"
            cd "$OUT_DIR"
            sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
            md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
            echo -e "${GREEN}[OK] Checksums generated${NC}"
        fi
    else
        echo -e "${RED}[ERROR] ISO build failed!${NC}"
        exit 1
    fi
}

cleanup() {
    echo -e "${YELLOW}[INFO] Cleaning up...${NC}"
    
    # Clean work directory but keep output
    if [[ -d "$WORK_DIR" ]]; then
        sudo rm -rf "$WORK_DIR"
    fi
    
    echo -e "${GREEN}[OK] Cleanup completed${NC}"
}

show_completion() {
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    ✓ BUILD COMPLETED SUCCESSFULLY ✓${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}ISO Location:${NC} $OUT_DIR/$ISO_NAME"
    echo -e "${WHITE}ISO Size:${NC} $(du -h "$OUT_DIR/$ISO_NAME" 2>/dev/null | cut -f1 || echo "Unknown")"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "${BLUE}1.${NC} Test the ISO in a virtual machine"
    echo -e "${BLUE}2.${NC} Write to USB: sudo dd if=$OUT_DIR/$ISO_NAME of=/dev/sdX bs=4M status=progress"
    echo -e "${BLUE}3.${NC} Or use tools like Ventoy, Rufus, or Etcher"
    echo ""
    echo -e "${PURPLE}⚠ Remember: Use CyberForge OS only for authorized security testing ⚠${NC}"
    echo ""
}

# Main execution
main() {
    print_banner
    
    echo -e "${WHITE}Starting CyberForge OS build process...${NC}"
    echo ""
    
    check_requirements
    prepare_directories
    setup_archiso_profile
    build_iso
    cleanup
    show_completion
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi