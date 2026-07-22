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
        $display("FS[%0d]=%0d",i,dut.topdata.ram[i]);
    end
    $finish;
    end
    endmodule

