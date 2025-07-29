module stall_testbench;
  logic clk;
  logic reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  // Instantiate your top-level module
  riscv_top cpu (
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset and test initialization
  initial begin
    $dumpfile("stall_test.vcd");
    $dumpvars(0, stall_testbench);

    reset = 1;
    #20;
    reset = 0;

    // Wait sufficient cycles for the instructions to propagate
    repeat (20) @(posedge clk);
    $display("-------------------------------------------------");
    $display("Register dump after execution:");
    $display("x1 = %0d", cpu.reg_file.register[1]);
    $display("x2 = %0d", cpu.reg_file.register[2]);
    $display("x3 = %0d", cpu.reg_file.register[3]);
    $display("-------------------------------------------------");
    // Check register values
    if (cpu.reg_file.register[1] !== 32'd5) begin
      $display("❌ Test Failed: x1 != 5");
    end else if (cpu.reg_file.register[2] !== 32'd10) begin
      $display("❌ Test Failed: x2 != 10 (x1 + x1)");
    end else if (cpu.reg_file.register[3] !== 32'd0) begin
      $display("❌ Test Failed: x3 != 0 (10 & 5)");
    end else begin
      $display("✅ Stall Test Passed: Register values are correct.");
    end

    $finish;
  end

endmodule