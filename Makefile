test.bin: test.v tm1637.v test_8k.pcf
	yosys -q -p "synth_ice40 -blif test.blif" test.v tm1637.v
	arachne-pnr -d 8k -p test_8k.pcf test.blif -o test.txt
#	icebox_explain test.txt > test.ex
	icepack test.txt test.bin

clean:
	rm -f test.blif test.txt test.ex test.bin
