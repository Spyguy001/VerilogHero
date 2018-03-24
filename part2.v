// Part 2 skeleton
 
module part2
    (
        CLOCK_50,                       //  On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
		  LEDR,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                        //  VGA Clock
        VGA_HS,                         //  VGA H_SYNC
        VGA_VS,                         //  VGA V_SYNC
        VGA_BLANK_N,                        //  VGA BLANK
        VGA_SYNC_N,                     //  VGA SYNC
        VGA_R,                          //  VGA Red[9:0]
        VGA_G,                          //  VGA Green[9:0]
        VGA_B                           //  VGA Blue[9:0]
    );
 
    input           CLOCK_50;               //  50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;
	 output [9:0] LEDR;
 
    // Declare your inputs and outputs here
    // Do not change the following outputs
    output          VGA_CLK;                //  VGA Clock
    output          VGA_HS;                 //  VGA H_SYNC
    output          VGA_VS;                 //  VGA V_SYNC
    output          VGA_BLANK_N;                //  VGA BLANK
    output          VGA_SYNC_N;             //  VGA SYNC
    output  [9:0]   VGA_R;                  //  VGA Red[9:0]
    output  [9:0]   VGA_G;                  //  VGA Green[9:0]
    output  [9:0]   VGA_B;                  //  VGA Blue[9:0]++
   
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
    /* vga_adapter VGA(
          .resetn(resetn),
         .clock(CLOCK_50),
          .colour(colour),
          .x(x),
          .y(y),
          .plot(writeEn),
          // Signals for the DAC to drive the monitor. 
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
      defparam VGA.BACKGROUND_IMAGE = "black.mif"; */
           
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
   
    wire run, frame, slock; 
	 wire flag;
    RateDivider_p2 r0 (1'b1, 2'd0, CLOCK_50, resetn, run);
    RateDivider_p2 r1 (run, 2'd3, CLOCK_50, resetn, frame);
	 RateDivider_p2 r2 (1'b1, 2'd0, CLOCK_50, resetn, slock);
   
    reg [6:0] data_in;
    wire [6:0] outY, outX;
    wire directoutX, directoutY;
    XCounter_p2 xC(frame, 1'b1, CLOCK_50, resetn, outX, directoutX);
    YCounter_p2 yC(frame, 1'b1, CLOCK_50, resetn, outY, directoutY);
   
    always@(*) begin
        if(ld_x)
            data_in = outX;
        else if(ld_y)
            data_in = outY;
    end
   
    datapath_p2 d0(
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
		  .flag(flag),
        .out_colour(colour),
		  .ledr(LEDR)
    );
   control_p2 c0(
        .clock(CLOCK_50),
        .resetn(resetn),
        .ld(slock),
        .go(frame),
        .ld_x(ld_x),
        .ld_y(ld_y),
        .ld_r(ld_r),
        .ld_e(ld_e),
        .draw(draw),
        .plot(writeEn)
        );
endmodule
 
module datapath_p2(data, colour, resetn, clock, ld_x, ld_y, ld_r, ld_e, draw, out_x, out_y, out_colour, flag, ledr);
    input [6:0] data;
    input [2:0] colour;
    input resetn, clock, ld_x, ld_y, ld_r, ld_e, draw;
   
    output [7:0] out_x;
    output [6:0] out_y;
    output reg [2:0] out_colour;
	 output reg flag;
	 output [9:0] ledr;
   
    reg [7:0] x;
    reg [6:0] y;
    reg [3:0] count;
	 
	 wire check_1, check_2, check_3, check_4;
	 
	 keyboard_tracker #(.PULSE_OR_HOLD(0)) checker(
	     .clock(clock),
		  .reset(resetn),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(check_1),
		  .a(check_2),
		  .s(check_3),
		  .d(check_4),
		  .left(ledr[0]),
		  .right(ledr[1]),
		  .up(ledr[2]),
		  .down(ledr[3]),
		  .space(ledr[8]),
		  .enter(ledr[9])
		  );
   
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
        if (!resetn) begin
            count <= 4'b0000;
				flag <= 0;
				end
        else if (draw)
            begin
                if (count == 4'b1111) begin
                    count <= 0;
						  flag <= 1;
						  end
                else
                    count <= count + 1'b1;
            end
		  else if (!draw)
				flag <= 0;
    end
   
    assign out_x = x + count[1:0];
    assign out_y = y + count[3:2];
endmodule
 
module XCounter_p2(enable, direction, clock, resetn, x, directout);
    input enable, direction, clock, resetn;
    output reg [6:0] x; output reg directout;
   
    always@(posedge clock) begin
        if(resetn == 1'b0) begin
            x <= 7'd0;
            directout <= 1'b1;
        end
        else if(enable == 1'b1) begin
            if(direction == 1'b0 && x != 7'd0)
                x <= x - 1'b1;
            else if(direction == 1'b0 && x == 7'd0)
                directout <= 1'b1;
            else if(direction == 1'b1 && x != 7'b11111111)
                x <= x + 1'b1;
            else if(direction == 1'b1 && x == 7'b11111111)
                directout <= 1'b0;
            else
                x <= x;
        end
    end
endmodule
 
module YCounter_p2(enable, direction, clock, resetn, y, directout);
    input enable, direction, clock, resetn;
    output reg [6:0] y; output reg directout;
   
    always@(posedge clock) begin
        if(resetn == 1'b0) begin
            y <= 7'd60;
            directout <= 1'b1;
        end
        else if(enable == 1'b1) begin
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
 
/*module RateDivider(enable, par_load, clock, reset_n, q);
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
            else					ld_e = 1'b1;
                out <= out - 1'b1;
        end
    end
   
    assign q = (out == 28'd0) ? 1 : 0;
endmodule*/
module RateDivider_p2(enable, frequency, clock, reset_n, enable_out);
	input enable;
	input clock;
	input reset_n;
	input [1:0] frequency;
	
	output enable_out;
	
	wire [27:0] Start;
	reg [27:0] start;
	wire [27:0] Count_Down;
	reg [27:0] count_down;
	
	
	always @(*)
	
	begin
		case(frequency)
			2'b00: start = {27'd0, 1'b1};
			2'b01: start = {2'b00, 26'd2};
			2'b10: start = {1'b0, 27'd3};
			2'b11: start = {28'd15};
			default: start = {27'd0, 1'b1};
		endcase
	end
	
	assign Start = start;
	
	
	always @(posedge clock)

	begin

		if (reset_n == 1'b0)

			count_down <= Start;

		else if (enable == 1'b1)

			begin

				if (count_down == 0)

					count_down <= Start;

				else

					count_down <= count_down - 1'b1;

			end

	end
	
	assign Count_Down = count_down;
	
	assign enable_out = (Count_Down == 28'd0) ? 1 : 0;

	
endmodule
 
module control_p2(clock, resetn, go, ld, ld_x, ld_y, ld_r, ld_e, draw, plot);
    input resetn, clock, go, ld;
    output reg ld_x, ld_y, ld_r, ld_e, draw, plot;
 
    reg [3:0] current_state, next_state;
   
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
            WAIT: next_state = go ? ERASE : WAIT;
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
		  ld_e = 1'b0;
        draw = 1'b0;
        plot = 1'b0;
       
        case (current_state)
				LOAD_X: begin
					ld_x = 1'b1;
					end
				LOAD_Y: begin
					ld_y = 1'b1;
					end
				LOAD_COLOUR: begin
					ld_r = 1'b1;
					end
				DRAW: begin
					draw = 1'b1;
					plot = 1'b1;
					end
				WAIT: begin
					draw = 1'b1;
					plot = 1'b1;
					end
				ERASE: begin
					ld_e = 1'b1;
					draw = 1'b1;
					plot = 1'b1;
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