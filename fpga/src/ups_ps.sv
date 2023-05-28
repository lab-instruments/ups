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

    // -------------------------------------------------------------------------
    //  Variables
    // -------------------------------------------------------------------------
    logic          rst_l;
    logic          busy_l;
    logic  [ 4:0]  cout_l;
    logic  [15:0]  dout_l;
    logic          eoc_l;
    logic  [15:0]  data_l;
    logic          dv_l;

    // Data Read/Write Signals
    logic          den_l;
    logic          drdy_l;
    logic  [ 6:0]  daddr_l;

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
        .probe0                        (rst_l),
        .probe1                        (busy_l),
        .probe2                        (eoc_l),
        .probe3                        (cout_l),
        .probe4                        (dout_l),
        .probe5                        (den_l),
        .probe6                        (drdy_l),
        .probe7                        (daddr_l),
        .probe8                        (data_l),
        .probe9                        (2'b0)
    );

    // -------------------------------------------------------------------------
    //  Data Read from XADC Controller
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : XADC_IFACE
        if(rst_n == 1'b0) begin
            // Internal Read Signals
            den_l                      <=  1'b0;
            daddr_l                    <=  7'h0;

        end else begin

            // Default Values
            den_l                      <= 1'b0;
            dv_l                       <= 1'b0;

            if(eoc_l == 1'b1) begin
                // Register Channel into Address
                daddr_l        <= {2'b00, cout_l};

                // Issue Read Enable
                den_l          <= 1'b1;

           end
        end
    end

    // -------------------------------------------------------------------------
    //  ADC Data Block Output
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : ADC_OUTPUT
        if(rst_n == 1'b0) begin
            // Internal Read Signals
            dv_l                       <=  1'b0;
            data_l                     <=  7'h0;

        end else begin

            // Default Values
            dv_l                       <= 1'b0;

            if(drdy_l == 1'b1) begin
                // Register Channel into Address
                data_l         <= dout_l;

                // Issue Read Enable
                dv_l           <= 1'b1;

           end
        end
    end

    // -------------------------------------------------------------------------
    //  FPGA XADC Primative
    // -------------------------------------------------------------------------
    ups_xadc ps(
        .daddr_in                      (daddr_l),                // Address bus for the dynamic reconfiguration port
        .dclk_in                       (clk),                    // Clock input for the dynamic reconfiguration port
        .den_in                        (den_l),                   // Enable Signal for the dynamic reconfiguration port
        .di_in                         (16'h0),                  // Input data bus for the dynamic reconfiguration port
        .dwe_in                        (1'b0),                   // Write Enable for the dynamic reconfiguration port
        .reset_in                      (1'b0),                  // Reset signal for the System Monitor control logic
        .vauxp1                        (vaux1_p),                // Auxiliary channel 1
        .vauxn1                        (vaux1_n),
        .busy_out                      (busy_l),               // ADC Busy signal
        .channel_out                   (cout_l),               // Channel Selection Outputs
        .do_out                        (dout_l),               // Output data bus for dynamic reconfiguration port
        .drdy_out                      (drdy_l),               // Data ready signal for the dynamic reconfiguration port
        .eoc_out                       (eoc_l),               // End of Conversion Signal
        .eos_out                       (),               // End of Sequence Signal
        .alarm_out                     (),               // OR'ed output of all the Alarms
        .vp_in                         (),               // Dedicated Analog Input Pair
        .vn_in                         ()
    );

endmodule // ups_ps
