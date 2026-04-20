/*
 * ESP32-S3 DevKitC-1 Blink Example - ESP-IDF
 *
 * This example demonstrates basic GPIO control on the ESP32-S3 using ESP-IDF
 * framework by blinking the built-in RGB LED. The ESP32-S3-DevKitC-1 typically
 * has an addressable RGB LED on GPIO48.
 *
 * For this simple example, we'll use the LED as a simple GPIO output.
 * For full RGB control, you would use the RMT or LED PWM peripheral.
 */

#include <stdio.h>
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "sdkconfig.h"

// GPIO pin for the built-in RGB LED on ESP32-S3-DevKitC-1
#define LED_GPIO GPIO_NUM_48

// Blink interval in milliseconds
#define BLINK_PERIOD_MS 1000

static const char *TAG = "blink";

void app_main(void)
{
    ESP_LOGI(TAG, "ESP32-S3 Blink Example Starting...");
    ESP_LOGI(TAG, "LED GPIO: %d", LED_GPIO);

    // Configure GPIO pin as output
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,         // Disable interrupt
        .mode = GPIO_MODE_OUTPUT,               // Set as output mode
        .pin_bit_mask = (1ULL << LED_GPIO),     // Bit mask of the pin
        .pull_down_en = GPIO_PULLDOWN_DISABLE,  // Disable pull-down
        .pull_up_en = GPIO_PULLUP_DISABLE       // Disable pull-up
    };
    gpio_config(&io_conf);

    ESP_LOGI(TAG, "Setup complete! Starting blink loop...");

    // Main blink loop
    uint8_t led_state = 0;
    while (1) {
        // Toggle LED state
        led_state = !led_state;
        gpio_set_level(LED_GPIO, led_state);

        ESP_LOGI(TAG, "LED %s", led_state ? "ON" : "OFF");

        // Wait for specified period
        vTaskDelay(BLINK_PERIOD_MS / portTICK_PERIOD_MS);
    }
}
