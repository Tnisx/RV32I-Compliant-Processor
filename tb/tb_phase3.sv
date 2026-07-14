
// ALU+RegFile+ControlUnit+Immediate+RAM Testbench
`timescale 1ns/1ps

module phase3_tb;

logic clk;
logic [31:0] instr;
alu_op_t local_alu_op;

always #5 clk = ~clk;

top dut(
    .clk(clk),
    .instr(instr)
);

initial begin
    clk = 0;
    instr = 32'h0000_0013; 

    #1;

    // addi x1, x0, 5
    instr = 32'h00500093;
    @(posedge clk); #1;

    // addi x2, x0, 10
    instr = 32'h00A00113;
    @(posedge clk); #1;


    
    // add x3, x1, x2 
    instr = 32'h002081B3; 
    @(posedge clk); 
    #1;
    local_alu_op = dut.alu_op;
    $display("Executed Instruction Hex: %h", instr);
    $display("Current ALU Operation   : %s", local_alu_op.name());
    $display("Result written to x3    : %d (Expected: 15)", dut.topreg.regs[3]);

    //  addi x3, x1, 15
    instr = 32'h00A08193;
    @(posedge clk);
    #1;
    local_alu_op = dut.alu_op;
    $display("Executed Instruction Hex: %h", instr);
    $display("Current ALU Operation   : %s", local_alu_op.name());
    $display("Result written to x3    : %d (Expected: 20)", dut.topreg.regs[3]);

    
    // sw x3, 8(x0) 
    instr = 32'h00302423;
    @(posedge clk);
    #1;
    local_alu_op = dut.alu_op;
    $display("Executed Instruction Hex: %h (sw x3, 8(x0))", instr);
    $display("RAM Address Calculated  : %d", dut.topalu.result);
    $display("Data Saved inside RAM[2]: %d (Expected: 20)", dut.topdata.ram[2]);

    // Instructions Clear For the cycle
    instr = 32'h0000_0013;
    @(posedge clk);
    #1;

    // lw x4, 8(x0)
    instr = 32'h00802203;
    @(posedge clk);
    #1;
    local_alu_op = dut.alu_op;
    $display("Executed Instruction Hex: %h (lw x4, 8(x0))", instr);
    $display("Data Fetched from RAM   : %d", dut.topdata.rdata);
    $display("Result written to x4    : %d (Expected: 20)", dut.topreg.regs[4]);

    
    instr = 32'h0000_0013;
    @(posedge clk);
    #1;
    
    $finish;
end

endmodule