`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2023 08:54:05 AM
// Design Name: 
// Module Name: histEquilizer
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

module histEquilizer #(parameter imageSize=(640*480),DataWidth = 8,outWidth = $clog2(imageSize))(
input                   i_clk,
input                   i_reset_n,
input					i_start,
output					o_done,
input   [DataWidth-1:0] i_pixel,
input                   i_pixel_valid,
output  [DataWidth-1:0] o_pixel,
output                  o_pixel_valid,
output                  o_pixel_last,
input		            i_pixel_ready,
output					o_rd_image
);

wire start_hist;
wire start_mapping;

localparam numIntLevels = 2**DataWidth;

controlLogic #(.imageSize(imageSize))CL(
	.i_clk(i_clk),
	.i_reset_n(i_reset_n),
	.i_start(i_start),
	.o_done(o_done),
	.i_pixel_valid(i_pixel_valid),
	.o_rd_image(o_rd_image),
	.o_start_hist(start_hist),
	.o_start_mapping(start_mapping)
);

wire [numIntLevels*outWidth-1:0] cdfVals;
wire [DataWidth*numIntLevels-1:0] histVals;

generate
genvar i;
    for(i=0;i<numIntLevels;i=i+1)
    begin:cdfLoop
        cdfCalc #(.DataWidth(DataWidth),.outWidth(outWidth),.compareVal(i))cdfCalcInst(
            .i_clk(i_clk),
            .i_reset_n(i_reset_n&!o_done),
            .i_pixel(i_pixel),
            .i_pixel_valid(i_pixel_valid),
            .o_frequency(cdfVals[i*outWidth+:outWidth])
        );
    end
endgenerate


wire [outWidth-1:0] cdfMin;

cdfMinDetector #(.DataWidth(DataWidth),.outWidth(outWidth))minDetect(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n&!o_done),
    .i_pixel(i_pixel),
    .i_pixel_valid(i_pixel_valid),
    .cdfMin(cdfMin)
);

scaledHistogramCalculator #(.DataWidth(DataWidth),.inWidth(outWidth),.multFactor(16777216/imageSize),.divFactor(16777216))SHC(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n&!o_done),
    .i_cdfMin(cdfMin),
    .i_start_calc(start_hist),
    .i_frequency(cdfVals),
    .o_histogram(histVals)
);

mapper #(.DataWidth(DataWidth))mapper(
    .i_clk(i_clk),
	.i_enable(start_mapping),
    .i_pixel_value(i_pixel),
    .i_pixel_valid(i_pixel_valid),
    .i_pixel_last(start_hist),
    .i_map_domain(histVals),
    .o_pixel_value(o_pixel),
    .o_pixel_valid(o_pixel_valid),
    .o_pixel_last(o_pixel_last)
);

endmodule
