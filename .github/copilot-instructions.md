# GitHub Copilot Instructions for ESP32-S3 Template

## Project Overview

This is an **ESP32-S3 embedded firmware project** using:

- **PlatformIO** as the build system (not Arduino IDE)
- **ESP-IDF framework** (Espressif IoT Development Framework, not Arduino)
- **FreeRTOS** for task management
- **Dev Container** environment with all tools pre-installed

The project is a template designed for professional ESP32-S3 development with
complete tooling for formatting, linting, and CI/CD.

## Build, Test, and Lint Commands

### Build Commands

```bash
# Build firmware
make build
# or: pio run -e esp32-s3-devkitc-1

# Upload to device
make upload
# or: pio run -e esp32-s3-devkitc-1 -t upload

# Build and upload
make flash

# Serial monitor
make monitor
# or: pio device monitor --baud 115200

# Check firmware size
make size
# or: pio run -e esp32-s3-devkitc-1 -t size

# Clean build
make clean
```

### Code Quality Commands

```bash
# Format all C files
make format

# Run static analysis (clang-tidy)
make lint

# Run all checks (format + lint + pre-commit hooks)
make test

# Install pre-commit hooks
make install-hooks
```

### Individual File Operations

```bash
# Format a single file
clang-format -i src/myfile.c

# Check formatting without modifying
clang-format --dry-run --Werror src/myfile.c

# Lint a single file (requires compile_commands.json)
clang-tidy src/myfile.c -p .
```

## Architecture and Project Structure

### Build System Integration

- **PlatformIO** manages ESP-IDF installation, dependencies, and compilation
- **ESP-IDF v5.5.3** provides the actual SDK, drivers, and FreeRTOS
- **platformio.ini** is the single source of truth for build configuration
- Build artifacts go to `.pio/build/esp32-s3-devkitc-1/`
- No Arduino framework - this is pure ESP-IDF

### Configuration Hierarchy

1. **platformio.ini** - Board, framework, upload settings
2. **sdkconfig.defaults** - ESP-IDF SDK configuration defaults
3. **CMakeLists.txt** - ESP-IDF component registration (if custom components added)

### Source Organization

- **src/main.c** - Contains `app_main()` entry point (not `main()`)
- No `setup()` or `loop()` functions - use FreeRTOS tasks instead
- Create tasks with `xTaskCreate()` for concurrent operations

### Tooling Files

- **compile_commands.json** - Generated build database for clang-tidy (DO NOT commit)
- **.clang-tidy** - Static analysis rules (already configured for ESP-IDF)
- **.clang-format** - Code style rules (ESP-IDF compatible, 120 char limit)
- **.pre-commit-config.yaml** - Git hooks for automated checks

## Key Conventions

### ESP-IDF Naming Patterns

**Static logging tags:**

```c
static const char *TAG = "my_component";  // UPPER_CASE is allowed
```

The clang-tidy config specifically allows `TAG` in UPPER_CASE as it's an ESP-IDF
convention. Global variables normally require UPPER_CASE per `.clang-tidy`.

**Function naming:**

- Lower case with underscores: `my_function_name()`
- Macros in UPPER_CASE: `MY_MACRO`
- Local variables in lower_case

### ESP-IDF Logging

Use ESP logging macros, not printf:

```c
#include "esp_log.h"

ESP_LOGI(TAG, "Info message: %d", value);
ESP_LOGW(TAG, "Warning: %s", message);
ESP_LOGE(TAG, "Error occurred");
ESP_LOGD(TAG, "Debug info");  // Only shown if debug level enabled
```

### GPIO and Driver Usage

**Always use ESP-IDF drivers, not direct register access:**

```c
#include "driver/gpio.h"

gpio_config_t io_conf = {
    .intr_type = GPIO_INTR_DISABLE,
    .mode = GPIO_MODE_OUTPUT,
    .pin_bit_mask = (1ULL << GPIO_NUM_48),
    .pull_down_en = GPIO_PULLDOWN_DISABLE,
    .pull_up_en = GPIO_PULLUP_DISABLE
};
gpio_config(&io_conf);
```

### FreeRTOS Task Management

```c
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

void my_task(void *pvParameters) {
    while (1) {
        // Task code
        vTaskDelay(pdMS_TO_TICKS(1000));  // Use pdMS_TO_TICKS, not raw values
    }
}

void app_main(void) {
    xTaskCreate(my_task, "my_task", 4096, NULL, 5, NULL);
}
```

**Important:** Use `portTICK_PERIOD_MS` for delay calculations:

```c
vTaskDelay(1000 / portTICK_PERIOD_MS);  // 1 second delay
```

### Board-Specific Hardware

