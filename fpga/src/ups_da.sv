// -----------------------------------------------------------------------------
//  File Name   :  ups_da.sv
//  Autoher     :  Mike DeLong
//  Date        :  03.16.2019
//  Description :  UPS Digital to Analog Interface to AD5541A
// -----------------------------------------------------------------------------
module ups_da(
    // -------------------------------------------------------------------------
    //  Clocks and Resets
    // -------------------------------------------------------------------------
    input          clk,
    input          rst_n,

    // -------------------------------------------------------------------------
    //  Converter Data Interface0
    // -------------------------------------------------------------------------
    input          dv0,
    input   [11:0] data0,

    // -------------------------------------------------------------------------
    //  Converter Data Interface1
    // -------------------------------------------------------------------------
    input          dv1,
    input   [11:0] data1,

    // -------------------------------------------------------------------------
    //  DAC SPI Interface
    // -------------------------------------------------------------------------
    output         sclk,
    output         dout0,
    output         dout1,
    output         cs_n,
    output         ldac_n

);

    // -------------------------------------------------------------------------
    //  Typedefs
    // -------------------------------------------------------------------------
    typedef enum logic[5:0] { DA_INIT, DA_CS_START, DA_CS_STOP, DA_LDAC_START, DA_LDAC_STOP, DA_SND } state_t;

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    // State Variable
    state_t state;

    // Clock Divider Register
    logic [ 7:0]  clk_div_l;

    // SPI Signals
    logic         sclk_l;
    logic         sclk_n_l;
    logic         sclk_n_reg_l;
    logic         sclk_reg_l;
    logic         sclk_out_l;
    logic         cs_n_l;
    logic         dout0_l;
    logic         dout1_l;
    logic         ldac_n_l;

    // Internal Register
    logic [15:0]  data0_l;
    logic [15:0]  data1_l;
    logic [ 4:0]  dcnt_l;

    // -------------------------------------------------------------------------
    //  Pin Assignment Statements
    // -------------------------------------------------------------------------
    // Invert Clock
    assign sclk_n_l                    = ~sclk_l;

    // Assign Pins
    assign sclk                        = sclk_out_l;
    assign cs_n                        = cs_n_l;
    assign dout0                       = dout0_l;
    assign dout1                       = dout1_l;
    assign ldac_n                      = ldac_n_l;

    // -------------------------------------------------------------------------
    //  Generate SCLK
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : SCLK_DIVIDER
        // Sync Reset
        if(rst_n == 1'b0) begin
            // Reset Clock Divier Register
            clk_div_l                  <= 'b0;
            sclk_l                     <= 1'b0;

        end else begin
            clk_div_l                  <= clk_div_l + 1'b1;                     // Increment Clock Divider
            sclk_l                     <= clk_div_l[2];

        end
    end

    // -------------------------------------------------------------------------
    //  DA Write State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : READ_STATE_MACHINE
        // Sync Reset
        if(rst_n == 1'b0) begin
            state                      <= DA_INIT;
            dcnt_l                     <= 'b0;
            sclk_n_reg_l               <= 1'b0;
            sclk_reg_l                 <= 1'b0;
            data0_l                    <= 'b0;
            data1_l                    <= 'b0;
            dout0_l                    <= 1'b0;
            dout1_l                    <= 1'b0;
            sclk_out_l                 <= 1'b1;
            cs_n_l                     <= 1'b1;
            ldac_n_l                   <= 1'b1;

        end else begin

            // -----------------------------------------------------------------
            //  Default Values
            // -----------------------------------------------------------------
            cs_n_l                     <= 1'b1;                                 // Default Not Chip Selected
            sclk_n_reg_l               <= sclk_n_l;                             // Register Inverse Clock
            sclk_reg_l                 <= sclk_l;                               // Register Clock
            sclk_out_l                 <= 1'b1;                                 // Normally Not Output Clock
            ldac_n_l                   <= 1'b1;                                 // Normally Deassert LDAC

            // -----------------------------------------------------------------
            //  Case Statement
            // -----------------------------------------------------------------
            case(state)

                // -------------------------------------------------------------
                //  State DA_INIT
                //    In this state, we wait for the user to strobe the data
                //    valid interface (dv).  We register the requested value
                //    and move onto send the data.
                // -------------------------------------------------------------
                DA_INIT : begin
                    if((dv0 == 1'b1) || (dv1 == 1'b1)) begin
                        state          <= DA_CS_START;                          // Next State :: DA_CS_START
                        dcnt_l         <= 5'h10;                                // Reset Counter

                        // Load Data
                        if(dv0 == 1'b1) begin
                            data0_l[11:0]   <= data0;                           // Register Input Data0
                        end else begin // dv1 == 1'b1
                            data1_l[11:0]   <= data1;                           // Register Input Data1
                        end
                    end
                end

                // -------------------------------------------------------------
                //  State DA_CS_START
                //    In this state, we start the chip select bit.
                // -------------------------------------------------------------
                DA_CS_START : begin
                    // Send Bit to DA
                    if((sclk_n_l == 1'b1) && (sclk_n_reg_l == 1'b0)) begin      // Look for Falling Edge
                        cs_n_l         <= 1'b0;                                 // Assert CS
                        state          <= DA_SND;                               // Next State :: DA_SND
                        dout0_l        <= data0[dcnt_l - 1'b1];                 // Register Data0 Bit to Pin
                        dout1_l        <= data1[dcnt_l - 1'b1];                 // Register Data1 Bit to Pin
                        dcnt_l         <= dcnt_l - 1'b1;                        // Increment Counter

                    end
                end

                // -------------------------------------------------------------
                //  State DA_SND
                //    In this state, we wait serialize and send the data
                //    requested by the user.
                // -------------------------------------------------------------
                DA_SND : begin
                    sclk_out_l         <= sclk_l;                               // Send Clock to Pin
                    cs_n_l             <= 1'b0;                                 // Assert CS

                    // Send Bit to DA
                    if((sclk_n_l == 1'b1) && (sclk_n_reg_l == 1'b0)) begin      // Look for Falling Edge
                        dout0_l        <= data0[dcnt_l - 1'b1];                 // Register Data0 Bit to Pin
                        dout1_l        <= data1[dcnt_l - 1'b1];                 // Register Data1 Bit to Pin
                        dcnt_l         <= dcnt_l - 1'b1;                        // Increment Counter

                    end

                    if((sclk_l == 1'b1) && (sclk_reg_l == 1'b0)) begin          // Look for Rising Edge
                        if(dcnt_l == 5'h0) begin
                            state      <= DA_CS_STOP;                           // Next State :: DA_CS_STOP
                            dcnt_l     <= 5'h0;                                 // Reset Counter

                        end
                    end
                end

                // -------------------------------------------------------------
                //  State DA_CS_STOP
                //    In this state, we deassert the chip select at the proper
                //    time.
                // -------------------------------------------------------------
                DA_CS_STOP : begin
                    cs_n_l             <= 1'b0;                                 // Assert CS

                    // Wait for Rising Edge
                    if((sclk_n_l == 1'b1) && (sclk_n_reg_l == 1'b0)) begin      // Look for Falling Edge
                        state          <= DA_LDAC_START;                        // Next State :: DA_LDAC_START

                    end
                end

                // -------------------------------------------------------------
                //  State DA_LDAC_START
                //    In this state, we assert the ldac.
                // -------------------------------------------------------------
                DA_LDAC_START : begin
                    ldac_n_l           <= 1'b0;                                 // Assert LDAC

                    // Look for Rising Clock Rising Edge
                    if((sclk_l == 1'b1) && (sclk_reg_l == 1'b0)) begin          // Look for Falling Edge
                        state          <= DA_LDAC_STOP;                         // Next State :: DA_LDAC_STOP

                    end
                end

                // -------------------------------------------------------------
                //  State DA_LDAC_STOP
                //    In this state, we assert the ldac.
                // -------------------------------------------------------------
                DA_LDAC_STOP : begin
                    ldac_n_l           <= 1'b0;                                 // Assert LDAC

                    // Look for Rising Clock Rising Edge
                    if((sclk_l == 1'b1) && (sclk_reg_l == 1'b0)) begin          // Look for Falling Edge
                        state          <= DA_INIT;                              // Next State :: DA_INIT

                    end
                end

                // -------------------------------------------------------------
                //  Default State
                // -------------------------------------------------------------
                default : begin
                    // Assign Outputs
                    state              <= DA_INIT;                              // Next State :: DA_INIT

                end
            endcase
        end
    end

endmodule
