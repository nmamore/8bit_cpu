/*
* @file program_counter.sv
* @brief Holds location of next instruction to be executed
* @author Nicholas Amore namore7@gmail.com
* @date Created 5/2/2022
*/

`timescale 1ns / 100ps

module program_counter
(
	input logic i_clk,
	input logic i_rstn,
	
	inout logic io_databus,
	
	input logic i_cntn,
	input logic i_den,
	input logic i_din,
	
	output logic o_overflow
);

logic [7:0] pc_data;
logic carry;

//Outputs program address to bus
assign io_databus = (!i_den) ? pc_data:8'bz;
assign o_overflow = carry;

always_ff @(posedge i_clk or negedge i_rstn) begin
	if(!i_rstn) begin
		carry <= 8'b0;
		pc_data <= 8'b0;
	end
	//Increments address by 1
	else if(!i_cntn) begin
		{carry,pc_data} <= pc_data + 1'b1;
	end
	//Loads new address into register
	else if(!i_din) begin
		pc_data <= io_databus;
	end
end

endmodule