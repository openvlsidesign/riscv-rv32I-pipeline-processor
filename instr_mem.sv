module instr_mem(
    input logic [31:0]  pc_i,
    output logic [31:0] instr_o
    
);


logic [31:0] RAM [63:0];
initial
$readmemh("control_hazard.dat",RAM); // Load instructions from a file
assign instr_o = RAM[pc_i[31:2]]; // word aligned

endmodule
