module immgen(
    input  logic [31:0] instr,
    output logic [31:0] imm_ext
);

always_comb begin
    case(instr[6:0])
        7'b0100011: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // S-type (store)
        7'b1100011: imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};  // B-type (branch)
        7'b1101111: imm_ext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};  // J-type (jal)
        7'b0110111, 7'b0010111: imm_ext = {instr[31:12],{12{1'b0}}};//U type
        
        default: imm_ext = {{20{instr[31]}}, instr[31:20]};  // I-type (addi, lw)

    endcase
end
endmodule