// -----------------------------------------------------------------------------
//  File Name   :  axi.vh
//  Autoher     :  Mike DeLong
//  Date        :  03.10.2019
//  Description :  AXI Test Bench Helpers
// -----------------------------------------------------------------------------
task automatic axi4l_read;
    input [31:0] addr;
    begin
        s_axi_araddr                   = addr;
        s_axi_arvalid                  = 1;
        s_axi_rready                   = 1;
        wait(s_axi_arready);
        wait(s_axi_rvalid);

        $display("AXI4-Lite Read Data :  0x%08X:  ", data);

        @(posedge s_axi_aclk) #1;
        s_axi_arvalid                  = 0;
        s_axi_rready                   = 0;

    end
endtask

task automatic axi4l_write;
    input [31:0] addr;
    input [31:0] data;
    begin
        s_axi_wdata                        = data;
        s_axi_awaddr                       = addr;
        s_axi_awvalid                      = 1;
        s_axi_wvalid                       = 1;

        wait(s_axi_awready && s_axi_wready);

        @(posedge s_axi_aclk) #1;
        s_axi_awvalid                      = 0;
        s_axi_wvalid                       = 0;

    end
endtask
