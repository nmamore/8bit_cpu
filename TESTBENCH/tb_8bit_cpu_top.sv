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

wire zr;
wire ng;
wire pa;
wire co;
wire of;

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
	.i_alu_flag_sel(alu_flag_sel),
	
	.o_zr(zr),
	.o_ng(ng),
	.o_pa(pa),
	.o_co(co),
	.o_of(of)
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
	test_ALUop();
	test_ALUflag();
	$stop;
end

/**
* @brief automated test for register write
* @detailed This test writes to the A and B register.
* Check is done by test_registerRead.
*/

task test_registerWrite();
	
	//Writes to A register
	drive.registerWrite(1'b0, 8'hA5);
	
	//Writes to B register
	drive.registerWrite(1'b1, 8'h5A);

endtask

/**
* @brief automated test for the ALU
* @detailed This test verifies that the A and B registers properly
* upload data to the data bus. Must be run after test_registerWrite.
*/

task test_registerRead();
	
	reg [7:0] data_array [0:1];
	
	//Reads A register, stores in array
	drive.registerRead(1'b0, data_array[0]);
	//Reads B register, stores in array
	drive.registerRead(1'b1, data_array[1]);
	
	//Checks data array that data was read out properly
	test.checkEquality(8'hA5, data_array[0]);
	test.checkEquality(8'h5A, data_array[1]);

endtask

/**
* @brief automated test for the ALU
* @detailed This test verifies that the ALU properly performs all 16 operations
*/

task test_ALUop();
	reg [7:0] data_array;
	
	//Tests pass through of A register
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'h0, data_array);
	test.checkEquality(8'hA5, data_array);
	#100;
	
	//Tests pass through of B register
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'h1, data_array);
	test.checkEquality(8'h5A, data_array);
	#100;
	
	//Test AND of A and B register
	drive.aluWrite(8'hA5, 8'h39, 1'b0, 4'h2, data_array);
	test.checkEquality(8'h21, data_array);
	#100;
	
	//Test OR of A and B register
	drive.aluWrite(8'hA5, 8'h39, 1'b0, 4'h3, data_array);
	test.checkEquality(8'hBD, data_array);
	#100;
	
	//Test XOR of A and B register
	drive.aluWrite(8'hA5, 8'h39, 1'b0, 4'h4, data_array);
	test.checkEquality(8'h9C, data_array);
	#100;
	
	//Tests addition without carry in
	drive.aluWrite(8'h03, 8'h04, 1'b0, 4'h5, data_array);
	test.checkEquality(8'h07, data_array);
	#100;
	
	//Tests addition with carry in
	drive.aluWrite(8'h03, 8'h04, 1'b1, 4'h5, data_array);
	test.checkEquality(8'h08, data_array);
	#100;
	
	//Tests Subtraction without carry in
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'h6, data_array);
	test.checkEquality(8'h4B, data_array);
	#100;
	
	//Tests Subtraction with carry in
	drive.aluWrite(8'hA5, 8'h5A, 1'b1, 4'h6, data_array);
	test.checkEquality( 8'h4C, data_array);
	#100;
	
	//Tests zeroing the output
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'h7, data_array);
	test.checkEquality(8'h00, data_array);
	#100;
	
	//Tests 1's compliment of A input
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'h8, data_array);
	test.checkEquality(8'h5A, data_array);
	#100;
	
	//Tests 2's compliment of A input
	drive.aluWrite(8'hA5, 8'h5A, 1'b1, 4'h8, data_array);
	test.checkEquality(8'h5B, data_array);
	#100;
	
	//Tests 1's compliment of B input
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'h9, data_array);
	test.checkEquality(8'hA5, data_array);
	#100;
	
	//Tests 2's compliment of B input
	drive.aluWrite(8'hA5, 8'h5A, 1'b1, 4'h9, data_array);
	test.checkEquality(8'hA6, data_array);
	#100;
	
	//Tests increment of A input
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'hA, data_array);
	test.checkEquality(8'hA6, data_array);
	#100;
	
	//Tests decrement of A input
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'hB, data_array);
	test.checkEquality(8'hA4, data_array);
	#100;
	
	//Tests logical shift left
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'hC, data_array);
	test.checkEquality(8'h4A, data_array);
	#100;
	
	//Tests logical shift right
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'hD, data_array);
	test.checkEquality(8'h52, data_array);
	#100;
	
	//Tests arithmetic shift left
	drive.aluWrite(8'hA5, 8'h5A, 1'b0, 4'hE, data_array);
	test.checkEquality(8'h4B, data_array);
	#100;
	
	//Tests bit reveral
	drive.aluWrite(8'hCC, 8'h5A, 1'b0, 4'hF, data_array);
	test.checkEquality(8'h33, data_array);
	#100;
endtask

/**
* @brief automated test for the ALU flags
* @detailed Performs various ALU operations that will force flags to set
*/

task test_ALUflag();
	reg [7:0] dummy_data;
	
	//Tests zero flag
	drive.aluWrite(8'h00, 8'h5A, 1'b0, 4'h0, dummy_data);
	test.checkEquality(1'b1, zr);
	#100;
	
	//Tests zero flag
	drive.aluWrite(8'h01, 8'h5A, 1'b0, 4'h0, dummy_data);
	test.checkEquality(1'b0, zr);
	#100;
	
	//Tests negative flag
	drive.aluWrite(8'hA0, 8'h5A, 1'b0, 4'h0, dummy_data);
	test.checkEquality(1'b1, ng);
	#100;
	
	//Tests negative flag
	drive.aluWrite(8'h01, 8'h5A, 1'b0, 4'h0, dummy_data);
	test.checkEquality(1'b0, ng);
	#100;
	
	//Tests parity flag
	drive.aluWrite(8'hAA, 8'h5A, 1'b0, 4'h0, dummy_data);
	test.checkEquality(1'b1, pa);
	#100;
	
	//Tests parity flag
	drive.aluWrite(8'h01, 8'h5A, 1'b0, 4'h0, dummy_data);
	test.checkEquality(1'b0, pa);
	#100;
	
	//Tests carry-out flag
	drive.aluWrite(8'hFF, 8'h5A, 1'b1, 4'h5, dummy_data);
	test.checkEquality(1'b1, co);
	#100;
	
	//Tests carry-out flag
	drive.aluWrite(8'h01, 8'h5A, 1'b1, 4'h5, dummy_data);
	test.checkEquality(1'b0, co);
	#100;
	
	//Tests overflow flag
	drive.aluWrite(8'h70, 8'h40, 1'b0, 4'h5, dummy_data);
	test.checkEquality(1'b1, of);
	#100;
	
	//Tests overflow flag
	drive.aluWrite(8'h01, 8'h01, 1'b0, 4'h5, dummy_data);
	test.checkEquality(1'b0, of);
	#100;
endtask

endmodule