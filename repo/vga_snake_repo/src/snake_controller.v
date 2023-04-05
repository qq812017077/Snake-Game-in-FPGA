//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : snake controller
// Description    : 
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module snake_controller(
	output			snake_head,
	output			snake_body,
	
    input			vga_clk,
    input			upd_clk,
    input			rst_n,
    input    [10:0] col_addr,
    input    [10:0] row_addr,
    input 	 [3:0]	move_dir,
    input 			reset,
	input    [7:0]	length,
	input    [10:0] cell_size
);
	
	parameter UP = 4'b1000, DOWN = 4'b0100, LEFT = 4'b0010, RIGHT = 4'b0001;
	
	integer index1, index2, index3;
	reg [10:0] snakeX[0:255];
	reg [10:0] snakeY[0:255];
	
	reg in_snake_head, in_snake_body;
	assign snake_head = in_snake_head;
	assign snake_body = in_snake_body;
	
	initial begin
		for(index1 = 1; index1 < 32; index1 = index1+1) begin
				snakeX[index1] = 1400;
				snakeY[index1] = 900;
			end
			snakeX[0] = 50; //center
			snakeY[0] = 500;
	end
	// update snake position
	always @(posedge upd_clk) begin
		if(reset) begin
			for(index1 = 1; index1 < 32; index1 = index1+1) begin
				snakeX[index1] = 1400;
				snakeY[index1] = 900;
			end
			snakeX[0] = 50; //center
			snakeY[0] = 500;
		end
		else begin
			if( move_dir == UP || move_dir == DOWN || move_dir == LEFT || move_dir == RIGHT) begin
				for(index2 = 255; index2 > 0; index2 = index2 - 1) begin
					if(index2 <= (length - 1)) begin
					snakeX[index2] = snakeX[index2 - 1];
					snakeY[index2] = snakeY[index2 - 1];
					end
				end
			end

			case(move_dir)
				UP: 	snakeY[0] <= (snakeY[0] - cell_size);
				DOWN: 	snakeY[0] <= (snakeY[0] + cell_size);
				LEFT: 	snakeX[0] <= (snakeX[0] - cell_size);
				RIGHT: 	snakeX[0] <= (snakeX[0] + cell_size);
				default: begin
					snakeX[0] <= snakeX[0];
					snakeY[0] <= snakeY[0];
				end
			endcase
		end
	end
	
	//update head state
	always @(posedge vga_clk, negedge rst_n) begin
		if(!rst_n || reset) begin
			in_snake_head <= 0;
		end
		else begin
			in_snake_head <= (col_addr > snakeX[0] && col_addr < (snakeX[0]+cell_size)) && (row_addr > snakeY[0] && row_addr < (snakeY[0]+cell_size));
		end
	end
	
	//update body state
	always @(posedge vga_clk, negedge rst_n) begin
		if(!rst_n || reset) begin
			in_snake_body <= 1'b0;
		end
		else begin
			in_snake_body = 1'b0;
			for(index3 = 1; index3 < 255; index3 = index3 + 1) begin
				if( index3 < length && in_snake_body == 1'b0) begin
					if((col_addr > snakeX[index3] && col_addr < (snakeX[index3]+cell_size)) && (row_addr > snakeY[index3] && row_addr < (snakeY[index3]+cell_size)))
						in_snake_body = 1'b1;
				end
			end
		end
	end
	
endmodule
