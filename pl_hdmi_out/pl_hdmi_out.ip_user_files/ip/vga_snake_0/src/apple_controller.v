//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : apple controller
// Description    : 
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module apple_controller(
	output			apple,
	
    input			vga_clk,
    input			upd_clk,
    input			rst_n,
    input    [10:0] col_addr,
    input    [10:0] row_addr,
    input 			reset,
    input 			refresh,
	input    [10:0] cell_size
);

reg [10:0] appleX;
reg [10:0] appleY;

//random position
wire [10:0] rnd_x;
wire [10:0]	rnd_y;

reg in_apple;
reg apple_inX;
reg apple_inY;
assign apple = in_apple;


//随机数生成
random_pos_gen RANDOM_POS_GEN(
	.randX(rnd_x),
	.randY(rnd_y),
	
	.vga_clk(vga_clk),			//74.25MHz
	.upd_clk(upd_clk),			//50Hz
	.rst_n(rst_n),
	.cell_size(cell_size)
);

always @(posedge vga_clk, negedge rst_n) begin
	if(!rst_n || reset) begin
		appleX= 11'd200;	//initial position
		appleY= 11'd200;
    end
	else begin
		if(refresh) begin
			appleX=rnd_x;
			appleY=rnd_y;
		end
	end
end

always @(posedge vga_clk) begin
	apple_inX = (col_addr > appleX && col_addr < (appleX + cell_size));
	apple_inY = (row_addr > appleY && row_addr < (appleY + cell_size));
	in_apple = apple_inX && apple_inY;
end

endmodule
