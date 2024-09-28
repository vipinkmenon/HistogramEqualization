module cumul_hist #(parameter pixLevel=0,imageSize=640*480,outWidth=$clog2(imageSize))(
input		  			  i_clk,
input					  i_reset_n,
input	[7:0] 			  i_pixel,
input		  			  i_pixel_valid,
output reg	[outWidth-1:0]	  o_cum_hist
);

always @(posedge i_clk)
begin
	if(!i_reset_n)
		o_cum_hist <= 0;
	else if(i_pixel_valid)
	begin
		if(i_pixel<=pixLevel)
			o_cum_hist <= o_cum_hist+1;
	end
end

endmodule