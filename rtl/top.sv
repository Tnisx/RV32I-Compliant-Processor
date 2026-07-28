`include "cpu_defs.svh"

module top (
    input  logic        clk,
    input  logic        rst
);

// Wire Declarations
logic        zero;
logic [31:0] result;
logic [31:0] rdata1, rdata2, imm_ext;
logic [31:0] mem_rdata;
ctrl_t       ctrl;

logic [31:0] pc, pc_next,pc_4;
logic        branch_taken;
logic [31:0] auipc_val;



logic [31:0] instr;
logic branch_cond;

//Assignment

assign pc_4=pc+4;
assign auipc_val = pc + imm_ext;


instr_mem topinstr(
    .addr(pc),
    .instr(instr)
);

immgen topgen(
    .instr(instr),
    .imm_ext(imm_ext)
);

control_unit topcu(
    .opcode(instr[6:0]),
    .funct3(instr[14:12]),
    .funct7_6(instr[30]),
    .ctrl(ctrl)
);

regfile topreg(
    .clk(clk),
    .rst(rst),
    .we(ctrl.we),
    .rs1(instr[19:15]),
    .rs2(instr[24:20]),
    .rd(instr[11:7]),
    .ddata(ctrl.jal|ctrl.jalr?pc_4:
           ctrl.lui? imm_ext:
           ctrl.auipc?pc+imm_ext:
          ctrl.mem_to_reg ? mem_rdata : result),
    .rdata1(rdata1),
    .rdata2(rdata2)
);

ALU topalu(
    .a     (rdata1),
    .b     (ctrl.alu_src ? imm_ext : rdata2),
    .op    (ctrl.alu_op),
    .result(result),
    .zero  (zero)
    );

data_mem topdata(
    .clk(clk),
    .mem_write(ctrl.mem_write),
    .addr(result),
    .wdata(rdata2),
    .lsmem(ctrl.lsmem),
    .lsmem_signed(ctrl.lsmem_signed),
    .rdata(mem_rdata)
);

pc_reg toppc(
    .clk(clk),
    .rst(rst),
    .pc_next(pc_next),
    .pc(pc)
);
branch_man topbranch(
    .in(instr[14:12]),
    .branch_cond(branch_cond),
    .zero(zero),
    .result(result[0])
);

assign branch_taken=ctrl.branch&branch_cond;


always_comb begin
    if (ctrl.jal)
        pc_next = pc + imm_ext;
    else if(ctrl.jalr)
        pc_next = {result[31:1],1'b0};
    else if (branch_taken)
        pc_next = pc + imm_ext;
    else
        pc_next = pc + 4;
end

endmodule