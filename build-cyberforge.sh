#!/usr/bin/env bash

#####################################
#                                   #
#  CyberForge OS Build Automation   #
#  Author: CyberForge Team          #
#                                   #
#####################################

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
BUILD_DIR="$SCRIPT_DIR"
WORK_DIR="$BUILD_DIR/work"
OUT_DIR="$BUILD_DIR/out"
LOG_FILE="$BUILD_DIR/build.log"

# Functions
print_banner() {
    clear
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
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    CyberForge OS Build Automation${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "${RED}Error: This script must be run as root${NC}"
        log "${YELLOW}Use: sudo $0${NC}"
        exit 1
    fi
}

check_dependencies() {
    log "${YELLOW}Checking dependencies...${NC}"
    
    local deps=("archiso" "git" "wget" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "${RED}Missing dependencies: ${missing[*]}${NC}"
        log "${YELLOW}Installing missing dependencies...${NC}"
        
        # Update package database
        pacman -Sy
        
        # Install missing packages
        for dep in "${missing[@]}"; do
            case "$dep" in
                "archiso")
                    pacman -S --noconfirm archiso
                    ;;
                *)
                    pacman -S --noconfirm "$dep"
                    ;;
            esac
        done
    fi
    
    log "${GREEN}Dependencies check completed${NC}"
}

