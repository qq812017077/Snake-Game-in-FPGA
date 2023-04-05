//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : clock divider
// Description    : update frequence: 50Hz
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module update_clock(
    output	clk_100hz,	// output 
    output	clk_2hz,	// output 
    
    input	clk,
	input 	rst_n
);

reg [31:0] count1, count2;
reg [31:0] DIV_100HZ_COUNT;
reg [31:0] DIV_2HZ_COUNT;
parameter 	CLOCK_FREQ = 32'd74250000,	//74.25MHZ
			FREQ_100HZ = 32'd200,		//100 flip per second  -> 50Hz
			FREQ_2HZ = 32'd4;			//4 flip per second  -> 2Hz


initial begin
	DIV_100HZ_COUNT = CLOCK_FREQ / FREQ_100HZ - 1;	//count for 100hz
	// DIV_2HZ_COUNT = CLOCK_FREQ / FREQ_2HZ - 1;	//count for 2hz
	DIV_2HZ_COUNT = CLOCK_FREQ / FREQ_2HZ - 1;	//count for 2hz
end

reg clk_100hz_div;
reg clk_2hz_div;
assign clk_100hz = clk_100hz_div;
assign clk_2hz = clk_2hz_div;

// div 50hz
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		clk_100hz_div <= 0;
		count1 <= 0;
    end
	else begin
		if (count1 == DIV_100HZ_COUNT) begin
			count1 <= 0;
			clk_100hz_div <= ~clk_100hz_div; 
		end 
		else begin
			count1 <= count1 + 1'b1;
		end
	end
end

// div 1hz
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		clk_2hz_div <= 0;
		count2 <= 0;
    end
	else begin
		if (count2 == DIV_2HZ_COUNT) begin
			count2 <= 0;
			clk_2hz_div <= ~clk_2hz_div;
		end 
		else begin
			count2 <= count2 + 1'b1;
		end
	end
end
endmodule
