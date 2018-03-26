
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
// .resetn(resetn),
// .clock(CLOCK_50),
// .colour(colour),
// .x(x),
// .y(y),
// .plot(writeEn),
// /* Signals for the DAC to drive the monitor. */
// .VGA_R(VGA_R),
// .VGA_G(VGA_G),
// .VGA_B(VGA_B),
// .VGA_HS(VGA_HS),
// .VGA_VS(VGA_VS),
// .VGA_BLANK(VGA_BLANK_N),
// .VGA_SYNC(VGA_SYNC_N),
// .VGA_CLK(VGA_CLK));
// defparam VGA.RESOLUTION = "160x120";
// defparam VGA.MONOCHROME = "FALSE";
// defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
// defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    wire draw, shift, erase, reset_counter, gen_rand, reset_draw, done_wait, done_flag, en_delay, enabled; 
    wire [5:0] state;
    wire [6:0] select_node;
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
		.shift (shift),
		.enabled (enabled)
	);
   control c0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.go(~KEY[1]),
		.done_flag    (done_flag),
		.enabled (enabled),
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

module datapath(clock, resetn, shift, select_node, gen_rand, en_delay, in_colour,  draw, erase, reset_counter, reset_draw, done_wait, out_x, out_y, out_colour, done_flag, enabled);
	input [2:0] in_colour;
	input clock, draw,shift, erase, gen_rand, resetn, en_delay, reset_counter, reset_draw;
	input [6:0] select_node;
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_colour;
	output done_wait;
	output done_flag, enabled;
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
		.out_colour (out_colour),
		.enabled	(enabled)
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

module draw_node(enable, out, enabled, clock, in_x, in_y, resetn, in_colour, shift,draw, erase, reset_draw, out_x, out_y, out_colour, done_flag);
	input [2:0] in_colour;
	input [6:0] in_y;
	input [7:0] in_x;
	input enable, shift, clock, draw, erase, resetn,reset_draw;
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_colour;
	output enabled;
	output reg done_flag;
	output reg out;

	reg i_draw;
	wire i_done;

	assign enabled = enable;
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

