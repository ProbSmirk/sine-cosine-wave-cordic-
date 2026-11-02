# System Clock (100 MHz)
set_property PACKAGE_PIN Y9 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]

# Reset Button (BTNC) - Bank 34 (1.8V)
set_property PACKAGE_PIN P16 [get_ports {rst}]
set_property IOSTANDARD LVCMOS18 [get_ports {rst}]

# Rotary Encoder Inputs (JD Pmod connector) - Bank 13 (3.3V)
set_property PACKAGE_PIN W7 [get_ports {JD1_N}]
set_property IOSTANDARD LVCMOS33 [get_ports {JD1_N}]

set_property PACKAGE_PIN V7 [get_ports {JD1_P}]
set_property IOSTANDARD LVCMOS33 [get_ports {JD1_P}]

set_property PACKAGE_PIN F22 [get_ports {sw0}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw0}]

# DAC Outputs (JA Pmod connector) - Bank 13 (3.3V)
# JA1 is nSYNC
set_property PACKAGE_PIN Y11 [get_ports {nSYNC}]
set_property IOSTANDARD LVCMOS33 [get_ports {nSYNC}]

# JA2 is D1
set_property PACKAGE_PIN AA11 [get_ports {D1}]
set_property IOSTANDARD LVCMOS33 [get_ports {D1}]

# JA3 is D2
set_property PACKAGE_PIN Y10 [get_ports {D2}]
set_property IOSTANDARD LVCMOS33 [get_ports {D2}]

# JA4 is clk_spi
set_property PACKAGE_PIN AA9 [get_ports {clk_spi}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk_spi}]