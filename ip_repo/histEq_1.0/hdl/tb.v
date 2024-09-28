`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2024 21:54:10
// Design Name: 
// Module Name: tb
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
`define imgSize 640*480

module tb();
    
reg clk;
reg aresetn;
wire done;

initial
begin
    clk = 0;
    forever
    begin
        clk <= !clk;
        #3.33;
    end
end


initial
begin
    aresetn = 0;
    #200;
    @(posedge clk)
    aresetn <= 1;
end    

reg [31:0] frameData0;
integer file;
integer file1;
integer i;
wire arvalid0;
reg rvalid0;
reg rlast0;
integer sentSize=0;
integer rxSize=0;
reg wready = 0;
integer randCount=0;

always @(posedge clk)
begin
	randCount <= randCount+1;
	if(randCount%100 == 0)
	begin
		@(posedge clk);
		wready <= 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		wready <= 1'b1;
	end
end

initial
begin
	@(posedge aresetn);
	@(posedge clk);
	dut.histEq_v1_0_S00_AXI_inst.slv_reg2 = 32'h40000000;//image start addr
	dut.histEq_v1_0_S00_AXI_inst.slv_reg3 = 32'h50000000;//image start addr
	dut.histEq_v1_0_S00_AXI_inst.slv_reg0 = 'h1;//start
	@(posedge done);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	dut.histEq_v1_0_S00_AXI_inst.slv_reg0 = 'h0;//start
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	$fclose(file1);
	$stop;
end

initial
begin
	file = $fopen("input.bin","rb");
	rvalid0 = 1'b0;
	rlast0 = 1'b0;
	forever
	begin
		@(posedge arvalid0);//wait for read request
		repeat(10)
			@(posedge clk);//wait for some time
		for(i=0;i<256;i=i+1)
		begin
			@(posedge clk);
			$fscanf(file,"%c%c%c%c",frameData0[7:0],frameData0[15:8],frameData0[23:16],frameData0[31:24]); //32bit data
			rvalid0 <= 1'b1;
			if(i==255)
				rlast0 <= 1'b1;
		end
		@(posedge clk);
		rvalid0 <= 1'b0;
		rlast0 <= 1'b0;
		sentSize = sentSize+1024;
		if(sentSize >= `imgSize)
		begin
			sentSize = 0;
			$fclose(file);
			file = $fopen("input.bin","rb");
		end
	end
end

initial
begin
	file1 = $fopen("out.bin","wb");
end

wire pixel_valid;
wire [31:0] pixel_data;
wire [7:0] out_data;

always @(posedge clk)
begin
	if(pixel_valid&wready)
	begin
		$fwrite(file1,"%c%c%c%c",pixel_data[7:0],pixel_data[15:8],pixel_data[23:16],pixel_data[31:24]);
	end
end

histEq_v1_0 dut
	(
		.s00_axi_aclk(clk),
		.s00_axi_aresetn(aresetn),
		.s00_axi_awaddr(),
		.s00_axi_awprot(),
		.s00_axi_awvalid(),
		.s00_axi_awready(),
		.s00_axi_wdata(),
		.s00_axi_wstrb(),
		.s00_axi_wvalid(),
		.s00_axi_wready(),
		.s00_axi_bresp(),
		.s00_axi_bvalid(),
		.s00_axi_bready(),
		.s00_axi_araddr(),
		.s00_axi_arprot(),
		.s00_axi_arvalid(),
		.s00_axi_arready(),
		.s00_axi_rdata(),
		.s00_axi_rresp(),
		.s00_axi_rvalid(),
		.s00_axi_rready(),
		.o_intr(done),
        //AXI master i/f
        .m00_axi_awready(1'b1),
        .m00_axi_wready(wready),//
        .m00_axi_wvalid(pixel_valid),
        .m00_axi_wdata(pixel_data),
        .m00_axi_arid(),
        .m00_axi_araddr(),
        .m00_axi_arlen(),
        .m00_axi_arsize(),
        .m00_axi_arburst(),
        .m00_axi_arlock(),
        .m00_axi_arcache(),
        .m00_axi_arprot(),
        .m00_axi_arqos(),
        .m00_axi_aruser(),
        .m00_axi_arvalid(arvalid0),
        .m00_axi_arready(1'b1),
        .m00_axi_rid(),
        .m00_axi_rdata(frameData0),
        .m00_axi_rresp(),
        .m00_axi_rlast(rlast0),
        .m00_axi_ruser(),
        .m00_axi_rvalid(rvalid0),
        .m00_axi_rready()
	);
    
endmodule
