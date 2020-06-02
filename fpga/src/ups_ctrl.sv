// -----------------------------------------------------------------------------
//  File Name   :  ups_ctrl.sv
//  Autoher     :  Mike DeLong
//  Date        :  03.19.2019
//  Description :  UPS Controller
// -----------------------------------------------------------------------------
module ups_ctrl(
    // -------------------------------------------------------------------------
    //  Clocks and Resets
    // -------------------------------------------------------------------------
    input          clk,
    input          rst_n,

    // -------------------------------------------------------------------------
    //  Mode Interface
    // -------------------------------------------------------------------------
    input  [31:0]  mode,
    input          mode_update,

    // -------------------------------------------------------------------------
    //  DAC0 Interface
    // -------------------------------------------------------------------------
    input  [11:0]  dac0_test_data,
    input          dac0_test_dv,

    // -------------------------------------------------------------------------
    //  DAC1 Interface
    // -------------------------------------------------------------------------
    input  [11:0]  dac1_test_data,
    input          dac1_test_dv,

    // -------------------------------------------------------------------------
    //  ADC Interface
    // -------------------------------------------------------------------------
    input  [11:0]  adc,
    input          adc_dv,

    // -------------------------------------------------------------------------
    //  DAC0 Interface
    // -------------------------------------------------------------------------
    output [11:0]  dac0,
    output         dac0_dv,

    // -------------------------------------------------------------------------
    //  DAC1 Interface
    // -------------------------------------------------------------------------
    output [11:0]  dac1,
    output         dac1_dv,

    // -------------------------------------------------------------------------
    //  Pinch Valve Control Interface
    // -------------------------------------------------------------------------
    input          pv_test,
    output         pv,

    // -------------------------------------------------------------------------
    //  Run Mode Interface
    // -------------------------------------------------------------------------
    input  [ 7:0]  run_loops,
    input  [ 7:0]  run_pre,
    input  [ 7:0]  run,
    input  [ 7:0]  run_post,
    input          run_start,
    input          run_stop,

    // -------------------------------------------------------------------------
    //  Status Interface
    // -------------------------------------------------------------------------
    output [31:0]  status

);

    // -------------------------------------------------------------------------
    //  Typedefs
    // -------------------------------------------------------------------------
    typedef enum logic[5:0] {
                             // Idle State
                             CTRL_IDLE,

                             // Test States
                             CTRL_TEST_LB,
                             CTRL_TEST_DAC,
                             CTRL_TEST_CONV,

                             // Normal Run States
                             CTRL_RUN_INIT,
                             CTRL_RUN_IDLE,
                             CTRL_RUN_PRE_PULSE,
                             CTRL_RUN_PULSE,
                             CTRL_RUN_POST_PULSE

                            } state_t;

    // -------------------------------------------------------------------------
    //  Assigns
    // -------------------------------------------------------------------------
    assign dac0                        = dac0_l;                                // Assign Data to DAC0
    assign dac0_dv                     = dac0_dv_l;                             // Assign Data Valid to DAC0
    assign dac1                        = dac1_l;                                // Assign Data to DAC1
    assign dac1_dv                     = dac1_dv_l;                             // Assign Data Valid to DAC1
    assign pv                          = pv_l;                                  // Assign PV Value to PV
    assign status                      = status_l;                              // Assign Status Value to Status

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    // State Variable
    state_t state;

    // State Machine Reset
    logic          sm_rst_n;

    // DAC Constant Values
    const logic [11:0] TWO_VOLT = 12'h9B2;
    const logic [11:0] ONE_VOLT = 12'h505;
    const logic [31:0] HUND_MIL = 32'd100000000;
    // const logic [31:0] HUND_MIL = 32'd100000;

    // DAC0 Internal Registers
    logic [11:0]   dac0_l;
    logic          dac0_dv_l;

    // DAC1 Internal Registers
    logic [11:0]   dac1_l;
    logic          dac1_dv_l;

    // Conversion Constant
    logic [31:0]   conv_c = 32'h9B2; // (2/3.3 * 4096)

    // Conversion Registers
    logic [ 2:0]   adc_dv_sr_l;
    logic [11:0]   adc_conv_data_l;
    logic          adc_conv_dv_l;
    logic [31:0]   adc_conv_int_l;
    logic [11:0]   adc_reg_l;

    // Run Mode Control Registers
    logic [31:0]   run_pre_cnt_l;
    logic [31:0]   run_pls_cnt_l;
    logic [31:0]   run_post_cnt_l;
    logic [31:0]   run_loop_l;
    logic [31:0]   run_cnt_l;

    // Pinch Valve Internal Signal
    logic          pv_l;

    // Current Status
    logic [31:0]   status_l;

    // -------------------------------------------------------------------------
    //  Look for Mode Change
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : MODE_CHANGE_DETECTION
        // Sync Reset
        if(rst_n == 1'b0) begin
            sm_rst_n                   <= 1'b0;

        end else begin
            if(mode_update == 1'b1) begin
                sm_rst_n               <= 1'b0;

            end else begin
                sm_rst_n               <= 1'b1;

            end
        end
    end

    // -------------------------------------------------------------------------
    //  Convert from 12-bit 0-3.3V Full Scale to 16-bit 1V/PSI
    //    1. Multiply ADC Value by 0x3333 {12.8 * 1024}.
    //    2. Bit Slice to Divide by 1024.
    //    3. Register and Indicate Value
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : ADC_DATA_CONVERTER
        // Sync Reset
        if(rst_n == 1'b0) begin
            adc_dv_sr_l                <= 'b0;                                  // Reset Shift Register
            adc_conv_data_l            <= 'b0;                                  // Reset Converted Data Reg
            adc_conv_dv_l              <= 'b0;                                  // Reset Converted Data Valid
            adc_conv_int_l             <= 'b0;                                  // Reset Intermediate Data
            adc_reg_l                  <= 'b0;                                  // Reset ADC Data Register

        end else begin

            // -----------------------------------------------------------------
            //  Shift Register
            // -----------------------------------------------------------------
            adc_dv_sr_l[2:1]           <= adc_dv_sr_l[1:0];                     // Shift!
            adc_dv_sr_l[0]             <= adc_dv;                               // Register ADC Data Valid
            adc_reg_l                  <= adc;                                  // Register ADC Data
            adc_conv_dv_l              <= 1'b0;                                 // Normally Not Valid

            // -----------------------------------------------------------------
            //  Generate Intermediate Data
            // -----------------------------------------------------------------
            if(adc_dv_sr_l[0] == 1'b1) begin
                adc_conv_int_l         <= adc_reg_l * conv_c;                   // Convert Data

            end

            // -----------------------------------------------------------------
            //  Generate Converted Data
            // -----------------------------------------------------------------
            if(adc_dv_sr_l[1] == 1'b1) begin
                adc_conv_data_l        <= adc_conv_int_l[23:12];                // Slice Data
                adc_conv_dv_l          <= 1'b1;                                 // Indicate Valid

            end
        end
    end

    // -------------------------------------------------------------------------
    //  Controller State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : CONTROLLER_STATE_MACHINE
        if(sm_rst_n == 1'b0) begin
            state                      <= CTRL_IDLE;                            // Reset State Controller
            dac0_dv_l                  <= 'b0;                                  // Reset DAC0 DV
            dac0_l                     <= 'b0;                                  // Reset DAC0 Register
            dac1_dv_l                  <= 'b0;                                  // Reset DAC1 DV
            dac1_l                     <= 'b0;                                  // Reset DAC1 Register
            run_post_cnt_l             <= 'b0;                                  // Reset Run Post Pulse Counter
            run_pre_cnt_l              <= 'b0;                                  // Reset Run Pre Pulse Counter
            run_pls_cnt_l              <= 'b0;                                  // Reset Run Pulse Counter
            run_loop_l                 <= 'b0;                                  // Reset Run Loop Counter
            run_cnt_l                  <= 'b0;                                  // Reset Run Counter
            pv_l                       <= 'b0;                                  // Reset Pinch Valve Value
            status_l                   <= 'b0;                                  // Reset Status Register

        end else begin

            // -----------------------------------------------------------------
            //  Defaults
            // -----------------------------------------------------------------
            dac0_dv_l                  <= 1'b0;                                 // Normally not Valid
            dac1_dv_l                  <= 1'b0;                                 // Normally not Valid
            pv_l                       <= 1'b0;                                 // Normally Closed
            status_l                   <= 'b0;                                  // Normally 0x0

            // -----------------------------------------------------------------
            //  Read State Machine
            // -----------------------------------------------------------------
            case(state)

                // -------------------------------------------------------------
                //  CTRL_IDLE State
                //    In this state we wait for the convert strobe.
                // -------------------------------------------------------------
                CTRL_IDLE : begin
                    if(mode == 32'h1) begin
                        state          <= CTRL_TEST_LB;                         // Next State :: CTRL_TEST_LB

                    end else if(mode == 32'h2) begin
                        state          <= CTRL_TEST_DAC;                        // Next State :: CTRL_TEST_DAC

                    end else if(mode == 32'h3) begin
                        state          <= CTRL_RUN_INIT;                        // Next State :: CTRL_RUN_INIT

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_TEST_LB State
                //    In this state we pass the ADC to the DAC shifted 4-bits.
                // -------------------------------------------------------------
                CTRL_TEST_LB : begin
                    if(adc_conv_dv_l == 1'b1) begin
                        // Assign DAC0 Data
                        dac0_dv_l      <= 1'b1;
                        dac0_l         <= adc_conv_data_l;

                        // Assign DAC1 Data
                        dac1_dv_l      <= 1'b1;
                        dac1_l         <= adc_conv_data_l;

                    end

                    // Assign Pinch Valve Control
                    pv_l               <= pv_test;

                end

                // -------------------------------------------------------------
                //  CTRL_TEST_DAC State
                //    In this state we pass a user assigned value to the dac.
                // -------------------------------------------------------------
                CTRL_TEST_DAC : begin
                    // Send DAC0 Test Data to Converter
                    if(dac0_test_dv == 1'b1) begin
                        dac0_dv_l      <= 1'b1;
                        dac0_l         <= dac0_test_data;

                    end

                    // Send DAC1 Test Data to Converter
                    if(dac1_test_dv == 1'b1) begin
                        dac1_dv_l      <= 1'b1;
                        dac1_l         <= dac1_test_data;

                    end

                    // Assign Pinch Valve Control
                    pv_l               <= pv_test;

                end

                // -------------------------------------------------------------
                //  CTRL_RUN_INIT State
                //    In this state we reset the interfaces to known values.
                // -------------------------------------------------------------
                CTRL_RUN_INIT : begin
                    // Control DAC0
                    dac0_dv_l          <= 1'b1;                                 // Write to DAC0
                    dac0_l             <= 'b0;                                  // Zero the DAC0 Value

                    // Assign DAC1 Data
                    dac1_dv_l          <= 1'b1;                                 // Write to DAC1
                    dac1_l             <= 'b0;                                  // Zero the DAC1 Value

                    // Next State
                    state              <= CTRL_RUN_IDLE;                        // Next State :: CTRL_RUN_IDLE

                end

                // -------------------------------------------------------------
                //  CTRL_RUN_STATE State
                //    In this state we wait until we receive a run start
                //    strobe from an input port.  The run_loops is registers
                //    and we transition to the run states.
                // -------------------------------------------------------------
                CTRL_RUN_IDLE : begin
                    // Set Status
                    status_l           <= 32'h1;                                // Status 0x1 --- Waiting for Trigger

                    // Wait for Trigger
                    if(run_start == 1'b1) begin
                        // Control Information
                        run_loop_l     <= run_loops;                            // Register Loops
                        run_pre_cnt_l  <= run_pre * HUND_MIL;                   // Convert Pre-Pulse from Sec to Clks
                        run_post_cnt_l <= run_post * HUND_MIL;                  // Convert Post-Pulse from Sec to Clks
                        run_pls_cnt_l  <= run * HUND_MIL;                       // Convert Run from Sec to Clks
                        run_cnt_l      <= 'b0;                                  // Reset Run Counter

                        // Next State
                        state          <= CTRL_RUN_PRE_PULSE;                   // Next State :: CTRL_RUN_PRE_PULSE

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_RUN_PRE_PULSE State
                //    In this state we set the start pulse for 1 second then
                //    wait the remainder of the pre-pulse counter.
                // -------------------------------------------------------------
                CTRL_RUN_PRE_PULSE : begin
                    // Set Status
                    status_l           <= 32'h2;                                // Status 0x2

                    // Look for run_stop Strobe .. GoTo Init if Hit
                    if(run_stop == 1'b1) begin
                        state          <= CTRL_RUN_INIT;                        // Next State :: CTRL_RUN_INIT

                    end

                    // Assign DAC1 Data
                    if(run_cnt_l == 0) begin
                        dac1_dv_l      <= 1'b1;                                 // Write to DAC1
                        dac1_l         <= TWO_VOLT;                             // Set DAC1 Output to 2V

                    end


                    // Control User Start Pulse
                    if(run_cnt_l == HUND_MIL) begin // One Second
                        dac1_dv_l      <= 1'b1;                                 // Write to DAC1
                        dac1_l         <= 'b0;                                  // Set DAC1 Output to Zero

                    end

                    // Count for Pre-Puse
                    if(run_cnt_l < run_pre_cnt_l) begin
                        run_cnt_l      <= run_cnt_l + 1'b1;                     // Increment Counter

                    end else begin
                        // Reset Counter and Next State
                        run_cnt_l      <= 'b0;                                  // Reset Counter
                        state          <= CTRL_RUN_PULSE;                       // Next State :: CTRL_RUN_PULSE

                        // Set DAC1 to 1V
                        dac1_dv_l      <= 1'b1;                                 // Write to DAC1
                        dac1_l         <= ONE_VOLT;                             // Set DAC1 Output to 1V

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_RUN_PULSE State
                //    In this state we set DAC1 to 1V and pass the ADC values
                //    through to DAC0.
                // -------------------------------------------------------------
                CTRL_RUN_PULSE : begin
                    // Set Status
                    status_l           <= 32'h3;                                // Status 0x3

                    // Look for run_stop Strobe .. GoTo Init if Hit
                    if(run_stop == 1'b1) begin
                        state          <= CTRL_RUN_INIT;                        // Next State :: CTRL_RUN_INIT

                    end

                    // Set Valve State
                    pv_l               <= 1'b1;

                    // Count for Puse
                    if(run_cnt_l < run_pls_cnt_l) begin
                        // Increment Counter
                        run_cnt_l      <= run_cnt_l + 1'b1;

                        // Set DAC0
                        if(adc_conv_dv_l == 1'b1) begin
                            // Assign DAC0 Data
                            dac0_dv_l  <= 1'b1;
                            dac0_l     <= adc_conv_data_l;

                        end

                    end else begin
                        // Reset Counter and Next State
                        run_cnt_l      <= 'b0;                                  // Reset Counter
                        state          <= CTRL_RUN_POST_PULSE;                  // Next State :: CTRL_RUN_POST_PULSE

                        // Control DAC0
                        dac0_dv_l      <= 1'b1;                                 // Write to DAC0
                        dac0_l         <= 'b0;                                  // Zero the DAC0 Value

                        // Assign DAC1 Data
                        dac1_dv_l      <= 1'b1;                                 // Write to DAC1
                        dac1_l         <= 'b0;                                  // Zero the DAC1 Value

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_RUN_POST_PULSE State
                //    In this state we wait until next loop start.
                // -------------------------------------------------------------
                CTRL_RUN_POST_PULSE : begin
                    // Set Status
                    status_l           <= 32'h4;                                // Status 0x4

                    // Look for run_stop Strobe .. GoTo Init if Hit
                    if(run_stop == 1'b1) begin
                        state          <= CTRL_RUN_INIT;                        // Next State :: CTRL_RUN_INIT

                    end

                    // Count for Puse
                    if(run_cnt_l < run_post_cnt_l) begin
                        // Increment Counter
                        run_cnt_l      <= run_cnt_l + 1'b1;

                    end else begin
                        // Reset Counter
                        run_cnt_l      <= 'b0;

                        // Check Loops for Next State
                        if(run_loop_l > 1) begin
                            run_loop_l <= run_loop_l - 1'b1;                    // Decrement Loop Counter
                            state      <= CTRL_RUN_PRE_PULSE;                   // Next State :: CTRL_RUN_PRE_PULSE

                        end else begin
                            // Reset Counter and Next State
                            state      <= CTRL_RUN_IDLE;                        // Next State :: CTRL_RUN_IDLE

                        end
                    end
                end

                // -------------------------------------------------------------
                //  Default State
                // -------------------------------------------------------------
                default : begin
                    state              <= CTRL_IDLE;                            // Fail State

                end
            endcase
        end
    end
endmodule

