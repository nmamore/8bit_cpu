/*
* @file cpu_drive.sv
* @brief Contains tasks needed to drive CPU 
* @author Nicholas Amore namore7@gmail.com
* @date Created 5/1/2022
*/

`timescale 1ns/1ps

module cpu_drive (
	output logic o_pld_clk,
	output logic o_pld_rstn,
	
	output logic o_a_wrtn,
	output logic o_a_rdn,
	output logic o_b_wrtn,
	output logic o_b_rdn,
	
	output logic [3:0] o_alu_opcode,
	output logic o_cin,
	
	output logic o_alu_sel,
	output logic o_alu_flag_sel,
	
	inout logic [7:0] io_databus
);

// ref clock = 24.00MHz => 41.7ns, For half of clock, PLD_CLK_SPEED = 20.9ns
localparam PLD_CLK_SPEED = 20.9;

logic pld_mclk;
logic pld_rstn;

logic [7:0] databus;

logic a_wrtn;
logic a_rdn;
logic b_wrtn;
logic b_rdn;

logic [3:0] alu_op;
logic alu_cin;

logic alu_sel;
logic alu_flag_sel;

assign o_pld_clk = pld_mclk;
assign o_pld_rstn = pld_rstn;
assign io_databus = databus;

assign o_a_wrtn = a_wrtn;
assign o_a_rdn = a_rdn;
assign o_b_wrtn = b_wrtn;
assign o_b_rdn = b_rdn;

assign o_cin = alu_cin;
assign o_alu_opcode = alu_op;

assign o_alu_flag_sel = alu_flag_sel;
assign o_alu_sel = alu_sel;

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

//Reset PLD
initial begin
	$display("PLD reset");
	pld_rstn = 1'b0;
	#200;
	pld_rstn = 1'b1;
	#500;	
end

initial begin
	$display("Set initial values");
	
	a_wrtn = 1'b1;
	a_rdn = 1'b1;
	b_wrtn = 1'b1;
	b_rdn = 1'b1;
	
	alu_op = 4'h0;
	alu_cin = 1'b0;
	
	alu_sel = 1'b0;
	alu_flag_sel = 1'b0;
end

task registerWrite(
	input sel_reg,
	input [7:0] data
);
	if(sel_reg == 0) begin
		databus = data;
		@(posedge pld_mclk);
		a_wrtn = 1'b0;
		@(posedge pld_mclk);
		a_wrtn = 1'b1;
		@(posedge pld_mclk);
	end
	
	else if (sel_reg == 1) begin
		databus = data;
		@(posedge pld_mclk);
		b_wrtn = 1'b0;
		@(posedge pld_mclk);
		b_wrtn = 1'b1;
		@(posedge pld_mclk);
	end

endtask

task registerRead(
	input sel_reg,
	output [7:0] data
);

	if(sel_reg == 0) begin
		a_rdn = 1'b0;
		@(posedge pld_mclk);
		data = io_databus;
		@(posedge pld_mclk);
		a_rdn = 1'b1;
		@(posedge pld_mclk);
	end
	
	else if (sel_reg == 1) begin
		b_rdn = 1'b0;
		@(posedge pld_mclk);
		data = io_databus;
		@(posedge pld_mclk);
		b_rdn = 1'b1;
		@(posedge pld_mclk);
	end
endtask

task aluWrite(
	input [7:0] a_data,
	input [7:0] b_data,
	input cin,
	input [3:0] alu_opcode,
	output[7:0] data
);

	registerWrite(1'b0, a_data);
	registerWrite(1'b1, b_data);
	alu_op = alu_opcode;
	alu_cin = cin;
	alu_sel = 1'b1;
	alu_flag_sel = 1'b1;
	@(posedge pld_mclk);
	data = io_databus;
	@(posedge pld_mclk);
	alu_sel = 1'b0;
	alu_flag_sel = 1'b0;

endtask
endmodule