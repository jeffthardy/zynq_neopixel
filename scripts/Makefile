


#OUTPUT_PATH = ../output

#VIVADO_OPTS = -journal


.PHONY: all prog clean

all: synth place route bitgen

synth:
	vivado -mode batch -source vivado_synth.tcl -nojournal -nolog -tempDir ./work

place:
	vivado -mode batch -source vivado_place.tcl -nojournal -nolog -tempDir ./work

route:
	vivado -mode batch -source vivado_route.tcl -nojournal -nolog -tempDir ./work

bitgen:
	vivado -mode batch -source vivado_bitgen.tcl -nojournal -nolog -tempDir ./work

prog:
	vivado -mode batch -source program_fpga.tcl -nojournal -nolog  -tempDir ./work


clean:
	rm -f *.jou
	rm -f *.log
	rm -f *.os
	rm -f *.html
	rm -f *.xml
	rm -rf work