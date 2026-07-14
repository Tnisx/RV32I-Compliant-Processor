//ALU+RegFile+ControlUnit+Immediate Testbench

`timescale 1ns/1ps

module phase1_tb;

logic clk;
logic [31:0] instr;
alu_op_t local_alu_op;
always #5 clk=~clk;

top dut(
    .clk(clk),
    .instr(instr)
);


initial begin
    clk=0;
    instr=0;
    dut.topreg.regs[1] = 32'd10;  // Preloading Data 10
    dut.topreg.regs[2] = 32'd5;   // Preloading Data 5

    #1


instr = 32'h002081B3; // add x3, x1, x2

@(posedge clk); 
#1;
local_alu_op = dut.alu_op;



$display("Executed Instruction Hex: %h", instr);
$display("Current ALU Operation   : %s", local_alu_op.name());
$display("Result written to x3    : %d (Expected: 15)", dut.topreg.regs[3]);

#1

instr=32'h00A08193;

@(posedge clk);
#1
local_alu_op = dut.alu_op;
$display("Executed Instruction Hex: %h", instr);
$display("Current ALU Operation   : %s", local_alu_op.name());
$display("Result written to x3    : %d (Expected: 20)", dut.topreg.regs[3]);

    
end
endmodule