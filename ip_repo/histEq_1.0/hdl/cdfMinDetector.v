`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2023 12:33:41 PM
// Design Name: 
// Module Name: cdfMinDetector
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


module cdfMinDetector #(parameter DataWidth = 8,outWidth = $clog2(640*480))(
input                       i_clk,
input                       i_reset_n,
input  [DataWidth-1:0]      i_pixel,
input                       i_pixel_valid,
output  reg [outWidth-1:0]  cdfMin
);
 
reg [DataWidth-1:0] currentIndex;   

    
always @(posedge i_clk)
begin
    if(!i_reset_n)
    begin
        cdfMin <= 0;
        currentIndex <= 2**DataWidth-1;    
    end
    else if(i_pixel_valid)
    begin
        if(currentIndex == i_pixel)
            cdfMin <= cdfMin+1;
        else if(i_pixel < currentIndex)
        begin
            cdfMin <= 1;
            currentIndex <= i_pixel;
        end
    end
end


endmodule
