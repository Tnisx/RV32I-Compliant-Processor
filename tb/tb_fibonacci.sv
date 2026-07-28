`timescale 1ps/1ps

module fibonacci;
logic clk;
logic rst;

top dut(
    .clk(clk),
    .rst(rst)
);
always #5 clk=~clk;

initial begin
    $dumpfile("fibonacci.vcd");
    $dumpvars(0, fibonacci);

    clk=0;
    rst=1;
    #50;
    rst=0;


    #900;

  $display("Fibonacchi Sequence");
for(int i=0;i<10;i=i+1)begin
    logic [31:0] word;
    word = {dut.topdata.ram[i*4+3], dut.topdata.ram[i*4+2],
            dut.topdata.ram[i*4+1], dut.topdata.ram[i*4]};
    $display("FS[%0d]=%0d", i, word);
end
    $finish;
    end
    endmodule

