//----------------------------------------------------------------------------
// Project Name   : vga top
// File Name	  : vga display
// Description    : vga output signal generate
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module vga_display(
    output reg [7:0] R,
    output reg [7:0] G,
    output reg [7:0] B,
    
    input            clk,
    input            rst_n,
    input            ready,
	input			 game_over,
	input			 snake_head,
	input			 snake_body,
	input			 apple,
	input 			 border
);

localparam WIDTH  = 32'd1280;
localparam HEIGHT = 32'd720;

localparam  WALL = 8'b0000_0000,
			BODY = 8'b0000_0011,
			HEAD = 8'b0000_1100,
			APPLE = 8'b0011_0000,
			BG = 8'b1100_0000,
			OVER = 8'b1111_1111;


// Display
reg [7:0] color_table;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        color_table <= BG;
    else begin
		if(game_over) color_table <= OVER;
		else if(border) color_table <= WALL;
		else if(apple) color_table <= APPLE;
		else if(snake_head) color_table <= HEAD;
		else if(snake_body) color_table <= BODY;
		else color_table <= BG;
			
	end
end

always @(color_table, ready) begin
    if(ready) begin
        case(color_table) 
            WALL: 	begin R = 8'b0000_0000; G = 8'b0000_0000; B = 8'b1111_1111; end
            BODY: 	begin R = 8'b0000_0000; G = 8'b1111_1111; B = 8'b0000_0000; end
            HEAD: 	begin R = 8'b0111_1111; G = 8'b1111_1111; B = 8'b0111_1111; end
            APPLE: 	begin R = 8'b1111_1111; G = 8'b0000_0000; B = 8'b0000_0000; end
            BG: 	begin R = 8'b0000_0000; G = 8'b0000_0000; B = 8'b0000_0000; end
            OVER: 	begin R = 8'b1111_1111; G = 8'b1111_1111; B = 8'b1111_1111; end
            default:begin R = 8'b0000_0000; G = 8'b0000_0000; B = 8'b0000_0000; end
        endcase
    end
    else begin
        R = 8'b0000_0000;
        G = 8'b0000_0000;
        B = 8'b0000_0000;
    end
end

endmodule
