/*
* @file 8bit_cpu.sv
* @brief top-level file for the 8-bit CPU
* @author Nicholas Amore namore7@gmail.com
* @date Created 4/29/2022
*/


`timescale 1ns / 100ps

module cpu_8bit_top
(
	input logic i_clk,
	input logic i_rstn
);

logic [7:0] a_data;
logic [7:0] b_data;
logic [7:0] alu_out;

logic [3:0] alu_op;

logic alu_sel;
logic flag_sel;

logic cin;

logic zr;
logic ng;
logic pa;
logic co;
logic of;

alu ALU_module(
	.i_a_data(a_data),
	.i_b_data(b_data),
	
	.i_alu_sel(alu_sel),
	
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_flag_sel(flag_sel),
	
	.i_cin(cin),
	
	.i_alu_op(alu_op),
	
	.o_out_data(alu_out),
	
	.o_zr(zr),
	.o_ng(ng),
	.o_pa(pa),
	.o_co(co),
	.o_of(of)
);

endmodule