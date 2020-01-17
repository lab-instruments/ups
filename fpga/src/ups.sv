// -----------------------------------------------------------------------------
//  File Name   :  ups.sv
//  Autoher     :  Mike DeLong
//  Date        :  02.20.2019
//  Description :  UPS Project Top Level
// -----------------------------------------------------------------------------
`define DW 8
`define DI 3
module ups(
    // -------------------------------------------------------------------------
    //  DDR Signals
    // -------------------------------------------------------------------------
    inout  [14:0]       ddr_addr,
    inout  [ 2:0]       ddr_ba,
    inout               ddr_cas_n,
    inout               ddr_clk_n,
    inout               ddr_clk,
    inout               ddr_cke,
    inout               ddr_cs_n,
    inout  [ 3:0]       ddr_dm,
    inout  [31:0]       ddr_dq,
    inout  [ 3:0]       ddr_dqs_n,
    inout  [ 3:0]       ddr_dqs,
    inout               ddr_odt,
    inout               ddr_ras_n,
    inout               ddr_reset_n,
    inout               ddr_we_n,
    inout               ddr_vrn,
    inout               ddr_vrp,

    // -------------------------------------------------------------------------
    //  General Purpose Signals
    // -------------------------------------------------------------------------
    inout  [53:0]       mio,
    inout               ps_clk,
    inout               ps_porb,
    inout               ps_srstb,

    // -------------------------------------------------------------------------
    //  DAC SPI Interface
    // -------------------------------------------------------------------------
    output              dac_sclk,
    output              dac_dout,
    output              dac_cs_n,

    // -------------------------------------------------------------------------
    //  ADC SPI Interface
    // -------------------------------------------------------------------------
    output              adc_sclk,
    input               adc_din,
    output              adc_cs_n,

    // -------------------------------------------------------------------------
    //  OD Interface
    // -------------------------------------------------------------------------
    output              valve,

    // -------------------------------------------------------------------------
    //  LED Outputs
    // -------------------------------------------------------------------------
    output [ 3:0]       led
);

    // -------------------------------------------------------------------------
    //  Assigns
    // -------------------------------------------------------------------------
    assign valve                       = data_l[2][0];

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    // Clock and Reset
    logic               fclk_l;
    logic               rst_n_l;

    // Address Read Cycle
    logic [31:0]       ca4l_araddr_l;
    logic [ 0:0]       ca4l_arready_l;
    logic [ 0:0]       ca4l_arvalid_l;

    // Address Read Cycle
    logic [31:0]        ca4l_awaddr_l;
    logic [ 0:0]        ca4l_awready_l;
    logic [ 0:0]        ca4l_awvalid_l;

    // Response Cylce
    logic [ 0:0]        ca4l_bready_l;
    logic [ 1:0]        ca4l_bresp_l;
    logic [ 0:0]        ca4l_bvalid_l;

    // Data Read Cycle
    logic [31:0]        ca4l_rdata_l;
    logic [ 0:0]        ca4l_rready_l;
    logic [ 1:0]        ca4l_rresp_l;
    logic [ 0:0]        ca4l_rvalid_l;

    // Data Write Cycle
    logic [31:0]        ca4l_wdata_l;
    logic [ 0:0]        ca4l_wready_l;
    logic [ 3:0]        ca4l_wstrb_l;
    logic [ 0:0]        ca4l_wvalid_l;

    // Control Data
    logic [`DW-1:0]     dv_l;
    logic   [31:0]      data_l[`DW-1:0];

    // ADC Data
    logic               adc_dv_l;
    logic [11:0]        adc_data_l;

    // DAC Data
    logic              dac_dv_l;
    logic [15:0]       dac_data_l;

    // -------------------------------------------------------------------------
    //  Analog to Digital Converter
    // -------------------------------------------------------------------------
    ups_ctrl ctrl(
        // ---------------------------------------------------------------------
        //  Clocks and Resets
        // ---------------------------------------------------------------------
        .clk                           (fclk_l),
        .rst_n                         (rst_n_l),

        // ---------------------------------------------------------------------
        //  Parameter Interface
        // ---------------------------------------------------------------------
        .mode                          (data_l[0]),
        .mode_update                   (dv_l[0]),

        .dac_test_data                 (data_l[1][15:0]),
        .dac_test_dv                   (dv_l[1]),

        // ---------------------------------------------------------------------
        //  ADC Interface
        // ---------------------------------------------------------------------
        .adc                           (adc_data_l),
        .adc_dv                        (adc_dv_l),

        // ---------------------------------------------------------------------
        //  DAC Interface
        // ---------------------------------------------------------------------
        .dac                           (dac_data_l),
        .dac_dv                        (dac_dv_l)

    );

    // -------------------------------------------------------------------------
    //  Analog to Digital Converter
    // -------------------------------------------------------------------------
    ups_ad ad(
        // ---------------------------------------------------------------------
        //  Clocks and Resets
        // ---------------------------------------------------------------------
        .clk                           (fclk_l),
        .rst_n                         (rst_n_l),

        // ---------------------------------------------------------------------
        //  Converter Data Interface
        // ---------------------------------------------------------------------
        .data                          (adc_data_l),
        .dv                            (adc_dv_l),

        // ---------------------------------------------------------------------
        //  ADC SPI Interface
        // ---------------------------------------------------------------------
        .sclk                          (adc_sclk),
        .din                           (adc_din),
        .cs_n                          (adc_cs_n)

    );

    // -------------------------------------------------------------------------
    //  ADC ILA
    // -------------------------------------------------------------------------
    adc_ila adc_ila0(
        .clk                           (fclk_l),
        .probe0                        (adc_dv_l),
        .probe1                        (adc_data_l)
    );

    // -------------------------------------------------------------------------
    //  Digital to Analog Converter
    // -------------------------------------------------------------------------
    ups_da da(
        // ---------------------------------------------------------------------
        //  Clocks and Resets
        // ---------------------------------------------------------------------
        .clk                           (fclk_l),
        .rst_n                         (rst_n_l),

        // ---------------------------------------------------------------------
        //  Converter Data Interface
        // ---------------------------------------------------------------------
        .dv                            (dac_dv_l),
        .data                          (dac_data_l),

        // ---------------------------------------------------------------------
        //  DAC SPI Interface
        // ---------------------------------------------------------------------
        .sclk                          (dac_sclk),
        .dout                          (dac_dout),
        .cs_n                          (dac_cs_n)

    );

    // -------------------------------------------------------------------------
    //  Power on Reset
    // -------------------------------------------------------------------------
    ups_por por(
        // ---------------------------------------------------------------------
        //  Clocks
        // ---------------------------------------------------------------------
        .clk                           (fclk_l),

        // ---------------------------------------------------------------------
        //  Power on Reset
        // ---------------------------------------------------------------------
        .por_n                         (rst_n_l)

    );

    // ------------------------------------------------------------------------
    //  Zynq Block Diagram Wrapper
    // ------------------------------------------------------------------------
    ups_zynq_wrapper zynq(
        // --------------------------------------------------------------------
        //  DDR Signals
        // --------------------------------------------------------------------
        .ddr_addr                      (ddr_addr),
        .ddr_ba                        (ddr_ba),
        .ddr_cas_n                     (ddr_cas_n),
        .ddr_ck_n                      (ddr_clk_n),
        .ddr_ck_p                      (ddr_clk),
        .ddr_cke                       (ddr_cke),
        .ddr_cs_n                      (ddr_cs_n),
        .ddr_dm                        (ddr_dm),
        .ddr_dq                        (ddr_dq),
        .ddr_dqs_n                     (ddr_dqs_n),
        .ddr_dqs_p                     (ddr_dqs),
        .ddr_odt                       (ddr_odt),
        .ddr_ras_n                     (ddr_ras_n),
        .ddr_reset_n                   (ddr_reset_n),
        .ddr_we_n                      (ddr_we_n),

        // --------------------------------------------------------------------
        //  DDR Signals
        // --------------------------------------------------------------------
        .ddr_vrn                       (ddr_vrn),
        .ddr_vrp                       (ddr_vrp),
        .mio                           (mio),
        .ps_clk                        (ps_clk),
        .ps_porb                       (ps_porb),
        .ps_srstb                      (ps_srstb),

        // --------------------------------------------------------------------
        //  Output Clock
        // --------------------------------------------------------------------
        .fclk                          (fclk_l),

        // --------------------------------------------------------------------
        //  DDR Signals
        // --------------------------------------------------------------------
        .led                           (led),

        // --------------------------------------------------------------------
        //  AXI4-Lite Signals
        // --------------------------------------------------------------------
        // Address Read Cylce
        .ca4l_araddr                   (ca4l_araddr_l),   // output [31:0]
        .ca4l_arprot                   (),                // output [ 2:0]
        .ca4l_arready                  (ca4l_arready_l),  // input  [ 0:0]
        .ca4l_arvalid                  (ca4l_arvalid_l),  // output [ 0:0]

        // Address Write Cycle
        .ca4l_awaddr                   (ca4l_awaddr_l),   // output [31:0]
        .ca4l_awprot                   (),                // output [ 2:0]
        .ca4l_awready                  (ca4l_awready_l),  // input  [ 0:0]
        .ca4l_awvalid                  (ca4l_awvalid_l),  // output [ 0:0]

        // Response Cycle
        .ca4l_bready                   (ca4l_bready_l),  // output [ 0:0]
        .ca4l_bresp                    (ca4l_bresp_l),   // input  [ 1:0]
        .ca4l_bvalid                   (ca4l_bvalid_l),  // input  [ 0:0]

        // Data Read Cycle
        .ca4l_rdata                    (ca4l_rdata_l),   // input  [31:0]
        .ca4l_rready                   (ca4l_rready_l),  // output [ 0:0]
        .ca4l_rresp                    (ca4l_rresp_l),   // input  [ 1:0]
        .ca4l_rvalid                   (ca4l_rvalid_l),  // input  [ 0:0]

        // Data Write Cycle
        .ca4l_wdata                    (ca4l_wdata_l),   // output [31:0]
        .ca4l_wready                   (ca4l_wready_l),  // input  [ 0:0]
        .ca4l_wstrb                    (ca4l_wstrb_l),   // output [ 3:0]
        .ca4l_wvalid                   (ca4l_wvalid_l)   // output [ 0:0]

    );

    ups_axi axi(
        // ---------------------------------------------------------------------
        //  Clocks and Resets
        // ---------------------------------------------------------------------
        .clk                           (fclk_l),
        .rst_n                         (rst_n_l),

        // ---------------------------------------------------------------------
        //  Register Output
        // ---------------------------------------------------------------------
        .data                          (data_l),
        .dv                            (dv_l),

        // ---------------------------------------------------------------------
        //  AXI4-Lite Interface
        // ---------------------------------------------------------------------
        // Address Read Cylce
        .ca4l_araddr                   (ca4l_araddr_l),  // input  [31:0]
        .ca4l_arready                  (ca4l_arready_l), // output [ 0:0]
        .ca4l_arvalid                  (ca4l_arvalid_l), // input  [ 0:0]

        // Address Write Cycle
        .ca4l_awaddr                   (ca4l_awaddr_l),  // input  [31:0]
        .ca4l_awready                  (ca4l_awready_l), // output [ 0:0]
        .ca4l_awvalid                  (ca4l_awvalid_l), // input  [ 0:0]

        // Response Cycle
        .ca4l_bready                   (ca4l_bready_l), // input  [ 0:0]
        .ca4l_bresp                    (ca4l_bresp_l),  // output [ 1:0]
        .ca4l_bvalid                   (ca4l_bvalid_l), // output [ 0:0]

        // Data Read Cylce
        .ca4l_rdata                    (ca4l_rdata_l),  // output [31:0]
        .ca4l_rready                   (ca4l_rready_l), // input  [ 0:0]
        .ca4l_rresp                    (ca4l_rresp_l),  // output [ 1:0]
        .ca4l_rvalid                   (ca4l_rvalid_l), // output [ 0:0]

        // Data Write Cycle
        .ca4l_wdata                    (ca4l_wdata_l),  // input  [31:0]
        .ca4l_wready                   (ca4l_wready_l), // output [ 0:0]
        .ca4l_wstrb                    (ca4l_wstrb_l),  // input  [ 3:0]
        .ca4l_wvalid                   (ca4l_wvalid_l)  // input  [ 0:0]

    );

endmodule // ups
