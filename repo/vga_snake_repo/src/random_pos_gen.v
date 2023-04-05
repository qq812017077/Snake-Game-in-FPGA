//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : random pos gen
// Description    : generate random position in screen.
//					NOTE: randX, randY use different clk.
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module random_pos_gen(
    output	[10:0]	randX,	// 
    output	[10:0]	randY,	// 
    
    input			vga_clk,
    input			upd_clk,
	input 			rst_n,
	input    [10:0] cell_size
);

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
reg [10:0] i;
reg [10:0] j;

assign randX = i;
assign randY = j;

always @(posedge vga_clk, negedge rst_n) begin
	if(!rst_n) begin
		i <= left_border;
    end
	else begin
		if(i > right_border) begin 
			i <= left_border;
		end
		else begin 
			i <= i + cell_size; 
		end
		
	end
end

always @(posedge upd_clk, negedge rst_n) begin
	if(!rst_n) begin
		j <= up_border;
    end
	else begin
		if(j > down_border) begin 
			j <= up_border;
		end
		else begin 
			j <= j + cell_size;
		end
		
	end
end
endmodule
