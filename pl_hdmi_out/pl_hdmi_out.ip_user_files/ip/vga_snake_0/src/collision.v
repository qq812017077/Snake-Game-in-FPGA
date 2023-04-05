//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : collision
// Description    : 
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module snake_collision(
	output reg[1:0] collision,
	
    input			clk,
    input			rst_n,
    input 			reset,
	input			border,
	input			snake_head,
	input 			snake_body,
	input 			apple,
	input			flag
);
	localparam WALL_COLLISION = 2'b10, APPLE_COLLISION = 2'b01, NO_COLLISION = 2'b00;
	
	//update collision state
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n || reset) begin
			collision  <= NO_COLLISION;
		end
		else begin
			if( (border || snake_body)&& snake_head)
				collision <= WALL_COLLISION;
			else if(apple && snake_head && flag)
				collision <= APPLE_COLLISION;
			else 
				collision <= NO_COLLISION;
		end
	end

endmodule
