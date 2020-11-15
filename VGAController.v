`timescale 1 ns/ 100 ps
module VGAController(
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data,

	input[9:0] ball_x,	// ball data
	input[8:0] ball_y,
	input[5:0] ball_width,

	input[9:0] paddle_l_x, // paddle data
	input[8:0] paddle_l_y,
	input[9:0] paddle_r_x,
	input[8:0] paddle_r_y,
	input[5:0] paddle_width,
	input[8:0] paddle_length,

	input[3:0] score_left_tens, score_left_ones,
	input[3:0] score_right_tens, score_right_ones);

	// Lab Memory Files Location
	localparam FILES_PATH = "";	// in root

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;

	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display(
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)

	// Image Data to Map Pixel Location to Color Address
	localparam
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	RAM #(
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel

	RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading


	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color
	assign colorOut = active ? colorData : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = (ball | paddle_l | paddle_r | l_tens | l_ones | r_tens | r_ones) ? 12'hfff : colorOut; // if in ball draw white otherwise draw regular background

	// Determine if area inside ball
	reg ball;
	reg paddle_l, paddle_r;
	reg l_tens, l_ones, r_tens, r_ones;

	always @(screenEnd) begin
		// ball
		if(x>=ball_x && x<=ball_x+ball_width && y>=ball_y && y<=ball_y+ball_width)
			ball <= 1'b1; // coord inside ball
		else
			ball <= 1'b0; // coord outside ball

		// paddle left
		if(x>paddle_l_x && x<paddle_l_x+paddle_width && y>paddle_l_y && y<paddle_l_y+paddle_length)
			paddle_l <= 1'b1;
		else
			paddle_l <= 1'b0;

		// paddle right
		if(x>paddle_r_x && x<paddle_r_x+paddle_width && y>paddle_r_y && y<paddle_r_y+paddle_length)
			paddle_r <= 1'b1;
		else
			paddle_r <= 1'b0;


		// display a two digit score on left and right of screen
		// each score has a 'tens' and 'ones' digit
		// get ready for some shitty code
		// cover your eyes kids

		// score left
		// tens
		if(score_left_tens==0) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>80 && x<90 && y>30 && y<80) || (x>100 && x<110 && y>30 && y<80) || (x>80 && x<110 && y>70 && y<80))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==1) begin
			if((x>100 && x<110 && y>30 && y<80))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==2) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>80 && x<90 && y>50 && y<80) || (x>100 && x<110 && y>30 && y<60) || (x>80 && x<110 && y>70 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==3) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>100 && x<110 && y>30 && y<80) || (x>80 && x<110 && y>70 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==4) begin
			if((x>80 && x<90 && y>30 && y<60) || (x>100 && x<110 && y>30 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==5) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>80 && x<90 && y>30 && y<60) || (x>100 && x<110 && y>50 && y<80) || (x>80 && x<110 && y>70 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==6) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>80 && x<90 && y>30 && y<80) || (x>100 && x<110 && y>50 && y<80) || (x>80 && x<110 && y>70 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==7) begin
			if((x>100 && x<110 && y>30 && y<80) || (x>80 && x<110 && y>30 && y<40))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==8) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>80 && x<90 && y>30 && y<80) || (x>100 && x<110 && y>30 && y<80) || (x>80 && x<110 && y>70 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end
		else if(score_left_tens==9) begin
			if((x>80 && x<110 && y>30 && y<40) || (x>80 && x<90 && y>30 && y<60) || (x>100 && x<110 && y>30 && y<80) || (x>80 && x<110 && y>70 && y<80) || (x>80 && x<110 && y>50 && y<60))
				l_tens <= 1'b1;
			else
				l_tens <= 1'b0;
		end

		// ones
		// holy fuck
		// but it works, so...
		if(score_left_ones==0) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>120 && x<130 && y>30 && y<80) || (x>140 && x<150 && y>30 && y<80) || (x>120 && x<150 && y>70 && y<80))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==1) begin
			if((x>140 && x<150 && y>30 && y<80))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==2) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>120 && x<130 && y>50 && y<80) || (x>140 && x<150 && y>30 && y<60) || (x>120 && x<150 && y>70 && y<80) || (x>120 && x<150 && y>50 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==3) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>140 && x<150 && y>30 && y<80) || (x>120 && x<150 && y>70 && y<80) || (x>120 && x<150 && y>50 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==4) begin
			if((x>140 && x<150 && y>30 && y<80) || (x>120 && x<150 && y>50 && y<60) || (x>120 && x<130 && y>30 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==5) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>120 && x<130 && y>30 && y<60) || (x>140 && x<150 && y>50 && y<80) || (x>120 && x<150 && y>70 && y<80) || (x>120 && x<150 && y>50 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==6) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>120 && x<130 && y>30 && y<80) || (x>140 && x<150 && y>50 && y<80) || (x>120 && x<150 && y>70 && y<80) || (x>120 && x<150 && y>50 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==7) begin
			if((x>140 && x<150 && y>30 && y<80) || (x>120 && x<150 && y>30 && y<40))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==8) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>120 && x<130 && y>30 && y<80) || (x>140 && x<150 && y>30 && y<80) || (x>120 && x<150 && y>70 && y<80) || (x>120 && x<150 && y>50 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end
		else if(score_left_ones==9) begin
			if((x>120 && x<150 && y>30 && y<40) || (x>120 && x<130 && y>30 && y<60) || (x>140 && x<150 && y>30 && y<80) || (x>120 && x<150 && y>70 && y<80) || (x>120 && x<150 && y>50 && y<60))
				l_ones <= 1'b1;
			else
				l_ones <= 1'b0;
		end

		// right side score
		// basically the same as the left side
		if(score_right_tens==0) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>490 && x<500 && y>30 && y<80) || (x>510 && x<520 && y>30 && y<80))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==1) begin
			if((x>510 && x<520 && y>30 && y<80))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==2) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>490 && x<500 && y>50 && y<80) || (x>510 && x<520 && y>30 && y<60) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==3) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>510 && x<520 && y>30 && y<80) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==4) begin
			if((x>490 && x<500 && y>30 && y<60) || (x>510 && x<520 && y>30 && y<80) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==5) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>490 && x<500 && y>30 && y<60) || (x>510 && x<520 && y>50 && y<80) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==6) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>490 && x<500 && y>30 && y<80) || (x>510 && x<520 && y>50 && y<80) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==7) begin
			if((x>510 && x<520 && y>30 && y<80) || (x>490 && x<520 && y>30 && y<40))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==8) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>490 && x<500 && y>30 && y<80) || (x>510 && x<520 && y>30 && y<80) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end
		else if(score_right_tens==9) begin
			if((x>490 && x<520 && y>30 && y<40) || (x>490 && x<520 && y>70 && y<80) || (x>490 && x<500 && y>30 && y<60) || (x>510 && x<520 && y>30 && y<80) || (x>490 && x<520 && y>50 && y<60))
				r_tens <= 1'b1;
			else
				r_tens <= 1'b0;
		end

		// ones
		if(score_right_ones==0) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>530 && x<540 && y>30 && y<80) || (x>550 && x<560 && y>30 && y<80))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==1) begin
			if((x>550 && x<560 && y>30 && y<80))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==2) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>530 && x<540 && y>50 && y<80) || (x>550 && x<560 && y>30 && y<60) || (x>530 && x<560 && y>50 && y<60))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==3) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>550 && x<560 && y>30 && y<80) || (x>530 && x<560 && y>50 && y<60))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==4) begin
			if((x>550 && x<560 && y>30 && y<80) || (x>530 && x<560 && y>50 && y<60) || (x>530 && x<540 && y>30 && y<60))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==5) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>530 && x<540 && y>30 && y<60) || (x>550 && x<560 && y>50 && y<80) || (x>530 && x<560 && y>50 && y<60))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==6) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>530 && x<540 && y>30 && y<80) || (x>550 && x<560 && y>50 && y<80) || (x>530 && x<560 && y>50 && y<60))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==7) begin
			if((x>550 && x<560 && y>30 && y<80) || (x>530 && x<560 && y>30 && y<40))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==8) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>550 && x<560 && y>30 && y<80) || (x>530 && x<560 && y>50 && y<60) || (x>530 && x<540 && y>30 && y<80))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		else if(score_right_ones==9) begin
			if((x>530 && x<560 && y>30 && y<40) || (x>530 && x<560 && y>70 && y<80) || (x>550 && x<560 && y>30 && y<80) || (x>530 && x<560 && y>50 && y<60) || (x>530 && x<540 && y>30 && y<60))
				r_ones <= 1'b1;
			else
				r_ones <= 1'b0;
		end
		// wow
	end
endmodule
