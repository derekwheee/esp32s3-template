# ESP32-S3 DevKitC-1 PlatformIO Template

A VS Code dev container template for ESP32-S3 development using PlatformIO with ESP-IDF framework.

## Features

- 🐳 **Dev Container Ready**: Complete development environment in Docker
- 🔧 **PlatformIO**: Professional embedded development platform
- 🚀 **ESP-IDF**: Official Espressif IoT Development Framework
- 🐛 **USB Debugging**: Built-in USB-JTAG debugging support
- 📡 **Serial Monitor**: Integrated serial communication with ESP logging
- 🎨 **Code Formatting**: Clang-format with ESP-IDF style
- ✅ **Pre-commit Hooks**: Automated code quality checks
- 🔄 **CI/CD**: GitHub Actions for automated builds
- ⚡ **Quick Start**: Includes working blink example with FreeRTOS

## Hardware Requirements

- ESP32-S3-DevKitC-1 development board (or compatible)
- USB-C cable for power, programming, and debugging

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (or Docker Engine on Linux)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Setup

1. **Clone or copy this template** to your project directory

2. **Open in VS Code**:
   ```bash
   code .
   ```

3. **Reopen in Container**:
   - Press `F1` or `Cmd/Ctrl+Shift+P`
   - Select `Dev Containers: Reopen in Container`
   - Wait for the container to build (first time takes ~5-10 minutes)

4. **Connect your ESP32-S3 board** via USB

5. **Set up pre-commit hooks** (optional but recommended):
   ```bash
   pre-commit install
   ```

### Build and Upload

#### Using PlatformIO IDE (GUI)

- **Build**: Click the checkmark (✓) icon in the bottom toolbar
- **Upload**: Click the right arrow (→) icon in the bottom toolbar
- **Serial Monitor**: Click the plug icon in the bottom toolbar

#### Using Command Line

```bash
# Build the project
pio run

# Upload to board
pio run --target upload

# Open serial monitor
pio device monitor

# Build, upload, and monitor in one command
pio run --target upload && pio device monitor
```

### Expected Behavior

The built-in LED on GPIO48 should blink on and off every second. The serial monitor should show:

```
I (XXX) blink: ESP32-S3 Blink Example Starting...
I (XXX) blink: LED GPIO: 48
I (XXX) blink: Setup complete! Starting blink loop...
I (XXX) blink: LED ON
I (XXX) blink: LED OFF
I (XXX) blink: LED ON
I (XXX) blink: LED OFF
...
```

## Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json    # Dev container configuration
│   └── setup.sh             # Container setup script
├── .github/
│   └── workflows/
│       └── build.yml        # CI/CD workflow
├── src/
│   └── main.c               # Main application code (blink example)
├── .clang-format            # Code formatting rules
├── .clang-tidy              # Static analysis configuration
├── .editorconfig            # Code style configuration
├── .pre-commit-config.yaml  # Pre-commit hooks
├── platformio.ini           # PlatformIO project configuration
├── sdkconfig.defaults       # ESP-IDF default configuration
├── DEVELOPMENT.md           # Development tooling guide
├── .gitignore              # Git ignore patterns
└── README.md               # This file
```

## Code Style

This project uses [EditorConfig](https://editorconfig.org/) to maintain consistent coding styles. The `.editorconfig` file enforces:

- **C files**: 4-space indentation, 120 character line limit
- **UTF-8 encoding** and **LF line endings** for all files
- **Trailing whitespace** removal (except Markdown)

### VS Code Settings

The included `.vscode/settings.json` configures the development environment:

- **Format on save**: Automatically formats C files when saving
- **Clang-format integration**: Uses `.clang-format` configuration
- **PlatformIO optimization**: Auto-rebuild IntelliSense index
- **File exclusions**: Hides build artifacts from explorer
- **Consistent indentation**: 4 spaces for C, 2 for JSON/YAML

### Code Formatting & Quality

- **Clang-format**: Automatic C code formatting following ESP-IDF style
- **Clang-tidy**: Static analysis for bug detection
- **Pre-commit hooks**: Automated checks before commits
- **GitHub Actions**: CI/CD for automated builds and testing

See **[DEVELOPMENT.md](DEVELOPMENT.md)** for complete documentation on:
- Setting up and using pre-commit hooks
- Code formatting with clang-format
- Static analysis with clang-tidy
- CI/CD workflow details

## Configuration

### platformio.ini

The main configuration file for PlatformIO. Key settings:

- **Board**: `esp32-s3-devkitc-1`
- **Framework**: `espidf` (ESP-IDF)
- **Monitor Speed**: 115200 baud
- **Upload Speed**: 921600 baud
- **Debug Tool**: esp-builtin (USB-JTAG)

### Customizing the LED Pin

If your ESP32-S3 board uses a different GPIO for the LED, edit `src/main.c`:

```c
#define LED_GPIO    GPIO_NUM_48  // Change to your LED GPIO number
```

Common LED pins on ESP32-S3 boards:
- **GPIO48**: ESP32-S3-DevKitC-1 (addressable RGB LED)
- **GPIO2**: Some custom boards
- **GPIO21**: Adafruit QT Py ESP32-S3

### Using ESP-IDF Features

This template uses ESP-IDF, giving you access to:
- **FreeRTOS**: Real-time operating system with tasks, queues, semaphores
- **ESP Logging**: Multi-level logging (ESP_LOGI, ESP_LOGW, ESP_LOGE)
- **GPIO Driver**: Advanced GPIO control with interrupts
- **WiFi & Bluetooth**: Full wireless stack
- **Peripheral Drivers**: SPI, I2C, UART, ADC, DAC, etc.

To add ESP-IDF components, use the standard ESP-IDF API. Example:

```c
#include "esp_wifi.h"
#include "nvs_flash.h"
#include "driver/i2c.h"
```

## Troubleshooting

### Device Not Found / Permission Denied

**Linux/macOS**: The container needs privileged access to USB devices.

1. Make sure your board is connected
2. Check if the device appears: `ls -l /dev/tty*` or `ls -l /dev/cu.*`
3. The dev container is configured with `--privileged` mode for USB access

**macOS specific**: You may need to install drivers for USB-Serial chips:
- [CP210x Driver](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)
- [CH340 Driver](https://github.com/adrianmihalko/ch340g-ch34g-ch34x-mac-os-x-driver)

### Upload Failed

1. **Press and hold BOOT button** on the board, then press RESET
2. Try the upload command again
3. Release BOOT button after upload starts

### Serial Monitor Shows Garbage

Check that monitor speed matches in both `platformio.ini` and your code:
```ini
monitor_speed = 115200
```

### Container Build Fails

1. Make sure Docker is running
2. Try rebuilding: `Dev Containers: Rebuild Container`
3. Check Docker has enough disk space

## Development

### Adding Libraries

For ESP-IDF components, they're built-in. For third-party libraries, add to `platformio.ini`:

```ini
lib_deps = 
    https://github.com/espressif/esp-idf-lib.git
```

You can also create custom components in a `components/` directory following ESP-IDF structure.

### Debugging

The ESP32-S3 has built-in USB-JTAG debugging. To use it:

1. Ensure `debug_tool = esp-builtin` is in `platformio.ini` (already configured)
2. Press `F5` in VS Code to start debugging
3. Set breakpoints in your code
4. Use the debug console to inspect variables

The debugger will break at `app_main()` by default.

## Resources

- [PlatformIO Documentation](https://docs.platformio.org/)
- [ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/)
- [ESP32-S3 Technical Reference](https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_en.pdf)
- [ESP32-S3-DevKitC-1 User Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/hw-reference/esp32s3/user-guide-devkitc-1.html)
- [ESP-IDF API Reference](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-reference/index.html)

## License

This template is provided as-is for educational and commercial use.
