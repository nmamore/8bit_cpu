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
	input logic i_rstn,
	
	input logic i_a_wrtn,
	input logic i_a_rdn,
	input logic i_b_wrtn,
	input logic i_b_rdn,
	
	inout logic [7:0] io_data_bus,
	
	input logic [3:0] i_alu_opcode,
	input logic i_cin,
	
	input logic i_alu_sel,
	input logic i_alu_flag_sel
);

//Data from registers
logic [7:0] a_data;
logic [7:0] b_data;

//ALU flags
logic zr;
logic ng;
logic pa;
logic co;
logic of;

alu ALU_module(
	.i_a_data(a_data),
	.i_b_data(b_data),
	
	.i_alu_sel(i_alu_sel),
	
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_flag_sel(i_alu_flag_sel),
	
	.i_cin(i_cin),
	
	.i_alu_op(i_alu_opcode),
	
	.o_out_data(io_data_bus),
	
	.o_zr(zr),
	.o_ng(ng),
	.o_pa(pa),
	.o_co(co),
	.o_of(of)
);

register_8bit a_register
(
	.io_bus_data(io_data_bus),
	
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
	.i_rdn(i_a_rdn),
	.i_wrtn(i_a_wrtn),
	
	.o_out_data(a_data)
);

register_8bit b_register
(
	.io_bus_data(io_data_bus),
	
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
	.i_rdn(i_b_rdn),
	.i_wrtn(i_b_wrtn),
	
	.o_out_data(b_data)
);

endmodule