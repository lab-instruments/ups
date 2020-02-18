set_property PACKAGE_PIN N15 [get_ports {led[2]}]
set_property PACKAGE_PIN G17 [get_ports {led[3]}]
set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property PACKAGE_PIN L14 [get_ports {led[0]}]

# JA TOP ROW --- DAC
set_property PACKAGE_PIN Y18 [get_ports {dac_cs_n}  ]
set_property PACKAGE_PIN Y19 [get_ports {dac_dout0} ]
set_property PACKAGE_PIN Y16 [get_ports {dac_dout1} ]
set_property PACKAGE_PIN Y17 [get_ports {dac_sclk}  ]

# JA BOTTOM ROW --- ADC
set_property PACKAGE_PIN U18 [get_ports {adc_cs_n}]
set_property PACKAGE_PIN U19 [get_ports {adc_din} ]
set_property PACKAGE_PIN W19 [get_ports {adc_sclk}]

# JB BOTTOM ROW
set_property PACKAGE_PIN V16 [get_ports {valve}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dac_cs_n} ]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_dout0}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_dout1}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_sclk} ]

set_property IOSTANDARD LVCMOS33 [get_ports {adc_cs_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_din}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_sclk}]

set_property IOSTANDARD LVCMOS33 [get_ports {valve}]

set_property iostandard "LVCMOS33" [get_ports "ps_clk"]                         
set_property PACKAGE_PIN "E7"      [get_ports "ps_clk"]                              
set_property slew "fast"           [get_ports "ps_clk"]
 