module hazard_unit (
    input logic [4:0] rs1d_i, rs2d_i, rde_i, rs1e_i, rs2e_i, rdm_i, rdw_i,
    input logic reg_write_m_i, reg_write_w_i, pc_src_i, result_src_i,
    output logic stall_f_o, stall_d_o, flush_d_o, flush_e_o,
    output logic [1:0] forwarding_a_o, forwarding_b_o
);
logic lw_stall;
always_comb begin

    // Hazard detection for data hazards
    if (reg_write_m_i && (rs1e_i != 0) && (rdm_i == rs1e_i)) begin
        forwarding_a_o = 2'b10; // Forward from MEM stage
    end else if (reg_write_w_i && (rs1e_i != 0) && (rdw_i == rs1e_i)) begin
        forwarding_a_o = 2'b01; // Forward from WB stage
    end
    else begin
        forwarding_a_o = 2'b00; // No forwarding
    end

    if (reg_write_m_i && (rs2e_i != 0) && (rdm_i == rs2e_i)) begin
        forwarding_b_o = 2'b10; // Forward from MEM stage
    end else if (reg_write_w_i && (rs2e_i != 0) && (rdw_i == rs2e_i)) begin
        forwarding_b_o = 2'b01; // Forward from WB stage
    end
    else begin
        forwarding_b_o = 2'b00; // No forwarding
    end

    //Stall and flush logic
    lw_stall = (result_src_i && ((rs1d_i == rde_i) || (rs2d_i == rde_i)));
    stall_f_o = lw_stall; // Stall fetch if load-use hazard
    stall_d_o = lw_stall; // Stall decode if load-use hazard
    flush_d_o = pc_src_i; // Flush decode stage if branch taken
    flush_e_o = lw_stall | pc_src_i; // Flush execute stage if load-use hazard or branch taken
end

endmodule