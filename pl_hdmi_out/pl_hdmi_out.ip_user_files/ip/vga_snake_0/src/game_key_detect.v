//----------------------------------------------------------------------------
// Project Name   : vga snake
// File Name	  : snake move detect
// Description    : according to user's input, detect the snake move direction.
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module game_key_detect(
    output	[3:0] dir,	//
	output  reset,
    
    input	clk,		// 100Hz
	input 	rst_n,
	input 	key_turn_left,
	input 	key_turn_right,
	input   key_reset
);

reg [3:0] move_dir;
reg reset_reg;

assign dir = move_dir;
assign reset = reset_reg;
parameter UP = 4'b1000, DOWN = 4'b0100, LEFT = 4'b0010, RIGHT = 4'b0001;
//----------------------------------------------------- key press down confirm
reg [2:0] key_press_down;
reg [2:0] key_press_down_r;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        key_press_down <= 3'b111;
        key_press_down_r <= 3'b111;
    end
    else begin
        key_press_down <= {key_reset, key_turn_right, key_turn_left}; // no input --> 1111 |  input --> 1110 | 1101 | 1011 | 0111
        key_press_down_r <= key_press_down;
    end
end

wire [2:0] key_press_down_conf;
assign key_press_down_conf = key_press_down_r & (~key_press_down);

//------------------------------------------------------ 20ms hysteresis range
reg [3:0] cnt_k;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        cnt_k <= 20'd0;
    else if(key_press_down_conf != 2'd0)  // key pressed down found, start count
        cnt_k <= 20'd0;
    else
        cnt_k <= cnt_k + 1'b1;
end

reg [2:0] sampled_key_info;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        sampled_key_info <= 3'b111;
    else begin
		if(cnt_k == 2)  // 20ms jetter covered, sample the key info 
			sampled_key_info <= {key_reset, key_turn_right, key_turn_left};
		else
			sampled_key_info <= 3'b111;
	end
end

//------------------------------------------------------ 20ms hysteresis range
wire input_turn_left, input_turn_right, input_reset; 
assign input_turn_left = !sampled_key_info[0];
assign input_turn_right = !sampled_key_info[1];
assign input_reset = !sampled_key_info[2];
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		move_dir <= RIGHT;
    end
	else begin
		if(input_reset) begin
			reset_reg <= 1'b1;
			move_dir <= RIGHT;
		end
		else begin
			reset_reg <= 1'b0;
			if(input_turn_left)begin
				case(move_dir)
					UP: 	move_dir <= LEFT;
					DOWN:	move_dir <= RIGHT;
					LEFT:	move_dir <= DOWN;
					RIGHT:	move_dir <= UP;
				endcase
			end
			else if(input_turn_right) begin
				case(move_dir)
					UP: 	move_dir <= RIGHT;
					DOWN:	move_dir <= LEFT;
					LEFT:	move_dir <= UP;
					RIGHT:	move_dir <= DOWN;
				endcase
			end
			else move_dir <= move_dir;	//keep last input if no input.
		end
	end
end

endmodule
