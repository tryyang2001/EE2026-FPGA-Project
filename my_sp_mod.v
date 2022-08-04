`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2021 09:03:01 PM
// Design Name: 
// Module Name: my_sp_mod
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module my_sp_mod(
    input slow_clk, input btn, output pulse
    );
    
wire out1, out2;
my_dff dff1(slow_clk, btn, out1);
my_dff dff2(slow_clk, out1, out2);
assign pulse = out1 & ~out2;

endmodule
