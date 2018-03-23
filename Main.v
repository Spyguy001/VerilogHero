
module lab7
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
    
    wire draw, shift, erase, reset_counter, gen_rand, reset_draw, done_wait, done_flag, en_delay; 
    wire [3:0] state;
    wire [4:0] select_node;
	datapath d0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.in_colour    (SW[9:7]),
		.gen_rand     (gen_rand),
		.draw         (draw),
		.erase        (erase),
		.reset_counter(reset_counter),
		.reset_draw   (reset_draw),
		.done_wait    (done_wait),
		.out_x        (x),
		.out_y        (y),
		.out_colour   (colour),
		.done_flag    (done_flag),
		.en_delay     (en_delay),
		.select_node  (select_node),
		.shift (shift)
	);
   control c0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.go(~KEY[1]),
		.done_flag    (done_flag),
		.gen_rand     (gen_rand),
		.done_wait    (done_wait),
		.erase        (erase),
		.reset_counter(reset_counter),
		.reset_draw   (reset_draw),
		.draw         (draw),
		.plot         (writeEn),
		.state        (state),
		.en_delay (en_delay),
		.select_node  (select_node),
		.shift 		   (shift)
		);
endmodule

module datapath(clock, resetn, shift, select_node, gen_rand, en_delay, in_colour,  draw, erase, reset_counter, reset_draw, done_wait, out_x, out_y, out_colour, done_flag);
	input [2:0] in_colour;
	input clock, draw,shift, erase, gen_rand, resetn, en_delay, reset_counter, reset_draw;
	input [4:0] select_node;
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_colour;
	output done_wait;
	output done_flag;
	wire delay_count;
	reg [6:0] in_y;
	wire reset;
	// wire [4:0]random_n;
	// wire random_draw;
	// wire interal_done;
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

	draw_select dr0(
		.clock      (clock),
		.resetn     (resetn),
		.gen_rand   (gen_rand),
		.shift      (shift),
		.draw       (draw),
		.erase      (erase),
		.reset_draw (reset_draw),
		.select_node(select_node),
		.done_flag  (done_flag),
		.out_x      (out_x),
		.out_y      (out_y),
		.out_colour (out_colour)
		);
	// YCounter y0(
	// 	.enable(en_count), 
	// 	.clock(clock), 
	// 	.resetn(resetn),

	// 	.out(in_y));
	// generate_random g0 (
	// 	.enable(draw),
	// 	.clock (clock),
	// 	.resetn(resetn),
	// 	.out   (random_n)
	// 	);

	// always @(*) 
 //    begin
 //    	case (select_node)
 //    		5'b00000: begin
 //    			in_y = 7'b0000000;
 //    		end 
 // 		   	5'b00001: begin
 // 		   		in_y = 7'b0001111;
 // 		   	end
 //    		default: begin
 //    			in_y = 7'b0000000;
 //    		end
 //    	endcase
 //    end

	// assign random_draw = ((random_n[4]) & draw) | (erase & draw);
	// assign done_flag = ((~(random_n[4]) & ~erase) | interal_done);
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
	// draw_module dr0(
	// 	.in_x      (8'b00000000),
	// 	.in_y      (in_y),
	// 	.in_colour (in_colour),
	// 	.clock     (clock),
	// 	.draw      (draw),
	// 	.erase     (erase),
	// 	.resetn    (reset_draw & resetn),

	// 	.out_x     (out_x),
	// 	.out_y     (out_y),
	// 	.out_colour(out_colour),
	// 	.done_flag (done_flag)
	// );

endmodule

module draw_node(enable, out,clock, in_x, in_y, resetn, in_colour, shift,draw, erase, reset_draw, out_x, out_y, out_colour, done_flag);
	input [2:0] in_colour;
	input [6:0] in_y;
	input [7:0] in_x;
	input enable, shift, clock, draw, erase, resetn,reset_draw;
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_colour;
	output reg done_flag;
	output reg out;

	reg i_draw;
	wire i_done;
	always @(posedge clock) 
    begin
    	if(!resetn) begin
    		done_flag <= 1'b0;
    		out <= 1'b0;
    		// i_done <= 1'b0;
    		i_draw <= 1'b0;
    	end
		else if (erase) begin
			i_draw <= draw;
    		done_flag <= i_done;
		end
		else if (shift) begin
    		out <= enable;
    	end
    	else if(enable && draw) begin
    		i_draw <= draw;
    		done_flag <= i_done;
    	end
    	else if ((~enable) && draw) begin
    		i_draw <= 1'b0;
    		done_flag <= 1'b1;
    	end
		else begin
			i_draw <= draw;
    		done_flag <= i_done;
		end 
    end

	draw_module dr0(
		.in_x      (in_x),
		.in_y      (in_y),
		.in_colour (in_colour),
		.clock     (clock),
		.draw      (i_draw),
		.erase     (erase),
		.resetn    (reset_draw & resetn),

		.out_x     (out_x),
		.out_y     (out_y),
		.out_colour(out_colour),
		.done_flag (i_done)
	);
