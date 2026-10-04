# read modules from Verilog files
read_verilog top_mac.v
read_verilog accumulator.v
read_verilog multiplier.v
read_verilog bit_selector.v
read_verilog sign_extender.v

# elaborate design hierarchy
hierarchy -check -top top_mac

# flatten so the mapper optimizes across module boundaries
flatten

# translate processes (always blocks) to netlists
proc

# optimize + convert multiplier/adder to gates
opt
techmap
opt

# mapping flip-flops to NangateOpenCellLibrary_typical.lib
dfflibmap -liberty NangateOpenCellLibrary_typical.lib

# mapping logic to NangateOpenCellLibrary_typical.lib
abc -liberty NangateOpenCellLibrary_typical.lib

# remove unused cells and wires
clean

# report cell count and area
tee -o build/synth_stat.rpt stat -liberty NangateOpenCellLibrary_typical.lib

# write the netlist
write_verilog -noattr build/top_mac_netlist.v
