module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

localparam int DEPTH =4096;
localparam int WIDTH =$clog2(DEPTH);

logic [31:0] mem[0:DEPTH-1];


initial begin

    $readmemh("print.hex", mem);
    
end

assign instr=mem[addr[WIDTH+1:2]];

endmodule
