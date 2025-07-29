module controller (
    input logic [6:0]   op_i,
    input logic [2:0]   funct3,
    input logic         funct7, //for rv32I only bit 5 on funct7 is required

    output logic [1:0]  result_src_o,
    output logic [1:0]  imm_src_o,
    output logic        jump_o,
    output logic        branch_o,
    output logic        mem_write_o,
    output logic        reg_write_o,
    output logic        alu_src_o,
    output logic [2:0]  alu_ctrl_o,
    input  logic        zero_flag_i     
);

logic [1:0] alu_op;

//assign pc_src_o = (zero_flag_i & branch) | jump; // PC source is determined by zero flag for branch instructions

main_decoder main_decoder_inst (
    .op_i           (op_i),
    .result_src_o   (result_src_o),
    .imm_src_o      (imm_src_o),
    .mem_write_o    (mem_write_o),
    .reg_write_o    (reg_write_o),
    .alu_src_o      (alu_src_o),
    .alu_op_o       (alu_op),
    .branch_o       (branch_o), // Branch signal
    .jump_o         (jump_o)  // Jump signal
);

alu_decoder alu_decoder_inst (
    .op_i       (op_i),
    .funct3     (funct3),
    .funct7     (funct7),
    .alu_op_i   (alu_op),
    .alu_ctrl_o (alu_ctrl_o)
);

endmodule