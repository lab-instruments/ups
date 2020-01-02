set_property PACKAGE_PIN N15 [get_ports {led[2]}]                               # LED0_R
set_property PACKAGE_PIN G17 [get_ports {led[3]}]                               # LED0_G
set_property PACKAGE_PIN M15 [get_ports {led[1]}]                               # LED1_R
set_property PACKAGE_PIN L14 [get_ports {led[0]}]                               # LED1_G

# JA TOP ROW --- DAC
set_property PACKAGE_PIN Y18 [get_ports {dac_cs_n}  ]                           # JA1_P -- PIN 1
set_property PACKAGE_PIN Y19 [get_ports {dac_dout0} ]                           # JA1_N -- PIN 2
set_property PACKAGE_PIN Y17 [get_ports {dac_sclk}  ]                           # JA2_N -- PIN 4

# JA BOTTOM ROW --- ADC
set_property PACKAGE_PIN U18 [get_ports {adc_cs_n}]                             # JA3_P -- PIN 1
set_property PACKAGE_PIN U19 [get_ports {adc_din} ]                             # JA3_N -- PIN 2
set_property PACKAGE_PIN W19 [get_ports {adc_sclk}]                             # JA4_N -- PIN 4

# JB BOTTOM ROW
set_property PACKAGE_PIN V16 [get_ports {valve}]                                # JA3_P -- PIN 1

set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dac_cs_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_dout}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_ldac_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_sclk}]

set_property IOSTANDARD LVCMOS33 [get_ports {adc_cs_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_din}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_sclk}]

set_property IOSTANDARD LVCMOS33 [get_ports {valve}]

set_property iostandard "LVCMOS33" [get_ports "ps_clk"]                         
set_property PACKAGE_PIN "E7"      [get_ports "ps_clk"]                              
set_property slew "fast"           [get_ports "ps_clk"]
 