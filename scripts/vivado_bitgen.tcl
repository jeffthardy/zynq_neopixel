
set outputDir ../test_output
read_checkpoint $outputDir/post_route.dcp
link_design
#
# STEP#6: generate a bitstream
#
write_bitstream -force $outputDir/cpu.bit