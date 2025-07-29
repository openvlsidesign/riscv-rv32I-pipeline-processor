module alu_decoder (
    input logic [6:0] op_i,
    input logic [2:0] funct3,
    input logic funct7, // for rv32I only bit 5 on funct7 is required
    input logic [1:0] alu_op_i,

    output logic [2:0] alu_ctrl_o
);
logic [6:0] cond;
assign cond = {alu_op_i, funct3, op_i[5], funct7};

always_comb begin
    
    casez(cond)
        7'b00_???_?_?: alu_ctrl_o = 3'b000; // ADD
        7'b01_???_?_?: alu_ctrl_o = 3'b001; // SUB beq
        7'b10_000_0_0: alu_ctrl_o = 3'b000; // ADD
        7'b10_000_0_1: alu_ctrl_o = 3'b000; // ADD
        7'b10_000_1_0: alu_ctrl_o = 3'b000; // ADD
        7'b10_000_1_1: alu_ctrl_o = 3'b001; // SUB
        7'b10_010_?_?: alu_ctrl_o = 3'b101; // SLT
        7'b10_110_?_?: alu_ctrl_o = 3'b011; // OR
        7'b10_111_?_?: alu_ctrl_o = 3'b010; // AND
        
        default: alu_ctrl_o = 3'b000; // Default case
    endcase
end

endmodule