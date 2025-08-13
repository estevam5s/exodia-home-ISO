# CyberForge OS Build Makefile

.PHONY: all build clean install-deps test help

# Variables
BUILD_SCRIPT = ./build-cyberforge.sh
ISO_DIR = ./out
WORK_DIR = ./work

# Default target
all: build

# Install dependencies
install-deps:
	@echo "Installing build dependencies..."
	sudo pacman -S --needed archiso base-devel git

# Build the ISO
build:
	@echo "Building CyberForge OS ISO..."
	@chmod +x $(BUILD_SCRIPT)
	$(BUILD_SCRIPT)

# Clean build artifacts
clean:
	@echo "Cleaning build directories..."
	sudo rm -rf $(WORK_DIR) $(ISO_DIR)
	@echo "Clean completed."

# Test ISO in QEMU (requires qemu)
test:
	@if [ ! -f $(ISO_DIR)/cyberforge-security-*.iso ]; then \
		echo "ISO not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Testing ISO in QEMU..."
	qemu-system-x86_64 -m 4096 -enable-kvm -cdrom $(shell ls $(ISO_DIR)/cyberforge-security-*.iso | head -1)

# Quick build for testing
quick:
	@echo "Quick build (minimal packages)..."
	QUICK_BUILD=1 $(BUILD_SCRIPT)

# Show help
help:
	@echo "CyberForge OS Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  all         - Build the complete ISO (default)"
	@echo "  build       - Build the complete ISO"
	@echo "  install-deps- Install required dependencies"
	@echo "  clean       - Clean build directories"
	@echo "  test        - Test ISO in QEMU"
	@echo "  quick       - Quick build for testing"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make install-deps  # Install dependencies"
	@echo "  make build         # Build ISO"
	@echo "  make test          # Test in VM"
	@echo "  make clean         # Clean up"