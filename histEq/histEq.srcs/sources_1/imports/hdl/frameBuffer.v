`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2023 12:25:27 PM
// Design Name: 
// Module Name: frameBuffer
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


module frameBuffer #(parameter DataWidth = 8, imageSize=640*480)( 
input                   i_clk,
input                   i_reset_n,
input   [DataWidth-1:0] i_pixel,
input                   i_pixel_valid,
input                   i_start_strm,
output  reg [DataWidth-1:0] o_pixel,
output  reg             o_pixel_valid,
output  reg             o_pixel_last,
input			        i_pixel_ready
);

 integer wrPntr;
 integer rdPntr;
     
 reg [DataWidth-1:0] mem[imageSize:0];
 
 always @(posedge i_clk)
 begin
    if(!i_reset_n)
        wrPntr <= 0;
    else if(i_pixel_valid)
    begin
        mem[wrPntr] <= i_pixel;
        wrPntr <= wrPntr+1;
        if(wrPntr == imageSize-1)
            wrPntr <= 0;
    end
 end
 
 
 always @(posedge i_clk)
 begin
    if(!i_reset_n)
    begin
        o_pixel_last <= 1'b0;
        rdPntr <= 0;
    end
    else
    begin
        o_pixel <= mem[rdPntr];
        o_pixel_last <= 1'b0;
        if(rdPntr == imageSize-1)
        begin
            rdPntr <= 0;
            o_pixel_last <= 1'b1;
        end
        else if(rdPntr != 0 & i_pixel_ready)
        begin
            rdPntr <= rdPntr+1;
            o_pixel_valid <= 1'b1;
        end
        else if(i_start_strm & i_pixel_ready)
        begin
            o_pixel_valid <= 1'b1;
            rdPntr <= rdPntr+1;
        end
        else
            o_pixel_valid <= 1'b0;
    end
 end
 
    
endmodule