endmodule

module draw_select (clock, resetn, shift, draw, erase, gen_rand, reset_draw, select_node, done_flag, out_x, out_y, out_colour);
	input clock, resetn, draw, shift, erase, reset_draw, gen_rand;
	output reg [7:0] out_x;
	output reg [6:0] out_y;
	output reg [2:0] out_colour;
	input [4:0] select_node;
	output reg done_flag;
	wire done1, done2, done3;
	wire out1, out2, out3;
	wire [7:0] x1, x2, x3;
	wire [6:0] y1, y2, y3;
	wire [2:0] c1, c2, c3;
	reg draw1, draw2, draw3;

	wire [4:0] random_n;

	generate_random g0 (
		.enable(gen_rand),
		.clock (clock),
		.resetn(resetn),
		.out   (random_n)
		);

	draw_node d0 (
		.enable    (random_n[4]),
		.out       (out1),
		.clock     (clock),
		.in_x      (8'b00000000),
		.in_y      (7'b000000),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw1),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x1),
		.out_y     (y1),
		.out_colour(c1),
		.done_flag (done1)
		);

	draw_node d1 (
		.enable    (out1),
		.out       (out2),
		.clock     (clock),
		.in_x      (8'b00000000),
		.in_y      (7'b0000111),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw2),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x2),
		.out_y     (y2),
		.out_colour(c2),
		.done_flag (done2)
		);

	draw_node d2 (
		.enable    (out2),
		.out       (out3),
		.clock     (clock),
		.in_x      (8'b00000000),
		.in_y      (7'b0011111),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw3),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x3),
		.out_y     (y3),
		.out_colour(c3),
		.done_flag (done3)
		);

	always @(*) 
    begin
    	case (select_node)
    		5'b00000: begin
    			out_y = y1;
    			out_x = x1;
    			out_colour = c1;
    			done_flag = done1;
    			draw1 = draw;
    			draw2 = 1'b0;
    			draw3 = 1'b0;
    		end 
 		   	5'b00001: begin
 		   		out_y = y2;
    			out_x = x2;
    			out_colour = c2;
    			done_flag = done2;
    			draw1 = 1'b0;
    			draw2 = draw;
    			draw3 = 1'b0;
 		   	end
 		   	5'b00010: begin
 		   		out_y = y3;
    			out_x = x3;
    			out_colour = c3;
    			done_flag = done3;
    			draw1 = 1'b0;
    			draw2 = 1'b0;
    			draw3 = draw;
 		   	end
    		default: begin
    			out_y = 7'b0000000;
    			out_x = 8'b00000000;
    			out_colour = 3'b000;
    			done_flag = 1'b0;
    			draw1 = 1'b0;
    			draw2 = 1'b0;
    			draw3 = 1'b0;
    		end
    	endcase
    end
endmodule

module generate_random(enable, clock, resetn, out);
	input clock, resetn, enable;
	output reg [4:0]out;
	wire [4:0] temp;
	fibonacci_lfsr r0(
		.clk  (clock),
		.rst_n(resetn),
		.data (temp)
		);
	always @(posedge clock) begin
		if(!resetn) begin
			out <= 5'b00000;
		end
		else if (enable) begin
			out <= temp;
		end
		// else begin
		// 	out <= 5'b00000;
		// end
	end

endmodule

// SOURCE: https://stackoverflow.com/questions/14497877/how-to-implement-a-pseudo-hardware-random-number-generator
module fibonacci_lfsr(clk, rst_n, data);
	input  clk;
  input  rst_n;

  output reg [4:0] data;

wire feedback = data[4] ^ data[1] ;

always @(posedge clk or negedge rst_n)
  if (~rst_n) 
    data <= 4'hf;
  else
    data <= {data[3:0], feedback} ;

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

	reg [3:0]count;

	always @(posedge clock)
	begin
		// active low
		if (!resetn)
			out_colour <= 3'b000;
		else if (erase)
			out_colour <= 3'b000;
		else if (~erase)
			out_colour <= in_colour;
		else 
			out_colour <= 3'b111;
	end

	// Counter code from rate divider
	always @(posedge clock)
	begin
		// active low
		if (!resetn) begin
			count <= 4'b0000;
			done_flag <= 1'b0;
		end
		else if (draw)
			begin
				if (count == 4'b1111) begin
					done_flag <= 1'b1;
					count <= 4'd0;
				end
				else begin
					count <= count + 1'b1;
					done_flag <= 1'b0;
				end
			end
	end
	
	assign out_x = in_x + count[1:0];
	assign out_y = in_y + count[3:2];
endmodule

module DelayCounter(enable, clock, resetn, out);
	input enable, clock, resetn;
	output out;
	
	reg [27:0] delay = 28'd10;
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
				counter <= counter - 1'b1;
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
			if (frame_counter == 4'b1111)
				frame_counter <= 4'b0000;
			else
				frame_counter <= frame_counter + 1'b1;
		end
	end
	
	assign out = (frame_counter == 4'b1111) ? 1 : 0;
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

module control(clock, resetn, go, done_flag, done_wait, erase, reset_counter, reset_draw, shift,draw, plot, state, en_delay, select_node, gen_rand);
	input resetn, clock, go, done_flag, done_wait; 
	output reg reset_counter, reset_draw, erase, draw, plot, shift, en_delay, gen_rand;
	output [3:0] state;
	output reg [4:0] select_node;
	reg [3:0] current_state, next_state;
	assign state = current_state;
	localparam  IDLE = 4'd0,
				DRAW = 4'd1,
				DRAW_WAIT = 4'd2,
				DRAW1 = 4'd3,
				DRAW_WAIT1 = 4'd4,
				DRAW2 = 4'd5,
				WAIT= 4'd6,
				WAIT_FINISH = 4'd7,
				ERASE= 4'd8,
				ERASE_WAIT = 4'd9,
				ERASE1= 4'd10, // a
				ERASE_WAIT1 = 4'd11, // b
				ERASE2= 4'd12, // c
				UPDATE = 4'd13, // d 
				GENERATE = 4'd14; // e
				

	// wire [4:0] random_n;
	// generate_random g0 (
	// 	.enable(1'b1),
	// 	.clock (clock),
	// 	.resetn(resetn),
	// 	.out   (random_n)
	// 	);

	always @(*)
	begin: state_table
		case (current_state)
			IDLE: next_state = go ? GENERATE : IDLE;
			DRAW: next_state = done_flag ? DRAW_WAIT : DRAW;
			DRAW_WAIT: next_state = DRAW1;
			DRAW1: next_state = done_flag ? DRAW_WAIT1 : DRAW1;
			DRAW_WAIT1: next_state = DRAW2;
			DRAW2: next_state = done_flag ? WAIT : DRAW2;
			WAIT: next_state = WAIT_FINISH;
			WAIT_FINISH: next_state =  done_wait ? ERASE : WAIT_FINISH;
			ERASE: next_state = done_flag ? ERASE_WAIT : ERASE;
			ERASE_WAIT: next_state = ERASE1;
			ERASE1: next_state = done_flag ? ERASE_WAIT1 : ERASE1;
			ERASE_WAIT1: next_state = ERASE2;
			ERASE2: next_state = done_flag ? UPDATE : ERASE2;
			UPDATE: next_state = GENERATE;
			GENERATE: next_state = DRAW;
			default: next_state = IDLE;
		endcase
	end
	
	always @(*)
	begin: signals
		reset_counter = 1'b1;
		reset_draw = 1'b1;
		erase = 1'b0;
		shift = 1'b0;
		en_delay = 1'b0;
		draw = 1'b0;
		plot = 1'b0;
		select_node = 5'b11111;
		gen_rand = 1'b0;
		
		case (current_state)
			DRAW: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 5'd0;
			end
			DRAW_WAIT: begin
				reset_draw = 1'b0;
			end
			DRAW1: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 5'd1;
			end
			DRAW_WAIT1: begin
				reset_draw = 1'b0;
			end
			DRAW2: begin
				draw = 1'b1;
				// plot = 1'b1;
				select_node = 5'd2;
			end
			WAIT: begin
				reset_counter = 1'b0;
				reset_draw = 1'b0;
				en_delay = 1'b1;
				end
			WAIT_FINISH: begin
				en_delay = 1'b1;
				reset_draw = 1'b0;
				end
			ERASE: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 5'd0;
				end
			ERASE_WAIT: begin
				reset_draw = 1'b0;
			end
			ERASE1: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 5'd1;
				end
			ERASE_WAIT1: begin
				reset_draw = 1'b0;
			end
			ERASE2: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 5'd2;
				end
			UPDATE: begin
				shift = 1'b1;
				reset_draw = 1'b0;
				end
			GENERATE: begin
				gen_rand = 1'b1;
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
