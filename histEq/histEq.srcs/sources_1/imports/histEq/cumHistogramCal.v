module cumHistogramCal #(imageSize=640*480)(
input	i_clk,
input	i_reset_n,
input	[7:0] i_pixel_data,
input	i_pixel_valid
);

wire [$clog2(imageSize)-1:0] cum_histogram[255:0];

generate
genvar i;
	for(i=0;i<256;i=i+1)
	begin:genBlock
	cumul_hist #(.pixLevel(i),.imageSize(640*480))cumul_hist_inst(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_pixel(i_pixel_data),
    .i_pixel_valid(i_pixel_valid),
    .o_cum_hist(cum_histogram[i])
);
	end
endgenerate

endmodule