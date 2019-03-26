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
    //  Parameter Interface
    //    MODE -- Controller Mode
    // -------------------------------------------------------------------------
    input  [31:0]  mode,
    input          mode_update,

    input  [15:0]  dac_test_data,
    input          dac_test_dv,

    // -------------------------------------------------------------------------
    //  ADC Interface
    // -------------------------------------------------------------------------
    input  [11:0]  adc,
    input          adc_dv,

    // -------------------------------------------------------------------------
    //  DAC Interface
    // -------------------------------------------------------------------------
    output [15:0]  dac,
    output         dac_dv

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
                             CTRL_RUN_STAGE,
                             CTRL_RUN_PRE_PULSE,
                             CTRL_RUN_PULSE,
                             CTRL_RUN_LOOP

                            } state_t;

    // -------------------------------------------------------------------------
    //  Assigns
    // -------------------------------------------------------------------------
    assign dac0                        = dac0_l;                                // Assign Data to DAC
    assign dac0_dv                     = dac0_dv_l;                             // Assign Data Valid to DAC

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    // State Variable
    state_t state;

    // State Machine Reset
    logic          sm_rst_n;

    // DAC Internal Registers
    logic [15:0]   dac0_l;
    logic          dac0_dv_l;

    // Conversion Constant
    logic [31:0]   conv_c = 32'hCCD9; // 12.803 * 1024

    // Conversion Registers
    logic [ 2:0]   adc_dv_sr_l;
    logic [15:0]   adc_conv_data_l;
    logic          adc_conv_dv_l;
    logic [31:0]   adc_conv_int_l;
    logic [11:0]   adc_reg_l;

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
                adc_conv_data_l        <= adc_conv_int_l[27:12];                // Slice Data
                adc_conv_dv_l          <= 1'b1;                                 // Indicate Valid

            end
        end
    end

    // -------------------------------------------------------------------------
    //  Controller State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : AD_READ_STATE_MACHINE
        if(sm_rst_n == 1'b0) begin
            state                      <= CTRL_IDLE;                            // Reset State Controller
            dac0_dv_l                  <= 'b0;                                  // Reset DAC DV
            dac0_l                     <= 'b0;                                  // Reset DAC Register

        end else begin

            // -----------------------------------------------------------------
            //  Defaults
            // -----------------------------------------------------------------
            dac0_dv_l                  <= 1'b0;                                 // Normally not Valid

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
                        state          <= CTRL_TEST_CONV;                       // Next State :: CTRL_TEST_CONV

                    end else if(mode == 32'h3) begin
                        state          <= CTRL_RUN_STAGE;                       // Next State :: CTRL_RUN_STATE

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_TEST_LB State
                //    In this state we pass the ADC to the DAC shifted 4-bits.
                // -------------------------------------------------------------
                CTRL_TEST_LB : begin
                    if(adc_dv == 1'b1) begin
                        dac0_dv_l      <= 1'b1;
                        dac0_l         <= { adc, 4'h0 };

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_TEST_DAC State
                //    In this state we pass a user assigned value to the dac.
                // -------------------------------------------------------------
                CTRL_TEST_DAC : begin
                    if(dac_test_dv == 1'b1) begin
                        dac0_dv_l      <= 1'b1;
                        dac0_l         <= dac_test_data;

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_TEST_CONV State
                //    In this state we pass the converted data to the dac.
                // -------------------------------------------------------------
                CTRL_TEST_CONV : begin
                    if(adc_conv_dv_l == 1'b1) begin
                        dac0_dv_l      <= 1'b1;
                        dac0_l         <= adc_conv_data_l;

                    end
                end

                // -------------------------------------------------------------
                //  CTRL_RUN_STATE State
                //    In this state we stage the configuration and prep for the
                //    test.
                // -------------------------------------------------------------
                CTRL_RUN_STAGE : begin
                    
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

