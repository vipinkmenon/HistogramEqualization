`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2023 09:08:23 AM
// Design Name: 
// Module Name: scaledHistogramCalculator
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


module scaledHistogramCalculator #(parameter DataWidth=8,inWidth = $clog2(640*480),numIntLevels = 2**DataWidth,multFactor=53,divFactor=16777216)(
input                                          i_clk,
input                                          i_reset_n,
input                                          i_start_calc,
input   [inWidth*numIntLevels-1:0]             i_frequency,
input   [inWidth-1:0]                          i_cdfMin,
output  reg [DataWidth*numIntLevels-1:0]       o_histogram
);

integer i;
reg [inWidth+DataWidth+1:0] scaledFreq;
reg [inWidth+DataWidth+10:0] scaledCDF;
reg state;

localparam IDLE = 'd0,
           CALC = 'd1;

always @(posedge i_clk)
begin
    if(!i_reset_n)
    begin
        state <= IDLE;
        i <= 0;
        scaledFreq <= 0;
        scaledCDF <= 0;
        o_histogram <= 0;
    end
    else
    begin
        case(state)
            IDLE:begin
                if(i_start_calc)
                begin
                    state <= CALC;
                    i <= 0;
                end
            end
            CALC:begin
                if(i != numIntLevels-1)
                begin
                    if(i_frequency[i*inWidth+:inWidth] == 0)
                        o_histogram[i*DataWidth+:DataWidth] <= 0;
                    else
                    begin
                         scaledFreq <= (i_frequency[i*inWidth+:inWidth]-i_cdfMin)*numIntLevels;//(i_frequency[i*inWidth+:inWidth]-i_cdfMin*i_frequency[i*inWidth+:inWidth])*256-(i_frequency[i*inWidth+:inWidth]-i_cdfMin*i_frequency[i*inWidth+:inWidth]);
                         scaledCDF  <= (scaledFreq*multFactor);
                         o_histogram[(i-2)*DataWidth+:DataWidth] <= scaledCDF/divFactor;
                    end
                    i <= i+1;
                end
                else
                begin
                    o_histogram[(numIntLevels-1)*DataWidth+:DataWidth] <= numIntLevels-1;
                    o_histogram[(numIntLevels-2)*DataWidth+:DataWidth] <= numIntLevels-1;
                    o_histogram[(numIntLevels-3)*DataWidth+:DataWidth] <= numIntLevels-1;
                    state <= IDLE;
                end
            end
        endcase
    end
end


endmodule
