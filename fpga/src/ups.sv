// -----------------------------------------------------------------------------
//  File Name   :  ups.sv
//  Autoher     :  Mike DeLong
//  Date        :  02.20.2019
//  Description :  UPS Project Top Level
// -----------------------------------------------------------------------------
`define DW 16
`define DI 4
`define NEW_BOARD
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
    //  DAC0 SPI Interface
    // -------------------------------------------------------------------------
    input               vaux1_p,
    input               vaux1_n,

    // -------------------------------------------------------------------------
    //  DAC0 SPI Interface
    // -------------------------------------------------------------------------
    output              dac0_sclk,
    output              dac0_dout,
    output              dac0_cs_n,
    output              dac0_ldac,

    // -------------------------------------------------------------------------
    //  DAC1 SPI Interface
    // -------------------------------------------------------------------------
    output              dac1_sclk,
    output              dac1_dout,
    output              dac1_cs_n,
    output              dac1_ldac,

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
    //  Variables
    // -------------------------------------------------------------------------
    // Clock and Reset
    logic               fclk_l;
    logic               rst_n_l;

    // Address Read Cycle
    logic [31:0]        ca4l_araddr_l;
    logic [ 0:0]        ca4l_arready_l;
    logic [ 0:0]        ca4l_arvalid_l;

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
    logic [31:0]        data_l[`DW-1:0];
    logic [31:0]        status_l;

    // ADC Data
    logic               adc_dv_l;
    logic [11:0]        adc_data_l;

    // DAC0 Data
    logic              dac0_dv_l;
    logic [11:0]       dac0_data_l;

    // DAC0 Data
    logic              dac1_dv_l;
    logic [11:0]       dac1_data_l;

    // DAC SPI Interface Internal Signals
    logic              dac0_sclk_l;
    logic              dac0_dout_l;
    logic              dac0_cs_n_l;
    logic              dac0_ldac_n_l;
    logic              dac0_busy_l;

    logic              dac1_sclk_l;
    logic              dac1_dout_l;
    logic              dac1_cs_n_l;
    logic              dac1_ldac_n_l;
    logic              dac1_busy_l;


    // ADC SPI Interface Internal sSignals
    logic              adc_sclk_l;
    logic              adc_din_l;
    logic              adc_cs_n_l;

    // Valve Pins
    logic              valve_l;

    // -------------------------------------------------------------------------
    //  Assigns
    // -------------------------------------------------------------------------
    assign valve                       = valve_l;                               // Assign Valvle Pin to Internal Sig

    assign dac0_sclk                   = dac0_sclk_l;                           // Assign Internal DAC SCLK to Pin
    assign dac0_dout                   = dac0_dout_l;                           // Assign Internal DAC1 DOUT to Pin
    assign dac0_cs_n                   = dac0_cs_n_l;                           // Assign Internal DAC CS to Pin
    assign dac0_ldac                   = dac0_ldac_n_l;                         // Assign DAC LDAC to Pin

    assign dac1_sclk                   = dac1_sclk_l;                           // Assign Internal DAC SCLK to Pin
    assign dac1_dout                   = dac1_dout_l;                           // Assign Internal DAC1 DOUT to Pin
    assign dac1_cs_n                   = dac1_cs_n_l;                           // Assign Internal DAC CS to Pin
    assign dac1_ldac                   = dac1_ldac_n_l;                         // Assign DAC LDAC to Pin

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
        //  Mode Interface
        // ---------------------------------------------------------------------
        .mode                          (data_l[0]),
        .mode_update                   (dv_l[0]),

        // ---------------------------------------------------------------------
        //  DAC0 Interface
        // ---------------------------------------------------------------------
        .dac0_test_data                (data_l[1][11:0]),
        .dac0_test_dv                  (dv_l[1]),

        // ---------------------------------------------------------------------
        //  DAC1 Interface
        // ---------------------------------------------------------------------
        .dac1_test_data                (data_l[2][11:0]),
        .dac1_test_dv                  (dv_l[2]),

        // ---------------------------------------------------------------------
        //  ADC Interface
        // ---------------------------------------------------------------------
        .adc                           (adc_data_l),
        .adc_dv                        (adc_dv_l),

        // ---------------------------------------------------------------------
        //  DAC General Control
        // ---------------------------------------------------------------------
        .dac0_busy                     (dac0_busy_l),
        .dac1_busy                     (dac1_busy_l),

        // ---------------------------------------------------------------------
        //  DAC0 Interface
        // ---------------------------------------------------------------------
        .dac0                          (dac0_data_l),
        .dac0_dv                       (dac0_dv_l),

        // ---------------------------------------------------------------------
        //  DAC1 Interface
        // ---------------------------------------------------------------------
        .dac1                          (dac1_data_l),
        .dac1_dv                       (dac1_dv_l),

        // ---------------------------------------------------------------------
        //  Pinch Valve Control Interface
        // ---------------------------------------------------------------------
        .pv_test                       (data_l[3][0]),                          // Test Request for Valve Control
        .pv                            (valve_l),                               // Output to Pinch Valve Pin

        // ---------------------------------------------------------------------
        //  Run Mode Interface
        // ---------------------------------------------------------------------
        .run_loops                     (data_l[4][7:0]),
        .run_pre                       (data_l[5][7:0]),
        .run                           (data_l[6][7:0]),
        .run_post                      (data_l[7][7:0]),
        .run_start                     (dv_l[8]),
        .run_stop                      (dv_l[9]),

        // ---------------------------------------------------------------------
        //  Status Interface
        // ---------------------------------------------------------------------
        .status                        (status_l)

    );

    // -------------------------------------------------------------------------
    //  Analog to Digital Converter
    // -------------------------------------------------------------------------
