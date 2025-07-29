module main_decoder (
    input logic [6:0] op_i,

    output logic [1:0] result_src_o,
    output logic [1:0] imm_src_o,
    output logic mem_write_o,
    output logic reg_write_o,
    output logic alu_src_o,
    output logic [1:0] alu_op_o,
    output logic branch_o,
    output logic jump_o
);

always_comb begin
    
    casex (op_i)
        7'b0110011: begin // R-type instructions
            reg_write_o = 1'b1;
            alu_src_o = 1'b0;
            result_src_o = 2'b00; // ALU result
            mem_write_o = 1'b0; // No memory write
            imm_src_o = 2'bxx; // No immediate
            
            alu_op_o = 2'b10; // ALU operation for R-type
            branch_o = 1'b0; // No branching for R-type
            jump_o = 1'b0; // No jump for R-type
        end
        7'b0000011: begin // Load instructions
            reg_write_o = 1'b1;
            alu_src_o = 1'b1; // Use immediate for address calculation
            mem_write_o = 1'b0; // No memory write
            
            alu_op_o = 2'b00; // ALU operation for load
            result_src_o = 2'b01; // Memory read result
            imm_src_o = 2'b00; // I-type immediate
            branch_o = 1'b0; // No branching for load
            jump_o = 1'b0; // No jump for load
        end
        7'b0100011: begin // Store instructions
            reg_write_o = 1'b0; // No register write
            result_src_o = 2'bxx; // No result source
            
            alu_op_o = 2'b00; // ALU operation for store
            mem_write_o = 1'b1;
            alu_src_o = 1'b1; // Use immediate for address calculation
            imm_src_o = 2'b01; // S-type immediate
            branch_o = 1'b0; // No branching for store
            jump_o = 1'b0; // No jump for store
        end
        7'b1100011: begin // Branch instructions
            reg_write_o = 1'b0; // No register write
            result_src_o = 2'bxx; // No result source
            mem_write_o = 1'b0; // No memory write
            alu_op_o = 2'b01; // ALU
            
            alu_src_o = 1'b0; // No immediate, use registers for branch comparison
            imm_src_o = 2'b10; // B-type immediate
            branch_o = 1'b1; // Enable branching
            jump_o = 1'b0; // No jump for branch instructions
        end
        7'b0010011: begin // I-type ALU instructions
            reg_write_o = 1'b1;
            alu_src_o = 1'b1; // Use immediate for ALU operation
            mem_write_o = 1'b0; // No memory write
            
            result_src_o = 2'b00; // ALU result
            imm_src_o = 2'b00; // I-type immediate
            alu_op_o = 2'b10; // ALU operation for I-type
            branch_o = 1'b0; // No branching for I-type
            jump_o = 1'b0; // No jump for I-type
        end
        7'b1101111: begin // J-type instructions (JAL)
            reg_write_o = 1'b1; // Write to register
            result_src_o = 2'b10; // PC + 4 (next instruction address)
            mem_write_o = 1'b0; // No memory write
            
            alu_src_o = 1'bx; // No ALU source, use PC for jump
            imm_src_o = 2'b11; // J-type immediate
            alu_op_o = 2'bxx; // ALU operation for jump
            branch_o = 1'b0; // No branching for JAL
            jump_o = 1'b1; // Enable jump
        end
        default: begin
            // Handle other cases or invalid opcodes if necessary
            reg_write_o = 1'b0;
            result_src_o = 2'b00;
            mem_write_o = 1'b0;
            alu_src_o = 1'b0;   // Default to no ALU source
            imm_src_o = 2'b00;  // Default to no immediate
            alu_op_o = 2'b00;   // Default ALU operation
            branch_o = 1'b0;    // Default to no branching
            jump_o = 1'b0;      // Default to no jump
        end
    endcase

end

endmodule