#include "blinky_task.hpp"
#include "stm32f1xx_hal.h"
#include "FreeRTOS.h"
#include "task.h"

void blinky(void *pvParameters) {
  while (1) {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
    /* Insert delay 100 ms */
    vTaskDelay(1000/portTICK_PERIOD_MS);
  }
}
