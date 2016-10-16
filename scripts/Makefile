


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


view_synth:
	vivado -mode gui -source vivado_view_synth_results.tcl -nojournal -nolog -tempDir ./work

view_place:
	vivado -mode gui -source vivado_view_place_results.tcl -nojournal -nolog -tempDir ./work

view_route:
	vivado -mode gui -source vivado_view_route_results.tcl -nojournal -nolog -tempDir ./work

help:
	echo "Make targets: all = (synth, place, route, bitgen) , prog, help, clean"

clean:
	rm -f *.jou
	rm -f *.log
	rm -f *.os
	rm -f *.html
	rm -f *.xml
	rm -rf work