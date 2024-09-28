`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2023 08:45:09 AM
// Design Name: 
// Module Name: cdfCalc
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


module cdfCalc #(parameter DataWidth = 8,outWidth = $clog2(640*480),compareVal=0)(
input                   i_clk,
input                   i_reset_n,
input [DataWidth-1:0]   i_pixel,
input                   i_pixel_valid,
output reg [outWidth-1:0] o_frequency
);


always @(posedge i_clk)
begin
    if(!i_reset_n)
        o_frequency <= 0;
    else if(i_pixel_valid)
    begin
        if(i_pixel <= compareVal)
            o_frequency <= o_frequency+1;
    end
end

endmodule
