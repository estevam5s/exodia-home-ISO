# CyberForge OS Makefile

.PHONY: all clean deps build test usb help

# Default target
all: deps build

# Install dependencies
deps:
	@echo "Installing dependencies..."
	sudo bash setup-build-deps.sh

# Build ISO
build:
	@echo "Building CyberForge OS..."
	sudo ./build-cyberforge.sh

# Test ISO in QEMU
test:
	@echo "Testing ISO..."
	@ISO_FILE=$$(find out -name "*.iso" | head -1); \
	if [ -n "$$ISO_FILE" ]; then \
		qemu-system-x86_64 -cdrom "$$ISO_FILE" -boot d -m 4G -smp 2 -enable-kvm; \
	else \
		echo "No ISO file found. Build first with 'make build'"; \
	fi

# Create bootable USB
usb:
	@if [ -f "out/create-bootable-usb.sh" ]; then \
		sudo bash out/create-bootable-usb.sh; \
	else \
		echo "USB script not found. Build first with 'make build'"; \
	fi

# Clean build environment
clean:
	@echo "Cleaning build environment..."
	sudo rm -rf work out
	mkdir -p work out

# Quick build (without downloads)
quick:
	@echo "Quick build..."
	sudo ./build-cyberforge.sh --quick

# Full build with downloads
full:
	@echo "Full build with downloads..."
	sudo ./build-cyberforge.sh --full

# Help
help:
	@echo "CyberForge OS Build System"
	@echo "=========================="
	@echo ""
	@echo "Available targets:"
	@echo "  all     - Install deps and build ISO (default)"
	@echo "  deps    - Install build dependencies"
	@echo "  build   - Build CyberForge OS ISO"
	@echo "  test    - Test ISO in QEMU"
	@echo "  usb     - Create bootable USB"
	@echo "  clean   - Clean build environment"
	@echo "  quick   - Quick build (no downloads)"
	@echo "  full    - Full build with downloads"
	@echo "  help    - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make all        # Complete build"
	@echo "  make build      # Build only"
	@echo "  make test       # Test in VM"
	@echo "  make usb        # Create USB"