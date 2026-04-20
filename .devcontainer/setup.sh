#!/bin/bash

set -e

echo "================================================"
echo "Setting up ESP32-S3 development environment..."
echo "================================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Install system dependencies
echo "Installing system packages..."
apt-get update
apt-get install -y \
    git \
    build-essential \
    udev \
    usbutils \
    minicom \
    screen \
    wget \
    curl \
    ca-certificates \
    clang-format \
    clang-tidy

# Install PlatformIO Core as the vscode user
echo "Installing PlatformIO..."
su - vscode -c "pip install --upgrade pip"
su - vscode -c "pip install platformio"

# Install pre-commit for code quality checks as the vscode user
echo "Installing pre-commit..."
su - vscode -c "pip install pre-commit"

# Install pre-commit hooks automatically if in a git repository
if [ -d "/workspaces/$(basename "$(pwd)")/.git" ]; then
    echo "Installing pre-commit hooks..."
    cd "/workspaces/$(basename "$(pwd)")" || cd /workspace || exit 0
    su - vscode -c "cd /workspaces/$(basename "$(pwd)") && pre-commit install --install-hooks" || echo "Note: pre-commit hooks will be installed on first commit"
fi

# Set up udev rules for ESP32 (allows non-root USB access)
echo "Setting up USB device access rules..."
cat > /etc/udev/rules.d/99-platformio-udev.rules << 'EOF'
# ESP32 USB-JTAG
SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666"
# CP210x USB to UART
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666"
# CH340 USB to UART
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666"
# FTDI USB to UART
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666"
EOF

# Reload udev rules
udevadm control --reload-rules 2>/dev/null || true
udevadm trigger 2>/dev/null || true

echo ""
echo "================================================"
echo "Setup complete!"
echo "================================================"

# Get versions as vscode user
PIO_VERSION=$(su - vscode -c "pio --version" 2>/dev/null || echo "installed")
CLANG_VERSION=$(clang-format --version 2>/dev/null | head -1 || echo "installed")
PRECOMMIT_VERSION=$(su - vscode -c "pre-commit --version" 2>/dev/null || echo "installed")

echo "PlatformIO: $PIO_VERSION"
echo "Clang-format: $CLANG_VERSION"
echo "Pre-commit: $PRECOMMIT_VERSION"
echo ""
echo "Development tools installed:"
echo "  ✓ PlatformIO (ESP-IDF framework)"
echo "  ✓ Clang-format (code formatting)"
echo "  ✓ Clang-tidy (static analysis)"
echo "  ✓ Pre-commit (automated hooks)"
echo ""
echo "Ready to develop for ESP32-S3!"
echo "================================================"
