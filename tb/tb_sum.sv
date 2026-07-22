// Full Single Cycle RISCV testbench
`timescale 1ns/1ps

module phase4_tb;

logic clk;
logic rst;

top dut (
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;


always @(posedge clk) begin
    #1; 
    $display("t=%0t  pc=%0d  instr=%h  x8=%0d  x9=%0d  x19=%0d",
              $time, dut.pc, dut.instr,
              dut.topreg.regs[8], dut.topreg.regs[9], dut.topreg.regs[19]);
end

initial begin
    $dumpfile("phase4_tb.vcd");
    $dumpvars(0, phase4_tb);

    clk = 0;
    rst = 1;
    #12;          // hold reset for atleast once cycle
    rst = 0;

    // estimated time for every instruction to execute
    #700

    $display("Final: x8 (sum) = %0d, x9 (bound) = %0d, x19 (i) = %0d",
              dut.topreg.regs[8], dut.topreg.regs[9], dut.topreg.regs[19]);

    if (dut.topreg.regs[8] == 210)
        $display("PASS: sum 1..20 = 210");
    else
        $display("FAIL: expected 210, got %0d", dut.topreg.regs[8]);

    $finish;
end

endmodule
