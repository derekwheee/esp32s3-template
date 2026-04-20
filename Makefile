# Makefile for common ESP32-S3 development tasks
# Provides convenient shortcuts for PlatformIO commands

.PHONY: help build upload monitor clean flash size format lint test install-hooks

# Default target
help:
	@echo "ESP32-S3 Development Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build          - Build the firmware"
	@echo "  make upload         - Upload firmware to ESP32-S3"
	@echo "  make monitor        - Open serial monitor"
	@echo "  make flash          - Build and upload firmware"
	@echo "  make clean          - Clean build files"
	@echo "  make size           - Show firmware size"
	@echo "  make format         - Format C source files"
	@echo "  make lint           - Run static analysis"
	@echo "  make test           - Run all checks (format + lint)"
	@echo "  make install-hooks  - Install pre-commit hooks"
	@echo ""

# Build firmware
build:
	pio run -e esp32-s3-devkitc-1

# Upload firmware to device
upload:
	pio run -e esp32-s3-devkitc-1 -t upload

# Open serial monitor
monitor:
	pio device monitor --baud 115200

# Build and upload
flash: build upload

# Clean build artifacts
clean:
	pio run -t clean
	rm -rf .pio

# Show firmware size
size:
	pio run -e esp32-s3-devkitc-1 -t size

# Format C source files
format:
	@echo "Formatting C source files..."
	@find src -name "*.c" -o -name "*.h" | xargs clang-format -i
	@echo "Done!"

# Run static analysis
lint:
	@echo "Running clang-tidy..."
	@find src -name "*.c" | xargs clang-tidy -- -Isrc
	@echo "Done!"

# Run all checks
test: format lint
	@echo "Running pre-commit hooks..."
	@pre-commit run --all-files || true
	@echo "All checks complete!"

# Install pre-commit hooks
install-hooks:
	@echo "Installing pre-commit hooks..."
	@pre-commit install
	@echo "Pre-commit hooks installed!"
