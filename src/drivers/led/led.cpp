#include "led.hpp"
#include "stm32f1xx_hal.h"

Led* Led::led_ = nullptr;

Led *Led::getInstance()
{
    if(led_ == nullptr){
        led_ = new Led();
    }
    return led_;
}

void Led::init()
{
    GPIO_InitTypeDef GPIO_Config;

    GPIO_Config.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_Config.Pull = GPIO_NOPULL;
    GPIO_Config.Speed = GPIO_SPEED_FREQ_HIGH;

    GPIO_Config.Pin = GPIO_PIN_5;

    __HAL_RCC_GPIOA_CLK_ENABLE();
    HAL_GPIO_Init(GPIOA, &GPIO_Config);
}

void Led::toggle()
{
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
}

void Led::on()
{
    HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET);
}

void Led::off()
{
    HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET);
}
