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
	inout ps2_data);

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
	assign {VGA_R, VGA_G, VGA_B} = ball ? 12'hfff : colorOut; // if in ball draw white otherwise draw regular background




	// Clock divider 100 MHz -> 100 Hz
	wire clk100; // 25MHz clock

	reg[19:0] pixCounter2 = 0;      // Pixel counter to divide the clock
	assign clk100 = pixCounter2[19]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter2 <= pixCounter2 + 1; // Since the reg is only _ bits, it will reset every _ cycles
	end

	// draw ball, upper left coords
	wire[9:0] ball_x, ball_inX;
	wire[8:0] ball_y, ball_inY;
	reg[5:0] width = 6'b100000;

	// ball velocity
	wire[5:0] velX, velY;
	reg[5:0] vX, vY;

	assign velX = vX;
	assign velY = vY;

	// update ball position
	ball ball_loc(.inX(ball_inX), .inY(ball_inY), .velX(6'b1), .velY(6'b1), .width(width), .clk(clk100), .reset(reset), .outX(ball_x), .outY(ball_y));

	assign ball_inX = ball_x;
	assign ball_inY = ball_y;

	// determine boundaries of ball
	// wire[9:0] ball_left, ball_right;
	// wire[8:0] ball_up, ball_down;
	reg ball;

	// assign ball_left = ball_x;
	// assign ball_right = ball_x+width;
	// assign ball_up = ball_y;
	// assign ball_down = ball_y+width;

	always @(screenEnd) begin
		if(x>=ball_x && x<=ball_x+width && y>=ball_y && y<=ball_y+width)
			ball <= 1'b1; // coord inside ball
		else
			ball <= 1'b0; // coord outside ball
	end




endmodule
