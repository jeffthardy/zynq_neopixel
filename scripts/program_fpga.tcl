open_hw
connect_hw_server
open_hw_target
current_hw_device [lindex [get_hw_devices] 1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 1]
set_property PROBES.FILE {} [lindex [get_hw_devices] 1]
set_property PROGRAM.FILE {../test_output/cpu.bit} [lindex [get_hw_devices] 1]
program_hw_devices [lindex [get_hw_devices] 1]
refresh_hw_device [lindex [get_hw_devices] 1]
disconnect_hw_server localhost:3121
