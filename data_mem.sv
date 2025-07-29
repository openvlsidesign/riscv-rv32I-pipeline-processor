module data_mem (
   input logic clk, reset,
    input [31:0] address_i,
    input wr_en_i,
    input logic [31:0] write_data_i,

    output  logic [31:0] data_mem_o // going to register file
);

logic [31:0] mem [31:0];


assign data_mem_o = mem[address_i[31:2]]; // word aligned memory access

always_ff @(posedge clk) begin
    if (wr_en_i) begin
        mem[address_i[31:2]] <= write_data_i; // write data to memory
    end 
end

endmodule