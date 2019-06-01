`timescale 1ns / 1ps
//****************************************************************                                                                
//  Class: CECS 360													          
//  Project name: Animated VGA										          
//  File name: vga_sync.v		                                 
//                                                                
//  Created by Jayson Trinh on 10/10/17			                     
//  Copyright © 2017 Jayson Trinh. All rights reserved.            
//                                                                 
//  Abstract: This module is used to generate a wall, ball,
//				  and paddle. The paddle can move up and down  
//				  using the onboard buttons, the ball can move in 
//				  diagonal directions, and they all can detect
//				  collisions
//				     				
//  Edit history: 1.0											            
//****************************************************************
module graph_gen(clk, reset, db1, db2, video_on, hcount, vcount, graph_rgb);

	//Inputs
	input clk, reset, db1, db2, video_on;
	input [9:0] hcount, vcount;
	
	//Outputs
	output reg [11:0] graph_rgb;
	
	//Wires
	wire refr_tick, wall_on, bar_on, sq_ball_on, rd_ball_on;;
	wire [2:0] rom_addr, rom_col;
	wire [9:0] bar_y_t, bar_y_b, ball_x_l, ball_x_r, ball_y_t, ball_y_b, ball_x_next, ball_y_next;
	wire [11:0] wall_rgb, bar_rgb, ball_rgb;
	
	//Registers
	reg [7:0] rom_data;
	reg [9:0] ball_x_reg, ball_y_reg, bar_y_reg, bar_y_next,
				 x_delta_reg, x_delta_next, y_delta_reg, y_delta_next;
	
	//round ball image ROM
	always @(*)
		case(rom_addr)
			3'h0: rom_data = 8'b00111100;
			3'h1: rom_data = 8'b01111110;
			3'h2: rom_data = 8'b11111111;
			3'h3: rom_data = 8'b11111111;
			3'h4: rom_data = 8'b11111111;
			3'h5: rom_data = 8'b11111111;
			3'h6: rom_data = 8'b01111110;
			3'h7: rom_data = 8'b00111100;
		endcase
	
	//Register State Machine
	always@(posedge clk, posedge reset)
		if(reset)
			begin
				bar_y_reg <= 0;
				ball_x_reg <= 0;
				ball_y_reg <= 0;
				x_delta_reg <= 10'h004;
				y_delta_reg <= 10'h004;
			end
		else
			begin
				bar_y_reg <= bar_y_next;
				ball_x_reg <= ball_x_next;
				ball_y_reg <= ball_y_next;
				x_delta_reg <= x_delta_next;
				y_delta_reg <= y_delta_next;
			end
			
		assign refr_tick = (vcount == 481) && (hcount==0);
		
		//Wall Generator
		assign wall_on = (32 <= hcount) && (hcount<=35);
		assign wall_rgb = 12'b101100111010; //#B3A
		
		//Paddle Generator
		assign bar_y_t = bar_y_reg;
		assign bar_y_b = bar_y_t + 71;
		
		assign bar_on = (600 <= hcount) && (hcount <= 603) && 
						    (bar_y_t <= vcount) && (vcount <= bar_y_b);
							 
		assign bar_rgb = 12'b101111100000;
		
		always@(*)
		begin
			bar_y_next = bar_y_reg;
			if(refr_tick)
				if(db2 & (bar_y_b < (475)))
					bar_y_next = bar_y_reg + 4;
				else if(db1 & (bar_y_t > 4))
					bar_y_next = bar_y_reg - 4;
		end
		
		//Square Ball Generator
		assign ball_x_l = ball_x_reg;
		assign ball_y_t = ball_y_reg;
		assign ball_x_r = ball_x_l + 7;
		assign ball_y_b = ball_y_t + 7;
		
		assign sq_ball_on = (ball_x_l <= hcount) && (hcount <= ball_x_r) && 
								  (ball_y_t <= vcount) && (vcount <= ball_y_b);
		
		assign rom_addr = vcount[2:0] - ball_y_t[2:0];
		assign rom_col = hcount[2:0] - ball_x_l[2:0];
		assign rom_bit = rom_data[rom_col];
		assign rd_ball_on = sq_ball_on & rom_bit;
		assign ball_rgb = 12'b000000000000;
		
		assign ball_x_next = (refr_tick) ? ball_x_reg + x_delta_reg : ball_x_reg;
		assign ball_y_next = (refr_tick) ? ball_y_reg + y_delta_reg : ball_y_reg;
		
		//Boundaries Generator
		always@(*)
		begin
			x_delta_next = x_delta_reg;
			y_delta_next = y_delta_reg;
			if(ball_y_t < 1)   			//If ball hits top
				y_delta_next = 2;
			else if(ball_y_b > (479))	//If ball hits bottom
				y_delta_next = -2;
			else if(ball_x_l <= 35)		//If ball hits wall
				x_delta_next = 2; 
			else if((600 <= ball_x_r) && (ball_x_r <= 603) //If ball hits paddle
						&&(bar_y_t <= ball_y_b) && (ball_y_t <= bar_y_b))
				x_delta_next = -2;
		end
		
		//RGB Multiplexing Circuit
		always@(*)
			if(~video_on)
				graph_rgb = 12'b000000000000;
			else
				if(wall_on)
					graph_rgb = wall_rgb;
				else if(bar_on)
					graph_rgb = bar_rgb;
				else if(rd_ball_on)
					graph_rgb = ball_rgb;
				else
					graph_rgb = 12'b101111101110;
			
endmodule
