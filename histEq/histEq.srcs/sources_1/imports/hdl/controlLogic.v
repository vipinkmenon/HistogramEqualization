`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2023 09:32:16 AM
// Design Name: 
// Module Name: controlLogic
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


module controlLogic #(parameter imageSize=640*480)(
input       i_clk,
input       i_reset_n,
input       i_pixel_valid,
output  reg o_start_hist,
output  reg o_start_mapping
    );
    
 
integer pixelCount;  
reg state;
localparam  IDLE = 'd0,
            WAIT_HIST = 'd1;

always @(posedge i_clk)
begin
    if(!i_reset_n)
    begin
        state <= IDLE;
        pixelCount <= 0;
		o_start_mapping <= 1'b0;
		o_start_hist <= 1'b0;
    end
    else
    begin
        case(state)
            IDLE:begin
                o_start_mapping <= 1'b0;
                if(i_pixel_valid)
                    pixelCount <= pixelCount+1;
                if(pixelCount == imageSize)
                begin
                    o_start_hist <= 1;
                    state <= WAIT_HIST;
                    pixelCount <= 0;
                end
            end
            WAIT_HIST:begin
                o_start_hist <= 0;
                if(pixelCount != 255)//256 clocks to calculate histogram
                    pixelCount <= pixelCount+1;
                else
                begin
                    o_start_mapping <= 1'b1;
                    state <= IDLE;
                end
            end
        endcase
    end
end    
    
endmodule
