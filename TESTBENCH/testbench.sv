/*
* @file testbench.sv
* @brief Contains functions for testing of modules
* @author Nicholas Amore namore7@gmail.com
* @date Created 4/29/2022
*/

`timescale 1ns / 100ps

module testbench();
    
	task checkEquality(
		input int expected_val,
		input int actual_val
	);
	
		if(expected_val == actual_val)begin
			$display("time=%0t expected_val=0x%0h actual_val=0x%0h", $time, expected_val, actual_val);
		end
		
		else begin
			$display("time=%0t expected_val=0x%0h actual_val=0x%0h", $time, expected_val, actual_val);
			$display("Error, test failed");
		end
	endtask

endmodule