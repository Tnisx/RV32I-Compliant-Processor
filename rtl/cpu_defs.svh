`ifndef CPU_DEFS_SVH
`define CPU_DEFS_SVH

typedef enum logic [3:0] {
    ALU_ADD, ALU_SUB, ALU_AND, ALU_OR,
    ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA,
    ALU_SLT, ALU_SLTU
} alu_op_t;

typedef struct packed {
 logic        alu_src;     // MUX Selector for ALU Operand B: 0 = rdata2, 1 = imm_ext
 logic        we;          // Register File Write Enable: 1 = Save data to rd, 0 = Disable
 alu_op_t     alu_op;      // Operation code sent to the ALU defining the math/logic circuit to activate
 logic        mem_write;   // Data Memory Write Enable: 1 = Save data into RAM at current clock edge, 0 = Disable
 logic        mem_to_reg;  // Writeback MUX Selector: 0 = Route ALU result to RegFile, 1 = Route RAM read data to RegFile
 logic        branch;      // Mux select to tell when to branch
 logic        jal;         // jal mux
 logic        jalr;        //jalr mux
 logic        lui;         //lui mux
 logic        auipc;       //auipc mux
 logic  [1:0] lsmem;        //for load stype structure bit width 
 logic        lsmem_signed; //signed or unsigned load type
   } ctrl_t;

`endif

