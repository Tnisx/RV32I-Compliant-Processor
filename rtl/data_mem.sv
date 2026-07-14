module data_mem (
    input  logic        clk,
    input  logic        mem_write,  // High when saving data (sw)
    input  logic [31:0] addr,       // Calculated address from the ALU
    input  logic [31:0] wdata,      // Data to store (comes from rs2)
    output logic [31:0] rdata       // Data read out of memory (goes to mux)
);

logic [31:0] ram [0:63];


   
always_ff@(posedge clk)begin
    if(mem_write)begin
        ram[addr[31:2]]<=wdata;
    end
end

assign rdata=ram[addr[31:2]];
  


endmodule