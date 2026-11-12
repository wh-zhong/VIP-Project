set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports { clk } ]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports { clk }]

set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports { led1 } ]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports { led2 } ]
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { led3 } ]
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports { active } ]
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { rst } ]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { servo_out } ]
