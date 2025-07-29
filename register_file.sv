module register_file (
    input logic         clk, reset,

    // read port1
    input logic [4:0]   rs1,
    output logic [31:0] readdata1_o,

    // read port2
    input logic [4:0]   rs2,
    output logic [31:0] readdata2_o,

    // write port
    input logic [31:0]  wr_data_i,      // data from data memory
    input logic         reg_file_writeen_i,
    input logic [4:0]   dest_reg_i             // ← now last port, no comma needed
);

logic [31:0] register [31:0];



initial begin
    // Initialize all registers to zero
    for (int i = 0; i < 32; i++) begin
        register[i] = 32'b0;
    end
end

always_ff @(posedge clk) begin
    if (reg_file_writeen_i && dest_reg_i != 5'b0) begin
        // Write data to the destination register if write enable is high and dest_reg is not zero
        register[dest_reg_i] <= wr_data_i;
    end
end

assign readdata1_o = (rs1 != 5'b0) ? register[rs1] : 32'b0;
assign readdata2_o = (rs2 != 5'b0) ? register[rs2] : 32'b0;

endmodule