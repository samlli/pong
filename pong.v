module pong(
    input clk, 			// 100 MHz System Clock
    input reset, 		// Reset Signal
    output hSync, 		// H Sync Signal
    output vSync, 		// Veritcal Sync Signal
    output[3:0] VGA_R,  // Red Signal Bits
    output[3:0] VGA_G,  // Green Signal Bits
    output[3:0] VGA_B,  // Blue Signal Bits
    inout ps2_clk,
    inout ps2_data);

    // Clock divider 100 MHz -> 100 Hz
	wire clk100; // 25MHz clock

	reg[19:0] pixCounter = 0;      // Pixel counter to divide the clock
	assign clk100 = pixCounter[19]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only _ bits, it will reset every _ cycles
	end

    // calculate ball position
    // draw ball, upper left coords
	wire[9:0] ball_x;
	wire[8:0] ball_y;
	reg[5:0] ball_width = 6'b100000; // width of ball

    ball ball_loc(.width(ball_width), .clk(clk100), .reset(reset), .outX(ball_x), .outY(ball_y));

    // calculate paddle position
    // paddle_left

    // paddle_right


    // VGAController for drawing on screen
    VGAController board(.clk(clk), .reset(reset), .hSync(hSync), .vSync(vSync), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .ball_x(ball_x), .ball_y(ball_y), .ball_width(ball_width));



    // FSM counter for scoring


endmodule
