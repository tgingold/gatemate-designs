# Simple designs for GateMateA1-EVB

## Setup

Assuming Linux host...

Put CFG_SET1 switches to jtag (ON-ON-OFF-OFF).

Press the FPGA_RST1 button before loading a new bitstream (the 'make jtag')

Set TOOL_PREFIX in common.mk


## Designs

### blink

From Cologne Chip example

Blinking led + UART loopback

```
make synth
make impl
make jtag
```

To test UART:
```
sudo picocom /dev/ttyACM0
```

### hello

Print 'Hello World' on UART (9600 8N1) when the FPGA_BUT1 is pressed

