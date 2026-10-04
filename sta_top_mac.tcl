read_liberty NangateOpenCellLibrary_typical.lib
read_verilog build/top_mac_netlist.v
link_design top_mac
read_sdc top_mac.sdc
report_checks -path_delay max -format full
report_checks -path_delay min -format full
report_wns
report_tns
