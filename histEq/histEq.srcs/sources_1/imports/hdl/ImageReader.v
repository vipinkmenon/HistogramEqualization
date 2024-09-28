module ImageReader #(parameter imageSize=640*480,burstSize=16)(
input             i_clk,
input             i_reset_n,
input	[31:0]	  i_ddrStartAddr,
input             i_start,
//interface to ddr arbiter
output reg [31:0] o_araddr,
output reg        o_ar_valid,
input             i_ar_ready,
output reg [7:0]  o_arsize,
input   [63:0]    i_rdata,
input             i_rvalid,
input             i_rlast,
//interface to FIFO
output  [63:0]    o_fifo_data,
output            o_fifo_wr_en,
input             i_fifo_full
);
 
integer dataRemaining;
reg [1:0] state;
reg fillBuffer;
reg checkFifo;
reg start_d;
reg start_d1;
reg start_p;

always @(posedge i_clk)
begin
    start_d <= i_start;
    start_d1 <= start_d;
    start_p <= start_d & ~start_d1;
end

localparam IDLE = 'd0,
           RdDDR = 'd1,
           WAITACK = 'd2,
           WAITDATA = 'd3;
         

always @(posedge i_clk)
begin
    if(!i_reset_n)
    begin
        o_araddr <= i_ddrStartAddr;
        dataRemaining <= imageSize;
        state <= IDLE;
        o_ar_valid <= 1'b0;
        fillBuffer <= 1'b0;
        checkFifo <= 1'b0;
    end
    else
    begin
        case(state)
            IDLE:begin
                if(start_p)
                begin
                    state <= RdDDR;
                    o_araddr <= i_ddrStartAddr;
					dataRemaining <= imageSize;
                    fillBuffer <= 1'b0;
                end
            end
            RdDDR:begin
                if(!i_fifo_full)
                begin
                    o_ar_valid <= 1'b1;
					if(dataRemaining >= burstSize*8)//one read is 8 bytes
					begin
						o_arsize <= burstSize-1;
						dataRemaining <= dataRemaining-(burstSize*8);
					end
					else
					begin
						o_arsize <= (dataRemaining/8)-1;
						dataRemaining <= 0;
					end
                    state <= WAITACK;
                    
                end
            end
            WAITACK:begin
                if(i_ar_ready)
                begin
                    o_ar_valid <= 1'b0;
					o_araddr <= o_araddr + (o_arsize+1)*8;
                    if(dataRemaining == 0)
                        state <= IDLE;
                    else if(!fillBuffer)//first time make back to back read request
                    begin
                        state <= RdDDR;
                        fillBuffer <= 1'b1;
                    end
                    else
                    begin
                        state <= WAITDATA;
                    end
                end
            end
            WAITDATA:begin
                if(i_rlast)//wait for last data to check whether fifo still has space
                begin
                    checkFifo <= 1'b1; //For one clock latency for the full to assert
                end 
                if(checkFifo)
                begin
                    if(!i_fifo_full)
                    begin
                        checkFifo <= 1'b0;
                        state <= RdDDR;
                    end
                end
            end
        endcase
    end
end

assign o_fifo_data = i_rdata;
assign o_fifo_wr_en = i_rvalid;

endmodule