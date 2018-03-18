// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire ld_x, ld_y, ld_r, ld_e, draw;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	// vga_adapter VGA(
	// 		.resetn(resetn),
	// 		.clock(CLOCK_50),
	// 		.colour(colour),
	// 		.x(x),
	// 		.y(y),
	// 		.plot(writeEn),
	// 		/* Signals for the DAC to drive the monitor. */
	// 		.VGA_R(VGA_R),
	// 		.VGA_G(VGA_G),
	// 		.VGA_B(VGA_B),
	// 		.VGA_HS(VGA_HS),
	// 		.VGA_VS(VGA_VS),
	// 		.VGA_BLANK(VGA_BLANK_N),
	// 		.VGA_SYNC(VGA_SYNC_N),
	// 		.VGA_CLK(VGA_CLK));
	// 	defparam VGA.RESOLUTION = "160x120";
	// 	defparam VGA.MONOCHROME = "FALSE";
	// 	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	// 	defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
	wire run, frame, slowclock;
   RateDivider r0 (1'b1, 27'd833333, CLOCK_50, resetn, run);
	RateDivider r1 (run, 27'd12500000, CLOCK_50, resetn, frame);
	RateDivider r2 (1'b1, 27'd5000, CLOCK_50, resetn, slowclock);
	
	wire [6:0] data_in;
	wire [6:0] outY; wire [7:0] outX;
	wire directionX, directoutX, directionY, directoutY;
	XCounter xC(frame, directionX, CLOCK_50, resetn, outX, directoutX);
	YCounter yC(frame, directionY, CLOCK_50, resetn, outY, directoutY);
	
	always@(*) begin
		if(ld_x)
			data_in = outX[6:0];
		else if(ld_y)
			data_in = outY;
		else
			data_in = 7'd0;
	end
	
	datapath d0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.data(data_in),
		.colour(SW[9:7]),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_e(ld_e),
		.ld_r(ld_r),
		.draw(draw),
		.out_x(x),
		.out_y(y),
		.out_colour(colour)
	);
   control c0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.ld(slowclock),
		.go(frame),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_r(ld_r),
		.ld_e(ld_e),
		.draw(draw),
		.plot(writeEn)
		);
endmodule

