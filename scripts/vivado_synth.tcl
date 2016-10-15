source reportCriticalPaths.tcl
# STEP#1: define the output directory area.
#
set outputDir ../test_output
file mkdir $outputDir
#
# STEP#2: setup design sources and constraints
#
read_verilog -sv [ glob ../src/*.v ]
read_xdc ../route/pins.xdc
#
# STEP#3: run synthesis, write design checkpoint, report timing,
# and utilization estimates
#
synth_design -top top -part xc7z010clg400-1 -flatten_hierarchy none -verbose
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
#
# Run custom script to report critical timing paths
reportCriticalPaths $outputDir/post_synth_critpath_report.csv