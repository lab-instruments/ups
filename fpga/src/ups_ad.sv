// -----------------------------------------------------------------------------
//  File Name   :  ups_ad.sv
//  Autoher     :  Mike DeLong
//  Date        :  03.19.2019
//  Description :  UPS Analog to Digital Interface to AD7476A
// -----------------------------------------------------------------------------
module ups_ad(
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
    //  ADC SPI Interface
    // -------------------------------------------------------------------------
    output         sclk,
    input          din,
    output         cs_n

);

    // -------------------------------------------------------------------------
    //  Typedefs
    // -------------------------------------------------------------------------
    typedef enum logic[5:0] { AD_INIT, AD_CS_SYNC_ASSERT, AD_CLK_DATA, AD_CS_SYNC_DEASSERT, AD_REG_DATA } state_t;

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    // State Variable
    state_t state;

    // Clock Divider Register
    logic [15:0]  clk_sr_l;

    // Clock Signals
    logic         clk_div_l;
    logic         clk_div_reg0_l;
    logic         clk_div_reg1_l;
    logic         clk_div_red_l;
    logic         clk_div_fed_l;

    // Internal SPI Registers
    logic         sclk_l;
    logic         cs_n_l;

    // Internal Data Register
    logic [11:0]  data_l;
    logic [15:0]  data_reg_l;
    logic [ 4:0]  dcnt_l;
    logic         dv_l;

    // Conversion Control Register
    logic         ad_strobe_l;
    logic         ad_strobe_reg_l;
    logic         ad_strobe_red_l;

    // -------------------------------------------------------------------------
    //  Pin Assignment Statements
    // -------------------------------------------------------------------------
    // Assign Pins
    assign sclk                        = sclk_l;
    assign cs_n                        = cs_n_l;

    // Data Output Pins
    assign data                        = data_l;
    assign dv                          = dv_l;

    // -------------------------------------------------------------------------
    //  Generate SCLK
    // -------------------------------------------------------------------------
    // Generate Clock
    always @(posedge clk) begin : SCLK_DIVIDER
        // Sync Reset
        if(rst_n == 1'b0) begin
            // Reset Clock Divier Register and Clock Registers
            clk_sr_l                   <= 'b0;
            clk_div_l                  <= 1'b0;
            clk_div_reg0_l             <= 1'b0;
            clk_div_reg1_l             <= 1'b0;

            // Reset AD Conversion Registers
            ad_strobe_l                <= 1'b0;
            ad_strobe_reg_l            <= 1'b0;

        end else begin
            // Clock Divider
            clk_sr_l                   <= clk_sr_l + 1'b1;                      // Increment Clock Divider

            // Generate SCLK
            clk_div_l                  <= clk_sr_l[3];                          // Divide 100MHz / 2^(3+1) = 6.25MHz
            clk_div_reg0_l             <= clk_div_l;                            // Delay Clock
            clk_div_reg1_l             <= clk_div_reg0_l;                       // Delay Clock

            // Generate AD Conversion Rate
            ad_strobe_l                <= clk_sr_l[12];                         // Divide 100MHz / 2^(12+1) = 12207.03125 kHz
            ad_strobe_reg_l            <= ad_strobe_l;                          // Register AD Strobe

        end
    end

    // Generate Clock Rising Edge Strobe
    always @(posedge clk) begin : EDGE_DETECTOR
        // Sync Reset
        if(rst_n == 1'b0) begin
            // Reset Rising Edge Strobes
            clk_div_red_l              <= 1'b0;
            clk_div_fed_l              <= 1'b0;
            ad_strobe_red_l            <= 1'b0;

        end else begin
            // Defaults
            clk_div_red_l              <= 1'b0;
            clk_div_fed_l              <= 1'b0;
            ad_strobe_red_l            <= 1'b0;

            // Look for Rising Edge of the Clock
            if((clk_div_l == 1'b1) && (clk_div_reg0_l == 1'b0)) begin
                clk_div_red_l          <= 1'b1;

            end

            // Look for Falling Edge of the Clock
            if((clk_div_l == 1'b0) && (clk_div_reg0_l == 1'b1)) begin
                clk_div_fed_l          <= 1'b1;

            end

            // Look for Rising Edge of the AD Strobe
            if((ad_strobe_l == 1'b1) && (ad_strobe_reg_l == 1'b0)) begin
                ad_strobe_red_l        <= 1'b1;

            end
        end
    end

    // -------------------------------------------------------------------------
    //  AD Read State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : AD_READ_STATE_MACHONE
        if(rst_n == 1'b0) begin
            sclk_l                     <= 1'b1;                                 // Reset SCLK
            cs_n_l                     <= 1'b1;                                 // Reset Chip Select
            data_l                     <= 'h0;                                  // Reset Internal Data Output Register
            data_reg_l                 <= 'h0;                                  // Reset Internal Staging Register
            dv_l                       <= 'b0;                                  // Reset Internal Data Valid Register
            state                      <= AD_INIT;                              // Reset State Controller
            dcnt_l                     <= 'h0;                                  // Reset Data Bit Pointer

        end else begin

            // -----------------------------------------------------------------
            //  Defaults
            // -----------------------------------------------------------------
            sclk_l                     <= 1'b1;                                 // Normally High SCLK
            cs_n_l                     <= 1'b1;                                 // Normally De-Assert Chip Select
            dv_l                       <= 1'b0;                                 // Normally Not Valid

            // -----------------------------------------------------------------
            //  Read State Machine
            // -----------------------------------------------------------------
            case(state)

                // -------------------------------------------------------------
                //  AD_INIT State
                //    In this state we wait for the convert strobe.
                // -------------------------------------------------------------
                AD_INIT : begin
                    if(ad_strobe_red_l == 1'b1) begin
                        // Next State
                        state          <= AD_CS_SYNC_ASSERT;                    // Next State :: AD_CS_SYNC_ASSERT

                    end
                end

                // -------------------------------------------------------------
                //  AD_CS_SYNC_ASSERT State
                //    In this state we assert the chip select (active low)
                //    when the rising edge strobe asserts.
                // -------------------------------------------------------------
                AD_CS_SYNC_ASSERT : begin
                    if(clk_div_red_l == 1'b1) begin
                        // Next State
                        state          <= AD_CLK_DATA;                          // Next State :: AD_CLK_DATA
                        dcnt_l         <= 5'd14;                                // Set Count to 14

                    end
                end

                // -------------------------------------------------------------
                //  AD_CLK_DATA State
                //    In this state we pass the clock and register the data.
                // -------------------------------------------------------------
                AD_CLK_DATA : begin
                    // Pass Clock and Chip Select
                    cs_n_l             <= 1'b0;
                    sclk_l             <= clk_div_reg0_l;

                    // Decrement and Register Data
                    if(clk_div_red_l == 1'b1) begin
                        data_reg_l[dcnt_l] <= din;                              // Register Data

                        // Check for Next State
                        if(dcnt_l == 5'h0) begin
                            state      <= AD_CS_SYNC_DEASSERT;

                        end else begin
                            dcnt_l     <= dcnt_l - 1'b1;                        // Decrement Bit Pointer

                        end
                    end
                end

                // -------------------------------------------------------------
                //  AD_CS_SYNC_DEASSERT State
                //    In this state we deassert the chip select (active low)
                //    when the rising edge strobe asserts.
                // -------------------------------------------------------------
                AD_CS_SYNC_DEASSERT : begin
                    // Pass Clock and Chip Select
                    cs_n_l             <= 1'b0;
                    sclk_l             <= 1'b1;

                    // Look for Rising Edge
                    if(clk_div_fed_l == 1'b1) begin
                        // Next State
                        state          <= AD_REG_DATA;                          // Next State :: AD_REG_DATA

                    end
                end

                // -------------------------------------------------------------
                //  AD_REG_DATA State
                //    In this state we deassert the chip select (active low)
                //    when the rising edge strobe asserts.
                // -------------------------------------------------------------
                AD_REG_DATA : begin
                    // Register Output
                    data_l             <= data_reg_l[11:0];                     // Slice Data
                    dv_l               <= 1'b1;                                 // Assert Data Valid
                    state              <= AD_INIT;                              // Next State :: AD_INIT
                end

                // -------------------------------------------------------------
                //  Default State
                // -------------------------------------------------------------
                default : begin
                    state              <= AD_INIT;                              // Fail State

                end
            endcase
        end
    end
endmodule

