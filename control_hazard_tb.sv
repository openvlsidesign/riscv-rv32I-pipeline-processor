`timescale 1ns/1ps

module control_hazard_tb();

  logic clk, reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  // Instantiate the DUT
  riscv_top dut (
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Register Initialization and Reset Sequence
  initial begin
    clk = 0;
    reset = 1;
    #20;
    reset = 0;

    // Preload registers x1 and x2 with the same value so that BEQ is taken
    dut.reg_file.register[1] = 32'h15;  // x1 = 21
    dut.reg_file.register[2] = 32'h15;  // x2 = 21
    dut.reg_file.register[9] = 32'd99;   // x9 = 99
    #100; // Run enough cycles for instructions to propagate

    // Check if x8 (destination of flushed addi) is still 0
    if (dut.reg_file.register[8] !== 0) begin
      $display("❌ Test Failed: ADDI should have been flushed, but x8 = %0d", dut.reg_file.register[8]);
    end else if (dut.reg_file.register[9] !== 0) begin
      $display("❌ Test Failed: ADD at label didn't execute");
    end else begin
      $display("✅ BEQ flush test passed. x8 = %0d, x9 = %0d", dut.reg_file.register[8], dut.reg_file.register[9]);
    end

    $finish;
  end

  // Dump VCD
  initial begin
    $dumpfile("control_hazard.vcd");
    $dumpvars(0, control_hazard_tb);
  end

endmodule