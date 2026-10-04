source "helpers.tcl"
source "flow_helpers.tcl"
source "Nangate45/Nangate45.vars"

set design "top_mac"
set top_module "top_mac"
set synth_verilog "top_mac_nangate45.v"
set sdc_file "top_mac_nangate45.sdc"
set die_area {0 0 110.2 110.6}
set core_area {10.07 11.2 100.13 100.8}

include -echo "flow.tcl"
