read_liberty NangateOpenCellLibrary_typical.lib
read_verilog build/top_mac_netlist.v
link_design top_mac
read_sdc top_mac_power.sdc
set_power_activity -input -activity 0.5
report_power
