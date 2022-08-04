`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2021 09:13:41 PM
// Design Name: 
// Module Name: xy_coordinates
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


module xy_coordinates(
    input[12:0] my_pix_index, output[7:0] x, y
    );
assign x = my_pix_index % 96;
assign y = my_pix_index / 96;
endmodule
