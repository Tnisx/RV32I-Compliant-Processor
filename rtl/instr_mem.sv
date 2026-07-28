module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

logic [31:0] mem[0:4095];

initial begin

    $readmemh("bubble_sort.hex", mem);
    
end

assign instr=mem[addr[31:2]];

endmodule
