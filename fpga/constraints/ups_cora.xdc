set_property PACKAGE_PIN N15 [get_ports {led[2]}]
set_property PACKAGE_PIN G17 [get_ports {led[3]}]
set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property PACKAGE_PIN L14 [get_ports {led[0]}]

# DAC0
set_property PACKAGE_PIN R16 [get_ports {dac0_cs_n}  ]
set_property PACKAGE_PIN U13 [get_ports {dac0_dout}  ]
set_property PACKAGE_PIN U12 [get_ports {dac0_sclk}  ]
set_property PACKAGE_PIN V15 [get_ports {dac0_ldac}  ]

# DAC1
set_property PACKAGE_PIN T16 [get_ports {dac1_cs_n}  ]
set_property PACKAGE_PIN T17 [get_ports {dac1_dout}  ]
set_property PACKAGE_PIN U17 [get_ports {dac1_sclk}  ]
set_property PACKAGE_PIN R18 [get_ports {dac1_ldac}  ]

# JB BOTTOM ROW
set_property PACKAGE_PIN V16 [get_ports {valve} ]

set_property PACKAGE_PIN E17 [get_ports {vaux1_p} ]
set_property PACKAGE_PIN D18 [get_ports {vaux1_n} ]

set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dac0_cs_n} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac0_dout} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac0_sclk} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac0_ldac} ]

set_property IOSTANDARD LVCMOS33 [get_ports {dac1_cs_n} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac1_dout} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac1_sclk} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac1_ldac} ]

set_property IOSTANDARD LVCMOS33 [get_ports {valve}]

set_property IOSTANDARD LVCMOS33 [get_ports {vaux1_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {vaux1_n}]

set_property iostandard "LVCMOS33" [get_ports "ps_clk"]
set_property PACKAGE_PIN "E7"      [get_ports "ps_clk"]
set_property slew "fast"           [get_ports "ps_clk"]
