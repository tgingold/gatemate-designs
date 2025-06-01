cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)

set(PICO_BOARD pico CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

# Initialise the Raspberry Pi Pico SDK
project(core1_hello C CXX)
pico_sdk_init()

add_executable(core1_hello
	hello_core1.c
)

pico_set_linker_script(core1_hello ${CMAKE_SOURCE_DIR}/memmap_sram.ld)
pico_set_binary_type(core1_hello no_flash)

# pull in common dependencies
target_link_libraries(core1_hello pico_stdlib)

# disable usb output, disable uart output
#pico_enable_stdio_usb(core1_hello 0)
pico_enable_stdio_uart(core1_hello 0)

# create map/bin/hex/uf2 file etc.
#pico_add_extra_outputs(core1_hello)

# add url via pico_set_program_url
#example_auto_set_url(core1_hello)

target_link_options(core1_hello PUBLIC "LINKER:-Map=core1_hello.map")
