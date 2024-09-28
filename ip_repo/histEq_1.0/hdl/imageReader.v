module ImageReader #(parameter imageSize=640*480,burstSize=256)(
input             i_clk,
input             i_reset_n,
input	[31:0]	  i_ddrStartAddr,
input             i_start,
//AXI master i/f
output wire        m00_axi_arid,
output reg  [31:0] m00_axi_araddr,
output wire [7: 0] m00_axi_arlen,
output wire [2: 0] m00_axi_arsize,
output wire [1: 0] m00_axi_arburst,
output wire        m00_axi_arlock,
output wire [3: 0] m00_axi_arcache,
output wire [2: 0] m00_axi_arprot,
output wire [3: 0] m00_axi_arqos,
output wire [0: 0] m00_axi_aruser,
output reg         m00_axi_arvalid,
input wire         m00_axi_arready,
input wire         m00_axi_rid,
input wire [31: 0] m00_axi_rdata,
input wire [1 : 0] m00_axi_rresp,
input wire         m00_axi_rlast,
input wire [0 : 0] m00_axi_ruser,
input wire         m00_axi_rvalid,
output wire        m00_axi_rready,
//interface to FIFO
output  [7:0]     o_img_data,
output            o_img_data_valid,
input             i_img_data_ready
);
 
integer dataRemaining;
reg [1:0] state;
reg checkFifo;
reg start_d;
reg start_d1;
reg start_p;
wire fifo_full;

 assign m00_axi_arid    = 1'b0;
 assign m00_axi_arlock  = 1'b0;
 assign m00_axi_arcache = 4'd0;
 assign m00_axi_arprot  = 3'd0;
 assign m00_axi_arqos   = 4'd0;
 assign m00_axi_aruser  = 0;
 assign m00_axi_rready  = 1'b1;
 assign m00_axi_arsize  = 3'b010;
 assign m00_axi_arlen   = burstSize-1;//1KB is read in each burst
 assign m00_axi_arburst = 2'b01;//Increment address 
 assign o_img_data_valid = !fifo_empty & i_img_data_ready;
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
        m00_axi_araddr <= i_ddrStartAddr;
        dataRemaining <= imageSize;
        state <= IDLE;
        m00_axi_arvalid <= 1'b0;
        checkFifo <= 1'b0;
    end
    else
    begin
        case(state)
            IDLE:begin
                if(start_p)
                begin
                    state <= RdDDR;
                    m00_axi_araddr <= i_ddrStartAddr;
					dataRemaining <= imageSize;
                end
            end
            RdDDR:begin
                m00_axi_arvalid <= 1'b1;
				if(dataRemaining >= (burstSize*4))//one read is 1024 bytes
				begin
					dataRemaining <= dataRemaining-(burstSize*4);
				end
				else
				begin
					dataRemaining <= 0;
				end
                   state <= WAITACK;
                   
            end
            WAITACK:begin
                if(m00_axi_arready)
                begin
                    m00_axi_arvalid <= 1'b0;
					m00_axi_araddr <= m00_axi_araddr + (burstSize*4);
                    if(dataRemaining == 0)
                        state <= IDLE;
                    else
                    begin
                        state <= WAITDATA;
                    end
                end
            end
            WAITDATA:begin
                if(m00_axi_rlast)//wait for last data to check whether fifo still has space
                begin
                    checkFifo <= 1'b1; //For one clock latency for the full to assert
                end 
                if(checkFifo)
                begin
                    if(!fifo_full)
                    begin
                        checkFifo <= 1'b0;
                        state <= RdDDR;
                    end
                end
            end
        endcase
    end
end

imgBuff InBuff (
  .clk(i_clk),              // input wire clk
  .srst(!i_reset_n),            // input wire srst
  .din({m00_axi_rdata[7:0],m00_axi_rdata[15:8],m00_axi_rdata[23:16],m00_axi_rdata[31:24]}),              // input wire [31 : 0] din
  .wr_en(m00_axi_rvalid),          // input wire wr_en
  .rd_en(i_img_data_ready),          // input wire rd_en
  .dout(o_img_data),            // output wire [7 : 0] dout
  .full(),            // output wire full
  .empty(fifo_empty),          // output wire empty
  .prog_full(fifo_full)  // output wire prog_full
);


endmodule