`ifdef NEW_BOARD
    ups_ps ad(
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
        //  Analog Preassure Sensor Input
        // ---------------------------------------------------------------------
        .vaux1_p                       (vaux1_p),
        .vaux1_n                       (vaux1_n)

    );
`else
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
        .sclk                          (adc_sclk_l),
        .din                           (adc_din_l),
        .cs_n                          (adc_cs_n_l)

    );
`endif

`ifndef NEW_BOARD
    // -------------------------------------------------------------------------
    //  ADC ILA
    // -------------------------------------------------------------------------
    adc_ila adc_ila0(
        .clk                           (fclk_l),
        .probe0                        (adc_dv_l),
        .probe1                        (adc_data_l),
        .probe2                        (adc_sclk_l),
        .probe3                        (adc_din_l),
        .probe4                        (adc_cs_n_l)
    );
`endif

    // -------------------------------------------------------------------------
    //  DAC ILA
    // -------------------------------------------------------------------------
    dac_ila dac_ila0(
        .clk                           (fclk_l),
        .probe0                        (dac0_dv_l),
        .probe1                        (dac0_data_l),
        .probe2                        (dac1_dv_l),
        .probe3                        (dac1_data_l),
        .probe4                        (dac1_sclk_l),
        .probe5                        (dac1_dout_l),
        .probe6                        (dac1_cs_n_l),
        .probe7                        (dac1_busy_l),
        .probe8                        (dac1_ldac_n_l),
        .probe9                        (dac0_sclk_l),
        .probe10                       (dac0_dout_l),
        .probe11                       (dac0_cs_n_l),
        .probe12                       (dac0_busy_l),
        .probe13                       (dac0_ldac_n_l)

    );

    // -------------------------------------------------------------------------
    //  Data ILA
    // -------------------------------------------------------------------------
    data_ila data_ila0(
        .clk                           (fclk_l),
        .probe0                        (dv_l),
        .probe1                        (data_l[0]),
        .probe2                        (data_l[1]),
        .probe3                        (data_l[2]),
        .probe4                        (data_l[3]),
        .probe5                        (data_l[4]),
        .probe6                        (data_l[5]),
        .probe7                        (data_l[6]),
        .probe8                        (data_l[7]),
        .probe9                        (data_l[8]),
        .probe10                       (data_l[9])
    );

    // -------------------------------------------------------------------------
    //  Digital to Analog Converter
    // -------------------------------------------------------------------------
`ifdef NEW_BOARD
    ups_da2 da0(
            // -----------------------------------------------------------------
            //  Clocks and Resets
            // -----------------------------------------------------------------
            .clk                           (fclk_l),
            .rst_n                         (rst_n_l),

            // -----------------------------------------------------------------
            //  Converter Data Interface
            // -----------------------------------------------------------------
            .dv                            (dac0_dv_l),
            .data                          (dac0_data_l),

            // -----------------------------------------------------------------
            //  DAC SPI Interface
            // -----------------------------------------------------------------
            .sclk                          (dac0_sclk_l),
            .dout                          (dac0_dout_l),
            .cs_n                          (dac0_cs_n_l),
            .ldac_n                        (dac0_ldac_n_l),
            .busy                          (dac0_busy_l)
        );

    ups_da2 da1(
            // -----------------------------------------------------------------
            //  Clocks and Resets
            // -----------------------------------------------------------------
            .clk                           (fclk_l),
            .rst_n                         (rst_n_l),

            // -----------------------------------------------------------------
            //  Converter Data Interface
            // -----------------------------------------------------------------
            .dv                            (dac1_dv_l),
            .data                          (dac1_data_l),

            // -----------------------------------------------------------------
            //  DAC SPI Interface
            // -----------------------------------------------------------------
            .sclk                          (dac1_sclk_l),
            .dout                          (dac1_dout_l),
            .cs_n                          (dac1_cs_n_l),
            .ldac_n                        (dac1_ldac_n_l),
            .busy                          (dac1_busy_l)
        );
`else
    ups_da da(
        // ---------------------------------------------------------------------
        //  Clocks and Resets
        // ---------------------------------------------------------------------
        .clk                           (fclk_l),
        .rst_n                         (rst_n_l),

        // ---------------------------------------------------------------------
        //  Converter0 Data Interface
        // ---------------------------------------------------------------------
        .dv0                           (dac0_dv_l),
        .data0                         (dac0_data_l),

        // ---------------------------------------------------------------------
        //  Converter0 Data Interface
        // ---------------------------------------------------------------------
        .dv1                           (dac1_dv_l),
        .data1                         (dac1_data_l),

        // ---------------------------------------------------------------------
        //  DAC SPI Interface
        // ---------------------------------------------------------------------
        .sclk                          (dac_sclk_l),
        .dout0                         (dac_dout0_l),
        .dout1                         (dac_dout1_l),
        .cs_n                          (dac_cs_n_l),
        .busy                          (dac_busy_l)
    );
`endif

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

        // -------------------------------------------------------------------------
        //  Register Input
        // -------------------------------------------------------------------------
        .status                        (status_l),

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
