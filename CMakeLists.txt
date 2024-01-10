cmake_minimum_required(VERSION 3.21)

project(freertos-learning VERSION 1.0)
enable_language(C CXX ASM)

include(FetchContent)

set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH} 
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Compilation options #########################################################
set(CMAKE_C_STANDARD                11)
set(CMAKE_C_STANDARD_REQUIRED       ON)
set(CMAKE_C_EXTENSIONS              ON)
set(CMAKE_CXX_STANDARD              20)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            ON)
###############################################################################

# Options #####################################################################
option(CPP_CHECK "Enable CppCheck" OFF)
option(CLANG_FORMAT "Enable ClangFormat" OFF)
option(WITH_DOC "Enable Documentation generation" OFF)
###############################################################################

# Compilation #################################################################
set(SOURCES_FILES
  ${CMAKE_SOURCE_DIR}/src/main.cpp
  ${CMAKE_SOURCE_DIR}/src/freertos/tasks/blinky/blinky_task.cpp
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/syscalls.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/stm32f1xx_it.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/system_stm32f1xx.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/stm32f1xx_hal_msp.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/stm32f1xx_hal_timebase_tim.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_exti.c
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/startup/startup_stm32f103xb.s
)

set(INCLUDES_DIR
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/STM32F1xx_HAL_Driver/Inc
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/CMSIS/Include
  ${CMAKE_SOURCE_DIR}/src/stm32f103rb/peripherals/CMSIS/Device/ST/STM32F1xx/Include
  ${CMAKE_SOURCE_DIR}/src/freertos/tasks/blinky/
)

set(SYMBOLES
  -DUSE_HAL_DRIVER
  -DSTM32F103xB
)

set(CPU_PARAMETERS
  -mthumb
  -mcpu=cortex-m3
  -mfloat-abi=soft
)

add_compile_options(
  ${CPU_PARAMETERS}
)

set(linker_script_SRC ${CMAKE_SOURCE_DIR}/STM32F103XB_FLASH.ld)
set(EXECUTABLE ${CMAKE_PROJECT_NAME})

set(FREERTOS_CONFIG_FILE_DIRECTORY ${CMAKE_SOURCE_DIR}/src/freertos/FreeRTOSConfig CACHE STRING "")
set(FREERTOS_PORT GCC_ARM_CM3 CACHE STRING "")
add_subdirectory(${CMAKE_SOURCE_DIR}/src/freertos/Source)

add_executable(${EXECUTABLE} ${SOURCES_FILES})
target_include_directories(${EXECUTABLE} PRIVATE ${INCLUDES_DIR})
target_compile_definitions(${EXECUTABLE} PRIVATE ${SYMBOLES})
target_link_libraries(${EXECUTABLE} PRIVATE freertos_kernel)

target_compile_options(${EXECUTABLE} PRIVATE
  ${CPU_PARAMETERS}
  -Wall
  -Wextra
  -Wpedantic
  -Wno-unused-parameter
  # Full debug configuration
  $<$<CONFIG:Debug>:-Og -g3 -ggdb>
)

target_link_options(${EXECUTABLE} PRIVATE
  -T${linker_script_SRC}
  ${CPU_PARAMETERS}
  -Wl,-Map=${CMAKE_PROJECT_NAME}.map
  --specs=nosys.specs
  -u _printf_float                # STDIO float formatting support
  -Wl,--start-group
  -lc
  -lm
  -lstdc++
  -lsupc++
  -Wl,--end-group
  -Wl,--print-memory-usage
)

# Execute post-build to print size
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>
)

# Convert output to hex and binary
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.hex
)

# Convert to bin file -> add conditional check?
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.bin
)
###############################################################################

# Documentation ###############################################################
if (WITH_DOC)
  add_subdirectory(doc)
endif()
###############################################################################

# CppCheck ####################################################################
if (CPP_CHECK)
  find_program(C_CPPCHECK NAMES cppcheck)
  if (C_CPPCHECK)
    list(
        APPEND C_CPPCHECK 
            "--enable=warning,style,performance,portability,information,missingInclude"
            "--error-exitcode=10"
            "--force"
            "--suppress=missingInclude"
            "--inline-suppr"
            "-isrc/Drivers"
            "src/"
    )
    add_custom_target(
      cppcheck
      COMMAND ${C_CPPCHECK} 
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "Static code analysis"
    )
  endif()
endif()
###############################################################################

# Clang-format ################################################################
if (CLANG_FORMAT)
  find_package(ClangFormat)
endif()
###############################################################################