module datapath(data, colour, resetn, clock, ld_x, ld_y, ld_r, draw, out_x, out_y, out_colour);
	input [6:0] data;
	input [2:0] colour;
	input resetn, clock, ld_x, ld_y, ld_r, draw;
	
	output [7:0] out_x;
	output [6:0] out_y;
	output reg [2:0] out_colour;
	
	reg [7:0] x;
	reg [6:0] y;
	reg [3:0] count;
	
	always @(posedge clock)
	begin: LOAD
		// active low
		if (!resetn)
			begin
				x <= 0;
				y <= 0;
				out_colour = 0;
			end
		else 
			begin
				if (ld_x)
					// 8 bit wide
					x <= {1'b0, data};
				else if (ld_y)
					y <= data;
				else if (ld_r)
					out_colour <= colour;
				else if (ld_e)
					out_colour <= 3'b000;
			end
	end

	// Counter code from rate divider
	always @(posedge clock)
	begin: COUNTER
		// active low
		if (!resetn)
			count <= 4'b0000;
		else if (draw)
			begin
				if (count == 4'b1111)
					count <= 0;
				else
					count <= count + 1'b1;
			end
	end
	
	assign out_x = x + count[1:0];
	assign out_y = y + count[3:2];
endmodule

module XCounter(enable, direction, clock, resetn, x, directout);
	input enable, direction, clock, resetn;
	output reg [7:0] x; output directout;
	
	always@(posedge clock) begin
		if(resetn == 1'b0) begin
			x <= 8'd0;
			directout <= 1'b1;
		end
		else if(enable == 1b0) begin
			if(direction == 1'b0 && x != 8'd0)
				x <= x - 1'b1;
			else if(direction == 1'b0 && x == 8'd0)
				directout <= 1'b1;
			else if(direction == 1'b1 && x != 8'b11111111)
				x <= x + 1'b1;
			else if(direction == 1'b1 && x == 8'b11111111)
				directout <= 1'b0;
			else
				x <= x;
		end
	end
endmodule

module YCounter(enable, direction, clock, resetn, y, directout);
	input enable, direction, clock, resetn;
	output reg [6:0] y; output directout;
	
	always@(posedge clock) begin
		if(resetn == 1'b0) begin
			y <= 7'd60;
			directout <= 1'b1;
		end
		else if(enable == 1b0) begin
			if(direction == 1'b0 && y != 7'd0)
				y <= y - 1'b1;
			else if(direction == 1'b0 && y == 7'd0)
				directout <= 1'b1;
			else if(direction == 1'b1 && y != 7'b11111111)
				y <= y + 1'b1;
			else if(direction == 1'b1 && y == 7'b11111111)
				directout <= 1'b0;
			else
				y <= y;
		end
	end
endmodule

module RateDivider(enable, par_load, clock, reset_n, q);
	input enable, clock, reset_n;
	input [27:0] par_load;
	output q;
	
	reg [27:0] out;
	
	always@(posedge clock)
	begin
		if (reset_n == 1'b0)
			out <= par_load;
		else if (enable == 1'b1)
		begin
			if (out == 28'd0)
				out <= par_load;
			else
				out <= out - 1'b1;
		end
	end
	
	assign q = (out == 28'd0) ? 1 : 0;
endmodule

module control(clock, resetn, go, ld, ld_x, ld_y, ld_r, ld_e, draw, plot);
	input resetn, clock, go, ld;
	output reg ld_x, ld_y, ld_r, ld_e, draw, plot;

	reg [2:0] current_state, next_state;
	
	localparam  IDLE = 4'd0,
				LOAD_X = 4'd1,
				LOAD_X_WAIT= 4'd2,
				LOAD_Y= 4'd3,
				LOAD_Y_WAIT = 4'd4,
				LOAD_COLOUR = 4'd5,
				DRAW = 4'd6,
				WAIT = 4'd7,
				ERASE = 4'd8,
				ERASE_WAIT = 4'd9;

	always @(*)
	begin: state_table
		case (current_state)
			IDLE: next_state = ld ? LOAD_X : IDLE;
			LOAD_X: next_state = ld ? LOAD_X : LOAD_X_WAIT;
			LOAD_X_WAIT: next_state = ld ? LOAD_Y: LOAD_X_WAIT;
			LOAD_Y: next_state = ld ? LOAD_Y: LOAD_Y_WAIT;
			LOAD_Y_WAIT: next_state = LOAD_COLOUR;
			LOAD_COLOUR: next_state = ld ? DRAW : LOAD_COLOUR;
			DRAW: next_state = ld ? WAIT : DRAW;
			WAIT: next_state = frame ? ERASE : WAIT;
			ERASE: next_state = ld ? ERASE_WAIT : ERASE;
			ERASE_WAIT: next_state = ld ? LOAD_X : ERASE_WAIT;
			default: next_state = IDLE;
		endcase
	end
	
	always @(*)
	begin: signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_r = 1'b0;
		draw = 1'b0;
		plot = 1'b0;
		
		case (current_state)
			LOAD_X: begin 
				ld_x = 1'b1;
				end
			LOAD_Y: begin
				ld_y = 1'b1;
				end
			LOAD_COLOUR : begin
				ld_r = 1'b1;
				end
			DRAW: begin
				draw = 1'b1;
				plot = 1'b1;
			end
			ERASE: begin
				ld_e = 1'b1;
			end
		endcase
	end
	
	always@(posedge clock)
	    begin: state_FFs
	        if(!resetn)
	            current_state <= IDLE;
	        else
	            current_state <= next_state;
	    end // state_FFS
endmodule