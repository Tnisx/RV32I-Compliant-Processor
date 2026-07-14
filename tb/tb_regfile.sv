`timescale 1ms/1us
module regfile_tb;
  logic clk;
  logic we;    
  logic [4:0] rs1;     
  logic [4:0] rs2;   
  logic [4:0] rd;       
  logic [31:0] ddata; 
  logic [31:0] rdata1; 
  logic [31:0] rdata2;

  regfile dut(
    .clk(clk),
    .we(we),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .ddata(ddata),
    .rdata1(rdata1),
    .rdata2(rdata2)
  );

  always #5 clk=~clk;

  initial begin
   we=1;
   rd=1;
   ddata=32'd5;
   clk=0;

   #10

    @(posedge clk);
    we=0;
    rs1=1;
    #1
    $display("rs1 is %d and the data at that index is %d",rs1,rdata1);

    @(posedge clk);
    we=1;
    rd=2;
    ddata=32'd6;
    #1

    @(posedge clk);
    we=0;
    rs2=2;
    #1
    $display("rs1 is %d and the data at that index is %d",rs2,rdata2);

    $finish;

  end
endmodule
 


