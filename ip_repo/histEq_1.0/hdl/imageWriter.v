module ImageWriter #(parameter imageSize=640*480,burstSize=16)(
input             i_clk,
input             i_reset_n,
input			  i_start,
input	[31:0]	  i_ddrStartAddr,
output	reg		  o_wr_done,
//AXI master i/f
output reg         m00_axi_awvalid,
input wire         m00_axi_awready,
output reg  [31:0] m00_axi_awaddr,
output wire [2: 0] m00_axi_awprot,
output wire        m00_axi_awid,
output reg  [7: 0] m00_axi_awlen,
output wire [2: 0] m00_axi_awsize,
output wire [1: 0] m00_axi_awburst,
output wire        m00_axi_awlock,
output wire [3: 0] m00_axi_awcache,
output wire [3: 0] m00_axi_awqos,
output wire [0: 0] m00_axi_awuser,
output reg         m00_axi_wvalid,
input wire         m00_axi_wready,
output wire [31: 0] m00_axi_wdata,
output wire [3:0] m00_axi_wstrb,
output reg          m00_axi_wlast,
output wire [0 : 0] m00_axi_wuser,
input   wire        m00_bvalid,
output              m00_bready,
input wire [1:0]    m00_bresp,
input               m00_bid,
input               m00_buser,
//interface to FIFO
input   [7:0]     i_img_data,
input             i_img_data_valid,
output            o_img_data_ready
);

wire Fifofull;
wire fifo_pempty;
wire fifo_empty;
integer dataRemaining;
reg [8:0] brstSize;
reg start_d;
reg start_d1;
reg start_p;
wire fifo_rd_en;
wire [10:0] fifoDataCount;
reg [1:0] state;
reg [31:0] ddrAddr;
integer burstDataWritten;

localparam WAIT_START = 'd0,
		   IDLE = 'd1,
		   WrDDR = 'd2,
		   FlushFIFO = 'd3;

assign m00_axi_awsize = 3'b010;
assign m00_axi_awburst = 2'b01;//Increment address 
assign m00_axi_awprot = 0;
assign m00_axi_awid = 0;
assign m00_axi_awlock = 0;
assign m00_axi_awcache = 0;
assign m00_axi_awqos = 0;
assign m00_axi_awuser = 0;
assign m00_bready = 1;
assign m00_axi_wstrb = 4'hF;
assign fifo_rd_en = m00_axi_wready & (state == WrDDR);

always @(posedge i_clk)
begin
    start_d <= i_start;
    start_d1 <= start_d;
    start_p <= start_d & ~start_d1;
end

always @(posedge i_clk)
begin
    if(!i_reset_n)
    begin
		m00_axi_awvalid <= 1'b0;
        m00_axi_wvalid <= 1'b0;
		m00_axi_wlast <= 0;
		o_wr_done <= 1'b0;
		burstDataWritten <= 0;
        state <= WAIT_START;
    end
    else
    begin
        case(state)
			WAIT_START:begin
				o_wr_done <= 1'b0;
				if(start_p)
				begin
					state <= IDLE;
					m00_axi_awaddr <= i_ddrStartAddr;
					ddrAddr <= i_ddrStartAddr;
					dataRemaining <= imageSize;
					burstDataWritten <= 0;
				end
			end
            IDLE:begin
                if(!fifo_pempty & dataRemaining>=(burstSize*4))//there is one burst of data in fifo
                begin
                    m00_axi_awaddr <= ddrAddr;
					m00_axi_awvalid <= 1'b1;
					m00_axi_awlen <= burstSize-1;
					if(m00_axi_awready & m00_axi_awvalid)	
					begin
						m00_axi_awvalid <= 1'b0;
						m00_axi_wvalid <= 1'b1;
						state <= WrDDR;
						dataRemaining <= dataRemaining-(burstSize*4);
						burstDataWritten <= 0;
						brstSize <= burstSize;
					end
                end
				else if((dataRemaining < (burstSize*4)) & (fifoDataCount>=dataRemaining/4))
				begin
					m00_axi_awaddr <= ddrAddr;
					m00_axi_awvalid <= 1'b1;
					m00_axi_awlen <= (dataRemaining/4)-1;
					if(m00_axi_awready & m00_axi_awvalid)	
					begin
						m00_axi_awvalid <= 1'b0;
						state <= WrDDR;
						dataRemaining <= 0;
						burstDataWritten <= 0;
						brstSize <= (dataRemaining/4);
					end
				end
            end
            WrDDR:begin
				m00_axi_wvalid <= 1'b1;
				if(m00_axi_wready)
				begin
					burstDataWritten <= burstDataWritten+1;
					if(burstDataWritten == brstSize-2)
					begin
						m00_axi_wlast <= 1'b1;
					end
					if(burstDataWritten == brstSize-1)
					begin
						m00_axi_wvalid <= 1'b0;
						m00_axi_wlast <= 1'b0;
						ddrAddr <= ddrAddr+(brstSize*4);
						state <= IDLE;
						if(dataRemaining == 0)
						begin
							state <= WAIT_START;
							o_wr_done <= 1'b1;
						end
					end
				end
            end
        endcase
    end
end

assign o_img_data_ready = !Fifofull;

outBuff outBuff (
  .clk(i_clk),                      // input wire clk
  .srst(!i_reset_n),                    // input wire srst
  .din(i_img_data),                      // input wire [7 : 0] din
  .wr_en(i_img_data_valid),                  // input wire wr_en
  .rd_en(fifo_rd_en),                  // input wire rd_en
  .dout({m00_axi_wdata[7:0],m00_axi_wdata[15:8],m00_axi_wdata[23:16],m00_axi_wdata[31:24]}),                    // output wire [31 : 0] dout
  .full(Fifofull),                    // output wire full
  .almost_full(),      // output wire almost_full
  .empty(fifo_empty),                  // output wire empty
  .rd_data_count(fifoDataCount),  // output wire [10 : 0] rd_data_count
  .prog_empty(fifo_pempty)
);


endmodule