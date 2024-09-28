
`timescale 1 ns / 1 ps

	module histEq_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,
        output o_intr,
        //AXI master i/f
        output wire        m00_axi_arid,
        output wire  [31:0] m00_axi_araddr,
        output wire [7: 0] m00_axi_arlen,
        output wire [2: 0] m00_axi_arsize,
        output wire [1: 0] m00_axi_arburst,
        output wire        m00_axi_arlock,
        output wire [3: 0] m00_axi_arcache,
        output wire [2: 0] m00_axi_arprot,
        output wire [3: 0] m00_axi_arqos,
        output wire [0: 0] m00_axi_aruser,
        output wire        m00_axi_arvalid,
        input wire         m00_axi_arready,
        input wire         m00_axi_rid,
        input wire [31: 0] m00_axi_rdata,
        input wire [1 : 0] m00_axi_rresp,
        input wire         m00_axi_rlast,
        input wire [0 : 0] m00_axi_ruser,
        input wire         m00_axi_rvalid,
        output wire        m00_axi_rready,
        output             m00_axi_awvalid,
        input wire         m00_axi_awready,
        output      [31:0] m00_axi_awaddr,
        output wire [2: 0] m00_axi_awprot,
        output wire        m00_axi_awid,
        output wire [7: 0] m00_axi_awlen,
        output wire [2: 0] m00_axi_awsize,
        output wire [1: 0] m00_axi_awburst,
        output wire        m00_axi_awlock,
        output wire [3: 0] m00_axi_awcache,
        output wire [3: 0] m00_axi_awqos,
        output wire [0: 0] m00_axi_awuser,
        output wire         m00_axi_wvalid,
        input wire         m00_axi_wready,
        output wire [31: 0] m00_axi_wdata,
        output wire [3:0] m00_axi_wstrb,
        output wire         m00_axi_wlast,
        output wire [0 : 0] m00_axi_wuser,
        input   wire        m00_bvalid,
        output              m00_bready,
        input wire [1:0]    m00_bresp,
        input               m00_bid,
        input               m00_buser
	);
// Instantiation of Axi Bus Interface S00_AXI
	histEq_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) histEq_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		.m00_axi_arid(m00_axi_arid),
	    .m00_axi_araddr(m00_axi_araddr),
	    .m00_axi_arlen(m00_axi_arlen),
	    .m00_axi_arsize(m00_axi_arsize),
	    .m00_axi_arburst(m00_axi_arburst),
	    .m00_axi_arlock(m00_axi_arlock),
	    .m00_axi_arcache(m00_axi_arcache),
	    .m00_axi_arprot(m00_axi_arprot),
	    .m00_axi_arqos(m00_axi_arqos),
	    .m00_axi_aruser(m00_axi_aruser),
	    .m00_axi_arvalid(m00_axi_arvalid),
	    .m00_axi_arready(m00_axi_arready),
	    .m00_axi_rid(m00_axi_rid),
	    .m00_axi_rdata(m00_axi_rdata),
	    .m00_axi_rresp(m00_axi_rresp),
	    .m00_axi_rlast(m00_axi_rlast),
	    .m00_axi_ruser(m00_axi_ruser),
	    .m00_axi_rvalid(m00_axi_rvalid),
	    .m00_axi_rready(m00_axi_rready),
		.m00_axi_awvalid(m00_axi_awvalid),
        .m00_axi_awready(m00_axi_awready),
        .m00_axi_awaddr(m00_axi_awaddr),
        .m00_axi_awprot(m00_axi_awprot),
        .m00_axi_awid(m00_axi_awid),
        .m00_axi_awlen(m00_axi_awlen),
        .m00_axi_awsize(m00_axi_awsize),
        .m00_axi_awburst(m00_axi_awburst),
        .m00_axi_awlock(m00_axi_awlock),
        .m00_axi_awcache(m00_axi_awcache),
        .m00_axi_awqos(m00_axi_awqos),
        .m00_axi_awuser(m00_axi_awuser),
        .m00_axi_wvalid(m00_axi_wvalid),
        .m00_axi_wready(m00_axi_wready),
        .m00_axi_wdata(m00_axi_wdata),
        .m00_axi_wstrb(m00_axi_wstrb),
        .m00_axi_wlast(m00_axi_wlast),
        .m00_axi_wuser(m00_axi_wuser),
        .m00_bvalid(m00_bvalid),
        .m00_bready(m00_bready),
        .m00_bresp(m00_bresp),
        .m00_bid(m00_bid),
        .m00_buser(m00_buser),
		//interrupt
        .o_intr(o_intr)
	);

	// Add user logic here
	
	// User logic ends

	endmodule
