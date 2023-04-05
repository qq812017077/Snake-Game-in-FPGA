//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : game controller
// Description    : 
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module game_controller(
	output			game_over,
	output			snake_head,
	output			snake_body,
	output			apple,
	output 			border,
	
    input			vga_clk,
    input			clk_100hz,
    input			clk_2hz,
    input			rst_n,
    input    [10:0] col_addr,
    input    [10:0] row_addr,
    input 	 [3:0]	dir,
	input 			reset,
	input    [10:0] cell_size
);
	
	
	localparam WALL_COLLISION = 2'b10, APPLE_COLLISION = 2'b01, NO_COLLISION = 2'b00;
	//game state
	reg game_over_reg;
	assign game_over = game_over_reg;
	
	
	//collision
	wire [7:0] snake_length;
	wire [1:0] collision_type;
	wire flag;
	reg [7:0] snake_length_reg;
	reg [3:0] count;
	
	reg refresh;
	
	reg apple_collision, wall_collision;
	//cur pixel type
	wire in_apple, in_snake_head, in_snake_body, in_border;
	assign apple = in_apple;
	assign snake_head = in_snake_head;
	assign snake_body = in_snake_body;
	assign border = in_border;
	
	assign flag = !apple_collision;
	assign snake_length = snake_length_reg;
	
	
	initial begin
		game_over_reg <= 1'b0;
		snake_length_reg <= 1;
		apple_collision <= 0;
		wall_collision <= 0;
		refresh <= 1'b0;
	end
	
	// wall detector
	wall_detector WALL_DETECTOR(
		.border(in_border),
		
		.vga_clk(vga_clk),
		.rst_n(rst_n),
		.col_addr(col_addr),
		.row_addr(row_addr)
	);
	
	// apple controller
	apple_controller APPLE_CONTROLLER(
		.apple(in_apple),
		
		.vga_clk(vga_clk),
		.upd_clk(clk_100hz),		//50Hz
		.rst_n(rst_n),
		.reset(reset),
		.col_addr(col_addr),
		.row_addr(row_addr),
		.refresh(refresh),
		.cell_size(cell_size)
	);

	//snake controller
	snake_controller SNAKE_CONTROLLER(
		.snake_head(in_snake_head),
		.snake_body(in_snake_body),
		
		.vga_clk(vga_clk),
		.upd_clk(clk_2hz),		//1Hz
		.rst_n(rst_n),
		.col_addr(col_addr),
		.row_addr(row_addr),
		.move_dir(dir),
		.reset(reset),
		.length(snake_length),
		.cell_size(cell_size)
	);
	
	//collision
	snake_collision SNAKE_COLLISION(
		.collision(collision_type),
		
		.clk(vga_clk),
		.rst_n(rst_n),
		.reset(reset),
		.border(in_border),
		.snake_head(in_snake_head),
		.snake_body(in_snake_body),
		.apple(in_apple),
		.flag(flag)
	);
	
	always @(posedge vga_clk) begin
		if(reset) begin
			game_over_reg <= 1'b0;
		end
		else if(!game_over_reg) begin
			game_over_reg <= wall_collision;
		end
	end
	
	// update collision type
	always @(posedge vga_clk) begin
		if (reset) begin
			snake_length_reg <= 1;
			apple_collision <= 0;
			wall_collision <= 0;
			refresh <= 1'b0;
		end
		else begin
			if(apple_collision || wall_collision) begin		// 出现碰撞之后需要冷却几个时钟再重新检测，否则会出现bug：触发多次效果（吃一个果子生成多个果实）
				refresh <= 1'b0;
				if(count == 4'd10) begin
					apple_collision = 0;
					wall_collision = 0;
				end
				else
					count = count + 1'b1;
			end
			else begin
				count = 4'b0;
				case(collision_type)
				WALL_COLLISION: wall_collision = 1;
				APPLE_COLLISION: begin 
					apple_collision = 1;
					snake_length_reg = snake_length_reg + 1'b1;
					refresh <= 1'b1;
				end
			endcase
			end
		end
		
	end
	
endmodule
