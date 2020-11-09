module pong(
    input clk, 			// 100 MHz System Clock
    input reset, 		// Reset Signal
    output hSync, 		// H Sync Signal
    output vSync, 		// Veritcal Sync Signal
    output[3:0] VGA_R,  // Red Signal Bits
    output[3:0] VGA_G,  // Green Signal Bits
    output[3:0] VGA_B,  // Blue Signal Bits
    inout ps2_clk,
    inout ps2_data,
    output[15:0] LEDout);

    assign LEDout[15:6] = 14'b0; // unused for now
    // LED[0] - ball direction y
    // LED[1] - ball direction x

    // Clock divider 100 MHz -> 50 Hz
	wire clk50; // 25MHz clock

	reg[20:0] pixCounter = 0;      // Pixel counter to divide the clock
	assign clk50 = pixCounter[20]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only _ bits, it will reset every _ cycles
	end

    // calculate ball position
    // draw ball, upper left coords
	wire[9:0] ball_x;
	wire[8:0] ball_y;
	reg[5:0] ball_width = 32; // 32px width of ball

    ball ball_loc(.width(ball_width), .clk(clk50), .reset(reset), .outX(ball_x), .outY(ball_y), .LED(LEDout[1:0]));


    // calculate paddle position
    wire[9:0] paddle_left_x;
	wire[8:0] paddle_left_y;
    wire[9:0] paddle_right_x;
	wire[8:0] paddle_right_y;
    reg[5:0] paddle_width = 20;
    reg[8:0] paddle_length = 200;

    // paddle_left
    paddle paddle_left(.width(paddle_width), .length(paddle_length), .clk(clk50), .reset(reset), .ball_x(ball_x), .ball_y(ball_y), .ai_ctrl(1'b0), .side(1'b0), .outX(paddle_left_x), .outY(paddle_left_y), .LED(LEDout[3:2]));

    // paddle_right
    paddle paddle_right(.width(paddle_width), .length(paddle_length), .clk(clk50), .reset(reset), .ball_x(ball_x), .ball_y(ball_y), .ai_ctrl(1'b0), .side(1'b1), .outX(paddle_right_x), .outY(paddle_right_y), .LED(LEDout[5:4]));

    // VGAController for drawing on screen
    VGAController board(.clk(clk), .reset(reset), .hSync(hSync), .vSync(vSync), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .ball_x(ball_x), .ball_y(ball_y), .ball_width(ball_width), .paddle_l_x(0), .paddle_l_y(140), .paddle_r_x(620), .paddle_r_y(140), .paddle_width(20), .paddle_length(200));



    // FSM counter for scoring


endmodule
