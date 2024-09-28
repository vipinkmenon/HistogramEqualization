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
input   [DataWidth-1:0] i_pixel,
input                   i_pixel_valid,
output  [DataWidth-1:0] o_pixel,
output                  o_pixel_valid,
output                  o_pixel_last,
input		            i_pixel_ready
);

wire start_hist;
wire start_mapping;

localparam numIntLevels = 2**DataWidth;
reg pixel_valid_d;//Since the fifo doesn't support prefetching, delay valid by one clock

always @(posedge i_clk)
	pixel_valid_d <= i_pixel_valid;

controlLogic #(.imageSize(imageSize))CL(
	.i_clk(i_clk),
	.i_reset_n(i_reset_n&!o_pixel_last),
	.i_pixel_valid(pixel_valid_d),
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
            .i_reset_n(i_reset_n&!o_pixel_last),
            .i_pixel(i_pixel),
            .i_pixel_valid(pixel_valid_d),
            .o_frequency(cdfVals[i*outWidth+:outWidth])
        );
    end
endgenerate

wire fp_pixel_valid;
wire fp_pixel_last;
wire [DataWidth-1:0] fb_pixel;

frameBuffer #(.DataWidth(DataWidth),.imageSize(imageSize))fB(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_pixel(i_pixel),
    .i_pixel_valid(pixel_valid_d),
    .i_start_strm(start_mapping),
    .o_pixel(fb_pixel),
    .o_pixel_valid(fp_pixel_valid),
    .o_pixel_last(fp_pixel_last),
	.i_pixel_ready(i_pixel_ready)
    );


wire [outWidth-1:0] cdfMin;

cdfMinDetector #(.DataWidth(DataWidth),.outWidth(outWidth))minDetect(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n&!o_pixel_last),
    .i_pixel(i_pixel),
    .i_pixel_valid(pixel_valid_d),
    .cdfMin(cdfMin)
);

scaledHistogramCalculator #(.DataWidth(DataWidth),.inWidth(outWidth),.multFactor(16777216/imageSize),.divFactor(16777216))SHC(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n&!o_pixel_last),
    .i_cdfMin(cdfMin),
    .i_start_calc(start_hist),
    .i_frequency(cdfVals),
    .o_histogram(histVals)
);

mapper #(.DataWidth(DataWidth))mapper(
    .i_clk(i_clk),
    .i_pixel_value(fb_pixel),
    .i_pixel_valid(fp_pixel_valid),
    .i_pixel_last(fp_pixel_last),
    .i_map_domain(histVals),
    .o_pixel_value(o_pixel),
    .o_pixel_valid(o_pixel_valid),
    .o_pixel_last(o_pixel_last)
);

endmodule
