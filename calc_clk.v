`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2021 09:03:01 PM
// Design Name: 
// Module Name: calc_clk
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


module calc_clk(
    input clk, input[31:0] m, output reg slow_clk = 0
    );
reg[31:0] ct = 0;
always @(posedge clk) begin
    ct <= (ct == m)? 0 : ct + 1;
    slow_clk <= (ct == 0)? ~slow_clk : slow_clk;
end    
endmodule
