//----------------------------------------------------------------------------
// Project Name   : HDMI_Output_top
// Description    : Generate VGA signal, then convert it to DVI, and output from HDMI port.
//----------------------------------------------------------------------------
//  Version             Comments
//------------      ----------------
//    0.1              Created
//----------------------------------------------------------------------------

module HDMI_Output_Top(
    output [2:0] TMDS_DATA_P,
    output [2:0] TMDS_DATA_N,
    output       TMDS_CLK_P,
    output       TMDS_CLK_N,
    output       HDMI_OUT_EN,

    input        CLK,   // FPGA input clock 50 MHz, for get 74.25 MHz (1280 x 720) pixel clock
	input		 KEY_TURNLEFT,
	input		 KEY_TURNRIGHT,
	input		 KEY_RESET
);

wire clk_74p25MHz;
wire clk_371p25MHz;  // 74p25 * 5
wire locked;

clk_wiz_0 CLK_PLL_INST(
    .clk_out1(clk_74p25MHz),
    .clk_out2(clk_371p25MHz),
    .locked(locked),

    .clk_in1(CLK),
    .reset(1'b0)
);

wire Hsync;
wire Vsync;
wire ready;
wire [7:0] Red;
wire [7:0] Green;
wire [7:0] Blue;

vga_snake_0 VGA_SNAKE_INST(
    .RED(Red),
    .GREEN(Green),
    .BLUE(Blue),
    .HSYNC(Hsync),
    .VSYNC(Vsync),
    .READY(ready),

    .VGA_CLK(clk_74p25MHz),  // for 1280 x 720
    .RST_N(locked),
	.KEY_TURNLEFT(KEY_TURNLEFT),
	.KEY_TURNRIGHT(KEY_TURNRIGHT),
	.KEY_RESET(KEY_RESET)
);

// vga_top_0 VGA_TOP_INST(
    // .RED(Red),
    // .GREEN(Green),
    // .BLUE(Blue),
    // .HSYNC(Hsync),
    // .VSYNC(Vsync),
    // .READY(ready),

    // .CLK(clk_74p25MHz),  // for 1280 x 720
    // .RST_N(locked)
// );

rgb2dvi_0 RGB2DVI_INST(
    .TMDS_Clk_p(TMDS_CLK_P),
    .TMDS_Clk_n(TMDS_CLK_N),
    .TMDS_Data_p(TMDS_DATA_P),
    .TMDS_Data_n(TMDS_DATA_N),
    .aRst(1'b0), 
    .aRst_n(1'b1), 

    .vid_pData({Red, Blue, Green}),
    .vid_pVDE(ready),
    .vid_pHSync(Hsync),
    .vid_pVSync(Vsync),
    .PixelClk(clk_74p25MHz),
    .SerialClk(clk_371p25MHz)
); 

assign HDMI_OUT_EN = ready ? 1'b1 : 1'b0;

endmodule

