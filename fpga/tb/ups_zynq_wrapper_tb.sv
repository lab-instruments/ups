// -----------------------------------------------------------------------------
//  File Name   :  ups_zynq_wrapper.sv
//  Autoher     :  Mike DeLong
//  Date        :  02.20.2019
//  Description :  UPS Zynq Wrapper Testbench
// -----------------------------------------------------------------------------
module ups_zynq_wrapper(
    // -------------------------------------------------------------------------
    //  DDR Signals
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    //  Zynq Fixed IO
    // -------------------------------------------------------------------------
    inout          ddr_vrn,
    inout          ddr_vrp,
    inout  [53:0]  mio,
    inout          ps_clk,
    inout          ps_porb,
    inout          ps_srstb,

    // -------------------------------------------------------------------------
    //  Output Clock
    // -------------------------------------------------------------------------
    output         fclk,

    // ------------------------------------------------------------------------
    //  LED GPIO Outputs
    // ------------------------------------------------------------------------
    output [ 3:0]  led,

    // -------------------------------------------------------------------------
    //  PMOD Interface
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    //  Varibles
    // -------------------------------------------------------------------------
    logic fclk_l;

    // -------------------------------------------------------------------------
    //  PMOD Interface
    // -------------------------------------------------------------------------
    // Address Read Cycle
    logic [31:0]  ca4l_araddr_l;
    logic [ 2:0]  ca4l_arprot_l;
    logic [ 0:0]  ca4l_arvalid_l;

    // Address Read Cycle
    logic [31:0]  ca4l_awaddr_l;
    logic [ 2:0]  ca4l_awprot_l;
    logic [ 0:0]  ca4l_awvalid_l;

    // Response Cylce
    logic [ 0:0]  ca4l_bready_l;

    // Data Read Cycle
    logic [ 0:0]  ca4l_rready_l;

    // Data Write Cycle
    logic [31:0]  ca4l_wdata_l;
    logic [ 3:0]  ca4l_wstrb_l;
    logic [ 0:0]  ca4l_wvalid_l;

    // -------------------------------------------------------------------------
    //  DDR and MIO Assigns
    assign ddr_addr                    = 'b0;
    assign ddr_ba                      = 'b0;
    assign ddr_cas_n                   = 'b0;
    assign ddr_ck_n                    = 'b0;
    assign ddr_ck_p                    = 'b0;
    assign ddr_cke                     = 'b0;
    assign ddr_cs_n                    = 'b0;
    assign ddr_dm                      = 'b0;
    assign ddr_dq                      = 'b0;
    assign ddr_dqs_n                   = 'b0;
    assign ddr_dqs_p                   = 'b0;
    assign ddr_odt                     = 'b0;
    assign ddr_ras_n                   = 'b0;
    assign ddr_reset_n                 = 'b0;
    assign ddr_we_n                    = 'b0;
    assign ddr_vrn                     = 'b0;
    assign ddr_vrp                     = 'b0;
    assign mio                         = 'b0;
    assign ps_clk                      = 'b0;
    assign ps_porb                     = 'b0;
    assign ps_srstb                    = 'b0;
    assign led                         = 'b0;

    // -------------------------------------------------------------------------
    //  Assigns
    // -------------------------------------------------------------------------
    assign fclk                        = fclk_l;

    // -------------------------------------------------------------------------
    //  Tie Off Unused Signals
    // -------------------------------------------------------------------------
    assign ddr_addr                    = 'b0;
    assign ddr_ba                      = 'b0;
    assign ddr_cas_n                   = 'b0;
    assign ddr_ck_n                    = 'b0;
    assign ddr_ck_p                    = 'b0;
    assign ddr_cke                     = 'b0;
    assign ddr_cs_n                    = 'b0;
    assign ddr_dm                      = 'b0;
    assign ddr_dq                      = 'b0;
    assign ddr_dqs_n                   = 'b0;
    assign ddr_dqs_p                   = 'b0;
    assign ddr_odt                     = 'b0;
    assign ddr_ras_n                   = 'b0;
    assign ddr_reset_n                 = 'b0;
    assign ddr_we_n                    = 'b0;
    assign ddr_vrn                     = 'b0;
    assign ddr_vrp                     = 'b0;
    assign mio                         = 'b0;
    assign ps_clk                      = 'b0;
    assign ps_porb                     = 'b0;
    assign ps_srstb                    = 'b0;

    // -------------------------------------------------------------------------
    //  Assign AXI4-Lite Assigns
    // -------------------------------------------------------------------------
    // Address Read Cycle
    assign ca4l_araddr                 = ca4l_araddr_l;
    assign ca4l_arprot                 = ca4l_arprot_l;
    assign ca4l_arvalid                = ca4l_arvalid_l;

    // Address Read Cycle
    assign ca4l_awaddr                 = ca4l_awaddr_l;
    assign ca4l_awprot                 = ca4l_awprot_l;
    assign ca4l_awvalid                = ca4l_awvalid_l;

    // Response Cylce
    assign ca4l_bready                 = ca4l_bready_l;

    // Data Read Cycle
    assign ca4l_rready                 = ca4l_rready_l;

    // Data Write Cycle
    assign ca4l_wdata                  = ca4l_wdata_l;
    assign ca4l_wstrb                  = ca4l_wstrb_l;
    assign ca4l_wvalid                 = ca4l_wvalid_l;

    // -------------------------------------------------------------------------
    //  Clock Generator
    // -------------------------------------------------------------------------
    initial begin : POR
        fclk_l                         = 1'b0;

    end

    always begin : TB_CLK_GENERATOR
        #5 fclk_l                      = !fclk_l;

    end

    // -------------------------------------------------------------------------
    //  AXI4-Lite Inits
    // -------------------------------------------------------------------------
    initial begin : AXI4L
        // Address Read Cycle
        ca4l_araddr_l                  = 'b0;
        ca4l_arprot_l                  = 'b0;
        ca4l_arvalid_l                 = 'b0;

        // Address Read Cycle
        ca4l_awaddr_l                  = 'b0;
        ca4l_awprot_l                  = 'b0;
        ca4l_awvalid_l                 = 'b0;

        // Response Cylce
        ca4l_bready_l                  = 'b0;

        // Data Read Cycle
        ca4l_rready_l                  = 'b0;

        // Data Write Cycle
        ca4l_wdata_l                   = 'b0;
        ca4l_wstrb_l                   = 'b0;
        ca4l_wvalid_l                  = 'b0;

    end

    // -------------------------------------------------------------------------
    //  AXI4-Lite Test
    // -------------------------------------------------------------------------
    initial begin : AXI4L_TEST
        #3000;
        axi4l_write(32'h0, 32'h2);     // Set Mode to 2 {DEBUG}

        #150;
        axi4l_read(32'h0);             // Read Mode

        #150;
        axi4l_write(32'h4, 32'h800);   // Set DAC0 to 0x800

        #2000;
        axi4l_read(32'h4);             // Read DAC0

        #150;
        axi4l_write(32'h8, 32'hC00);   // Set DAC1 to 0xC00

        #150;
        axi4l_write(32'hC, 32'h1);     // Set Valve to On

        #150;
        axi4l_write(32'hC, 32'h0);     // Set Valve to Off

        #1000;
        axi4l_write(32'h0, 32'h3);     // Set Mode to 3 {RUN}
        axi4l_write(32'h10, 32'h2);    // Set Loops
        axi4l_write(32'h14, 32'h2);    // Set Pre Count to 2
        axi4l_write(32'h18, 32'h1);    // Set Run Count to 1
        axi4l_write(32'h1C, 32'h3);    // Set Post Count to 3
        #10
        axi4l_write(32'h20, 32'h0);    // Hit Start Strobe

        #20000000
        axi4l_write(32'h20, 32'h0);    // Hit Start Strobe
        #100
        axi4l_read(32'h40);            // Read Status
        #2000000
        axi4l_write(32'h24, 32'h0);    // Hit Stop Strobe
        #100
        axi4l_read(32'h40);            // Read Status
        // #20000
        // axi4l_write(32'h20, 32'h0);    // Hit Start Strobe


    end

task automatic axi4l_read;
    input [31:0] addr;
    begin

        @(posedge fclk_l);
        ca4l_araddr_l                  <= addr;
        ca4l_arvalid_l                 <= 1'b1;

        // Check for ARREADY
        while(ca4l_arready == 1'b0) begin
            #1;
        end
        @(posedge fclk_l);
        ca4l_arvalid_l                 <= 1'b0;
        ca4l_rready_l                  <= 1'b1;

        // Check for RREADY
        while(ca4l_rvalid == 1'b0) begin
            #1;
        end
        @(posedge fclk_l);
        ca4l_rready_l                  <= 1'b0;

        // Display Data
        $display("AXI4-Lite RD :  ADDR:0x%08X ---> DATA:0x%08X", addr, ca4l_rdata);

        @(posedge fclk_l);
        @(posedge fclk_l);

    end
endtask

task automatic axi4l_write;
    input [31:0] addr;
    input [31:0] data;
    begin

        @(posedge fclk_l);
        ca4l_awaddr_l                  <= addr;
        ca4l_awvalid_l                 <= 1'b1;

        // Check for AWREADY
        while(ca4l_awready == 1'b0) begin
            #1;
        end
        @(posedge fclk_l);
        ca4l_awvalid_l                 <= 1'b0;
        ca4l_wdata_l                   <= data;
        ca4l_wvalid_l                  <= 1'b1;

        // Check for WREADY
        while(ca4l_wready == 1'b0) begin
            #1;
        end
        @(posedge fclk_l);
        ca4l_wvalid_l                  <= 1'b0;
        ca4l_bready_l                  <= 1'b1;

        // Check for BREADY
        while(ca4l_bvalid == 1'b0) begin
            #1;
        end
        @(posedge fclk_l);
        ca4l_bready_l                  <= 1'b0;

        // Display Data
        $display("AXI4-Lite WR :  DATA:0x%08X ---> ADDR:0x%08X  ", data, addr);

        @(posedge fclk_l);
        @(posedge fclk_l);

    end
endtask

endmodule
