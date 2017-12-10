YOSYS=yosys
ARACHNE=arachne-pnr
ICEPACK=icepack
IVERILOG=iverilog
VVP=vvp

PART=8k
PCF=src/ice40hx8k.pcf

all: demos
demos: basic hex

# ------ TEMPLATES ------
%.blif: %.v
	$(YOSYS) -q -p "synth_ice40 -blif $@" $^
%.txt: %.blif
	$(ARACHNE) -d $(PART) -p $(PCF) $^ -o $@
%.bin: %.txt
	$(ICEPACK) $^ $@

%.vvp: %.v
	sed -i '' 's?".*\.vcd"?"$(subst .vvp,.vcd,$@)"?' $(filter %_tb.v,$(^))
	$(IVERILOG) -o $@ -s $(subst .vvp,,$(notdir $@)) $^
%.vcd: %.vvp
	$(VVP) $^ -lxt2
	open $@

# ------ DEMOS ------

#  BASIC
basic: demos/basic/basic.bin
demos/basic/basic.blif: demos/basic/basic.v src/tm1637/tm1637.v
demos/basic/basic.txt: demos/basic/basic.blif
demos/basic/basic.bin: demos/basic/basic.txt

# HEX DISPLAY
hex: demos/hex/hex.bin
demos/hex/hex.blif: demos/hex/hex.v src/hex/hex.v src/hex/hex_to_seg.v src/tm1637/tm1637.v
demos/hex/hex.txt: demos/hex/hex.blif
demos/hex/hex.bin: demos/hex/hex.txt

# DECIMAL DISPLAY
decimal: demos/decimal/decimal.bin
demos/decimal/decimal.blif: demos/decimal/decimal.v src/decimal/decimal.v src/decimal/dec_to_seg.v src/decimal/bcd.v src/tm1637/tm1637.v
demos/decimal/decimal.txt: demos/decimal/decimal.blif
demos/decimal/decimal.bin: demos/decimal/decimal.txt

# ------ TEST BENCHES ------

src/tm1637/tm1637_tb.vvp: src/tm1637/tm1637_tb.v src/tm1637/tm1637.v
src/tm1637/tm1637_tb.vcd: src/tm1637/tm1637_tb.vvp
tm1637_tb: src/tm1637/tm1637_tb.vcd

src/hex/hex_to_seg_tb.vvp: src/hex/hex_to_seg_tb.v src/hex/hex_to_seg.v
src/hex/hex_to_seg_tb.vcd: src/hex/hex_to_seg_tb.vvp
hex_to_seg_tb: src/hex/hex_to_seg_tb.vcd

src/hex/hex_tb.vvp: src/hex/hex_tb.v src/hex/hex.v src/hex/hex_to_seg.v src/tm1637/tm1637.v
src/hex/hex_tb.vcd: src/hex/hex_tb.vvp
hex_tb: src/hex/hex_tb.vcd

src/decimal/bcd_tb.vvp: src/decimal/bcd_tb.v src/decimal/bcd.v
src/decimal/bcd_tb.vcd: src/decimal/bcd_tb.vvp
bcd_tb: src/decimal/bcd_tb.vcd

src/decimal/dec_to_seg_tb.vvp: src/decimal/dec_to_seg_tb.v src/decimal/dec_to_seg.v
src/decimal/dec_to_seg_tb.vcd: src/decimal/dec_to_seg_tb.vvp
dec_to_seg_tb: src/decimal/dec_to_seg_tb.vcd

# ------ HELPERS ------
clean:
	find . -name '*.blif' -delete
	find . -name '*.txt' -delete
	find . -name '*.bin' -delete
	find . -name '*.vvp' -delete
	find . -name '*.vcd' -delete
