`timescale 1ns / 1ps
//****************************************************************                                                            
//  Class: CECS 360													          
//  Project name: Animated VGA											          
//  File name: AISO.v				                                  
//                                                                 
//  Created by Jayson Trinh on 9/25/17			                      
//  Copyright © 2017 Jayson Trinh. All rights reserved.            
//                                                                 
//  Abstract: This module takes asynchonous clock ,being the      
//				  clock on the Nexys board, and makes the clock 		
//				  synchounous to the reset. The reason why it has 		
//				  to be synchounous out is because the						
//			     reset is asyncronous and the clock is synchronous
//				  meaning that the circuit will cause metastability.				
//				          											 
//  Edit history: 1.0											             
//****************************************************************//
module AISO(clk, reset_i, reset_o);

	input clk, reset_i;
	output reset_o;
	
	reg Q1, Q2;
	
	//Aysynchonous In
	always@(posedge clk or posedge reset_i)
		if(reset_i)
			begin
				Q1 <= 0;
				Q2 <= 0;
			end
		else
			begin
				Q1 <= 1'b1;
				Q2 <= Q1;
			end
		
	//Synchonous Out
	assign reset_o = ~ Q2;

endmodule
