`timescale 1ns/1ps

module tb_top;
logic clk
logic rst
logic [31:0]pc_debug;
logic [31:0]result_debug;

top dut(
    .clk(clk),
    .rst(rst),
    .pc_debug(pc_debug),
    .result_debug(result_debug)

);

initial clk =0;
always #5 clk=~clk;

initial begin
    rst=1;
    #25
    rst=0;
    #5000;
    $finsih;
end

endmodule