// ----------------------------------------------------------------------------
//  File Name   :  ups_zynq_wrapper.sv
//  Autoher     :  Mike DeLong
//  Date        :  02.20.2019
//  Description :  UPS Zynq Wrapper
// ----------------------------------------------------------------------------
module ups_zynq_wrapper(
    // ------------------------------------------------------------------------
    //  DDR Signals
    // ------------------------------------------------------------------------
    inout  [14:0]  ddr_addr,
    inout  [ 2:0]  ddr_ba,
    inout          ddr_cas_n,
    inout          ddr_ck_n,
    inout          ddr_ck_p,
    inout          ddr_cke,
    inout          ddr_cs_n,
    inout  [ 3:0]  ddr_dm,
    inout  [31:0]  ddr_dq,
    inout  [ 3:0]  ddr_dqs_n,
    inout  [ 3:0]  ddr_dqs_p,
    inout          ddr_odt,
    inout          ddr_ras_n,
    inout          ddr_reset_n,
    inout          ddr_we_n,

    // ------------------------------------------------------------------------
    //  Zynq Fixed IO
    // ------------------------------------------------------------------------
    inout          ddr_vrn,
    inout          ddr_vrp,
    inout  [53:0]  mio,
    inout          ps_clk,
    inout          ps_porb,
    inout          ps_srstb,

    // ------------------------------------------------------------------------
    //  Output Clock
    // ------------------------------------------------------------------------
    output         fclk,

    // ------------------------------------------------------------------------
    //  LED GPIO Outputs
    // ------------------------------------------------------------------------
    output [ 3:0]  led,

    // ------------------------------------------------------------------------
    //  PMOD Interface
    // ------------------------------------------------------------------------
    // Address Read Cycle
    output [31:0]  ca4l_araddr,
    output [ 2:0]  ca4l_arprot,
    input  [ 0:0]  ca4l_arready,
    output [ 0:0]  ca4l_arvalid,

    // Address Read Cycle
    output [31:0]  ca4l_awaddr,
    output [ 2:0]  ca4l_awprot,
    input  [ 0:0]  ca4l_awready,
    output [ 0:0]  ca4l_awvalid,

    // Response Cylce
    output [ 0:0]  ca4l_bready,
    input  [ 1:0]  ca4l_bresp,
    input  [ 0:0]  ca4l_bvalid,

    // Data Read Cycle
    input  [31:0]  ca4l_rdata,
    output [ 0:0]  ca4l_rready,
    input  [ 1:0]  ca4l_rresp,
    input  [ 0:0]  ca4l_rvalid,

    // Data Write Cycle
    output [31:0]  ca4l_wdata,
    input  [ 0:0]  ca4l_wready,
    output [ 3:0]  ca4l_wstrb,
    output [ 0:0]  ca4l_wvalid
);

    // ------------------------------------------------------------------------
    //  Zynq Block Diagram Wrapper
    // ------------------------------------------------------------------------
    ups_zynq upz_zynq_instance(
        .DDR_addr                      (ddr_addr),
        .DDR_ba                        (ddr_ba),
        .DDR_cas_n                     (ddr_cas_n),
        .DDR_ck_n                      (ddr_ck_n),
        .DDR_ck_p                      (ddr_ck_p),
        .DDR_cke                       (ddr_cke),
        .DDR_cs_n                      (ddr_cs_n),
        .DDR_dm                        (ddr_dm),
        .DDR_dq                        (ddr_dq),
        .DDR_dqs_n                     (ddr_dqs_n),
        .DDR_dqs_p                     (ddr_dqs_p),
        .DDR_odt                       (ddr_odt),
        .DDR_ras_n                     (ddr_ras_n),
        .DDR_reset_n                   (ddr_reset_n),
        .DDR_we_n                      (ddr_we_n),
        .FIXED_IO_ddr_vrn              (ddr_vrn),
        .FIXED_IO_ddr_vrp              (ddr_vrp),
        .FIXED_IO_mio                  (mio),
        .FIXED_IO_ps_clk               (ps_clk),
        .FIXED_IO_ps_porb              (ps_porb),
        .FIXED_IO_ps_srstb             (ps_srstb),
        .fclk                          (fclk),
        .gpio_rtl_tri_o                (led),
        .ca4l_araddr                   (ca4l_araddr),
        .ca4l_arprot                   (ca4l_arprot),
        .ca4l_arready                  (ca4l_arready),
        .ca4l_arvalid                  (ca4l_arvalid),
        .ca4l_awaddr                   (ca4l_awaddr),
        .ca4l_awprot                   (ca4l_awprot),
        .ca4l_awready                  (ca4l_awready),
        .ca4l_awvalid                  (ca4l_awvalid),
        .ca4l_bready                   (ca4l_bready),
        .ca4l_bresp                    (ca4l_bresp),
        .ca4l_bvalid                   (ca4l_bvalid),
        .ca4l_rdata                    (ca4l_rdata),
        .ca4l_rready                   (ca4l_rready),
        .ca4l_rresp                    (ca4l_rresp),
        .ca4l_rvalid                   (ca4l_rvalid),
        .ca4l_wdata                    (ca4l_wdata),
        .ca4l_wready                   (ca4l_wready),
        .ca4l_wstrb                    (ca4l_wstrb),
        .ca4l_wvalid                   (ca4l_wvalid)
    );

endmodule
