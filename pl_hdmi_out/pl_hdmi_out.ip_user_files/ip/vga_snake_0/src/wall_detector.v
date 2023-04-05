//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : wall detector
// Description    : 
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module wall_detector(
	output 			border,
	
    input			vga_clk,
	input			rst_n,
    input    [10:0] col_addr,
    input    [10:0] row_addr
);
	
	reg in_border;
	
	assign border = in_border;
	localparam WIDTH  = 11'd1280;
	localparam HEIGHT = 11'd720;
	localparam WALL_WIDTH = 11'd10;
	//update collision state
	reg [10:0] left_border, right_border, up_border, down_border;
	
	initial begin
		left_border = WALL_WIDTH;
		up_border = WALL_WIDTH;
		right_border = WIDTH - WALL_WIDTH;
		down_border = HEIGHT - WALL_WIDTH;
	end
	
	always @(posedge vga_clk, negedge rst_n) begin
		if(!rst_n) begin
			in_border <= 0;
		end
		else begin
			if(col_addr < left_border || col_addr > right_border || row_addr < up_border || row_addr > down_border)
				in_border <= 1'b1;
			else
				in_border <= 1'b0;
		end
	end

endmodule
