/*
* @file control_logic.sv
* @brief Performs control logic of CPU
* @author Nicholas Amore namore7@gmail.com
* @date Created 5/5/2022
*/

module control_logic
(
	input logic i_clk,
	input logic i_rstn,
	
	inout wire [7:0] io_data_bus,
	
	output logic o_mem_sel, //0 - ROM/ 1 - RAM
	
	output logic o_rom_rdn,
	
	output logic o_ram_wrtn,
	output logic o_ram_rdn,
	
	output logic o_a_wrtn,
	output logic o_a_rdn,
	output logic o_b_wrtn,
	output logic o_b_rdn,
	
	output logic o_ir_wrtn,
	output logic o_ir_rdn,
	
	output logic [3:0] o_alu_opcode,
	output logic o_cin,
	
	output logic o_alu_sel,
	output logic o_alu_flag_sel,
	
	output logic o_pc_cnt,
	output logic o_pc_den,
	output logic o_pc_din,
	
	output logic o_mar_rdn,
	output logic o_mar_wrtn,
	
	input logic i_pc_of
);

typedef enum {s_reset, pc_inc} instruction_cycle;

instruction_cycle s_cycle;

always_ff @(posedge i_clk or negedge i_rstn) begin
	if (!i_rstn) begin
		o_a_wrtn <= 1'b1;
		o_a_rdn <= 1'b1;
		
		o_b_wrtn <= 1'b1;
		o_b_rdn <= 1'b1;
		
		o_ir_wrtn <= 1'b1;
		o_ir_rdn <= 1'b1;
		
		o_alu_opcode <= 4'h0;
		o_cin <= 1'b0;
		o_alu_sel <= 1'b0;
		o_alu_flag_sel <= 1'b0;
		
		o_pc_cnt <= 1'b1;
		o_pc_den <= 1'b1;
		o_pc_din <= 1'b1;
		
		o_mar_rdn <= 1'b1;
		o_mar_wrtn <= 1'b1;
		
		state_cycle <= s_reset;
	end
	else begin
		case (state_cycle) begin
			s_reset: begin
				o_mem_sel <= 1'b0;
				o_rom_rdn <= 1'b0;
				o_mar_wrtn <= 1'b0;
				o_pc_den <= 1'b0;
				state_cycle <= pc_inc;
			end
			pc_inc: begin
				o_rom_rdn <= 1'b1;
				o_mar_wrtn <= 1'b1;
				o_pc_den <= 1'b1;
				
				o_pc_cnt <= 1'b0;
				state_cycle <= mar_read;
			end
			mar_read: begin
				o_pc_cnt <= 1'b1;
				o_mar_rdn <= 1'b0;
				o_ir_wrtn <= 1'b0;
				state_cycle <= decode;
			end
			
		endcase
end
endmodule