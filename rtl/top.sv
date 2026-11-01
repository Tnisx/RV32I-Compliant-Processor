`include "cpu_defs.svh"

module top (
    input  logic        clk,
    input  logic        rst,
    output logic [31:0] pc_debug,
    output logic [31:0] result_debug
);

// Wire Declarations
logic        zero;//output from ALU for alu_sub
logic [31:0] result;//result from ALU
logic [31:0] rdata1, rdata2, imm_ext;//Possible data field that ALU can take
logic [31:0] mem_rdata;// data read out from ram
ctrl_t       ctrl;//typedef define

logic [31:0] pc, pc_next,pc_4;//pc values for current,next,and default next step
logic        branch_taken;//branch taken truth bit
logic [31:0] auipc_val;//auipc value
logic [31:0] csr_rdata;//data to read from csr registers
logic [31:0] mtvec;// trap handler address
logic [31:0] mepc;//return address to PC from handler
logic uart_en;//enable signal from UART




logic [31:0] instr;//instruction that the instr_mem will give out
logic branch_cond;//branch condition if branch_cond and branch_taken are true then only will  branching will happen

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
    .funct12(instr[31:20]),
    .ctrl(ctrl)
);

regfile topreg(
    .clk(clk),
    .rst(rst),
    .we(ctrl.we),
    .rs1(instr[19:15]),
    .rs2(instr[24:20]),
    .rd(instr[11:7]),
    .ddata(ctrl.csr_en?csr_rdata:
           ctrl.jal|ctrl.jalr?pc_4:
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
    .mem_write(ctrl.mem_write&~uart_en),
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
csr topcsr(
    .clk(clk),
    .rst(rst),
    .csr_addr(instr[31:20]),
    .funct3(instr[14:12]),
    .csr_en(ctrl.csr_en),
    .ecall(ctrl.ecall),
    .mret(ctrl.mret),
    .ebreak(ctrl.ebreak),
    .pc(pc),
    .csr_wdata(instr[14]==0?rdata1:instr[19:15]),
    .rs1_x0(instr[19:15]==0),
    .csr_rdata(csr_rdata),
    .mtvec(mtvec),
    .mepc(mepc)
);
addec topaddec(
    .addr(result),
    .uart_en(uart_en)
);
uart topuart(
    .clk(clk),
    .we(ctrl.mem_write&uart_en),
    .data(rdata2[7:0])
);

//Branch Jump Condition
assign branch_taken=ctrl.branch&branch_cond;

//Jump calculations
always_comb begin
    if (ctrl.jal)
        pc_next = pc + imm_ext;
    else if(ctrl.jalr)
        pc_next = {result[31:1],1'b0};
    else if (branch_taken)
        pc_next = pc + imm_ext;
    else if(ctrl.ecall|ctrl.ebreak)
        pc_next=mtvec;
    else if(ctrl.mret)
        pc_next=mepc;
    else
        pc_next = pc + 4;
end

assign pc_debug = pc;
assign result_debug = result;

endmodule