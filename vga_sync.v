`timescale 1ns / 1ps
//****************************************************************                                                                
//  Class: CECS 360													          
//  Project name: Animated VGA										          
//  File name: vga_sync.v		                                 
//                                                                
//  Created by Jayson Trinh on 10/10/17			                     
//  Copyright © 2017 Jayson Trinh. All rights reserved.            
//                                                                 
//  Abstract: This module is used to scan a 640x480 screen
//				  with a 25Mhz pixel rate. This also tracks the   
//				  relative position of the pixels by hsync and
//				  vsync.
//				     				
//  Edit history: 1.0											            
//****************************************************************
module vga_sync(clk, reset, hsync, vsync, video_on, hcount, vcount);

	//Inputs and Outputs
	input clk, reset;
	output hsync, vsync, video_on;
	output [9:0] hcount, vcount;
	
	//Wires
	wire Mhz25, endh, endv, h_video, v_video;
	
	//Registers
	reg [1:0] hclk, vclk;
	reg [9:0] hcount, vcount;
	
	//Assign the Boundaries
	assign Mhz25 = (vclk == 2'b11);
	assign endh  = (hcount == 10'd799);
	assign endv = (vcount == 10'd524);
	
	//Increment the Vertical Clock
	always@(posedge clk, posedge reset)
		if(reset) vclk <= 2'b0;
		else vclk <= vclk + 2'b1;
		
	//Incrementing the Horizontal Pixel
	always@(posedge clk, posedge reset)
		if(reset) hcount <= 10'b0;
		else if(Mhz25)
			if (endh) hcount <= 10'b0;
			else hcount <= hcount  + 10'b1;
	
	//Incrementing the Vertical Pixel
	always@(posedge clk, posedge reset)
		if(reset) vcount <= 10'b0;
		else if(Mhz25)
			if (endh)
				if (endv) vcount <= 10'b0;
				else vcount <= vcount  + 10'b1;
				
	//Assign the Outputs
	assign hsync = ~(hcount >= 656 & hcount <= 751);
	assign vsync = ~(vcount >= 490 & vcount <= 491);
	assign h_video = (hcount <= 639);
	assign v_video = (vcount <= 479);
	assign video_on = h_video & v_video;
	
endmodule
