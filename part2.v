
module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  PS2_DAT,
		  PS2_CLK,
		  LEDR,
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
	inout PS2_CLK, PS2_DAT;
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
    wire [7:0] state;
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
		.enabled (enabled),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.ledr(LEDR)
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

module datapath(clock, resetn, shift, select_node, gen_rand, en_delay, 
					in_colour,  draw, erase, reset_counter, reset_draw, 
					done_wait, out_x, out_y, out_colour, done_flag, enabled,
					PS2_CLK, PS2_DAT, ledr);
	input [2:0] in_colour;
	input clock, draw,shift, erase, gen_rand, resetn, en_delay, reset_counter, reset_draw;
	input [6:0] select_node;
	inout PS2_CLK, PS2_DAT;
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_colour;
	output done_wait;
	output done_flag, enabled;
	output [9:0] ledr;
	wire delay_count;
	reg [6:0] in_y;
	wire reset;
	// wire [4:0]random_n;
	// wire random_draw;
	// wire interal_done;
	
	wire check_1, check_2, check_3, check_4;
	wire c1, c2, c3, c4;
	wire waste1, waste2, waste3, waste4;
	
	assign ledr[1] = check_1;
	assign ledr[2] = check_2;
	assign ledr[3] = check_3;
	assign ledr[4] = check_4;
	assign ledr[5] = check_1 && c1;
	assign ledr[6] = check_2 && c2;
	assign ledr[7] = check_3 && c3;
	assign ledr[8] = check_4 && c4;
	
	
	wire finished;
	wire [7:0] life;
	wire [27:0] score;
	wire life_down =  (check_1 ^ c1) ||
							(check_2 ^ c2) ||
							(check_3 ^ c3) ||
							(check_4 ^ c4);
	
	LifeCounter l0(
		.enable(life_down),
		.clock(clock),
		.resetn(reset),
		.life(life),
		.out(finished));
	
	 
	 keyboard_tracker #(.PULSE_OR_HOLD(0)) checker(
	      .clock(clock),
	 	  .reset(resetn),
	 	  .PS2_CLK(PS2_CLK),
	 	  .PS2_DAT(PS2_DAT),
	 	  .w(check_1),
	 	  .a(check_2),
	 	  .s(check_3),
		  .d(check_4),
	 	  .left(waste1),
	 	  .right(waste2),
	 	  .up(waste3),
	 	  .down(ledr[0]),
	 	  .space(waste4),
	 	  .enter(ledr[9])
	 	  );
		  
	reg [5:0] frame_limit;
	wire seconds_count, change_speed;
	SecondsCounter sec0(
		.enable(!finished),
		.clock(clock),
		.resetn(reset),
		.counter(score),
		.out(seconds_count));
	SpeedCounter sp0(
		.enable(seconds_count),
		.clock(clock),
		.resetn(reset),
		.out(change_speed));
		
	always@(*) begin
		if(!reset)
			frame_limit <= 6'd32;
		else begin
			if (change_speed && frame_limit == 6'd32)
				frame_limit <= 6'd16;
			else if (change_speed && frame_limit == 6'd16)
				frame_limit <= 6'd8;
			else if (change_speed && frame_limit == 6'd8)
				frame_limit <= 6'd32;
			else
				frame_limit <= 6'd32;
		end
	end
	
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
		.frame_limit(frame_limit),
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
		.enabled	(enabled),
		.out_c1 (c1),
		.out_c2 (c2),
		.out_c3 (c3),
		.out_c4 (c4)
		);
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

module draw_select (clock, resetn, shift, draw, erase, gen_rand, reset_draw, select_node, done_flag, out_x, out_y, out_colour, enabled, out_c1, out_c2,out_c3, out_c4);
	input clock, resetn, draw, shift, erase, reset_draw, gen_rand;
	output reg [7:0] out_x;
	output reg [6:0] out_y;
	output reg [2:0] out_colour;
	input [6:0] select_node;
	output reg done_flag, enabled;
	output out_c1, out_c2, out_c3, out_c4;

	// COLUMN 1
	wire done11, done12, done13, done14, done15, done16, done17, done18;
	wire out11, out12, out13, out14, out15,out16,out17,out18;
	wire [7:0] x11, x12, x13, x14,x15,x16,x17,x18;
	wire [6:0] y11, y12, y13, y14,y15,y16,y17,y18;
	wire [2:0] c11, c12, c13, c14,c15,c16,c17,c18;
	reg draw11, draw12, draw13, draw14, draw15, draw16, draw17, draw18;
	wire e11, e12, e13, e14, e15, e16, e17, e18;

	// COLUMN 2
	wire done21, done22, done23, done24, done25, done26, done27, done28;
	wire out21, out22, out23, out24, out25,out26,out27,out28;
	wire [7:0] x21, x22, x23, x24,x25,x26,x27,x28;
	wire [6:0] y21, y22, y23, y24,y25,y26,y27,y28;
	wire [2:0] c21, c22, c23, c24,c25,c26,c27,c28;
	reg draw21, draw22, draw23, draw24, draw25, draw26, draw27, draw28;
	wire e21, e22, e23, e24, e25, e26, e27, e28;

	// COLUMN 3
	wire done31, done32, done33, done34, done35, done36, done37, done38;
	wire out31, out32, out33, out34, out35,out36,out37,out38;
	wire [7:0] x31, x32, x33, x34,x35,x36,x37,x38;
	wire [6:0] y31, y32, y33, y34,y35,y36,y37,y38;
	wire [2:0] c31, c32, c33, c34,c35,c36,c37,c38;
	reg draw31, draw32, draw33, draw34, draw35, draw36, draw37, draw38;
	wire e31, e32, e33, e34, e35, e36, e37, e38;

	// COLUMN 4
	wire done41, done42, done43, done44, done45, done46, done47, done48;
	wire out41, out42, out43, out44, out45,out46,out47,out48;
	wire [7:0] x41, x42, x43, x44,x45,x46,x47,x48;
	wire [6:0] y41, y42, y43, y44,y45,y46,y47,y48;
	wire [2:0] c41, c42, c43, c44,c45,c46,c47,c48;
	reg draw41, draw42, draw43, draw44, draw45, draw46, draw47, draw48;
	wire e41, e42, e43, e44, e45, e46, e47, e48;

	//assigning outs
	assign out_c1 = e18;
						 
	assign out_c2 = e28;

	assign out_c3 = e38;

	assign out_c4 = e48;


	wire [4:0] random_n0, random_n1, random_n2, random_n3;

 	// COLUMN 1
	generate_random g0 (
		.enable(gen_rand),
		.clock (clock),
		.resetn(resetn),
		.out   (random_n0)
		);
	generate_random g1 (
		.enable(gen_rand),
		.clock (clock),
		.resetn(resetn),
		.out   (random_n1)
		);
	generate_random g2 (
		.enable(gen_rand),
		.clock (clock),
		.resetn(resetn),
		.out   (random_n2)
		);
	generate_random g3 (
		.enable(gen_rand),
		.clock (clock),
		.resetn(resetn),
		.out   (random_n3)
		);

	draw_node d11 (
		.enable    (random_n0[4]),
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

	// COLUMN 2
	draw_node d21 (
		.enable    (random_n1[4] ^ random_n1[2]),
		.out       (out21),
		.enabled   (e21),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd1),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw21),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x21),
		.out_y     (y21),
		.out_colour(c21),
		.done_flag (done21)
		);

	draw_node d22 (
		.enable    (out21),
		.out       (out22),
		.enabled   (e22),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd6),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw22),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x22),
		.out_y     (y22),
		.out_colour(c22),
		.done_flag (done22)
		);

	draw_node d23 (
		.enable    (out22),
		.out       (out23),
		.enabled   (e23),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd11),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw23),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x23),
		.out_y     (y23),
		.out_colour(c23),
		.done_flag (done23)
		);

	draw_node d24 (
		.enable    (out23),
		.out       (out24),
		.enabled   (e24),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd16),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw24),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x24),
		.out_y     (y24),
		.out_colour(c24),
		.done_flag (done24)
		);

	draw_node d25 (
		.enable    (out24),
		.out       (out25),
		.enabled   (e25),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd21),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw25),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x25),
		.out_y     (y25),
		.out_colour(c25),
		.done_flag (done25)
		);
	draw_node d26 (
		.enable    (out25),
		.out       (out26),
		.enabled   (e26),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd26),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw26),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x26),
		.out_y     (y26),
		.out_colour(c26),
		.done_flag (done26)
		);
	draw_node d27 (
		.enable    (out26),
		.out       (out27),
		.enabled   (e27),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd31),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw27),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x27),
		.out_y     (y27),
		.out_colour(c27),
		.done_flag (done27)
		);
	draw_node d28 (
		.enable    (out27),
		.out       (out28),
		.enabled   (e28),
		.clock     (clock),
		.in_x      (8'b00001010),
		.in_y      (7'd36),
		.in_colour (3'b010),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw28),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x28),
		.out_y     (y28),
		.out_colour(c28),
		.done_flag (done28)
		);

	// COLUMN 3
	draw_node d31 (
		.enable    (random_n2[4] ^ random_n2[3]),
		.out       (out31),
		.enabled   (e31),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd1),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw31),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x31),
		.out_y     (y31),
		.out_colour(c31),
		.done_flag (done31)
		);

	draw_node d32 (
		.enable    (out31),
		.out       (out32),
		.enabled   (e32),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd6),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw32),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x32),
		.out_y     (y32),
		.out_colour(c32),
		.done_flag (done32)
		);

	draw_node d33 (
		.enable    (out32),
		.out       (out33),
		.enabled   (e33),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd11),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw33),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x33),
		.out_y     (y33),
		.out_colour(c33),
		.done_flag (done33)
		);

	draw_node d34 (
		.enable    (out33),
		.out       (out34),
		.enabled   (e34),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd16),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw34),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x34),
		.out_y     (y34),
		.out_colour(c34),
		.done_flag (done34)
		);

	draw_node d35 (
		.enable    (out34),
		.out       (out35),
		.enabled   (e35),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd21),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw35),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x35),
		.out_y     (y35),
		.out_colour(c35),
		.done_flag (done35)
		);
	draw_node d36 (
		.enable    (out35),
		.out       (out36),
		.enabled   (e36),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd26),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw36),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x36),
		.out_y     (y36),
		.out_colour(c36),
		.done_flag (done36)
		);
	draw_node d37 (
		.enable    (out36),
		.out       (out37),
		.enabled   (e37),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd31),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw37),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x37),
		.out_y     (y37),
		.out_colour(c37),
		.done_flag (done37)
		);
	draw_node d38 (
		.enable    (out37),
		.out       (out38),
		.enabled   (e38),
		.clock     (clock),
		.in_x      (8'b00010011),
		.in_y      (7'd36),
		.in_colour (3'b011),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw38),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x38),
		.out_y     (y38),
		.out_colour(c38),
		.done_flag (done38)
		);

	// COLUMN 4
	draw_node d41 (
		.enable    (random_n3[4]^ random_n2[0]),
		.out       (out41),
		.enabled   (e41),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd1),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw41),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x41),
		.out_y     (y41),
		.out_colour(c41),
		.done_flag (done41)
		);

	draw_node d42 (
		.enable    (out41),
		.out       (out42),
		.enabled   (e42),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd6),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw42),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x42),
		.out_y     (y42),
		.out_colour(c42),
		.done_flag (done42)
		);

	draw_node d43 (
		.enable    (out42),
		.out       (out43),
		.enabled   (e43),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd11),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw43),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x43),
		.out_y     (y43),
		.out_colour(c43),
		.done_flag (done43)
		);

	draw_node d44 (
		.enable    (out43),
		.out       (out44),
		.enabled   (e44),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd16),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw44),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x44),
		.out_y     (y44),
		.out_colour(c44),
		.done_flag (done44)
		);

	draw_node d45 (
		.enable    (out44),
		.out       (out45),
		.enabled   (e45),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd21),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw45),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x45),
		.out_y     (y45),
		.out_colour(c45),
		.done_flag (done45)
		);
	draw_node d46 (
		.enable    (out45),
		.out       (out46),
		.enabled   (e46),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd26),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw46),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x46),
		.out_y     (y46),
		.out_colour(c46),
		.done_flag (done46)
		);
	draw_node d47 (
		.enable    (out46),
		.out       (out47),
		.enabled   (e47),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd31),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw47),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x47),
		.out_y     (y47),
		.out_colour(c47),
		.done_flag (done47)
		);
	draw_node d48 (
		.enable    (out47),
		.out       (out48),
		.enabled   (e48),
		.clock     (clock),
		.in_x      (8'b00011100),
		.in_y      (7'd36),
		.in_colour (3'b100),
		.resetn    (resetn),
		.shift     (shift),
		.draw      (draw48),
		.erase     (erase),
		.reset_draw(reset_draw),
		.out_x     (x48),
		.out_y     (y48),
		.out_colour(c48),
		.done_flag (done48)
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e18;
 		   	end
 		   	//COLUMN 2
 		   	7'd8: begin
    			out_y = y21;
    			out_x = x21;
    			out_colour = c21;
    			done_flag = done21;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = draw;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e21;
    		end 
 		   	7'd9: begin
 		   		out_y = y22;
    			out_x = x22;
    			out_colour = c22;
    			done_flag = done22;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = draw;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e22;
 		   	end
 		   	7'd10: begin
 		   		out_y = y23;
    			out_x = x23;
    			out_colour = c23;
    			done_flag = done23;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = draw;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e23;
 		   	end
 		   	7'd11: begin
 		   		out_y = y24;
    			out_x = x24;
    			out_colour = c24;
    			done_flag = done24;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = draw;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e24;
 		   	end
 		   	7'd12: begin
 		   		out_y = y25;
    			out_x = x25;
    			out_colour = c25;
    			done_flag = done25;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = draw;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e25;
 		   	end
 		   	7'd13: begin
 		   		out_y = y26;
    			out_x = x26;
    			out_colour = c26;
    			done_flag = done26;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = draw;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e26;
 		   	end
 		   	7'd14: begin
 		   		out_y = y27;
    			out_x = x27;
    			out_colour = c27;
    			done_flag = done27;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = draw;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e27;
 		   	end
 		   	7'd15: begin
 		   		out_y = y28;
    			out_x = x28;
    			out_colour = c28;
    			done_flag = done28;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			draw28 = draw;
    			enabled = e28;
 		   	end

 		   	//COLUMN 3
 		   	7'd16: begin
    			out_y = y31;
    			out_x = x31;
    			out_colour = c31;
    			done_flag = done31;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = draw;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e31;
    		end 
 		   	7'd17: begin
 		   		out_y = y32;
    			out_x = x32;
    			out_colour = c32;
    			done_flag = done32;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = draw;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e32;
 		   	end
 		   	7'd18: begin
 		   		out_y = y33;
    			out_x = x33;
    			out_colour = c33;
    			done_flag = done33;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = draw;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e33;
 		   	end
 		   	7'd19: begin
 		   		out_y = y34;
    			out_x = x34;
    			out_colour = c34;
    			done_flag = done34;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = draw;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e34;
 		   	end
 		   	7'd20: begin
 		   		out_y = y35;
    			out_x = x35;
    			out_colour = c35;
    			done_flag = done35;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = draw;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e35;
 		   	end
 		   	7'd21: begin
 		   		out_y = y36;
    			out_x = x36;
    			out_colour = c36;
    			done_flag = done36;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = draw;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e36;
 		   	end
 		   	7'd22: begin
 		   		out_y = y37;
    			out_x = x37;
    			out_colour = c37;
    			done_flag = done37;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = draw;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e37;
 		   	end
 		   	7'd23: begin
 		   		out_y = y38;
    			out_x = x38;
    			out_colour = c38;
    			done_flag = done38;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = draw;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e38;
 		   	end
 		   		//COLUMN 4
 		   	7'd24: begin
    			out_y = y41;
    			out_x = x41;
    			out_colour = c41;
    			done_flag = done41;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = draw;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e41;
    		end 
 		   	7'd25: begin
 		   		out_y = y42;
    			out_x = x42;
    			out_colour = c42;
    			done_flag = done42;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = draw;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e42;
 		   	end
 		   	7'd26: begin
 		   		out_y = y43;
    			out_x = x43;
    			out_colour = c43;
    			done_flag = done43;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = draw;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e43;
 		   	end
 		   	7'd27: begin
 		   		out_y = y44;
    			out_x = x44;
    			out_colour = c44;
    			done_flag = done44;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = draw;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e44;
 		   	end
 		   	7'd28: begin
 		   		out_y = y45;
    			out_x = x45;
    			out_colour = c45;
    			done_flag = done45;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = draw;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e45;
 		   	end
 		   	7'd29: begin
 		   		out_y = y46;
    			out_x = x46;
    			out_colour = c46;
    			done_flag = done46;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = draw;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
    			enabled = e46;
 		   	end
 		   	7'd30: begin
 		   		out_y = y47;
    			out_x = x47;
    			out_colour = c47;
    			done_flag = done47;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = draw;
    			draw48 = 1'b0;
    			enabled = e47;
 		   	end
 		   	7'd31: begin
 		   		out_y = y48;
    			out_x = x48;
    			out_colour = c48;
    			done_flag = done48;
    			draw11 = 1'b0;
    			draw12 = 1'b0;
    			draw13 = 1'b0;
    			draw14 = 1'b0;
    			draw15 = 1'b0;
    			draw16 = 1'b0;
    			draw17 = 1'b0;
    			draw18 = 1'b0;
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = draw;
    			enabled = e48;
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
    			draw21 = 1'b0;
    			draw22 = 1'b0;
    			draw23 = 1'b0;
    			draw24 = 1'b0;
    			draw25 = 1'b0;
    			draw26 = 1'b0;
    			draw27 = 1'b0;
    			draw28 = 1'b0;
    			draw31 = 1'b0;
    			draw32 = 1'b0;
    			draw33 = 1'b0;
    			draw34 = 1'b0;
    			draw35 = 1'b0;
    			draw36 = 1'b0;
    			draw37 = 1'b0;
    			draw38 = 1'b0;
    			draw41 = 1'b0;
    			draw42 = 1'b0;
    			draw43 = 1'b0;
    			draw44 = 1'b0;
    			draw45 = 1'b0;
    			draw46 = 1'b0;
    			draw47 = 1'b0;
    			draw48 = 1'b0;
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

module SpeedCounter(enable, clock, resetn, out);
	input enable, clock, resetn;
	output out;
	
	reg [27:0] delay = 28'd60;
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



module LifeCounter(enable, clock, resetn, life, out);
	input enable, clock, resetn;
	output out;
	output reg [7:0] life;
	
	reg [7:0] delay = 8'b11111111;
	
	always@(posedge clock)
	begin
		if (resetn == 1'b0)
			life <= delay;
		else if (enable == 1'b1)
		begin
			if (life == 8'd0)
				life <= delay;
			else
				life <= life - 1'b1;
		end
	end
	
	assign out = (life == 8'd0) ? 1 : 0;
endmodule

module SecondsCounter(enable, clock, resetn, counter, out);
	input enable, clock, resetn;
	output out;
	output reg [27:0] counter;
	
	reg [27:0] delay = 28'd50000000;
	
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

module DelayCounter(enable, clock, resetn, out);
	input enable, clock, resetn;
	output out;
	
	//reg [27:0] delay = 28'd10;
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
				counter <= counter - 1'b1;
		end
	end
	
	assign out = (counter == 28'd0) ? 1 : 0;
endmodule

module FrameCounter(enable, clock, resetn, frame_limit, out);
	input enable, clock, resetn;
	input [5:0] frame_limit;
	output out;
	
	reg [5:0] frame_counter;
	
	always@(posedge clock)
	begin
		if (resetn == 1'b0)
			frame_counter <= 6'b000000;
		else if (enable == 1'b1)
		begin
			if (frame_counter == frame_limit)
				frame_counter <= 6'b000000;
			else
				frame_counter <= frame_counter + 1'b1;
		end
	end
	
	assign out = (frame_counter == frame_limit) ? 1 : 0;
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
	output [7:0] state;
	output reg [6:0] select_node;
	reg [7:0] current_state, next_state;
	assign state = current_state;
	localparam  IDLE = 8'd0,
				DRAW_WAIT0 = 8'd1,
				DRAW0 = 8'd2,
				DRAW_WAIT1 = 8'd3,
				DRAW1 = 8'd4,
				DRAW_WAIT2 = 8'd5,
				DRAW2 = 8'd6,
				DRAW_WAIT3 = 8'd7,
				DRAW3 = 8'd8,
				DRAW_WAIT4 = 8'd9,
				DRAW4 = 8'd10,
				DRAW_WAIT5 = 8'd11,
				DRAW5 = 8'd12,
				DRAW_WAIT6 = 8'd13,
				DRAW6 = 8'd14,
				DRAW_WAIT7 = 8'd15,
				DRAW7 = 8'd16,
				WAIT= 8'd17,
				WAIT_FINISH = 8'd18,
				ERASE0= 8'd19,
				ERASE_WAIT0 = 8'd20,
				ERASE1= 8'd21, 
				ERASE_WAIT1 = 8'd22, 
				ERASE2= 8'd23,
				ERASE_WAIT2 = 8'd24, 
				ERASE3= 8'd25,
				ERASE_WAIT3 = 8'd26, 
				ERASE4= 8'd27,
				ERASE_WAIT4 = 8'd28, 
				ERASE5= 8'd29,
				ERASE_WAIT5 = 8'd30, 
				ERASE6= 8'd31,
				ERASE_WAIT6 = 8'd32, 
				ERASE7= 8'd33,
				ERASE_WAIT7 = 8'd34, 
				UPDATE = 8'd35, 
				GENERATE = 8'd36,
				// column 2
				DRAW_WAIT20 = 8'd38,
				DRAW20 = 8'd39,
				DRAW_WAIT21 = 8'd40,
				DRAW21 = 8'd41,
				DRAW_WAIT22 = 8'd42,
				DRAW22 = 8'd43,
				DRAW_WAIT23 = 8'd44,
				DRAW23 = 8'd45,
				DRAW_WAIT24 = 8'd46,
				DRAW24 = 8'd47,
				DRAW_WAIT25 = 8'd48,
				DRAW25 = 8'd49,
				DRAW_WAIT26 = 8'd50,
				DRAW26 = 8'd51,
				DRAW_WAIT27 = 8'd52,
				DRAW27 = 8'd53,

				ERASE20 = 8'd55,
				ERASE_WAIT20 = 8'd56,
				ERASE21 = 8'd57, 
				ERASE_WAIT21 = 8'd58, 
				ERASE22 = 8'd59,
				ERASE_WAIT22 = 8'd60, 
				ERASE23 = 8'd61,
				ERASE_WAIT23 = 8'd62, 
				ERASE24 = 8'd63,
				ERASE_WAIT24 = 8'd64, 
				ERASE25 = 8'd65,
				ERASE_WAIT25 = 8'd66, 
				ERASE26 = 8'd67,
				ERASE_WAIT26 = 8'd68, 
				ERASE27 = 8'd69,
				ERASE_WAIT27 = 8'd70, 

				// column 3
				DRAW_WAIT30 = 8'd73,
				DRAW30 = 8'd74,
				DRAW_WAIT31 = 8'd75,
				DRAW31 = 8'd76,
				DRAW_WAIT32 = 8'd77,
				DRAW32 = 8'd78,
				DRAW_WAIT33 = 8'd79,
				DRAW33 = 8'd80,
				DRAW_WAIT34 = 8'd81,
				DRAW34 = 8'd82,
				DRAW_WAIT35 = 8'd83,
				DRAW35 = 8'd84,
				DRAW_WAIT36 = 8'd85,
				DRAW36 = 8'd86,
				DRAW_WAIT37 = 8'd87,
				DRAW37 = 8'd88,

				ERASE30 = 8'd90,
				ERASE_WAIT30 = 8'd91,
				ERASE31 = 8'd92, 
				ERASE_WAIT31 = 8'd93, 
				ERASE32 = 8'd94,
				ERASE_WAIT32 = 8'd95, 
				ERASE33 = 8'd96,
				ERASE_WAIT33 = 8'd97, 
				ERASE34 = 8'd98,
				ERASE_WAIT34 = 8'd99, 
				ERASE35 = 8'd100,
				ERASE_WAIT35 = 8'd101, 
				ERASE36 = 8'd102,
				ERASE_WAIT36 = 8'd103, 
				ERASE37 = 8'd104,
				ERASE_WAIT37 = 8'd105, 

				// column 4
				DRAW_WAIT40 = 8'd108,
				DRAW40 = 8'd109,
				DRAW_WAIT41 = 8'd110,
				DRAW41 = 8'd111,
				DRAW_WAIT42 = 8'd112,
				DRAW42 = 8'd113,
				DRAW_WAIT43 = 8'd114,
				DRAW43 = 8'd115,
				DRAW_WAIT44 = 8'd116,
				DRAW44 = 8'd117,
				DRAW_WAIT45 = 8'd118,
				DRAW45 = 8'd119,
				DRAW_WAIT46 = 8'd120,
				DRAW46 = 8'd121,
				DRAW_WAIT47 = 8'd122,
				DRAW47 = 8'd123,

				ERASE40 = 8'd125,
				ERASE_WAIT40 = 8'd126,
				ERASE41 = 8'd127, 
				ERASE_WAIT41 = 8'd128, 
				ERASE42 = 8'd129,
				ERASE_WAIT42 = 8'd130, 
				ERASE43 = 8'd131,
				ERASE_WAIT43 = 8'd132, 
				ERASE44 = 8'd133,
				ERASE_WAIT44 = 8'd134, 
				ERASE45 = 8'd135,
				ERASE_WAIT45 = 8'd136, 
				ERASE46 = 8'd137,
				ERASE_WAIT46 = 8'd138, 
				ERASE47 = 8'd139,
				ERASE_WAIT47 = 8'd140
				;
				
				

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
			//COLUMN 1
			DRAW_WAIT0: next_state = enabled ? DRAW0 : DRAW_WAIT1;
			DRAW0: next_state = done_flag ? DRAW_WAIT1 : DRAW0;
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
			DRAW_WAIT7: next_state = enabled ? DRAW7 : DRAW_WAIT20;
			DRAW7: next_state = done_flag ? DRAW_WAIT20 : DRAW7;
			// COLUMN 2
			DRAW_WAIT20: next_state = enabled ? DRAW20 : DRAW_WAIT21;
            DRAW20: next_state = done_flag ? DRAW_WAIT21 : DRAW20;
            DRAW_WAIT21: next_state = enabled ? DRAW21 : DRAW_WAIT22;
            DRAW21: next_state = done_flag ? DRAW_WAIT22 : DRAW21;
            DRAW_WAIT22: next_state = enabled ? DRAW22 : DRAW_WAIT23;
            DRAW22: next_state = done_flag ? DRAW_WAIT23 : DRAW22;
            DRAW_WAIT23: next_state = enabled ? DRAW23 : DRAW_WAIT24;
            DRAW23: next_state = done_flag ? DRAW_WAIT24 : DRAW23;
            DRAW_WAIT24: next_state = enabled ? DRAW24 : DRAW_WAIT25;
            DRAW24: next_state = done_flag ? DRAW_WAIT25 : DRAW24;
            DRAW_WAIT25: next_state = enabled ? DRAW25 : DRAW_WAIT26;
            DRAW25: next_state = done_flag ? DRAW_WAIT26 : DRAW25;
            DRAW_WAIT26: next_state = enabled ? DRAW26 : DRAW_WAIT27;
            DRAW26: next_state = done_flag ? DRAW_WAIT27 : DRAW26;
            DRAW_WAIT27: next_state = enabled ? DRAW27 : DRAW_WAIT30;
            DRAW27: next_state = done_flag ? DRAW_WAIT30 : DRAW27;
            // COLUMN 3
			DRAW_WAIT30: next_state = enabled ? DRAW30 : DRAW_WAIT31;
            DRAW30: next_state = done_flag ? DRAW_WAIT31 : DRAW30;
            DRAW_WAIT31: next_state = enabled ? DRAW31 : DRAW_WAIT32;
            DRAW31: next_state = done_flag ? DRAW_WAIT32 : DRAW31;
            DRAW_WAIT32: next_state = enabled ? DRAW32 : DRAW_WAIT33;
            DRAW32: next_state = done_flag ? DRAW_WAIT33 : DRAW32;
            DRAW_WAIT33: next_state = enabled ? DRAW33 : DRAW_WAIT34;
            DRAW33: next_state = done_flag ? DRAW_WAIT34 : DRAW33;
            DRAW_WAIT34: next_state = enabled ? DRAW34 : DRAW_WAIT35;
            DRAW34: next_state = done_flag ? DRAW_WAIT35 : DRAW34;
            DRAW_WAIT35: next_state = enabled ? DRAW35 : DRAW_WAIT36;
            DRAW35: next_state = done_flag ? DRAW_WAIT36 : DRAW35;
            DRAW_WAIT36: next_state = enabled ? DRAW36 : DRAW_WAIT37;
            DRAW36: next_state = done_flag ? DRAW_WAIT37 : DRAW36;
            DRAW_WAIT37: next_state = enabled ? DRAW37 : DRAW_WAIT40;
            DRAW37: next_state = done_flag ? DRAW_WAIT40 : DRAW37;
            // COLUMN 4
			DRAW_WAIT40: next_state = enabled ? DRAW40 : DRAW_WAIT41;
            DRAW40: next_state = done_flag ? DRAW_WAIT41 : DRAW40;
            DRAW_WAIT41: next_state = enabled ? DRAW41 : DRAW_WAIT42;
            DRAW41: next_state = done_flag ? DRAW_WAIT42 : DRAW41;
            DRAW_WAIT42: next_state = enabled ? DRAW42 : DRAW_WAIT43;
            DRAW42: next_state = done_flag ? DRAW_WAIT43 : DRAW42;
            DRAW_WAIT43: next_state = enabled ? DRAW43 : DRAW_WAIT44;
            DRAW43: next_state = done_flag ? DRAW_WAIT44 : DRAW43;
            DRAW_WAIT44: next_state = enabled ? DRAW44 : DRAW_WAIT45;
            DRAW44: next_state = done_flag ? DRAW_WAIT45 : DRAW44;
            DRAW_WAIT45: next_state = enabled ? DRAW45 : DRAW_WAIT46;
            DRAW45: next_state = done_flag ? DRAW_WAIT46 : DRAW45;
            DRAW_WAIT46: next_state = enabled ? DRAW46 : DRAW_WAIT47;
            DRAW46: next_state = done_flag ? DRAW_WAIT47 : DRAW46;
            DRAW_WAIT47: next_state = enabled ? DRAW47 : WAIT;
            DRAW47: next_state = done_flag ? WAIT : DRAW47;
			WAIT: next_state = WAIT_FINISH;
			WAIT_FINISH: next_state =  done_wait ? ERASE0 : WAIT_FINISH;
			// column 1
			ERASE0: next_state = done_flag ? ERASE_WAIT0 : ERASE0;
			ERASE_WAIT0: next_state = ERASE1;
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
			ERASE_WAIT7: next_state = ERASE20;
			// column 2
			ERASE20: next_state = done_flag ? ERASE_WAIT20 : ERASE20;
			ERASE_WAIT20: next_state = ERASE21;
			ERASE21: next_state = done_flag ? ERASE_WAIT21 : ERASE21;
			ERASE_WAIT21: next_state = ERASE22;
			ERASE22: next_state = done_flag ? ERASE_WAIT22 : ERASE22;
			ERASE_WAIT22: next_state = ERASE23;
			ERASE23: next_state = done_flag ? ERASE_WAIT23 : ERASE23;
			ERASE_WAIT23: next_state = ERASE24;
			ERASE24: next_state = done_flag ? ERASE_WAIT24 : ERASE24;
			ERASE_WAIT24: next_state = ERASE25;
			ERASE25: next_state = done_flag ? ERASE_WAIT25 : ERASE25;
			ERASE_WAIT25: next_state = ERASE26;
			ERASE26: next_state = done_flag ? ERASE_WAIT26 : ERASE26;
			ERASE_WAIT26: next_state = ERASE27;
			ERASE27: next_state = done_flag ? ERASE_WAIT27 : ERASE27;
			ERASE_WAIT27: next_state = ERASE30;
			// column 3
			ERASE30: next_state = done_flag ? ERASE_WAIT30 : ERASE30;
			ERASE_WAIT30: next_state = ERASE31;
			ERASE31: next_state = done_flag ? ERASE_WAIT31 : ERASE31;
			ERASE_WAIT31: next_state = ERASE32;
			ERASE32: next_state = done_flag ? ERASE_WAIT32 : ERASE32;
			ERASE_WAIT32: next_state = ERASE33;
			ERASE33: next_state = done_flag ? ERASE_WAIT33 : ERASE33;
			ERASE_WAIT33: next_state = ERASE34;
			ERASE34: next_state = done_flag ? ERASE_WAIT34 : ERASE34;
			ERASE_WAIT34: next_state = ERASE35;
			ERASE35: next_state = done_flag ? ERASE_WAIT35 : ERASE35;
			ERASE_WAIT35: next_state = ERASE36;
			ERASE36: next_state = done_flag ? ERASE_WAIT36 : ERASE36;
			ERASE_WAIT36: next_state = ERASE37;
			ERASE37: next_state = done_flag ? ERASE_WAIT37 : ERASE37;
			ERASE_WAIT37: next_state = ERASE40;
			// column 4
			ERASE40: next_state = done_flag ? ERASE_WAIT40 : ERASE40;
			ERASE_WAIT40: next_state = ERASE41;
			ERASE41: next_state = done_flag ? ERASE_WAIT41 : ERASE41;
			ERASE_WAIT41: next_state = ERASE42;
			ERASE42: next_state = done_flag ? ERASE_WAIT42 : ERASE42;
			ERASE_WAIT42: next_state = ERASE43;
			ERASE43: next_state = done_flag ? ERASE_WAIT43 : ERASE43;
			ERASE_WAIT43: next_state = ERASE44;
			ERASE44: next_state = done_flag ? ERASE_WAIT44 : ERASE44;
			ERASE_WAIT44: next_state = ERASE45;
			ERASE45: next_state = done_flag ? ERASE_WAIT45 : ERASE45;
			ERASE_WAIT45: next_state = ERASE46;
			ERASE46: next_state = done_flag ? ERASE_WAIT46 : ERASE46;
			ERASE_WAIT46: next_state = ERASE47;
			ERASE47: next_state = done_flag ? ERASE_WAIT47 : ERASE47;
			ERASE_WAIT47: next_state = UPDATE;
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
		select_node = 7'b1111111;
		gen_rand = 1'b0;
		
		case (current_state)
			DRAW_WAIT0: begin
				reset_draw = 1'b0;
				select_node = 7'd0;
			end
			DRAW0: begin
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
			//COLUMN 2
			DRAW_WAIT20: begin
				reset_draw = 1'b0;
				select_node = 7'd8;
			end
			DRAW20: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd8;
			end
			DRAW_WAIT21: begin
				reset_draw = 1'b0;
				select_node = 7'd9;
			end
			DRAW21: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd9;
			end
			DRAW_WAIT22: begin
				reset_draw = 1'b0;
				select_node = 7'd10;
			end
			DRAW22: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd10;
			end
			DRAW_WAIT23: begin
				reset_draw = 1'b0;
				select_node = 7'd11;
			end
			DRAW23: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd11;
			end
			DRAW_WAIT24: begin
				reset_draw = 1'b0;
				select_node = 7'd12;
			end
			DRAW24: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd12;
			end
			DRAW_WAIT25: begin
				reset_draw = 1'b0;
				select_node = 7'd13;
			end
			DRAW25: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd13;
			end
			DRAW_WAIT26: begin
				reset_draw = 1'b0;
				select_node = 7'd14;
			end
			DRAW26: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd14;
			end
			DRAW_WAIT27: begin
				reset_draw = 1'b0;
				select_node = 7'd15;
			end
			DRAW27: begin
				draw = 1'b1;
				plot = 1'b1;
				select_node = 7'd15;
			end
			//COLUMN 3
		    DRAW_WAIT30: begin
		          reset_draw = 1'b0;
		          select_node = 7'd16;
		    end
		    DRAW30: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd16;
		    end
		    DRAW_WAIT31: begin
		          reset_draw = 1'b0;
		          select_node = 7'd17;
		    end
		    DRAW31: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd17;
		    end
		    DRAW_WAIT32: begin
		          reset_draw = 1'b0;
		          select_node = 7'd18;
		    end
		    DRAW32: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd18;
		    end
		    DRAW_WAIT33: begin
		          reset_draw = 1'b0;
		          select_node = 7'd19;
		    end
		    DRAW33: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd19;
		    end
		    DRAW_WAIT34: begin
		          reset_draw = 1'b0;
		          select_node = 7'd20;
		    end
		    DRAW34: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd20;
		    end
		    DRAW_WAIT35: begin
		          reset_draw = 1'b0;
		          select_node = 7'd21;
		    end
		    DRAW35: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd21;
		    end
		    DRAW_WAIT36: begin
		          reset_draw = 1'b0;
		          select_node = 7'd22;
		    end
		    DRAW36: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd22;
		    end
		    DRAW_WAIT37: begin
		          reset_draw = 1'b0;
		          select_node = 7'd23;
		    end
		    DRAW37: begin
		          draw = 1'b1;
		          plot = 1'b1;
		          select_node = 7'd23;
		    end
		    //COLUMN 4
            DRAW_WAIT40: begin
                  reset_draw = 1'b0;
                  select_node = 7'd24;
            end
            DRAW40: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd24;
            end
            DRAW_WAIT41: begin
                  reset_draw = 1'b0;
                  select_node = 7'd25;
            end
            DRAW41: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd25;
            end
            DRAW_WAIT42: begin
                  reset_draw = 1'b0;
                  select_node = 7'd26;
            end
            DRAW42: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd26;
            end
            DRAW_WAIT43: begin
                  reset_draw = 1'b0;
                  select_node = 7'd27;
            end
            DRAW43: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd27;
            end
            DRAW_WAIT44: begin
                  reset_draw = 1'b0;
                  select_node = 7'd28;
            end
            DRAW44: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd28;
            end
            DRAW_WAIT45: begin
                  reset_draw = 1'b0;
                  select_node = 7'd29;
            end
            DRAW45: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd29;
            end
            DRAW_WAIT46: begin
                  reset_draw = 1'b0;
                  select_node = 7'd30;
            end
            DRAW46: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd30;
            end
            DRAW_WAIT47: begin
                  reset_draw = 1'b0;
                  select_node = 7'd31;
            end
            DRAW47: begin
                  draw = 1'b1;
                  plot = 1'b1;
                  select_node = 7'd31;
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
			// COLUMN 1
			ERASE0: begin
				draw = 1'b1;
				plot = 1'b1;
				erase = 1'b1;
				select_node = 7'd0;
				end
			ERASE_WAIT0: begin
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

			// COLUMN 2
	        ERASE20: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd8;
	                end
	        ERASE_WAIT20: begin
	                reset_draw = 1'b0;
	        end
	        ERASE21: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd9;
	                end
	        ERASE_WAIT21: begin
	                reset_draw = 1'b0;
	        end
	        ERASE22: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd10;
	                end
	        ERASE_WAIT22: begin
	                reset_draw = 1'b0;
	        end
	        ERASE23: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd11;
	                end
	        ERASE_WAIT23: begin
	                reset_draw = 1'b0;
	        end
	        ERASE24: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd12;
	                end
	        ERASE_WAIT24: begin
	                reset_draw = 1'b0;
	        end
	        ERASE25: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd13;
	                end
	        ERASE_WAIT25: begin
	                reset_draw = 1'b0;
	        end
	        ERASE26: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd14;
	                end
	        ERASE_WAIT26: begin
	                reset_draw = 1'b0;
	        end
	        ERASE27: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd15;
	                end
	        ERASE_WAIT27: begin
	                reset_draw = 1'b0;
	        end

			// COLUMN 3
	        ERASE30: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd16;
	                end
	        ERASE_WAIT30: begin
	                reset_draw = 1'b0;
	        end
	        ERASE31: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd17;
	                end
	        ERASE_WAIT31: begin
	                reset_draw = 1'b0;
	        end
	        ERASE32: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd18;
	                end
	        ERASE_WAIT32: begin
	                reset_draw = 1'b0;
	        end
	        ERASE33: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd19;
	                end
	        ERASE_WAIT33: begin
	                reset_draw = 1'b0;
	        end
	        ERASE34: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd20;
	                end
	        ERASE_WAIT34: begin
	                reset_draw = 1'b0;
	        end
	        ERASE35: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd21;
	                end
	        ERASE_WAIT35: begin
	                reset_draw = 1'b0;
	        end
	        ERASE36: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd22;
	                end
	        ERASE_WAIT36: begin
	                reset_draw = 1'b0;
	        end
	        ERASE37: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd23;
	                end
	        ERASE_WAIT37: begin
	                reset_draw = 1'b0;
	        end
			// COLUMN 4
	        ERASE40: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd24;
	                end
	        ERASE_WAIT40: begin
	                reset_draw = 1'b0;
	        end
	        ERASE41: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd25;
	                end
	        ERASE_WAIT41: begin
	                reset_draw = 1'b0;
	        end
	        ERASE42: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd26;
	                end
	        ERASE_WAIT42: begin
	                reset_draw = 1'b0;
	        end
	        ERASE43: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd27;
	                end
	        ERASE_WAIT43: begin
	                reset_draw = 1'b0;
	        end
	        ERASE44: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd28;
	                end
	        ERASE_WAIT44: begin
	                reset_draw = 1'b0;
	        end
	        ERASE45: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd29;
	                end
	        ERASE_WAIT45: begin
	                reset_draw = 1'b0;
	        end
	        ERASE46: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd30;
	                end
	        ERASE_WAIT46: begin
	                reset_draw = 1'b0;
	        end
	        ERASE47: begin
	                draw = 1'b1;
	                plot = 1'b1;
	                erase = 1'b1;
	                select_node = 7'd31;
	                end
	        ERASE_WAIT47: begin
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