/*
* @file tb_8bit_cpu.sv
* @brief top-level file for the 8-bit CPU testbench
* @author Nicholas Amore namore7@gmail.com
* @date Created 4/29/2022
*/

`timescale 1ns/1ps

module tb_cpu_8bit();
	
wire pld_mclk;
wire pld_rstn;
wire [7:0] data_bus;

wire a_wrtn;
wire a_rdn;
wire b_wrtn;
wire b_rdn;

wire [3:0] alu_opcode;
wire cin;

wire alu_sel;
wire alu_flag_sel;

cpu_8bit_top uut (
	.i_clk(pld_mclk),
	.i_rstn(pld_rstn),
	.io_data_bus(data_bus),
	
	.i_a_wrtn(a_wrtn),
	.i_a_rdn(a_rdn),
	.i_b_wrtn(b_wrtn),
	.i_b_rdn(b_rdn),
	
	.i_alu_opcode(alu_opcode),
	.i_cin(cin),
	
	.i_alu_sel(alu_sel),
	.i_alu_flag_sel(alu_flag_sel)
);

cpu_drive drive (	
	.o_pld_clk(pld_mclk),
	.o_pld_rstn(pld_rstn),
	
	.o_a_wrtn(a_wrtn),
	.o_a_rdn(a_rdn),
	.o_b_wrtn(b_wrtn),
	.o_b_rdn(b_rdn),
	
	.o_alu_opcode(alu_opcode),
	.o_cin(cin),
	
	.o_alu_sel(alu_sel),
	.o_alu_flag_sel(alu_flag_sel),
	
	.io_databus(data_bus)
);
testbench test();
	
//run tests
initial begin
	#2000;
	test_registerWrite();
	test_registerRead();
	$stop;
end
	
/**
* @brief automated test for the ALU
* @detailed This test verifies that the ALU properly performs all 16 operations
*/
	
/*task test_ALUop();
	
	//Tests pass through of A register
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h0);
	alu_desel();
	test.checkEquality(8'hA5, data_bus);
	#100;
	
	//Tests pass through of B register
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h1);
	alu_desel();
	test.checkEquality(8'h5A, data_bus);
	#100;
	
	//Test AND of A and B register
	writeALU(8'hA5, 8'h39, 1'b0, 4'h2);
	alu_desel();
	test.checkEquality(8'h21, data_bus);
	#100;
	
	//Test OR of A and B register
	writeALU(8'hA5, 8'h39, 1'b0, 4'h3);
	alu_desel();
	test.checkEquality(8'hBD, data_bus);
	#100;
	
	//Test XOR of A and B register
	writeALU(8'hA5, 8'h39, 1'b0, 4'h4);
	alu_desel();
	test.checkEquality(8'h9C, data_bus);
	#100;
	
	//Tests addition without carry in
	writeALU(8'h03, 8'h04, 1'b0, 4'h5);
	alu_desel();
	test.checkEquality(8'h07, data_bus);
	#100;
	
	//Tests addition with carry in
	writeALU(8'h03, 8'h04, 1'b1, 4'h5);
	alu_desel();
	test.checkEquality(8'h08, data_bus);
	#100;
	
	//Tests Subtraction without carry in
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h6);
	alu_desel();
	test.checkEquality(8'h4B, data_bus);
	#100;
	
	//Tests Subtraction with carry in
	writeALU(8'hA5, 8'h5A, 1'b1, 4'h6);
	alu_desel();
	test.checkEquality( 8'h4C, data_bus);
	#100;
	
	//Tests zeroing the output
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h7);
	alu_desel();
	test.checkEquality(8'h00, data_bus);
	#100;
	
	//Tests 1's compliment of A input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h8);
	alu_desel();
	test.checkEquality(8'h5A, data_bus);
	#100;
	
	//Tests 2's compliment of A input
	writeALU(8'hA5, 8'h5A, 1'b1, 4'h8);
	alu_desel();
	test.checkEquality(8'h5B, data_bus);
	#100;
	
	//Tests 1's compliment of B input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'h9);
	alu_desel();
	test.checkEquality(8'hA5, data_bus);
	#100;
	
	//Tests 2's compliment of B input
	writeALU(8'hA5, 8'h5A, 1'b1, 4'h9);
	alu_desel();
	test.checkEquality(8'hA6, data_bus);
	#100;
	
	//Tests increment of A input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hA);
	alu_desel();
	test.checkEquality(8'hA6, data_bus);
	#100;
	
	//Tests decrement of A input
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hB);
	alu_desel();
	test.checkEquality(8'hA4, data_bus);
	#100;
	
	//Tests logical shift left
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hC);
	alu_desel();
	test.checkEquality(8'h4A, data_bus);
	#100;
	
	//Tests logical shift right
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hD);
	alu_desel();
	test.checkEquality(8'h52, data_bus);
	#100;
	
	//Tests arithmetic shift left
	writeALU(8'hA5, 8'h5A, 1'b0, 4'hE);
	alu_desel();
	test.checkEquality(8'h4B, data_bus);
	#100;
	
	//Tests bit reveral
	writeALU(8'hCC, 8'h5A, 1'b0, 4'hF);
	alu_desel();
	test.checkEquality(8'h33, data_bus);
	#100;
endtask/*

/**
* @brief automated test for the ALU flags
* @detailed Performs various ALU operations that will force flags to set
*/

/*task test_ALUflag();
	
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
endtask*/

task test_registerWrite();
	
	drive.registerWrite(1'b0, 8'hA5);
	drive.registerWrite(1'b1, 8'h5A);

endtask

task test_registerRead();
	
	reg [7:0] data_array [0:1];
	
	drive.registerRead(1'b0, data_array[0]);
	drive.registerRead(1'b1, data_array[1]);
	
	test.checkEquality(8'hA5, data_array[0]);
	test.checkEquality(8'h5A, data_array[1]);

endtask

endmodule