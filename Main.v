// Part 2 skeleton

module Main
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  LEDR,
		  HEX0,
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
	output [6:0] HEX0;
	output [9:0] LEDR;

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

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
 vga_adapter VGA(
 		.resetn(resetn),
 		.clock(CLOCK_50),
 		.colour(colour),
 		.x(x),
 		.y(y),
 		.plot(writeEn),
 		/* Signals for the DAC to drive the monitor. */
 		.VGA_R(VGA_R),
 		.VGA_G(VGA_G),
 		.VGA_B(VGA_B),
 		.VGA_HS(VGA_HS),
 		.VGA_VS(VGA_VS),
 		.VGA_BLANK(VGA_BLANK_N),
 		.VGA_SYNC(VGA_SYNC_N),
 		.VGA_CLK(VGA_CLK));
 	defparam VGA.RESOLUTION = "160x120";
 	defparam VGA.MONOCHROME = "FALSE";
 	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
 	defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    wire en_count, draw, erase, reset_counter, reset_draw, done_wait, done_flag, en_delay; 
    wire [2:0] state;
	 assign LEDR[3:0] = KEY[3:0];
	datapath d0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.key(KEY),
		.en_count     (en_count),
		.in_colour    (SW[9:7]),
		.draw         (draw),
		.erase        (erase),
		.reset_counter(reset_counter),
		.reset_draw   (reset_draw),
		.done_wait    (done_wait),
		.out_x        (x),
		.out_y        (y),
		.hex 			  (HEX0),
		.led 				(LEDR[7:4]),
		.out_colour   (colour),
		.done_flag    (done_flag),
		.en_delay     (en_delay)
	);
   control c0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.go(~KEY[1]),
		.done_flag    (done_flag),
		.done_wait    (done_wait),
		.erase        (erase),
		.reset_counter(reset_counter),
		.reset_draw   (reset_draw),
		.en_count     (en_count),
		.draw(draw),
		.plot(writeEn),
		.state        (state),
		.en_delay (en_delay)
		);
endmodule

