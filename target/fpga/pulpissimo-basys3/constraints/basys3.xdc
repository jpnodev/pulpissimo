## Constraint File for the Basys 3 board (PULPissimo Port)
## -------------------------------------------------------

## Clock signal (100MHz)
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports sys_clk]
create_clock -period 10.000 -name ref_clk [get_ports sys_clk]

## Reset (Center Button - Active High)
# Mapped to U18. In RTL, ensure this signals active-high logic or invert it.
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports pad_reset_n]
set_false_path -from [get_ports pad_reset_n]
# Allow reset to be routed on non-clock pin
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pad_reset_n_IBUF]

## Buttons
# btnc_i moved to Switch 15 (R2) to avoid conflict with Reset on U18
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports btnc_i]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports btnd_i]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports btnl_i]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports btnr_i]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports btnu_i]

## Switches (SW0, SW1)
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports switch0_i]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports switch1_i]

## LEDs (0-3)
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports led0_o]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports led1_o]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports led2_o]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports led3_o]

## UART (USB-UART)
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports pad_uart_rx]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports pad_uart_tx]

## JTAG (PMOD JA)
set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [get_ports pad_jtag_tms]
set_property -dict {PACKAGE_PIN L2  IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN G2  IOSTANDARD LVCMOS33} [get_ports pad_jtag_tck]

# JTAG Timing Constraints
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports pad_jtag_tck]
set_input_jitter tck 1.000
# Allow JTAG clock on non-clock dedicated pin (PMOD)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_pulpissimo/i_padframe/i_pulpissimo_pads/i_all_pads/i_all_pads_pads/i_pad_jtag_tck/O]

set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tdi]
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tms]
set_output_delay -clock tck 5.000 [get_ports pad_jtag_tdo]

set_max_delay -to [get_ports pad_jtag_tdo] 20.000
set_max_delay -from [get_ports pad_jtag_tms] 20.000
set_max_delay -from [get_ports pad_jtag_tdi] 20.000

## I2C / I2S (PMOD JB)
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports pad_i2c0_sda]
set_property -dict { PACKAGE_PIN A16 IOSTANDARD LVCMOS33 } [get_ports pad_i2c0_scl]
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports pad_i2s0_sck]
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports pad_i2s0_ws]
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 } [get_ports pad_i2s0_sdi]
set_property -dict { PACKAGE_PIN A17 IOSTANDARD LVCMOS33 } [get_ports pad_i2s1_sdi]

## QSPI Flash (PMOD JC)
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports pad_spim_csn0]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio0]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio1]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio2]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio3]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports pad_spim_sck]

## SD Card (Mapped to JXADC Header)
# REQUIRED to satisfy IO placement even if you don't use SD.
# Corresponds to Basys 3 JXADC Pmod Header.
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports pad_sdio_clk]
# set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports { sd_cd }]; 
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports pad_sdio_cmd]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data0]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data1]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data2]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data3]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports sdio_reset_o]

# Allow SDIO clock on non-clock pin
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pad_sdio_clk_IBUF]

## Configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

## Clock Interaction & Dedicated Routes
set_clock_groups -asynchronous \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/slow_clk_o]] \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/i_clk_manager/clk_out1]]

set_clock_groups -asynchronous \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/i_clk_manager/clk_out1]] \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/i_clk_manager/clk_out2]]

set_clock_groups -asynchronous \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/pad_jtag_tck]] \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/i_clk_manager/clk_out1]]

set_clock_groups -asynchronous \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/pad_jtag_tck]] \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/i_clk_manager/clk_out2]]

set_clock_groups -asynchronous \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/i_clock_gen/slow_clk_o]] \
    -group [get_clocks -of_objects [get_pins i_pulpissimo/pad_jtag_tck]]

# Required workaround for cascade BUFG in Slow Clock Manager
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_pulpissimo/i_clock_gen/i_slow_clk_div/i_clk_mux/clk_o]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_pulpissimo/i_clock_gen/i_slow_clk_mngr/inst/clk_out1]

# 1. Fix BUFG Cascade Error
# Allow the slow clock divider to drive the clock manager via general routing
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_pulpissimo/i_clock_gen/i_slow_clk_div/i_clk_mux/clk_o]

# 2. Fix JTAG Clock Placement
# Allow JTAG TCK (from Pmod) to drive the internal clock network via general routing
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_pulpissimo/i_padframe/i_pulpissimo_pads/i_all_pads/i_all_pads_pads/i_pad_jtag_tck/O]

# 3. Fix Reset Routing
# Allow the Reset button to drive the reset network via general routing
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pad_reset_n_IBUF]