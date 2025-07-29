module riscv_top (
    input logic clk,
    input logic reset,
    output logic [31:0] WriteData, DataAdr,
    output logic MemWrite
);

logic   [31:0]  pc, instr;
logic   stall_f, stall_d, flush_d, flush_e;

logic   [1:0]   p1_d_result_src, p1_d_imm_src;
logic   p1_d_reg_write, p1_d_mem_write, p1_d_branch, p1_d_alu_src, p1_d_jump;
logic   [2:0]   p1_d_alu_control;
logic   [31:0]  p1_d_rd1, p1_d_rd2, p1_d_pc;
logic   [4:0]  p1_d_rs1, p1_d_rs2, p1_d_rd;
logic  [31:0]  p1_d_immext;


logic   [1:0]   p2_e_result_src, p2_e_imm_src;
logic   p2_e_reg_write, p2_e_mem_write, p2_e_branch, p2_e_alu_src, p2_e_jump;
logic   [2:0]   p2_e_alu_control; 
logic  [31:0]  p2_e_rd1, p2_e_rd2, p2_e_immext, p2_e_pc;
logic   p2_e_pc_src;
logic   [31:0] p2_e_pc_target;
logic   [31:0]  p2_e_alu_result;
logic   p2_e_zero;
logic   [4:0] p2_e_rd, p2_e_rs1, p2_e_rs2;

logic [31:0] p3_m_data_mem, p3_m_alu_result, p3_m_pc;
logic p3_m_reg_write, p3_m_mem_write;
logic [1:0] p3_m_result_src;

logic [31:0]  p3_m_write_data, p3_m_pc_p_4;
logic [4:0] p3_m_rd;


logic [31:0] pc_p_4, p1_d_pc_p_4, p2_e_pc_p_4;

logic [31:0] p4_w_data_mem, p4_w_pc_p_4, p4_w_alu_result;
logic [4:0] p4_w_rd;
logic [1:0] p4_w_result_src;
logic p4_w_reg_write;


assign pc_p_4 = pc + 32'd4;
assign p1_d_rs1 = p1_d_instr[19:15];
assign p1_d_rs2 = p1_d_instr[24:20];
assign p1_d_rd  = p1_d_instr[11:7];

//Fetch
program_counter prg_cntr (
    .clk                (clk),
    .reset              (reset),
    .stall_i            (stall_f),
    .pc_next_i          (p2_e_pc_src ? p2_e_pc_target : pc_p_4),
    .pc_o               (pc)

);

instr_mem instr_memory (
    .pc_i               (pc),
    .instr_o            (instr)
);

//pipeline 1 - decode (prefix p1_d)
logic [31:0] p1_d_instr;

always_ff @(posedge clk) begin
    if(reset) begin
        p1_d_instr  <=  32'd0;
        p1_d_pc     <=  32'd0;
        p1_d_pc_p_4 <=  32'd0;
    end
    else if (flush_d) begin
        p1_d_instr  <=  32'd0;
        p1_d_pc     <=  32'd0;
        p1_d_pc_p_4 <=  32'd0;
    end
    else if (stall_d) begin
        p1_d_instr  <=  p1_d_instr;
        p1_d_pc     <=  p1_d_pc;
        p1_d_pc_p_4 <=  32'd0;
    end
    else begin
        p1_d_instr  <=  instr;
        p1_d_pc     <=  pc;
        p1_d_pc_p_4 <=  pc_p_4;
    end
end



//Decode 


register_file reg_file (
    .clk                (clk),
    .reset              (reset),
    .rs1                (p1_d_rs1),
    .readdata1_o        (p1_d_rd1),

    .rs2                (p1_d_rs2),
    .readdata2_o        (p1_d_rd2),

    .wr_data_i          (WriteData), 
    .reg_file_writeen_i (p4_w_reg_write), 
    .dest_reg_i         (p4_w_rd) 


);

sign_extend se_inst (
    .instr_i            (p1_d_instr),
    .imm_src_i          (p1_d_imm_src),
    .immext_o           (p1_d_immext)
);

