// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:vga_snake:1.0
// IP Revision: 2

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module vga_snake_0 (
  RED,
  GREEN,
  BLUE,
  HSYNC,
  VSYNC,
  READY,
  VGA_CLK,
  RST_N,
  KEY_TURNLEFT,
  KEY_TURNRIGHT,
  KEY_RESET
);

output wire [7 : 0] RED;
output wire [7 : 0] GREEN;
output wire [7 : 0] BLUE;
output wire HSYNC;
output wire VSYNC;
output wire READY;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 VGA_CLK CLK" *)
input wire VGA_CLK;
input wire RST_N;
input wire KEY_TURNLEFT;
input wire KEY_TURNRIGHT;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 KEY_RESET RST" *)
input wire KEY_RESET;

  vga_snake inst (
    .RED(RED),
    .GREEN(GREEN),
    .BLUE(BLUE),
    .HSYNC(HSYNC),
    .VSYNC(VSYNC),
    .READY(READY),
    .VGA_CLK(VGA_CLK),
    .RST_N(RST_N),
    .KEY_TURNLEFT(KEY_TURNLEFT),
    .KEY_TURNRIGHT(KEY_TURNRIGHT),
    .KEY_RESET(KEY_RESET)
  );
endmodule