module datapath(clock, resetn, en_count, en_delay, led, in_colour,  draw, erase, reset_counter, reset_draw, done_wait, hex, key, out_x, out_y, out_colour, done_flag);
	input [2:0] in_colour;
	output [6:0] hex;
	input [9:0] key;
	output [3:0] led;
	input clock, draw, erase, resetn, en_delay, reset_counter, reset_draw, en_count;
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_colour;
	output done_wait;
	output done_flag;
	wire delay_count;
	wire [6:0] in_y;
	wire reset;
	reg [3:0] score;
	assign reset = reset_counter & resetn;
	DelayCounter d0(
		.enable(en_delay), 
		.clock(clock), 
		.resetn(reset),

		.out(delay_count));
	FrameCounter f0(
		.enable(delay_count), 
		.clock(clock), 
		.resetn(reset),

		.out(done_wait));
	YCounter y0(
		.enable(en_count), 
		.clock(clock), 
		.resetn(resetn),

		.out(in_y));
	
	reg [6:0] previous_y;
	always@(posedge clock) begin
		if (!resetn) begin
			score <= 4'd0;
			previous_y <= 7'd0;
		end
		else if(in_y <= 30) begin
			previous_y <= 7'd0;
		end
		else if(key[2] == 0 && in_y >= 7'd100 && previous_y != in_y) begin
			score <= score + 1'b1;
			previous_y <= in_y;
			end
	end
 	assign led = score;
	hex_decoder h1 (score, hex);
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
	draw_module dr0(
		.in_x      (8'b00000000),
		.in_y      (in_y),
		.in_colour (in_colour),
		.clock     (clock),
		.draw      (draw),
		.erase     (erase),
		.resetn    (reset_draw & resetn),

		.out_x     (out_x),
		.out_y     (out_y),
		.out_colour(out_colour),
		.done_flag (done_flag)
	);

endmodule

module draw_module(in_x, in_y, in_colour, clock, draw, erase,resetn, out_x, out_y, out_colour, done_flag);
	input [7:0] in_x;
	input [6:0] in_y;
	input [2:0] in_colour;
	input clock, draw, erase, resetn;
	output [7:0] out_x;
	output [6:0] out_y;
	output reg [2:0] out_colour;
	output reg done_flag;

	reg [7:0]count;
//	reg [2:0]count_x;

	always @(posedge clock)
	begin: LOAD
		// active low
		if (!resetn)
			out_colour <= 3'b000;
		else if (erase)
			out_colour <= 3'b000;
		else 
			out_colour <= in_colour;
	end

	// Counter code from rate divider
	always @(posedge clock)
	begin: COUNTER
		// active low
		if (!resetn) begin
//			count_y <= 5'd0;
			count <= 8'd0;
			done_flag <= 1'b0;
		end
		else if (draw)
			begin
				if (count == 8'b1111_1111) begin
					count <= 8'd0;
					done_flag <= 1'b1;
				end
//				else if (count_x == 3'b111) begin
//					count_x <= 3'd0;
//					count_y <= count_y + 1'b1;
//					done_flag <= 1'b0;
//				end
				else begin
					count <= count + 1'b1;
					done_flag <= 1'b0;
				end
			end
	end
	
	assign out_x = in_x + count[3:0];
	assign out_y = in_y + count[7:4];
endmodule

module DelayCounter(enable, clock, resetn, out);
	input enable, clock, resetn;
	output out;
	
	reg [27:0] delay = 28'd833333;
	reg [27:0] counter;
	
	always@(posedge clock)
	begin
		if (resetn == 1'b0)
			counter <= delay;
		else if (enable == 1'b1)
		begin
			if (counter == 28'd0)
				counter <= delay;
			else
				counter <= counter - 1'b11;
		end
	end
	
	assign out = (counter == 28'd0) ? 1 : 0;
endmodule

module FrameCounter(enable, clock, resetn, out);
	input enable, clock, resetn;
	output out;
	
	reg [3:0] frame_counter;
	
	always@(posedge clock)
	begin
		if (resetn == 1'b0)
			frame_counter <= 4'b0000;
		else if (enable == 1'b1)
		begin
			if (frame_counter == 4'b0011)
				frame_counter <= 4'b0000;
			else
				frame_counter <= frame_counter + 1'b1;
		end
	end
	
	assign out = (frame_counter == 4'b0001) ? 1 : 0;
endmodule

module YCounter(enable, clock, resetn, out);
	input enable, clock, resetn;
	output reg [6:0]out;
	
	always@(posedge clock)
	begin
		if (resetn == 1'b0)
			out <= 7'd0;
		else if (enable == 1'b1)
		begin
			if (out == 7'd120)
				out <= 7'd0;
			else
				out <= out + 1'b1;
		end
	end
endmodule

module control(clock, resetn, go, done_flag, done_wait, erase, reset_counter, reset_draw, en_count,draw, plot, state, en_delay);
	input resetn, clock, go, done_flag, done_wait; 
	output reg reset_counter, reset_draw, erase, draw, plot, en_count, en_delay;
	output [2:0] state;
	reg [2:0] current_state, next_state;
	assign state = current_state;
	localparam  IDLE = 3'd0,
				DRAW = 3'd1,
				WAIT= 3'd2,
				WAIT_FINISH = 3'd3,
				ERASE= 3'd4,
				UPDATE = 3'd5;

	always @(*)
	begin: state_table
		case (current_state)
			IDLE: next_state = go ? DRAW : IDLE;
			DRAW: next_state = done_flag ? WAIT : DRAW;
			WAIT: next_state = WAIT_FINISH;
			WAIT_FINISH: next_state =  done_wait ? ERASE : WAIT_FINISH;
			ERASE: next_state = done_flag ? UPDATE : ERASE;
			UPDATE: next_state = DRAW; 
			default: next_state = IDLE;
		endcase
	end
	
	always @(*)
	begin: signals
		reset_counter = 1'b1;
		reset_draw = 1'b1;
		erase = 1'b0;
		en_count = 1'b0;
		en_delay = 1'b0;
		draw = 1'b0;
		plot = 1'b0;
		
		case (current_state)
			DRAW: begin
				draw = 1'b1;
				plot = 1'b1;
				end
			WAIT: begin
				reset_counter = 1'b0;
				reset_draw = 1'b0;
				en_delay = 1'b1;
				end
			WAIT_FINISH: begin
				en_delay = 1'b1;
				end
			ERASE: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				end
			UPDATE: begin
				en_count = 1'b1;
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

module hex_decoder( SW, hecks);
    input [9:0] SW;
    output [6:0] hecks;

    assign hecks[0] = ( ~SW[3] & ~SW[2] & ~SW[1] & SW[0] )|( ~SW[3] & SW[2] & ~SW[1] & ~SW[0] )|(SW[3] & ~SW[2] & SW[1] & SW[0] )|( SW[3] & SW[2] & ~SW[1] & SW[0]);

    assign hecks[1] = ( ~SW[3] & SW[2] & ~SW[1] &   SW[0] )|
							(  SW[3] &          SW[2] &  ~SW[0] )|
	                   ( SW[3] &          SW[1] &   SW[0] )|
							 (         SW[2] &  SW[1] & ~ SW[0]);

    assign hecks[2] = ( ~SW[3] & ~ SW[2] & SW[1] & ~SW[0] )|( SW[3] & SW[2] & ~ SW[0] )|( SW[3] & SW[2] & SW[1]);

    assign hecks[3] = ( ~SW[3] & SW[2] & ~SW[1] & ~SW[0] )|( ~SW[2] & ~SW[1] & SW[0] )|( SW[3] & ~SW[2] & SW[1] &~SW[0] )|( SW[2] & SW[1] & SW[0]);

   assign  hecks[4] = ( ~SW[3] & SW[2] & ~SW[1] )|( ~SW[2] & ~SW[1] & SW[0] )|( ~SW[3] & SW[0]);

   assign  hecks[5] = ( ~SW[3] & ~SW[2] & SW[0] )|( ~SW[3] & ~SW[2] & SW[1] )|( ~SW[3] & SW[1] & SW[0] )|( SW[3] & SW[2] & ~SW[1] & SW[0]);

    assign hecks[6] = ( ~SW[3] & ~SW[2] & ~SW[1] )|( ~SW[3] & SW[2] & SW[1] & SW[0]) + (SW[3] & SW[2] & ~SW[1] & ~SW[0]);

endmodule