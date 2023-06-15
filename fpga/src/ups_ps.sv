// -----------------------------------------------------------------------------
//  File Name   :  ups_ps.sv
//  Autoher     :  Mike DeLong
//  Date        :  04.10.2022
//  Description :  UPS ADC utilinzing the FPGA XADC connected to the preassure
//                 sensor.
// -----------------------------------------------------------------------------
module ups_ps(
    // -------------------------------------------------------------------------
    //  Clocks and Resets
    // -------------------------------------------------------------------------
    input          clk,
    input          rst_n,

    // -------------------------------------------------------------------------
    //  Converter Data Interface
    // -------------------------------------------------------------------------
    output  [11:0] data,
    output         dv,

    // -------------------------------------------------------------------------
    //  Analog Preassure Sensor Input
    // -------------------------------------------------------------------------
    input          vaux1_p,
    input          vaux1_n

);

    // -------------------------------------------------------------------------
    //  Typedefs
    // -------------------------------------------------------------------------
    typedef enum logic[5:0] {
                             INIT,              // 0
                             RD_ISSUE,          // 1
                             RD_WAIT,           // 2
                             WAIT0,             // 3
                             WR_ISSUE,          // 4
                             WR_WAIT,           // 5
                             WAIT1,             // 6
                             RD_BACK_ISSUE,     // 7
                             RD_BACK_WAIT,      // 8
                             RUN                // 9
                            } startup_t;

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    logic          rst_l;
    logic          busy_l;
    logic  [ 4:0]  cout_l;
    logic          eoc_l;
    logic  [15:0]  data_l;
    logic          dv_l;

    // DRP Signals
    logic          drp_den_l;
    logic          drp_wen_l;
    logic          drp_rdy_l;
    logic  [ 6:0]  drp_addr_l;
    logic  [15:0]  drp_di_l;
    logic  [15:0]  drp_do_l;
    logic          drp_rdy_d_l;
    logic          drp_rdy_fed_l;

    // Configuration Registers
    logic [0:10][15:0] drp_setup_data_l = { 16'h0011, 16'h31AF, 16'h0400, 16'h0100, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000 };
    // logic [0:10][15:0] drp_setup_data_l = { 16'h1111, 16'h22AF, 16'h3300, 16'h4400, 16'h5500, 16'h6600, 16'h7700, 16'h8800, 16'h9900, 16'hAA00, 16'hBB00 };
    logic [0:10][ 6:0] drp_setup_addr_l = {    7'h40,    7'h41,    7'h42,    7'h48,    7'h49,    7'h4A,    7'h4B,    7'h4C,    7'h4D,    7'h4E,    7'h4F };
    logic [11:0]       cnt_l;

    // Init State Machine Logic
    startup_t      state;

    // -------------------------------------------------------------------------
    //  Assigns
    // -------------------------------------------------------------------------
    assign rst_l                       = ~rst_n;                                // Reset Inversion
    assign data                        = data_l[15:4];                          // Slice XADC Output Data
    assign dv                          = dv_l;                                  // Block ADC Output Valid

    // -------------------------------------------------------------------------
    //  FPGA PS ILA
    // -------------------------------------------------------------------------
    ups_ps_ila ila(
        .clk                           (clk),
        .probe0                        (rst_l),                                 //  1 Bit(s)
        .probe1                        (busy_l),                                //  1 Bit(s)
        .probe2                        (eoc_l),                                 //  1 Bit(s)
        .probe3                        (cout_l),                                //  5 Bit(s)
        .probe4                        (drp_do_l),                              // 16 Bit(s)
        .probe5                        (drp_den_l),                             //  1 Bit(s)
        .probe6                        (drp_rdy_l),                             //  1 Bit(s)
        .probe7                        (drp_addr_l),                            //  7 Bit(s)
        .probe8                        (drp_wen_l),                             //  1 Bit(s)
        .probe9                        (drp_di_l)                               // 16 Bit(s)
        // .probe10                       (state),                                 //  6 Bit(s)
        // .probe11                       (drp_rdy_d_l),                           //  1 Bit(s)
        // .probe12                       (drp_rdy_fed_l)                          //  1 Bit(s)
    );

    // -------------------------------------------------------------------------
    //  Startup Controller and Data Read from XADC Controller
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : XADC_IFACE
        if(rst_n == 1'b0) begin
            // Reset DRP Signals
            drp_den_l                  <=  1'b0;
            drp_addr_l                 <=  7'h0;
            drp_di_l                   <= 16'h0;

            // DRP Ready Delay Register
            drp_rdy_d_l                <=  1'b0;
            drp_rdy_fed_l              <=  1'b0;

            // State Control Variable
            state                      <= INIT;

        end else begin

            // Default Values
            drp_den_l                  <= 1'b0;
            drp_wen_l                  <= 1'b0;
            drp_rdy_d_l                <= drp_rdy_l;

            // DRP Ready Falling Edge Detection
            drp_rdy_fed_l              <= drp_rdy_d_l & (~drp_rdy_l);

            case(state)

                // -------------------------------------------------------------
                //  INIT State
                //    This state is the starting point for the XADC block.
                //
                // -------------------------------------------------------------
                INIT : begin
                    // Reset XADC DRP Signals
                    drp_den_l          <=  1'b0;
                    drp_addr_l         <=  7'h40;
                    drp_di_l           <= 16'h0;
                    drp_wen_l          <=  1'b0;
                    cnt_l              <= 12'h0;

                    // Next State :: RD
                    state              <= RD_ISSUE;

                end

                // -------------------------------------------------------------
                //  RD_ISSUE State
                //    This state, a DRP read is issued.
                //
                // -------------------------------------------------------------
                RD_ISSUE : begin

                    // Issue Read
                    if(drp_addr_l < 7'h50) begin
                        // Set DRP Read and Data Enable
                        drp_den_l      <= 1'b1;                                 // Set Data Enable to Read

                        // Next State
                        state          <= RD_WAIT;

                    end else begin
                        // Done Reading, Reset Data Enable and Address
                        drp_addr_l     <= 7'h40;

                        // Next State :: RUN
                        state          <= WAIT0;

                    end
                end

                // -------------------------------------------------------------
                //  RD_WAIT State
                //    This state, a DRP ready return to zero.
                //
                // -------------------------------------------------------------
                RD_WAIT : begin

                    // Wait for Falling Edge
                    if (drp_rdy_fed_l == 1'b1) begin
                        // Increment Address
                        drp_addr_l     <= drp_addr_l + 7'h1;

                        // Return to Issue State
                        state          <= RD_ISSUE;

                    end
                end

                // -------------------------------------------------------------
                //  WAIT0 State
                //    This state, we wait for the reads to clear out.
                //
                // -------------------------------------------------------------
                WAIT0 : begin
                    if(cnt_l < 16) begin
                        cnt_l          <= cnt_l + 12'h1;

                    end else begin
                        cnt_l          <= 12'h0;
                        state          <= WR_ISSUE;

                    end
                end


                // -------------------------------------------------------------
                //  WR_ISSUE State
                //    This state, a DRP write is issued.
                //
                // -------------------------------------------------------------
                WR_ISSUE : begin

                    // Write Processing
                    if (cnt_l < 4'd11) begin
                        // Set DRP Write Enable, Data Enable, Address and Data
                        drp_wen_l      <= 1'b1;                                 // Set Data Write Enable
                        drp_den_l      <= 1'b1;                                 // Set Data Enable
                        drp_addr_l     <= drp_setup_addr_l[cnt_l];              // Register Address
                        drp_di_l       <= drp_setup_data_l[cnt_l];              // Register Data

                        // Increment DRP Setup Counter
                        cnt_l          <= cnt_l + 12'h1;

                        // Go To Write Wait State
                        state          <= WR_WAIT;

                    end else begin
                        // Done Reading, Reset Write Enable and Address
                        drp_addr_l     <= 7'h40;
                        cnt_l          <= 12'h0;

                        // Next State :: RUN
                        state          <= WAIT1;

                    end
                end

                // -------------------------------------------------------------
                //  WR_WAIT State
                //    This state, a DRP ready return to zero.
                //
                // -------------------------------------------------------------
                WR_WAIT : begin

                    // On DRP Ready Falling Edge, Return to WR_ISSUE
                    if (drp_rdy_fed_l == 1'b1) begin
                        state          <= WR_ISSUE;

                    end
                end

                // -------------------------------------------------------------
                //  WAIT1 State
                //    This state, we wait for the writes to clear out.
                //
                // -------------------------------------------------------------
                WAIT1 : begin
                    if(cnt_l < 16) begin
                        cnt_l          <= cnt_l + 12'h1;

                    end else begin
                        cnt_l          <= 12'h0;
                        state          <= RD_BACK_ISSUE;

                    end
                end

                // -------------------------------------------------------------
                //  RD_BACK_ISSUE State
                //
                // -------------------------------------------------------------
                RD_BACK_ISSUE : begin

                    // Read Out All Registers
                    if(drp_addr_l < 7'h50) begin
                        // Set DRP Read
                        drp_den_l      <= 1'b1;                                 // Set Data Enable to Read

                        // Go To Read Back Wait State
                        state          <= RD_BACK_WAIT;

                    end else begin
                        // Done Reading, Reset Data Enable and Address
                        drp_addr_l     <= 7'h40;

                        // Next State :: RUN
                        state          <= RUN;

                    end
                end

                // -------------------------------------------------------------
                //  RD_BACK_WAIT State
                //
                // -------------------------------------------------------------
                RD_BACK_WAIT : begin

                    // Wait for Falling Edge Pulse
                    if (drp_rdy_fed_l == 1'b1) begin
                        // Increment Address
                        drp_addr_l     <= drp_addr_l + 7'h1;

                        // Return to Issue State
                        state          <= RD_BACK_ISSUE;

                    end
                end

                // -------------------------------------------------------------
                //  RUN State
                //    This state, normal XADC Opertion is Happening.
                //
                // -------------------------------------------------------------
                RUN : begin
                    if(eoc_l == 1'b1) begin
                        // Register Channel into Address
                        drp_addr_l        <= {2'b00, cout_l};

                        // Issue Read Enable
                        drp_den_l              <= 1'b1;

                    end
                end

                default : begin
                    state              <= INIT;

                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    //  ADC Data Block Output
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : ADC_OUTPUT
        if(rst_n == 1'b0) begin
            // Internal Read Signals
            dv_l                       <=  1'b0;
            data_l                     <= 16'h0;

        end else begin

            // Default Values
            dv_l                       <= 1'b0;

            if(drp_rdy_l == 1'b1) begin
                // Register Data Output
                data_l         <= drp_do_l;

                // Issue Read Enable
                dv_l           <= 1'b1;

           end
        end
    end

    // -------------------------------------------------------------------------
    //  FPGA XADC Primative
    // -------------------------------------------------------------------------
    ups_xadc ps(
        .daddr_in                      (drp_addr_l),                            // Address Bus for DRP
        .dclk_in                       (clk),                                   // Clock for DRP
        .den_in                        (drp_den_l),                             // Enable for DRP
        .di_in                         (drp_di_l),                              // Input Data Bus for DRP
        .dwe_in                        (drp_wen_l),                             // Write Enable for DRP
        .reset_in                      (rst_l),                                 // Reset signal for the System Monitor control logic
        .vauxp1                        (vaux1_p),                               // Auxiliary channel 1
        .vauxn1                        (vaux1_n),
        .busy_out                      (busy_l),                                // ADC Busy signal
        .channel_out                   (cout_l),                                // Channel Selection Outputs
        .do_out                        (drp_do_l),                              // Output Data Bus for DRP
        .drdy_out                      (drp_rdy_l),                             // Data Ready for DRP
        .eoc_out                       (eoc_l),                                 // End of Conversion Signal
        .eos_out                       (),                                      // End of Sequence Signal
        .alarm_out                     (),                                      // OR'ed output of all the Alarms
        .vp_in                         (1'b0),                                  // Dedicated Analog Input Pair
        .vn_in                         (1'b0)
    );

endmodule // ups_ps
