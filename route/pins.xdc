
#Switches
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { btns_4bits_tri_i[0] }]; #IO_L19N_T3_VREF_35 Sch=SW0
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { btns_4bits_tri_i[1] }];  #IO_L24P_T3_34 Sch=SW1
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { btns_4bits_tri_i[2] }]; #IO_L4N_T0_34 Sch=SW2
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { btns_4bits_tri_i[3] }]; #IO_L9P_T1_DQS_34 Sch=SW3


#LEDs
set_property PACKAGE_PIN M14 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN M15 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN G14 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property PACKAGE_PIN D18 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]

#Serial output to Neopixel Strand 1
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports neopixel_drive1]

# Ethernet Clock
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports clock_125m]

#Button 1
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports reset_125m]

create_clock -period 8.000 [get_ports clock_125m]