setup_build_environment() {
    log "${YELLOW}Setting up build environment...${NC}"
    
    # Create directories
    mkdir -p "$WORK_DIR" "$OUT_DIR"
    
    # Clean previous builds
    if [[ -d "$WORK_DIR" ]]; then
        rm -rf "$WORK_DIR"/*
    fi
    
    # Set permissions
    chmod 755 "$BUILD_DIR/src/airootfs/usr/local/bin/"*
    
    log "${GREEN}Build environment ready${NC}"
}

download_security_tools() {
    log "${YELLOW}Downloading additional security tools...${NC}"
    
    local tools_dir="$BUILD_DIR/src/airootfs/opt/tools"
    mkdir -p "$tools_dir"
    
    # Download SecLists
    if [[ ! -d "$tools_dir/SecLists" ]]; then
        log "${BLUE}Downloading SecLists...${NC}"
        git clone https://github.com/danielmiessler/SecLists.git "$tools_dir/SecLists" 2>/dev/null || true
    fi
    
    # Download PayloadsAllTheThings
    if [[ ! -d "$tools_dir/PayloadsAllTheThings" ]]; then
        log "${BLUE}Downloading PayloadsAllTheThings...${NC}"
        git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$tools_dir/PayloadsAllTheThings" 2>/dev/null || true
    fi
    
    # Download Wordlists
    local wordlists_dir="$BUILD_DIR/src/airootfs/opt/wordlists"
    mkdir -p "$wordlists_dir"
    
    if [[ ! -f "$wordlists_dir/rockyou.txt" ]]; then
        log "${BLUE}Downloading rockyou wordlist...${NC}"
        wget -q -O "$wordlists_dir/rockyou.txt.gz" "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" || true
        gunzip "$wordlists_dir/rockyou.txt.gz" 2>/dev/null || true
    fi
    
    log "${GREEN}Security tools downloaded${NC}"
}

build_iso() {
    log "${YELLOW}Building CyberForge OS ISO...${NC}"
    log "${BLUE}This may take 30-60 minutes depending on your system...${NC}"
    
    cd "$BUILD_DIR"
    
    # Build the ISO
    if mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" src/ 2>&1 | tee -a "$LOG_FILE"; then
        log "${GREEN}ISO build completed successfully!${NC}"
        
        # Find the generated ISO
        local iso_file=$(find "$OUT_DIR" -name "*.iso" | head -1)
        if [[ -n "$iso_file" ]]; then
            local iso_size=$(du -h "$iso_file" | cut -f1)
            log "${GREEN}Generated ISO: $iso_file ($iso_size)${NC}"
            
            # Generate checksums
            log "${YELLOW}Generating checksums...${NC}"
            cd "$OUT_DIR"
            sha256sum "$(basename "$iso_file")" > "$(basename "$iso_file").sha256"
            md5sum "$(basename "$iso_file")" > "$(basename "$iso_file").md5"
            log "${GREEN}Checksums generated${NC}"
            
            return 0
        else
            log "${RED}ISO file not found after build${NC}"
            return 1
        fi
    else
        log "${RED}ISO build failed${NC}"
        return 1
    fi
}

test_iso_qemu() {
    local iso_file="$1"
    log "${YELLOW}Testing ISO with QEMU...${NC}"
    
    if ! command -v qemu-system-x86_64 &> /dev/null; then
        log "${YELLOW}QEMU not found, installing...${NC}"
        pacman -S --noconfirm qemu-desktop
    fi
    
    log "${BLUE}Starting QEMU test (4GB RAM, 2 CPUs)...${NC}"
    log "${CYAN}Close QEMU window when done testing${NC}"
    
    qemu-system-x86_64 \
        -cdrom "$iso_file" \
        -boot d \
        -m 4G \
        -smp 2 \
        -enable-kvm \
        -cpu host \
        -display gtk \
        -name "CyberForge OS Test" \
        -netdev user,id=net0 \
        -device virtio-net-pci,netdev=net0 &
    
    local qemu_pid=$!
    log "${GREEN}QEMU started (PID: $qemu_pid)${NC}"
    log "${YELLOW}Test the ISO, then close QEMU window${NC}"
}

create_usb_script() {
    local iso_file="$1"
    local script_file="$OUT_DIR/create-bootable-usb.sh"
    
    cat > "$script_file" << 'EOF'
#!/bin/bash

# CyberForge OS USB Creator Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}CyberForge OS Bootable USB Creator${NC}"
echo "=================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Use: sudo $0"
    exit 1
fi

# List available USB devices
echo -e "${YELLOW}Available USB devices:${NC}"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk|part"

echo ""
read -p "Enter the USB device (e.g., /dev/sdb): " usb_device

if [[ ! -b "$usb_device" ]]; then
    echo -e "${RED}Error: Device $usb_device not found${NC}"
    exit 1
fi

# Confirm
echo -e "${RED}WARNING: This will DESTROY all data on $usb_device${NC}"
read -p "Are you sure? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Cancelled."
    exit 0
fi

# Find ISO file
iso_file=$(find . -name "*.iso" | head -1)
if [[ -z "$iso_file" ]]; then
    echo -e "${RED}Error: No ISO file found${NC}"
    exit 1
fi

echo -e "${YELLOW}Creating bootable USB...${NC}"
echo "ISO: $iso_file"
echo "Device: $usb_device"

# Unmount device
umount ${usb_device}* 2>/dev/null || true

# Write ISO to USB
if dd if="$iso_file" of="$usb_device" bs=4M status=progress conv=fsync; then
    sync
    echo -e "${GREEN}Bootable USB created successfully!${NC}"
    echo -e "${YELLOW}You can now boot from $usb_device${NC}"
else
    echo -e "${RED}Error creating bootable USB${NC}"
    exit 1
fi
EOF

    chmod +x "$script_file"
    log "${GREEN}USB creation script created: $script_file${NC}"
}

show_completion_info() {
    local iso_file="$1"
    
    echo ""
    log "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    log "${GREEN}║                    BUILD COMPLETED SUCCESSFULLY             ║${NC}"
    log "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log "${CYAN}Generated files:${NC}"
    log "  📁 ISO File: $iso_file"
    log "  📁 Checksums: $(dirname "$iso_file")/*.sha256, *.md5"
    log "  📁 USB Script: $OUT_DIR/create-bootable-usb.sh"
    echo ""
    
    log "${YELLOW}Next steps:${NC}"
    log "  🔥 Test in VM: Use QEMU/VirtualBox"
    log "  💾 Create USB: Run $OUT_DIR/create-bootable-usb.sh"
    log "  🚀 Boot: Boot from USB and enjoy CyberForge OS!"
    echo ""
    
    log "${PURPLE}CyberForge OS Features:${NC}"
    log "  ⚔️  Complete penetration testing suite"
    log "  🔍 Network reconnaissance tools"
    log "  🌐 Web application security testing"
    log "  📡 Wireless security analysis"
    log "  🔒 Cryptography and forensics tools"
    log "  🕵️  OSINT and information gathering"
    echo ""
    
    log "${RED}⚠️  Remember: Use only for authorized testing!${NC}"
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${GREEN}[1]${NC} ${YELLOW}Full Build (Recommended)${NC}"
        echo -e "${GREEN}[2]${NC} ${YELLOW}Quick Build (Skip downloads)${NC}"
        echo -e "${GREEN}[3]${NC} ${YELLOW}Test Existing ISO${NC}"
        echo -e "${GREEN}[4]${NC} ${YELLOW}Create Bootable USB${NC}"
        echo -e "${GREEN}[5]${NC} ${YELLOW}Clean Build Environment${NC}"
        echo -e "${GREEN}[0]${NC} ${YELLOW}Exit${NC}"
        echo ""
        
        read -p "$(echo -e ${CYAN}"Select option [0-5]: "${NC})" choice
        
        case $choice in
            1)
                full_build
                break
                ;;
            2)
                quick_build
                break
                ;;
            3)
                test_existing_iso
                ;;
            4)
                create_usb_menu
                ;;
            5)
                clean_environment
                ;;
            0)
                log "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                log "${RED}Invalid option!${NC}"
                sleep 2
                ;;
        esac
    done
}

full_build() {
    log "${YELLOW}Starting full build process...${NC}"
    
    check_root
    check_dependencies
    setup_build_environment
    download_security_tools
    
    if build_iso; then
        local iso_file=$(find "$OUT_DIR" -name "*.iso" | head -1)
        create_usb_script "$iso_file"
        show_completion_info "$iso_file"
        
        echo ""
        read -p "$(echo -e ${CYAN}"Test ISO in QEMU? (y/n): "${NC})" test_choice
        if [[ "$test_choice" =~ ^[Yy]$ ]]; then
            test_iso_qemu "$iso_file"
        fi
    else
        log "${RED}Build failed. Check $LOG_FILE for details.${NC}"
        exit 1
    fi
}

quick_build() {
    log "${YELLOW}Starting quick build process...${NC}"
    
    check_root
    check_dependencies
    setup_build_environment
    
    if build_iso; then
        local iso_file=$(find "$OUT_DIR" -name "*.iso" | head -1)
        create_usb_script "$iso_file"
        show_completion_info "$iso_file"
    else
        log "${RED}Build failed. Check $LOG_FILE for details.${NC}"
        exit 1
    fi
}

test_existing_iso() {
    local iso_file=$(find "$OUT_DIR" -name "*.iso" | head -1)
    if [[ -n "$iso_file" ]]; then
        test_iso_qemu "$iso_file"
    else
        log "${RED}No ISO file found in $OUT_DIR${NC}"
        sleep 2
    fi
}

create_usb_menu() {
    if [[ -f "$OUT_DIR/create-bootable-usb.sh" ]]; then
        log "${YELLOW}Running USB creation script...${NC}"
        bash "$OUT_DIR/create-bootable-usb.sh"
    else
        log "${RED}USB creation script not found. Build ISO first.${NC}"
        sleep 2
    fi
}

clean_environment() {
    log "${YELLOW}Cleaning build environment...${NC}"
    rm -rf "$WORK_DIR" "$OUT_DIR"
    log "${GREEN}Environment cleaned${NC}"
    sleep 2
}

# Initialize log
echo "CyberForge OS Build Log - $(date)" > "$LOG_FILE"

# Start main menu
main_menu