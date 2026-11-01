module uart(
    input clk,
    input we,
    input [7:0]data
);
always_ff @(posedge clk)begin : Print
    if(we)
    $write("%c",data);
end
endmodule