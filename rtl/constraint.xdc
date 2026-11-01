set_property PACKAGE_PIN Y9 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]
create_clock -period 10.000 [get_ports clock]

set_property PACKAGE_PIN P16 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property PACKAGE_PIN W7 [get_ports a]
set_property IOSTANDARD LVCMOS33 [get_ports a]

set_property PACKAGE_PIN V7 [get_ports b]
set_property IOSTANDARD LVCMOS33 [get_ports b]

set_property PACKAGE_PIN Y11 [get_ports nSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports nSYNC]

set_property PACKAGE_PIN AA9 [get_ports CLK_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_OUT]

set_property PACKAGE_PIN AA11 [get_ports DATA1]
set_property IOSTANDARD LVCMOS33 [get_ports DATA1]

