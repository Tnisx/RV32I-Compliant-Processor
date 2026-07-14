`timescale 1ns/1ps


module alu_tb;

    
    logic [31:0] a, b;
    alu_states   op;
    logic [31:0] result;
    logic        clk;
    logic        zero;

    
    ALU dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero)
    );

    
    always #5 clk = ~clk;

    
    initial begin
        
        clk = 0;
        op  = ALU_ADD;
        a   = 0;
        b   = 0;
        #10; 

       
        @(posedge clk);
        op = ALU_ADD; a = 2; b = 4;
        #1; 
        $display("Operation Finished (ADD): %d", result);

      
        @(posedge clk);
        op = ALU_SUB; a = 10; b = 4;
        #1; 
        $display("Operation Finished (SUB): %d", result);

     
        @(posedge clk);
        op = ALU_OR; a = 2; b = 4;
        #1; 
        $display("Operation Finished (OR):  %d", result);

      
        @(posedge clk);
        op = ALU_AND; a = 2; b = 4;
        #1; 
        $display("Operation Finished (AND): %d", result);

        #10;
        $finish;
    end 

endmodule