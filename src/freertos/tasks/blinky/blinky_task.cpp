#include "blinky_task.hpp"
#include "led.hpp"
#include "FreeRTOS.h"
#include "task.h"

void blinky(void *pvParameters) {
    Led *led = Led::getInstance();
    led->init();

    while (1) {
        led->toggle();
        /* Insert delay 100 ms */
        vTaskDelay(1000/portTICK_PERIOD_MS);
    }
}
