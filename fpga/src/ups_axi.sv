// -----------------------------------------------------------------------------
//  File Name   :  ups_axi.sv
//  Autoher     :  Mike DeLong
//  Date        :  03.04.2019
//  Description :  UPS AXI Interface
// -----------------------------------------------------------------------------
module ups_axi#(
    parameter DW                       = 16,                                    // Data Block Size
    parameter DI                       = 4                                      // Data Index Size log2(DW)

) (
    // -------------------------------------------------------------------------
    //  Clocks and Resets
    // -------------------------------------------------------------------------
    input          clk,
    input          rst_n,

    // -------------------------------------------------------------------------
    //  Register Output
    // -------------------------------------------------------------------------
    output [31:0]       data[DW-1:0],
    output [DW-1:0]     dv,

    // -------------------------------------------------------------------------
    //  Register Input
    // -------------------------------------------------------------------------
    input  [31:0]       status,

    // -------------------------------------------------------------------------
    //  AXI4-Lite Interface
    // -------------------------------------------------------------------------
    // Address Read Cylce
    input  [31:0]  ca4l_araddr,
    output [ 0:0]  ca4l_arready,
    input  [ 0:0]  ca4l_arvalid,

    // Address Write Cycle
    input  [31:0]  ca4l_awaddr,
    output [ 0:0]  ca4l_awready,
    input  [ 0:0]  ca4l_awvalid,

    // Response Cycle
    input  [ 0:0]  ca4l_bready,
    output [ 1:0]  ca4l_bresp,
    output [ 0:0]  ca4l_bvalid,

    // Data Read Cylce
    output [31:0]  ca4l_rdata,
    input  [ 0:0]  ca4l_rready,
    output [ 1:0]  ca4l_rresp,
    output [ 0:0]  ca4l_rvalid,

    // Data Write Cycle
    input  [31:0]  ca4l_wdata,
    output [ 0:0]  ca4l_wready,
    input  [ 3:0]  ca4l_wstrb,
    input  [ 0:0]  ca4l_wvalid
);

    // -------------------------------------------------------------------------
    //  Constants
    // -------------------------------------------------------------------------
    const logic [DI-1:0] DW_L = DW-1;

    // -------------------------------------------------------------------------
    //  Typedefs
    // -------------------------------------------------------------------------
    typedef enum logic[5:0] { AXI_AR, AXI_RDEC, AXI_RD } rd_state_t;
    typedef enum logic[5:0] { AXI_AW, AXI_W, AXI_WDEC, AXI_WB } wr_state_t;

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    rd_state_t          rd_state;                                               // Read State Machine Controller
    wr_state_t          wr_state;                                               // Write State Machine Controller

    // AXI4-Lite Read Registers
    logic [31:0]        ar_addr_l;                                              // Address Read Address Register
    logic [31:0]        ar_data_l;                                              // Address Read Data Register

    logic [31:0]        aw_addr_l;                                              // Address Write Address Register
    logic [31:0]        aw_data_l;                                              // Address Write Data Register

    // Internal Pin Logic Registers
    logic [ 0:0]        ca4l_arready_l;
    logic [ 0:0]        ca4l_awready_l;
    logic [ 1:0]        ca4l_bresp_l;
    logic [ 0:0]        ca4l_bvalid_l;
    logic [31:0]        ca4l_rdata_l;
    logic [ 1:0]        ca4l_rresp_l;
    logic [ 0:0]        ca4l_rvalid_l;
    logic [ 0:0]        ca4l_wready_l;

    // Internal Memory
    logic   [31:0]      data_l[DW-1:0];
    logic [DW-1:0]      dv_l;

    // -------------------------------------------------------------------------
    //  Assignment Statements
    // -------------------------------------------------------------------------
    // Pin Assignments
    assign ca4l_arready                = ca4l_arready_l;
    assign ca4l_awready                = ca4l_awready_l;
    assign ca4l_bresp                  = ca4l_bresp_l;
    assign ca4l_bvalid                 = ca4l_bvalid_l;
    assign ca4l_rdata                  = ca4l_rdata_l;
    assign ca4l_rresp                  = ca4l_rresp_l;
    assign ca4l_rvalid                 = ca4l_rvalid_l;
    assign ca4l_wready                 = ca4l_wready_l;

    assign data                        = data_l;
    assign dv                          = dv_l;

    // -------------------------------------------------------------------------
    //  AXI4-Lite Read State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : READ_STATE_MACHINE
        // Sync Reset
        if(rst_n == 1'b0) begin
            rd_state                   <= AXI_AR;

            // Reset AXI Signals
            ca4l_rdata_l               <= 'b0;                                  // Reset Read Data
            ca4l_arready_l             <= 1'b0;                                 // Reset Read Ready
            ca4l_rresp_l               <= 2'b0;                                 // Reset Read Response
            ca4l_rvalid_l              <= 1'b0;                                 // Reset Read Data Valid
            ar_addr_l                  <= 'b0;                                  // Reset Internal AR Address Register
            ar_data_l                  <= 'b0;                                  // Reset Internal AR Data Regsiter

        end else begin

            // -----------------------------------------------------------------
            //  Default Values
            // -----------------------------------------------------------------
            ca4l_arready_l             <= 1'b0;                                 // Normally Not Read Address Ready
            ca4l_rresp_l               <= 2'b0;                                 // Read Response -- 00
            ca4l_rvalid_l              <= 1'b0;                                 // Normally Not Valid

            // -----------------------------------------------------------------
            //  Case Statement
            // -----------------------------------------------------------------
            case(rd_state)

                // -------------------------------------------------------------
                //  AXI_AR State
                //    This state handles the address read portion of the
                //    AXI4-Lite read channel state machine.
                //
                //    arready == 1 && arvalid == 1 ... Register address.
                //
                // -------------------------------------------------------------
                AXI_AR : begin
                    // Indicate Ready for Address
                    ca4l_arready_l     <= 1'b1;                                 // Set Address Read Ready

                    // Wait for RREADY && ARVALID
                    if((ca4l_arready_l == 1'b1) && (ca4l_arvalid == 1'b1)) begin
                        ar_addr_l      <= ca4l_araddr;                          // Register AR-Addr
                        rd_state       <= AXI_RDEC;                             // Next State :: AXI_RDEC
                        ca4l_arready_l <= 1'b0;                                 // Set Address Read Not Ready

                    end
                end

                // -------------------------------------------------------------
                //  AXI_RDEC State
                //    This state handles the address decoding.
                // -------------------------------------------------------------
                AXI_RDEC : begin
                    // Decode Address
                    if(ar_addr_l < 32'd64) begin
                        ar_data_l      <= data_l[ar_addr_l[DI+2-1:2]];

                    // end else if(ar_addr_l == 32'd64) begin
                    //     ar_data_l      <= status;

                    end else begin
                        ar_data_l      <= status;

                    end

                    // Next State
                    rd_state           <= AXI_RD;                               // Next State :: AXI_RD

                end

                // -------------------------------------------------------------
                //  AXI_DR State
                //    This state handles the address decoding.
                // -------------------------------------------------------------
                AXI_RD : begin
                    // Assign Outputs
                    ca4l_rvalid_l      <= 1'b1;                                 // Indicate Read Data Valid
                    ca4l_rdata_l       <= ar_data_l;                            // Assign Read Data to Port

                    // Wait for ARREADY && ARVALID
                    if((ca4l_rvalid_l == 1'b1) && (ca4l_rready == 1'b1)) begin
                        rd_state       <= AXI_AR;                               // Next State :: AXI_AR
                        ca4l_rvalid_l  <= 1'b0;                                 // Indicate Read Data Not Valid

                    end
                end

                // -------------------------------------------------------------
                //  Default State
                // -------------------------------------------------------------
                default : begin
                    // Assign Outputs
                    rd_state           <= AXI_AR;                               // Next State :: AXI_AR

                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    //  AXI4-Lite Write State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : WRITE_STATE_MACHINE
        // Sync Reset
        if(rst_n == 1'b0) begin
            // Reset State
            wr_state                   <= AXI_AW;

            // Reset AXI Signals
            ca4l_awready_l             <= 1'b0;                                 // Normally Not Read Address Ready
            ca4l_wready_l              <= 1'b0;                                 // Normally Not Ready
            ca4l_bvalid_l              <= 1'b0;                                 // Normal Response Not Valid
            ca4l_bresp_l               <= 2'b0;                                 // Reset Response
            aw_data_l                  <= 'b0;                                  // Reset Internal AW Data Register
            aw_addr_l                  <= 'b0;                                  // Reset Internal AW Address Register

        end else begin

            // -----------------------------------------------------------------
            //  Default Values
            // -----------------------------------------------------------------
            ca4l_awready_l             <= 1'b0;                                 // Normally Not Read Address Ready
            ca4l_wready_l              <= 1'b0;                                 // Normally Not Ready
            ca4l_bvalid_l              <= 1'b0;                                 // Normal Response Not Valid
            ca4l_bresp_l               <= 2'b0;                                 // Reset Response
            dv_l                       <= 'b0;                                  // Normally Not Valid

            // -----------------------------------------------------------------
            //  Case Statement
            // -----------------------------------------------------------------
            case(wr_state)

                // -------------------------------------------------------------
                //  AXI_AW State
                //    This state handles the address write portion of the
                //    AXI4-Lite read channel state machine.
                // -------------------------------------------------------------
                AXI_AW : begin
                    // Indicate Ready for Address
                    ca4l_awready_l     <= 1'b1;                                 // Set Address Write Ready

                    // Wait for AWREADY && AWVALID
                    if((ca4l_awready_l == 1'b1) && (ca4l_awvalid == 1'b1)) begin
                        aw_addr_l      <= ca4l_awaddr;                          // Register AW-Addr
                        ca4l_awready_l <= 1'b0;                                 // Set Address Write Not Ready
                        wr_state       <= AXI_W;                                // Next State :: AXI_WDEC

                    end
                end

                // -------------------------------------------------------------
                //  AXI_W State
                //    This state handles the data write portion of the
                //    AXI4-Lite read channel state machine.
                // -------------------------------------------------------------
                AXI_W : begin
                    // Indicate Ready for Address
                    ca4l_wready_l      <= 1'b1;                                 // Set Data Write Ready

                    // Wait for WREADY && WVALID
                    if((ca4l_wready_l == 1'b1) && (ca4l_wvalid == 1'b1)) begin
                        aw_data_l      <= ca4l_wdata;                           // Register AW-Data
                        ca4l_wready_l  <= 1'b0;                                 // Set Data Write Not Ready
                        wr_state       <= AXI_WDEC;                             // Next State :: AXI_WDEC

                    end
                end

                // -------------------------------------------------------------
                //  AXI_WDEC State
                //    This state handles the address decoding.
                // -------------------------------------------------------------
                AXI_WDEC : begin
                    // Write Data to Structure
                    if(aw_addr_l[DI+2-1:2] < DW_L) begin
                        data_l[aw_addr_l[DI+2-1:2]]    <= aw_data_l;
                        dv_l[aw_addr_l[DI+2-1:2]]      <= 1'b1;

                    end

                    // Next State
                    wr_state           <= AXI_WB;                               // Next State :: AXI_WB

                end

                // -------------------------------------------------------------
                //  AXI_WB State
                //    This state handles the BRESP cycle.
                // -------------------------------------------------------------
                AXI_WB : begin
                    // Assign Outputs
                    ca4l_bvalid_l      <= 1'b1;                                 // Indicate BRESP Valid

                    // Wait for BREADY && BVALID
                    if((ca4l_bvalid_l == 1'b1) && (ca4l_bready == 1'b1)) begin
                        wr_state       <= AXI_AW;                               // Next State :: AXI_AW
                        ca4l_bvalid_l  <= 1'b0;                                 // Indicate BRESP Not Valid

                    end
                end

                // -------------------------------------------------------------
                //  Default State
                // -------------------------------------------------------------
                default : begin
                    // Assign Outputs
                    wr_state           <= AXI_AW;                               // Next State :: AXI_AW

                end
            endcase
        end
    end

endmodule
