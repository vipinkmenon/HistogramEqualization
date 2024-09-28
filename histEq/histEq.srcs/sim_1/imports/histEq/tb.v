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

module tb();
    
reg clk;
reg aresetn;


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

reg [7:0] imgData;
reg tvalid;
integer sentSize;
integer file;
integer i;


initial
begin
	
end

initial
 begin
    sentSize = 0;
	tvalid = 0;
	@(posedge aresetn);
    #100;
    //forever
    //begin
        file = $fopen("input.bin","rb");
        @(posedge clk);  
        for(i=0;i<640*480;i=i+1)
        begin
            @(posedge clk);
            #1;
            $fscanf(file,"%c",imgData[7:0]); //24bit data
            tvalid <= 1'b1;
            sentSize = sentSize + 1;
            //@(posedge clk);
            //tvalid <= 1'b0;
            //repeat(3)
            //    @(posedge clk);
        end  
        $fclose(file);
        @(posedge clk);
        tvalid <= 1'b0;
        $stop;
       // repeat(100)
       //     @(posedge clk);
   // end
end

cumHistogramCal histCalc(
.i_clk(clk),
.i_reset_n(aresetn),
.i_pixel_data(imgData),
.i_pixel_valid(tvalid)
);
    
endmodule
