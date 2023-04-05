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
	
	input		 KEY_UP,	// key for movement
	input		 KEY_DOWN,
	input		 KEY_LEFT,
	input		 KEY_RIGHT
);

wire UPD_CLK;
wire rdy;
wire [10:0] cl_adr;
wire [10:0] rw_adr;
assign READY = rdy;

// key input -> direction
wire [3:0] input_dir;
reg [10:0] unit_size;

wire game_over;
wire in_border;
wire in_apple;
wire in_snake_head;
wire in_snake_body;

initial begin
	unit_size = 11'd10;	//Drawing snake and apple should base on the cell.
end

// 分频到50Hz
update_clock UPDATE_CLK(
	.update_clk(UPD_CLK),
	
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
snake_move_detect SNAKE_MOVE_DETECT(
	.dir(input_dir),
	
	.clk(UPD_CLK),		//50Hz
	.rst_n(RST_N),
	.key_up(KEY_UP),
	.key_down(KEY_DOWN),
	.key_left(KEY_LEFT),
	.key_right(KEY_RIGHT)
);


//snake game
game_controller GAME_CONTROLLER(
	.game_over(game_over),
	.snake_head(in_snake_head),
	.snake_body(in_snake_body),
	.apple(in_apple),
	.border(in_border),
	
	.vga_clk(VGA_CLK),
	.clk(UPD_CLK),		//50Hz
	.rst_n(RST_N),
	.col_addr(cl_adr),
    .row_addr(rw_adr),
	.dir(input_dir),
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


