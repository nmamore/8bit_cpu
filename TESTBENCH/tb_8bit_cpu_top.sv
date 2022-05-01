/*
* @file tb_8bit_cpu.sv
* @brief top-level file for the nand2hack testbench
* @author Nicholas Amore namore7@gmail.com
* @date Created 4/29/2022
*/

`timescale 1ns/1ps

module tb_cpu_8bit ();

// ref clock = 24.00MHz => 41.7ns, For half of clock, PLD_CLK_SPEED = 20.9ns
localparam PLD_CLK_SPEED = 20.9;
	
logic pld_mclk;
logic pld_rstn;
	
cpu_8bit_top uut (
	.i_clk(pld_mclk),
	.i_rstn(pld_rstn)
);
	
testbench test();
//reference clock for CPU
initial begin
	$display("PLD clk started");
	pld_mclk = 1'b0;
	#15;
	forever
	begin
		#PLD_CLK_SPEED pld_mclk = 1'b1; //wait half period then toggle clock
		#PLD_CLK_SPEED pld_mclk = 1'b0;
	end
end
	
//run tests
initial begin
	#2000;
	pld_reset;
	test_ALUop();
	test_ALUflag();
	$stop;
end

/**
* @brief Reset PLD
* @detailed This test resets the PLD
*/
	
task pld_reset();
	pld_rstn = 1'b0;
	#200;
	pld_rstn = 1'b1;
	#500;	
endtask
	
/**
* @brief automated test for the ALU
* @detailed This test verifies that the ALU properly performs all 16 operations
*/
	
task test_ALUop();
	
	//Tests pass through of A register
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(8'hA5, uut.alu_out);
	#100;
	
	//Tests pass through of B register
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h1);
	alu_desel();
	test.checkEquality(8'h5A, uut.alu_out);
	#100;
	
	//Test AND of A and B register
	writeALU(8'hA5, 8'h39, 1'b0, 4'h2);
	alu_desel();
	test.checkEquality(8'h21, uut.alu_out);
	#100;
	
	//Test OR of A and B register
	writeALU(8'hA5, 8'h39, 1'b0, 4'h3);
	alu_desel();
	test.checkEquality(8'hBD, uut.alu_out);
	#100;
	
	//Test XOR of A and B register
	writeALU(8'hA5, 8'h39, 1'b0, 4'h4);
	alu_desel();
	test.checkEquality(8'h9C, uut.alu_out);
	#100;
	
	//Tests addition without carry in
	writeALU(8'h03, 8'h04, 1'b0, 4'h5);
	alu_desel();
	test.checkEquality(8'h07, uut.alu_out);
	#100;
	
	//Tests addition with carry in
	writeALU(8'h03, 8'h04, 1'b1, 4'h5);
	alu_desel();
	test.checkEquality(8'h08, uut.alu_out);
	#100;
	
	//Tests Subtraction without carry in
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h6);
	alu_desel();
	test.checkEquality(8'h4B, uut.alu_out);
	#100;
	
	//Tests Subtraction with carry in
	writeALU(8'hA5, 8'h5A, 1'b1, 4'h6);
	alu_desel();
	test.checkEquality( 8'h4C, uut.alu_out);
	#100;
	
	//Tests zeroing the output
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h7);
	alu_desel();
	test.checkEquality(8'h00, uut.alu_out);
	#100;
	
	//Tests 1's compliment of A input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h8);
	alu_desel();
	test.checkEquality(8'h5A, uut.alu_out);
	#100;
	
	//Tests 2's compliment of A input
	writeALU(8'hA5, 8'h5A, 1'b1, 4'h8);
	alu_desel();
	test.checkEquality(8'h5B, uut.alu_out);
	#100;
	
	//Tests 1's compliment of B input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h9);
	alu_desel();
	test.checkEquality(8'hA5, uut.alu_out);
	#100;
	
	//Tests 2's compliment of B input
	writeALU(8'hA5, 8'h5A, 1'b1, 4'h9);
	alu_desel();
	test.checkEquality(8'hA6, uut.alu_out);
	#100;
	
	//Tests increment of A input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hA);
	alu_desel();
	test.checkEquality(8'hA6, uut.alu_out);
	#100;
	
	//Tests decrement of A input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hB);
	alu_desel();
	test.checkEquality(8'hA4, uut.alu_out);
	#100;
	
	//Tests logical shift left
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hC);
	alu_desel();
	test.checkEquality(8'h4A, uut.alu_out);
	#100;
	
	//Tests logical shift right
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hD);
	alu_desel();
	test.checkEquality(8'h52, uut.alu_out);
	#100;
	
	//Tests arithmetic shift left
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hE);
	alu_desel();
	test.checkEquality(8'h4B, uut.alu_out);
	#100;
	
	//Tests bit reveral
	writeALU(8'hCC, 8'h5A, 1'b0, 4'hF);
	alu_desel();
	test.checkEquality(8'h33, uut.alu_out);
	#100;
endtask

task test_ALUflag();
	
	//Tests zero flag
	writeALU(8'h00, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(1'b1, uut.zr);
	#100;
	
	//Tests zero flag
	writeALU(8'h01, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(1'b0, uut.zr);
	#100;
	
	//Tests negative flag
	writeALU(8'hA0, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(1'b1, uut.ng);
	#100;
	
	//Tests negative flag
	writeALU(8'h01, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(1'b0, uut.ng);
	#100;
	
	//Tests parity flag
	writeALU(8'hAA, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(1'b1, uut.pa);
	#100;
	
	//Tests parity flag
	writeALU(8'h01, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(1'b0, uut.pa);
	#100;
	
	//Tests carry-out flag
	writeALU(8'hFF, 8'h5A, 1'b1, 4'h5);
	alu_desel();
	test.checkEquality(1'b1, uut.co);
	#100;
	
	//Tests carry-out flag
	writeALU(8'h01, 8'h5A, 1'b1, 4'h5);
	alu_desel();
	test.checkEquality(1'b0, uut.co);
	#100;
	
	//Tests overflow flag
	writeALU(8'h70, 8'h40, 1'b0, 4'h5);
	alu_desel();
	test.checkEquality(1'b1, uut.of);
	#100;
	
	//Tests overflow flag
	writeALU(8'h01, 8'h01, 1'b0, 4'h5);
	alu_desel();
	test.checkEquality(1'b0, uut.of);
	#100;
endtask

task writeALU(
	input [7:0] a_data,
	input [7:0] b_data,
	input cin,
	input [3:0] alu_opcode
);

	uut.a_data = a_data;
	uut.b_data = b_data;
	uut.alu_op = alu_opcode;
	uut.cin = cin;
	
	@(negedge pld_mclk);
	uut.alu_sel = 1'b1;
	uut.flag_sel = 1'b1;	
endtask

task alu_desel();
	@(negedge pld_mclk);
	uut.alu_sel = 1'b0;
	uut.flag_sel = 1'b0;	
endtask

endmodule