/*
* @file ALU.sv
* @brief Performs arithmetic and logical operations for CPU
* @author Nicholas Amore namore7@gmail.com
* @date Created 4/28/2022
*/

module alu
(
	input logic [7:0] i_a_data,
	input logic [7:0] i_b_data,
	
	input logic i_alu_sel,
	
	input logic i_clk,
	input logic i_rstn,
	input logic i_flag_sel,
	
	input logic i_cin,
	
	input logic [3:0] i_alu_op,
	
	output logic [7:0] o_out_data,
	
	output logic o_zr,
	output logic o_ng,
	output logic o_pa,
	output logic o_co,
	output logic o_of
);

logic [7:0] alu_out;
logic [7:0] a_data;
logic [7:0] b_data;

logic cin;

logic zr;
logic ng;
logic pa;
logic co;
logic of;

assign a_data = i_a_data;
assign b_data = i_b_data;
assign o_out_data = (i_alu_sel) ? alu_out:8'bz;
assign cin = i_cin;

//Flag checking
assign zr = ~(alu_out[7] | alu_out[6] | alu_out[5] | alu_out[4] | alu_out[3] | alu_out[2] | alu_out[1] | alu_out[0]); //Checks if output is 0
assign ng = alu_out[7]; //Checks if output is negative
assign pa = ~((alu_out[7] ^ alu_out[6]) ^ (alu_out[5] ^ alu_out[4]) ^ (alu_out[3] ^ alu_out[2]) ^ (alu_out[1] ^ alu_out[0])); //Checks if output is even
assign of = alu_out[7] ^ co;

//ALU operands
always_comb begin
	co = 1'b0;
	case(i_alu_op)
		4'h0: begin //Pass through A input
			alu_out = a_data;
		end
		4'h1: begin //Passes through B input
			alu_out = b_data;					
		end
		4'h2: begin //AND A and B input
			alu_out = a_data & b_data;			
		end
		4'h3: begin //OR A and B input
			alu_out = a_data | b_data;
		end
		4'h4: begin //XOR A and B input
			alu_out = a_data ^ b_data;
		end
		4'h5: begin //Adds A and B input
			{co,alu_out} = a_data + b_data + cin;			
		end
		4'h6: begin //Subtrats A and B input
			{co,alu_out} = {1'b0,a_data} - {1'b0,b_data} + cin;	
		end
		4'h7: begin //Zeros the output
			alu_out = 8'b0;						
		end
		4'h8: begin //Bitwise negation of the A input 
			alu_out = ~a_data + cin;
		end
		4'h9: begin //Bitwise negation of the B input 
			alu_out = ~b_data + cin;
		end
		4'hA: begin //Increment A input
			alu_out = a_data + 1'b1;
		end
		4'hB: begin //Decrement A input
			alu_out = a_data - 1'b1;
		end
		4'hC: begin //Logical Shift Left
			{co,alu_out} = {a_data[7:0], 1'b0};
		end
		4'hD: begin //Logical Shift Right
			{alu_out,co} = {1'b0, a_data[7:0]};
		end
		4'hE: begin //Arithmetic Shift Left
			{co,alu_out} = {a_data[7:0],a_data[7]};
		end
		4'hF: begin //Bit Reversal
			for(int i = 0; i < 8; i++) begin
				alu_out[i] = a_data[7-i];
			end
		end
		default: begin //Pass through A input
			alu_out = a_data;
		end
	endcase
end

//Flag Register
always_ff @(posedge i_clk or negedge i_rstn) begin
	if(!i_rstn) begin
		o_zr <= 1'b0;
		o_ng <= 1'b0;
		o_co <= 1'b0;
		o_pa <= 1'b0;
		o_of <= 1'b0;
	end
	else if (i_flag_sel) begin
		o_zr <= zr;
		o_ng <= ng;
		o_co <= co;
		o_pa <= pa;
		o_of <= of;
	end
end

endmodule