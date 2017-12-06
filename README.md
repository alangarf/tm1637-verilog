# tm1637-verilog
This is a basic verilog driver for the TM1637 LED driver chip. Included in test.v is a basic state machine that feeds instructions to the tm1637.v module to initialise the display and diplay `1234` as an example.

This project was done using **yosys/iceStorm/arachne-pnr**, however the tm1637.v should translate perfectly to other systems just fine.

The pin definition file is setup for the Lattice iCE40-HX8K Breakout Board.
