module program_counter (
    input   logic clk, reset, stall_i,
    input   logic [31:0] pc_next_i,
    output  logic [31:0] pc_o
);

always_ff @(posedge clk) begin
if(reset)
    pc_o <= '0;
else if (!stall_i)
    pc_o <= pc_next_i; // Update PC with the next value
else
    pc_o <= pc_o;
end 

endmodule