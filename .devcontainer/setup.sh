#!/bin/bash

# Install system dependencies
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

# Install PlatformIO Core
pip install --upgrade pip
pip install platformio

# Install pre-commit for code quality checks
pip install pre-commit

# Set up udev rules for ESP32 (allows non-root USB access)
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
udevadm control --reload-rules || true
udevadm trigger || true

echo "PlatformIO setup complete!"
pio --version
echo "Clang-format version: $(clang-format --version)"
echo "Pre-commit version: $(pre-commit --version)"
