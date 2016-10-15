
VIVADO = /xilinx/Vivado/2015.4/data/

SRC_FILES =  	../src/top.v											\
						 	../src/neopixel.v									\
						 	../src/neopixel_control.v         \
						 	$(VIVADO)/verilog/src/glbl.v


TB_FILES  = 	../tb/src/tb.sv

.PHONY: sim clean build elaborate

sim: build elaborate
	xsim neopixel -t run_sim.tcl -onfinish quit -stats -nolog

build:
	xvlog -work work -sv $(SRC_FILES) $(TB_FILES)

elaborate:
	xelab work.tb work.glbl -L unisims_ver -debug all -s neopixel -nolog

view:
	vivado -source display_sim.tcl

clean:
	rm -f *.log
	rm -f *.jou
	rm -f *.wdb
	rm -f *.zip
	rm -f *.pb
	rm -rf xsim.dir
