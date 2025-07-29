module alu (
    input logic [31:0] a_i, //First operand
    input logic [31:0] b_i, //Second operand
    input logic [2:0] alu_control_i, //ALU control signal
    output logic [31:0] result_o, //ALU result
    output logic zero_o //Zero flag
);

always_comb begin
    case(alu_control_i)
        3'b000: result_o = a_i + b_i; // ADD operation
        3'b001: result_o = a_i - b_i; // SUB operation
        3'b010: result_o = a_i & b_i; // AND operation
        3'b011: result_o = a_i | b_i; // OR  operation
        3'b101: result_o = (a_i < b_i) ? 1'b1: 1'b0; // SLT operation
        3'b110: result_o = a_i - b_i; // BEQ operation
        
        
        default: result_o = 32'b0; // Default case
    endcase
end

assign zero_o = result_o == '0; //(alu_control_i == 3'b110) & (result_o == '0);

endmodule