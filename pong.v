`timescale 1 ns/ 100 ps
module pong(
    input clkin, 			// 100 MHz System Clock
    input reset, 		// Reset Signal
    output hSync, 		// H Sync Signal
    output vSync, 		// Veritcal Sync Signal
    output[3:0] VGA_R,  // Red Signal Bits
    output[3:0] VGA_G,  // Green Signal Bits
    output[3:0] VGA_B,  // Blue Signal Bits
    inout ps2_clk,
    inout ps2_data,
    output[15:0] LEDout,
    input paddle_up,
    input paddle_down,
    input [3:0] ctrl);

    assign clk = ctrl[2] ? clkin : 1'b0; // freeze screen

    wire ball2;
    assign ball2 = ctrl[3];

    // assign LEDout[15:11] = 4'b0; // debug LEDs unused for now

    // keyboard input stuff
    // shits impossible

    // reg CLK50MHZ=0;
    // wire [31:0]keycode;
    //
    // always @(posedge(clk))begin
    //     CLK50MHZ<=~CLK50MHZ;
    // end
    //
    // PS2Receiver keyboard (
    // .clk(CLK50MHZ),
    // .kclk(ps2_clk),
    // .kdata(ps2_data),
    // .keycodeout(keycode[31:0])
    // );
    //
    // wire[7:0] rx_data;
    // assign rx_data = keycode[7:0];
    //
    // assign LEDout[15:11] = {|keycode, |keycode[7:0], |keycode[15:8], |keycode[23:16], |keycode[31:24]};

    // wire read_data, busy, err;
    // wire [7:0] rx_data;
    //
    // Ps2Interface keyboard(.ps2_clk(ps2_clk), .ps2_data(ps2_data), .clk(clk), .rst(reset), .tx_data(8'b0), .write_data(1'b0), .rx_data(rx_data), .read_data(read_data), .busy(busy), .err(err));

    // assign LEDout[10:6] = {1'b1, (rx_data==8'h1D), read_data, busy, err};

    // LED[0] - ball direction y
    // LED[1] - ball direction x

    // Clock divider 100 MHz -> 50 Hz
	wire clk50; // 50Hz clock

	reg[20:0] pixCounter = 0;      // Pixel counter to divide the clock
	assign clk50 = pixCounter[20]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only _ bits, it will reset every _ cycles
	end

    // boundaries of board
    reg[5:0] wall_width = 14;

    // calculate ball position
    // draw ball, upper left coords
	wire[9:0] ball_x;
	wire[8:0] ball_y;
	reg[5:0] ball_width = 32; // 32px width of ball
    wire ball_direction;

    ball ball_loc(.ball_width(ball_width), .wall_width(wall_width), .paddle_width(paddle_width), .paddle_length(paddle_length), .paddle_l_y(paddle_left_y), .paddle_r_y(paddle_right_y), .clk(clk50), .reset(reset), .outX(ball_x), .outY(ball_y), .ball_direction(ball_direction), .LED(LEDout[15:0]), .score_left_tens(score_left_tens), .score_left_ones(score_left_ones), .score_right_tens(score_right_tens), .score_right_ones(score_right_ones), .activein(1'b1), .activeout(activeout));

    // second ball
    wire[9:0] ball_2_x;
	wire[8:0] ball_2_y;
    wire ball_2_direction;

    // need global score variables now? both in/out and synchronize

    ball ball_2_loc(.ball_width(ball_width), .wall_width(wall_width), .paddle_width(paddle_width), .paddle_length(paddle_length), .paddle_l_y(paddle_left_y), .paddle_r_y(paddle_right_y), .clk(clk50), .reset(reset), .outX(ball_2_x), .outY(ball_2_y), .ball_direction(ball_2_direction), .LED(16'bz), .score_left_tens(4'bz), .score_left_ones(4'bz), .score_right_tens(4'bz), .score_right_ones(4'bz), .activein(activeout), .activeout(1'bz));


    // calculate paddle position
    wire[9:0] paddle_left_x;
	wire[8:0] paddle_left_y;
    wire[9:0] paddle_right_x;
	wire[8:0] paddle_right_y;
    reg[5:0] paddle_width = 20;
    reg[8:0] paddle_length = 100;

    wire[3:0] score_left_tens, score_left_ones, score_right_tens, score_right_ones;

    // paddle_left
    paddle paddle_left(.width(paddle_width), .wall_width(wall_width), .ball_width(ball_width), .length(paddle_length), .clk(clk50), .reset(reset), .ball_x(ball_x), .ball_y(ball_y), .ball_direction(ball_direction), .ball2(ball2), .ball_2_x(ball_2_x), .ball_2_y(ball_2_y), .ball_2_direction(ball_2_direction), .ai_ctrl(ctrl[0]), .side(1'b1), .up(1'b0), .down(1'b0), .outX(paddle_left_x), .outY(paddle_left_y), .LED(2'bz));

    // left side player score
    // score left_score(.ball_x(ball_x), .ball_width(ball_width), .paddle_left(1'b1), .clk(clk50), .reset(reset), .score_tens(score_left_tens), .score_ones(score_left_ones));

    // assign LEDout[15] = score_right[2];
    // assign LEDout[14] = score_right[1];
    // assign LEDout[13] = score_right[0];

    // paddle_right
    paddle paddle_right(.width(paddle_width), .wall_width(wall_width), .ball_width(ball_width), .length(paddle_length), .clk(clk50), .reset(reset), .ball_x(ball_x), .ball_y(ball_y), .ball_direction(ball_direction), .ball2(ball2), .ball_2_x(ball_2_x), .ball_2_y(ball_2_y), .ball_2_direction(ball_2_direction), .ai_ctrl(ctrl[1]), .side(1'b0), .up(paddle_up), .down(paddle_down), .outX(paddle_right_x), .outY(paddle_right_y), .LED(2'bz));

    // right side player score
    // score right_score(.ball_x(ball_x), .ball_width(ball_width), .paddle_left(1'b0), .clk(clk50), .reset(reset), .score_tens(score_right_tens), .score_ones(score_right_ones));

    // VGAController for drawing on screen
    VGAController board(.clk(clkin), .reset(reset), .hSync(hSync), .vSync(vSync), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .ball_x(ball_x), .ball_y(ball_y), .ball_width(ball_width), .ball2(ball2), .ball_2_x(ball_2_x), .ball_2_y(ball_2_y), .paddle_l_x(paddle_left_x), .paddle_l_y(paddle_left_y), .paddle_r_x(paddle_right_x), .paddle_r_y(paddle_right_y), .paddle_width(paddle_width), .paddle_length(paddle_length), .score_left_tens(score_left_tens), .score_left_ones(score_left_ones), .score_right_tens(score_right_tens), .score_right_ones(score_right_ones));



    // FSM counter for scoring


endmodule