**ESP32-S3-DevKitC-1 specifics:**

- Built-in LED: GPIO48 (addressable RGB, use as GPIO for simple on/off)
- USB-C port: Used for programming, power, and USB-JTAG debugging
- Flash: 8MB (configured in sdkconfig.defaults)
- PSRAM: Not enabled by default (N8 variant has none)

### Memory Management

- Stack size specified in `xTaskCreate()` - typical: 2048-4096 bytes
- Heap allocation uses `malloc()`/`free()` or ESP-IDF's `heap_caps_malloc()`
- Check stack usage with `uxTaskGetStackHighWaterMark()`
- Monitor heap: `esp_get_free_heap_size()`

## Code Quality Workflow

### Pre-commit Hooks

**Automatically run on `git commit`:**

1. Trailing whitespace removal
2. LF line endings enforcement
3. YAML syntax check
4. File size limits (500KB max)
5. clang-format on C files
6. shellcheck on shell scripts
7. markdownlint on documentation
8. EditorConfig compliance

**Bypass if needed:** `git commit --no-verify`

### Clang-Tidy Configuration

The `.clang-tidy` file enables:

- `bugprone-*` - Bug detection
- `cert-*` - CERT secure coding
- `clang-analyzer-*` - Deep static analysis
- `performance-*` - Performance issues
- `readability-*` - Code style

**Disabled checks:**

- `misc-unused-parameters` - Common in embedded callbacks
- `readability-magic-numbers` - Many hardware constants
- `readability-identifier-length` - Short names OK for embedded

**The `lint` target auto-generates `compile_commands.json` if missing.**

### CI/CD Pipeline

**GitHub Actions runs three jobs on push/PR:**

1. **build** - Compiles firmware, checks size, uploads artifacts
2. **format-check** - Verifies clang-format compliance
3. **lint** - Runs all pre-commit hooks

Artifacts are kept for 30 days in GitHub Actions.

## Adding New Source Files

1. Add `.c` file to `src/` directory
2. Add corresponding `.h` file if needed (headers in `src/` or create `include/`)
3. Include from other files: `#include "myfile.h"`
4. Run `make build` to compile

**No need to modify CMakeLists.txt** - PlatformIO auto-discovers source files.

## Adding ESP-IDF Components

**Built-in components** (already available):

```c
#include "esp_wifi.h"        // WiFi
#include "nvs_flash.h"       // Non-volatile storage
#include "driver/i2c.h"      // I2C driver
#include "driver/spi_master.h"  // SPI driver
#include "driver/uart.h"     // UART driver
```

**External libraries** - Add to platformio.ini:

```ini
lib_deps =
    https://github.com/espressif/esp-idf-lib.git
```

## Debugging

### USB-JTAG Debugging (Built-in)

1. Press F5 in VS Code
2. Debugger breaks at `app_main()` by default
3. Set breakpoints by clicking line numbers
4. Debug config in `.vscode/launch.json`

**Debug configuration in platformio.ini:**

```ini
debug_tool = esp-builtin
debug_init_break = tbreak app_main
```

### Serial Output Debugging

All ESP_LOG* macros output to UART0 at 115200 baud. Use `make monitor` to view.

## Common Patterns

### Initialization Sequence

```c
void app_main(void) {
    // 1. Initialize NVS (needed for WiFi)
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    // 2. Initialize drivers
    // 3. Create tasks
    // 4. Start operations
}
```

### Error Handling

```c
esp_err_t err = some_function();
if (err != ESP_OK) {
    ESP_LOGE(TAG, "Function failed: %s", esp_err_to_name(err));
    return;
}

// Or use assert for critical errors:
ESP_ERROR_CHECK(some_function());  // Aborts on error
```

## What to Avoid

- ❌ Arduino-style `setup()` and `loop()` - use `app_main()` and FreeRTOS tasks
- ❌ `delay()` - use `vTaskDelay(pdMS_TO_TICKS(ms))`
- ❌ `Serial.print()` - use `ESP_LOGI()` and ESP logging
- ❌ Direct register manipulation - use ESP-IDF drivers
- ❌ Blocking operations in `app_main()` - create tasks instead
- ❌ Committing `compile_commands.json` - it's in .gitignore
- ❌ Tabs in JSON/YAML files - use 2 spaces (.editorconfig enforced)
- ❌ Windows line endings (CRLF) - use LF (.editorconfig enforced)

## Resources

- ESP-IDF API Reference: <https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-reference/>
- ESP32-S3 TRM: <https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_en.pdf>
- FreeRTOS Documentation: <https://www.freertos.org/>
- PlatformIO ESP-IDF: <https://docs.platformio.org/en/latest/frameworks/espidf.html>
