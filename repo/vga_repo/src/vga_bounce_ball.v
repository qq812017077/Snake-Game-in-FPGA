//----------------------------------------------------------------------------
// Project Name   : vga top
// File Name	  : vga bounce ball
// Description    : vga output signal generate, here to generate a bouncing ball.
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module vga_bounce_ball(
    output reg [7:0] R,
    output reg [7:0] G,
    output reg [7:0] B,
    
    input             clk,
    input             rst_n,
    input      [10:0] col_addr,
    input      [10:0] row_addr,
    input             ready
);

localparam WIDTH  = 32'd1280;
localparam HEIGHT = 32'd720;

reg [31:0] x_pos;
reg [31:0] y_pos;
reg [31:0] x_vel;
reg [31:0] y_vel;

reg [24:0] count;
reg [24:0] DIV_COUNT;
reg clk_div;


parameter 	CLOCK_FREQ = 50000000,
			FREQ_PER_SEC = 100;
			
localparam 	BALL_RADIUS = 32'd100,
			BALL_SPEED_X = -32'd500,
			BALL_SPEED_Y = -32'd500;	//The velocity has to be a multiple of FREQ_PER_SEC

localparam  BLACK = 8'b0000_0000,
			WHITE = 8'b1111_1111;

// Set initial ball position and velocity
initial begin
    x_pos = WIDTH/2;
    y_pos = HEIGHT/2;
    x_vel = BALL_SPEED_X / FREQ_PER_SEC;
    y_vel = BALL_SPEED_Y / FREQ_PER_SEC;
	// x_vel = -1;
    // y_vel = -1;
	// count = 0;
	DIV_COUNT = CLOCK_FREQ / FREQ_PER_SEC - 1;
	// DIV_COUNT = 499999;
end

// div
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		clk_div <= 0;
    end
	else begin
		if (count == DIV_COUNT) begin  //based on 50Mhz, so 500000 clk means 10ms
			count <= 0;
			clk_div <= ~clk_div;  // 生成50%占空比的时钟
		end 
		else begin
			count <= count + 1;
		end
	end
end

// Bounce ball off walls
always @(posedge clk_div, negedge rst_n) begin
    if(!rst_n) begin
        x_pos <= WIDTH/2;
        y_pos <= HEIGHT/2;
    end
    else begin
        // update x position and velocity
		if(((x_pos + x_vel + BALL_RADIUS) > WIDTH)|| ((x_pos + x_vel - BALL_RADIUS) < 32'd1)) 
		// 我们这里不使用0作为边界 因为0会发生问题。猜测是负数带来的问题。
			x_vel <= -x_vel;
		
        x_pos <= x_pos + x_vel;
        
		// update y position and velocity
		if(((y_pos + y_vel + BALL_RADIUS) > HEIGHT) || ((y_pos + y_vel - BALL_RADIUS) < 32'd1))
		// 我们这里不使用0作为边界 因为0会发生问题。猜测是负数带来的问题。
			y_vel <= -y_vel;
        y_pos <= y_pos + y_vel;
    end
end

// Display ball
reg [7:0] color_table;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        color_table <= BLACK;
    else if(col_addr >= 11'd0 && col_addr < 11'd1280 && row_addr >= 11'd0 && row_addr < 11'd720) begin
        if ((row_addr - y_pos)*(row_addr - y_pos) + (col_addr - x_pos)*(col_addr - x_pos) <= BALL_RADIUS * BALL_RADIUS)  begin
            color_table = WHITE;
        end
        else 
            color_table <= BLACK;
    end
    else
        color_table <= BLACK;
end

always @(color_table, ready) begin
    if(ready) begin
        case(color_table) 
            BLACK: begin R = 8'b0000_0000; G = 8'b0000_0000; B = 8'b0000_0000; end
            WHITE: begin R = 8'b1111_1111; G = 8'b1111_1111; B = 8'b1111_1111; end
            default : begin R = 8'b0000_0000; G = 8'b0000_0000; B = 8'b0000_0000; end
        endcase
    end
    else begin
        R = 8'b0000_0000;
        G = 8'b0000_0000;
        B = 8'b0000_0000;
    end
end

endmodule