controller controller_inst (
    .op_i               (p1_d_instr[6:0]),
    .funct3             (p1_d_instr[14:12]),
    .funct7             (p1_d_instr[30]), //29?
    .result_src_o       (p1_d_result_src),
    .imm_src_o          (p1_d_imm_src),
    .mem_write_o        (p1_d_mem_write),
    .branch_o           (p1_d_branch),
    .jump_o             (p1_d_jump),
    .reg_write_o        (p1_d_reg_write),
    .alu_src_o          (p1_d_alu_src),
    .alu_ctrl_o         (p1_d_alu_control),
    .zero_flag_i        (p2_e_zero)
);

//pipeline 2 - execute. prefix p2_e
always_ff @(posedge clk) begin
    if (reset) begin
        p2_e_result_src   <=  2'b0;
        p2_e_imm_src      <=  2'b0;
        p2_e_reg_write    <=  1'b0;
        p2_e_mem_write    <=  1'b0;
        p2_e_branch       <=  1'b0;
        p2_e_jump         <=  1'b0;
        p2_e_alu_src      <=  1'b0;
        p2_e_alu_control  <=  3'b0;
        p2_e_rd1          <=  32'd0;
        p2_e_rd2          <=  32'd0;
        p2_e_immext       <=  32'd0;
        p2_e_pc           <=  32'd0;
        p2_e_rs1          <=  5'd0;
        p2_e_rs2          <=  5'd0;
        p2_e_rd           <=  5'd0;
        p2_e_pc_p_4     <=  32'd0;
    end
    else if (flush_e) begin
        p2_e_result_src   <=  2'b0;
        p2_e_imm_src      <=  2'b0;
        p2_e_reg_write    <=  1'b0;
        p2_e_mem_write    <=  1'b0;
        p2_e_branch       <=  1'b0;
        p2_e_jump         <=  1'b0;
        p2_e_alu_src      <=  1'b0;
        p2_e_alu_control  <=  3'b0; 
        p2_e_rd1          <=  32'd0; 
        p2_e_rd2          <=  32'd0; 
        p2_e_immext       <=  32'd0; 
        p2_e_pc           <=  32'd0; 
        p2_e_rs1          <=  5'd0; 
        p2_e_rs2          <=  5'd0; 
        p2_e_rd           <=  5'd0; 
        p2_e_pc_p_4       <=  32'd0; 
    end
    else begin
        p2_e_result_src   <=   p1_d_result_src;  
        p2_e_reg_write    <=   p1_d_reg_write; 
        p2_e_mem_write    <=   p1_d_mem_write; 
        p2_e_branch       <=   p1_d_branch; 
        p2_e_jump         <=   p1_d_jump; 
        p2_e_alu_src      <=   p1_d_alu_src;
        p2_e_alu_control  <=   p1_d_alu_control;
        p2_e_rd1          <=   p1_d_rd1;
        p2_e_rd2          <=   p1_d_rd2;
        p2_e_immext       <=   p1_d_immext;
        p2_e_pc           <=   p1_d_pc;
        p2_e_rs1          <=   p1_d_rs1;
        p2_e_rs2          <=   p1_d_rs2;
        p2_e_rd           <=   p1_d_rd;
        p2_e_pc_p_4       <=   p1_d_pc_p_4;
        
end
end



//Execute
logic [31:0] p2_e_a_i, p2_e_b, p2_e_b_i;
logic [1:0] forwarding_a, forwarding_b;

always_comb begin
    case(forwarding_a)
        2'b00: p2_e_a_i = p2_e_rd1;
        2'b01: p2_e_a_i = WriteData; // Forward from writeback stage
        2'b10: p2_e_a_i = p3_m_alu_result; // Forward from memory stage
        default: p2_e_a_i = 32'b0;
    endcase
end

always_comb begin
    case(forwarding_b)
        2'b00: p2_e_b = p2_e_rd2;
        2'b01: p2_e_b = WriteData; // Forward from writeback stage;
        2'b10: p2_e_b = p3_m_alu_result; // Forward from memory stage
        default: p2_e_b = 32'b0;
    endcase
