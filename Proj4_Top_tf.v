`timescale 1ns / 1ps

module Proj4_Top_tf;

	// Inputs
	reg clk;
	reg reset;
	reg sw1;
	reg sw2;

	// Outputs
	wire vsync;
	wire hsync;
	wire [11:0] rgb;

	// Instantiate the Unit Under Test (UUT)
	Proj4_Top uut (
		.clk(clk), 
		.reset(reset), 
		.sw1(sw1), 
		.sw2(sw2), 
		.vsync(vsync), 
		.hsync(hsync), 
		.rgb(rgb)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		sw1 = 0;
		sw2 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#always 
	end
      
endmodule

