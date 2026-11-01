module addec(
    input [31:0]addr,
    output uart_en
);
assign uart_en=(addr==32'h10000000);
endmodule