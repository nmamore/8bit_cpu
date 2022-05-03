/*
* @file register_8bit.sv
* @brief 8-bit register file
* @author Nicholas Amore namore7@gmail.com
* @date Created 5/1/2022
*/

module register_8bit
(
	inout logic [7:0] io_bus_data,
	
	input logic i_clk,
	input logic i_rstn,
	
	input logic i_rdn,
	input logic i_wrtn,
	
	output logic [7:0] o_out_data
);

logic [7:0] reg_data;

assign o_out_data = reg_data;
assign io_bus_data = (!i_rdn) ? reg_data: 8'bz;

always_ff @(posedge i_clk or negedge i_rstn) begin
	if(!i_rstn) begin
		reg_data <= 8'b0;
	end
	else if(!i_wrtn) begin
		reg_data <= io_bus_data;
	end
end

endmodule