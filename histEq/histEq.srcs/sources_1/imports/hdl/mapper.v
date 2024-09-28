`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2023 12:26:52 PM
// Design Name: 
// Module Name: mapper
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


module mapper #(parameter DataWidth = 8,numIntLevels = 2**DataWidth)(
input                         i_clk,
input   [DataWidth-1:0]       i_pixel_value,
input                         i_pixel_valid,
input                         i_pixel_last,
input   [DataWidth*numIntLevels-1:0]           i_map_domain,
output reg  [DataWidth-1:0]   o_pixel_value,
output reg                    o_pixel_valid,
output reg                    o_pixel_last
);

always @(posedge i_clk)
begin
    o_pixel_valid <= i_pixel_valid;
    o_pixel_last <= i_pixel_last;
end

always @(posedge i_clk)
    o_pixel_value <= i_map_domain[i_pixel_value*DataWidth+:DataWidth];
    
    
endmodule
