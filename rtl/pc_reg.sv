module pc_reg (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] pc_next,
    output logic [31:0] pc
);

always_ff @(posedge clk)begin
    if(rst)begin
        pc<=0;
    end
    else begin
        pc<=pc_next;
    end
end

endmodule