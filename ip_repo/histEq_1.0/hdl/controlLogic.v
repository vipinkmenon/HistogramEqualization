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
input		i_start,
output	reg	o_done,
output  reg o_rd_image,
input       i_pixel_valid,
output  reg o_start_hist,
output  reg o_start_mapping
);
    
 
integer pixelCount;  
integer delayCount;  
reg [1:0] state;
localparam  IDLE = 'd0,
            WAIT_HIST = 'd1,
			WAIT_COMPLETE = 'd2;

always @(posedge i_clk)
begin
    if(!i_reset_n)
    begin
        state <= IDLE;
        pixelCount <= 0;
		o_start_mapping <= 1'b0;
		o_start_hist <= 1'b0;
		delayCount <= 0;
		o_done <= 0;
		o_rd_image <= 0;
    end
    else
    begin
        case(state)
            IDLE:begin
                o_start_mapping <= 1'b0;
				o_rd_image <= i_start;
                if(i_pixel_valid)
                    pixelCount <= pixelCount+1;
                if(pixelCount == imageSize)
                begin
                    o_start_hist <= 1;
					pixelCount <= 0;
					o_rd_image <= 1'b0;
                    state <= WAIT_HIST;
                end
            end
            WAIT_HIST:begin
                o_start_hist <= 0;
                if(delayCount != 255)//256 clocks to calculate histogram
                    delayCount <= delayCount+1;
                else
                begin
                    o_start_mapping <= 1'b1;
					o_rd_image <= 1'b1;
                    state <= WAIT_COMPLETE;
					delayCount <= 0;
                end
            end
			WAIT_COMPLETE:begin
				if(i_pixel_valid)
                    pixelCount <= pixelCount+1;
				if(pixelCount >= imageSize)
				begin
					o_done <= 1'b1;
					o_rd_image <= 1'b0;
					o_start_mapping <= 1'b0;
				end
				if(!i_start)
				begin
					o_done <= 1'b0;
					pixelCount <= 0;
					state <= IDLE;
				end
			end
        endcase
    end
end    
    
endmodule
