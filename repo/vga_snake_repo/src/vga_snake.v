//----------------------------------------------------------------------------
// Project Name   : vga_top
// Description    : vga signal generate, with 1280 x 720 pixel.
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module vga_snake(
    output [7:0] RED,
    output [7:0] GREEN,
    output [7:0] BLUE,
    output       HSYNC,
    output       VSYNC,
    output       READY,

    input        VGA_CLK,  // 74.25 MHz, for 1280 x 720 pixel clock
    input        RST_N,
	
	input		 KEY_TURNLEFT,
	input		 KEY_TURNRIGHT,
	input		 KEY_RESET
);

wire CLK_100HZ;
wire CLK_2HZ;
wire rdy;
wire [10:0] cl_adr;
wire [10:0] rw_adr;
assign READY = rdy;

// key input -> direction
wire [3:0] input_dir;
wire input_reset;
reg [10:0] unit_size;

wire game_over;
wire in_border;
wire in_apple;
wire in_snake_head;
wire in_snake_body;

initial begin
	unit_size = 11'd20;	//Drawing snake and apple should base on the cell.
end

// 分频到50Hz
update_clock UPDATE_CLK(
	.clk_100hz(CLK_100HZ),
	.clk_2hz(CLK_2HZ),
	
	.clk(VGA_CLK),
	.rst_n(RST_N)
);

//VGA时序产生
sync_gen SYNC_GEN_INST(
    .Hsync(HSYNC),
    .Vsync(VSYNC),
    .ready(rdy),
    .col_addr(cl_adr),
    .row_addr(rw_adr),

    .clk(VGA_CLK),
    .rst_n(RST_N)
);

//movement direction
game_key_detect GAME_KEY_DETECT(
	.dir(input_dir),
	.reset(input_reset),
	
	.clk(CLK_100HZ),		//100Hz
	.rst_n(RST_N),
	.key_turn_left(KEY_TURNLEFT),
	.key_turn_right(KEY_TURNRIGHT),
	.key_reset(KEY_RESET)
);


//snake game
game_controller GAME_CONTROLLER(
	.game_over(game_over),
	.snake_head(in_snake_head),
	.snake_body(in_snake_body),
	.apple(in_apple),
	.border(in_border),
	
	.vga_clk(VGA_CLK),
	.clk_100hz(CLK_100HZ),		//50Hz
	.clk_2hz(CLK_2HZ),		//1Hz
	.rst_n(RST_N),
	.col_addr(cl_adr),
    .row_addr(rw_adr),
	.dir(input_dir),
	.reset(input_reset),
	.cell_size(unit_size)
);

vga_display VGA_DISPLAY(
    .R(RED),
    .G(GREEN),
    .B(BLUE),

    .clk(VGA_CLK),
    .rst_n(RST_N),
    .ready(rdy),
    .game_over(game_over),
	.snake_head(in_snake_head),
	.snake_body(in_snake_body),
	.apple(in_apple),
	.border(in_border)
	
);

endmodule