end

assign p2_e_b_i = p2_e_alu_src ? p2_e_immext : p2_e_b; 
assign p2_e_pc_target = p2_e_pc + p2_e_immext; 
assign p2_e_pc_src = (p2_e_branch & p2_e_zero) | p2_e_jump; 


alu alu_inst (
    .a_i                (p2_e_a_i),
    .b_i                (p2_e_b_i),
    .alu_control_i      (p2_e_alu_control),

    .result_o           (p2_e_alu_result),
    .zero_o             (p2_e_zero)
);

//pipeline 3 - memory. prefix p3_m
always_ff @(posedge clk) begin
    if (reset) begin
        p3_m_alu_result   <=  32'd0;
        p3_m_rd           <=  5'd0;
        p3_m_reg_write    <=  1'b0;
        p3_m_mem_write    <=  1'b0;
        p3_m_result_src   <=  2'b0;
        p3_m_pc_p_4       <=  32'd0;
        p3_m_write_data   <=  32'd0;
    end
    else begin
        p3_m_alu_result   <=  p2_e_alu_result;
        p3_m_pc_p_4       <=  p2_e_pc_p_4;
        p3_m_rd           <=  p2_e_rd;
        p3_m_reg_write    <=  p2_e_reg_write;
        p3_m_mem_write    <=  p2_e_mem_write;
        p3_m_result_src   <=  p2_e_result_src;
        p3_m_write_data   <=  p2_e_b;
    end
end


//Memory
data_mem data_memory (
    .clk                (clk),
    .reset              (reset),
    .address_i          (p3_m_alu_result),
    .wr_en_i            (p3_m_mem_write),
    .write_data_i       (p3_m_write_data),

    .data_mem_o         (p3_m_data_mem)

);

always_ff @(posedge clk) begin
    if (reset) begin
        p4_w_data_mem <= 32'd0;
        p4_w_pc_p_4   <= 32'd0;
        p4_w_rd       <= 5'd0;
        p4_w_alu_result <= 32'd0;
        p4_w_result_src <= 2'b0;
        p4_w_reg_write <= 1'b0;
    end
    else begin
        p4_w_data_mem <= p3_m_data_mem;
        p4_w_pc_p_4   <= p3_m_pc_p_4;
        p4_w_rd       <= p3_m_rd;
        p4_w_alu_result <= p3_m_alu_result;
        p4_w_result_src <= p3_m_result_src;
        p4_w_reg_write <= p3_m_reg_write;
    end
end

//Writeback
always_comb begin
    case(p4_w_result_src)
        2'b00: WriteData = p4_w_alu_result; // ALU result
        2'b01: WriteData = p4_w_data_mem; // Data memory output
        2'b10: WriteData = p4_w_pc_p_4; // PC + 4 (next instruction address)
        default: WriteData = 32'b0; // Default case
    endcase
end
assign DataAdr = p3_m_alu_result; //TODO: check this condition
assign MemWrite = p3_m_mem_write; //TODO: check this condition

//Hazard Unit
hazard_unit hazard_unit_inst (
    .rs1d_i          (p1_d_rs1),
    .rs2d_i          (p1_d_rs2),
    .rs1e_i          (p2_e_rs1),
    .rs2e_i          (p2_e_rs2),
    .rde_i          (p2_e_rd),
    .rdm_i          (p3_m_rd),
    .pc_src_i     (p2_e_pc_src),
    .result_src_i (p2_e_result_src[0]),
    .reg_write_m_i     (p3_m_reg_write),
    .reg_write_w_i     (p4_w_reg_write),
    .rdw_i          (p4_w_rd),
    .forwarding_a_o     (forwarding_a),
    .forwarding_b_o     (forwarding_b),
    .stall_f_o          (stall_f),
    .stall_d_o          (stall_d),
    .flush_d_o          (flush_d),
    .flush_e_o          (flush_e)

);



endmodule