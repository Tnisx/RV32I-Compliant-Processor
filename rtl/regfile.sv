module regfile (
    input  logic clk,
    input  logic rst,
    input  logic we,        // Write Enable: High to write to rd on posedge clk
    input  logic [4:0] rs1,       // Read Address 1
    input  logic [4:0] rs2,       // Read Address 2 
    input  logic [4:0] rd,        // Write Address  
    input  logic [31:0] ddata,     // 32-bit Data to write into register 'rd'
    output logic [31:0] rdata1,    // 32-bit Data read out from register 'rs1'
    output logic [31:0] rdata2     // 32-bit Data read out from register 'rs2'
);

    logic [31:0] regs[32];

    assign rdata1 = rs1==0?32'd0:regs[rs1];
    assign rdata2 = rs2==0?32'd0:regs[rs2];

    always_ff @(posedge clk) begin
        if(rst)begin
             for (int i = 1; i < 32; i++) //No other way of reset compiled with Iverilog
              regs[i] <= 0;
        end
        else begin

        if(we&&(rd!=0))begin
            regs[rd]<=ddata;
        end
        end
    end
        
endmodule