module draw_select (clock, resetn, shift, draw, erase, gen_rand, reset_draw, select_node, done_flag, out_x, out_y, out_colour, enabled);
	input clock, resetn, draw, shift, erase, reset_draw, gen_rand;
	output reg [7:0] out_x;
	output reg [6:0] out_y;
	output reg [2:0] out_colour;
	input [6:0] select_node;
	output reg done_flag, enabled;
	wire done11, done12, done13, done14, done15, done16, done17, done18;
	wire out11, out12, out13, out14, out15,out16,out17,out18;
	wire [7:0] x11, x12, x13, x14,x15,x16,x17,x18;
	wire [6:0] y11, y12, y13, y14,y15,y16,y17,y18;
	wire [2:0] c11, c12, c13, c14,c15,c16,c17,c18;
	reg draw11, draw12, draw13, draw14, draw15, draw16, draw17, draw18;
	wire e11, e12, e13, e14, e15, e16, e17, e18;

	wire [4:0] random_n;

	generate_random g0 (
		.enable(gen_rand),
		.clock (clock),
		.resetn(resetn),
		.out   (random_n)
		);

	draw_node d11 (
		.enable    (random_n[4]),
		.out       (out11),
		.enabled   (e11),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd1),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw11),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x11),
		.out_y     (y11),
		.out_colour(c11),
		.done_flag (done11)
		);

	draw_node d12 (
		.enable    (out11),
		.out       (out12),
		.enabled   (e12),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd6),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw12),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x12),
		.out_y     (y12),
		.out_colour(c12),
		.done_flag (done12)
		);

	draw_node d13 (
		.enable    (out12),
		.out       (out13),
		.enabled   (e13),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd11),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw13),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x13),
		.out_y     (y13),
		.out_colour(c13),
		.done_flag (done13)
		);

	draw_node d14 (
		.enable    (out13),
		.out       (out14),
		.enabled   (e14),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd16),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw14),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x14),
		.out_y     (y14),
		.out_colour(c14),
		.done_flag (done14)
		);

	draw_node d15 (
		.enable    (out14),
		.out       (out15),
		.enabled   (e15),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd21),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw15),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x15),
		.out_y     (y15),
		.out_colour(c15),
		.done_flag (done15)
		);
	draw_node d16 (
		.enable    (out15),
		.out       (out16),
		.enabled   (e16),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd26),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw16),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x16),
		.out_y     (y16),
		.out_colour(c16),
		.done_flag (done16)
		);
	draw_node d17 (
		.enable    (out16),
		.out       (out17),
		.enabled   (e17),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd31),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw17),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x17),
		.out_y     (y17),
		.out_colour(c17),
		.done_flag (done17)
		);
	draw_node d18 (
		.enable    (out17),
		.out       (out18),
		.enabled   (e18),
		.clock     (clock),
		.in_x      (8'b00000001),
		.in_y      (7'd36),
		.in_colour (3'b001),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw18),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x18),
		.out_y     (y18),
		.out_colour(c18),
		.done_flag (done18)
		);
	always @(*) 
    begin
    	case (select_node)
    		7'd0: begin
    			out_y = y11;
    			out_x = x11;
    			out_colour = c11;
    			done_flag = done11;
    			draw11 = draw;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = e11;
    		end 
 		   	7'd1: begin
 		   		out_y = y12;
    			out_x = x12;
    			out_colour = c12;
    			done_flag = done12;
    			draw11 = 1'b0;
    			draw12 = draw;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = e12;
 		   	end
 		   	7'd2: begin
 		   		out_y = y13;
    			out_x = x13;
    			out_colour = c13;
    			done_flag = done13;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = draw;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = e13;
 		   	end
 		   	7'd3: begin
 		   		out_y = y14;
    			out_x = x14;
    			out_colour = c14;
    			done_flag = done14;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = draw;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = e14;
 		   	end
 		   	7'd4: begin
 		   		out_y = y15;
    			out_x = x15;
    			out_colour = c15;
    			done_flag = done15;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = draw;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = e15;
 		   	end
 		   	7'd5: begin
 		   		out_y = y16;
    			out_x = x16;
    			out_colour = c16;
    			done_flag = done16;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = draw;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = e16;
 		   	end
 		   	7'd6: begin
 		   		out_y = y17;
    			out_x = x17;
    			out_colour = c17;
    			done_flag = done17;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = draw;
    			draw18 = 1'b0;
    			enabled = e17;
 		   	end
 		   	7'd7: begin
 		   		out_y = y18;
    			out_x = x18;
    			out_colour = c18;
    			done_flag = done18;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = draw;
    			enabled = e18;
 		   	end
    		default: begin
    			out_y = 7'b0000000;
    			out_x = 8'b00000000;
    			out_colour = 3'b000;
    			done_flag = 1'b0;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			enabled = 1'b0;
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

module control(clock, resetn, go, done_flag, done_wait, enabled, erase, reset_counter, reset_draw, shift,draw, plot, state, en_delay, select_node, gen_rand);
	input resetn, clock, go, done_flag, done_wait, enabled; 
	output reg reset_counter, reset_draw, erase, draw, plot, shift, en_delay, gen_rand;
	output [5:0] state;
	output reg [6:0] select_node;
	reg [5:0] current_state, next_state;
	assign state = current_state;
	localparam  IDLE = 6'd0,
				DRAW_WAIT0 = 6'd1,
				DRAW = 6'd2,
				DRAW_WAIT1 = 6'd3,
				DRAW1 = 6'd4,
				DRAW_WAIT2 = 6'd5,
				DRAW2 = 6'd6,
				DRAW_WAIT3 = 6'd7,
				DRAW3 = 6'd8,
				DRAW_WAIT4 = 6'd9,
				DRAW4 = 6'd10,
				DRAW_WAIT5 = 6'd11,
				DRAW5 = 6'd12,
				DRAW_WAIT6 = 6'd13,
				DRAW6 = 6'd14,
				DRAW_WAIT7 = 6'd15,
				DRAW7 = 6'd16,
				WAIT= 6'd17,
				WAIT_FINISH = 6'd18,
				ERASE= 6'd19,
				ERASE_WAIT = 6'd20,
				ERASE1= 6'd21, 
				ERASE_WAIT1 = 6'd22, 
				ERASE2= 6'd23,
				ERASE_WAIT2 = 6'd24, 
				ERASE3= 6'd25,
				ERASE_WAIT3 = 6'd26, 
				ERASE4= 6'd27,
				ERASE_WAIT4 = 6'd28, 
				ERASE5= 6'd29,
				ERASE_WAIT5 = 6'd30, 
				ERASE6= 6'd31,
				ERASE_WAIT6 = 6'd32, 
				ERASE7= 6'd33,
				ERASE_WAIT7 = 6'd34, 
				UPDATE = 6'd35, 
				GENERATE = 6'd36;
				
				

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
			DRAW_WAIT0: next_state = enabled ? DRAW : DRAW_WAIT1;
			DRAW: next_state = done_flag ? DRAW_WAIT1 : DRAW;
			DRAW_WAIT1: next_state = enabled ? DRAW1 : DRAW_WAIT2;
			DRAW1: next_state = done_flag ? DRAW_WAIT2 : DRAW1;
			DRAW_WAIT2: next_state = enabled ? DRAW2 : DRAW_WAIT3;
			DRAW2: next_state = done_flag ? DRAW_WAIT3 : DRAW2;
			DRAW_WAIT3: next_state = enabled ? DRAW3 : DRAW_WAIT4;
			DRAW3: next_state = done_flag ? DRAW_WAIT4 : DRAW3;
			DRAW_WAIT4: next_state = enabled ? DRAW4 : DRAW_WAIT5;
			DRAW4: next_state = done_flag ? DRAW_WAIT5 : DRAW4;
			DRAW_WAIT5: next_state = enabled ? DRAW5 : DRAW_WAIT6;
			DRAW5: next_state = done_flag ? DRAW_WAIT6 : DRAW5;
			DRAW_WAIT6: next_state = enabled ? DRAW6 : DRAW_WAIT7;
			DRAW6: next_state = done_flag ? DRAW_WAIT7 : DRAW6;
			DRAW_WAIT7: next_state = enabled ? DRAW7 : WAIT;
			DRAW7: next_state = done_flag ? WAIT : DRAW7;
			WAIT: next_state = WAIT_FINISH;
			WAIT_FINISH: next_state =  done_wait ? ERASE : WAIT_FINISH;
			ERASE: next_state = done_flag ? ERASE_WAIT : ERASE;
			ERASE_WAIT: next_state = ERASE1;
			ERASE1: next_state = done_flag ? ERASE_WAIT1 : ERASE1;
			ERASE_WAIT1: next_state = ERASE2;
			ERASE2: next_state = done_flag ? ERASE_WAIT2 : ERASE2;
			ERASE_WAIT2: next_state = ERASE3;
			ERASE3: next_state = done_flag ? ERASE_WAIT3 : ERASE3;
			ERASE_WAIT3: next_state = ERASE4;
			ERASE4: next_state = done_flag ? ERASE_WAIT4 : ERASE4;
			ERASE_WAIT4: next_state = ERASE5;
			ERASE5: next_state = done_flag ? ERASE_WAIT5 : ERASE5;
			ERASE_WAIT5: next_state = ERASE6;
			ERASE6: next_state = done_flag ? ERASE_WAIT6 : ERASE6;
			ERASE_WAIT6: next_state = ERASE7;
			ERASE7: next_state = done_flag ? ERASE_WAIT7 : ERASE7;
			ERASE_WAIT7: next_state = UPDATE;
			UPDATE: next_state = GENERATE;
			GENERATE: next_state = DRAW_WAIT0;
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
		select_node = 7'b11111;
		gen_rand = 1'b0;
		
		case (current_state)
			DRAW_WAIT0: begin
				reset_draw = 1'b0;
				select_node = 7'd0;
			end
			DRAW: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd0;
			end
			DRAW_WAIT1: begin
				reset_draw = 1'b0;
				select_node = 7'd1;
			end
			DRAW1: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd1;
			end
			DRAW_WAIT2: begin
				reset_draw = 1'b0;
				select_node = 7'd2;
			end
			DRAW2: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd2;
			end
			DRAW_WAIT3: begin
				reset_draw = 1'b0;
				select_node = 7'd3;
			end
			DRAW3: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd3;
			end
			DRAW_WAIT4: begin
				reset_draw = 1'b0;
				select_node = 7'd4;
			end
			DRAW4: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd4;
			end
			DRAW_WAIT5: begin
				reset_draw = 1'b0;
				select_node = 7'd5;
			end
			DRAW5: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd5;
			end
			DRAW_WAIT6: begin
				reset_draw = 1'b0;
				select_node = 7'd6;
			end
			DRAW6: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd6;
			end
			DRAW_WAIT7: begin
				reset_draw = 1'b0;
				select_node = 7'd7;
			end
			DRAW7: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd7;
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
				select_node = 7'd0;
				end
			ERASE_WAIT: begin
				reset_draw = 1'b0;
			end
			ERASE1: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd1;
				end
			ERASE_WAIT1: begin
				reset_draw = 1'b0;
			end
			ERASE2: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd2;
				end
			ERASE_WAIT2: begin
				reset_draw = 1'b0;
			end
			ERASE3: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd3;
				end
			ERASE_WAIT3: begin
				reset_draw = 1'b0;
			end
			ERASE4: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd4;
				end
			ERASE_WAIT4: begin
				reset_draw = 1'b0;
			end
			ERASE5: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd5;
				end
			ERASE_WAIT5: begin
				reset_draw = 1'b0;
			end
			ERASE6: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd6;
				end
			ERASE_WAIT6: begin
				reset_draw = 1'b0;
			end
			ERASE7: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd7;
				end
			ERASE_WAIT7: begin
				reset_draw = 1'b0;
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