
`include "cpu_defs.svh"

module control_unit (
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic        funct7_6, 
    output  ctrl_t       ctrl
);






always_comb begin
    ctrl.we=1'b0;
    ctrl.alu_op=ALU_ADD;
    ctrl.alu_src=0;
    ctrl.mem_write=0;
    ctrl.mem_to_reg=0;
    ctrl.branch=0;
    ctrl.jal=0;
    ctrl.jalr=0;
    ctrl.lui=0;
    ctrl.auipc=0;

    case(opcode)
    7'b0110011:begin
        ctrl.we=1;
        case(funct3)
        3'b000:ctrl.alu_op=alu_op_t'(funct7_6?ALU_SUB:ALU_ADD);
        3'b001:ctrl.alu_op=ALU_SLL;
        3'b010:ctrl.alu_op=ALU_SLT;
        3'b011:ctrl.alu_op=ALU_SLTU;
        3'b100:ctrl.alu_op=ALU_XOR;
        3'b101:ctrl.alu_op=alu_op_t'(funct7_6?ALU_SRA:ALU_SRL);
        3'b110:ctrl.alu_op=ALU_OR;
        3'b111:ctrl.alu_op=ALU_AND;
        endcase
    end


    7'b0010011: begin//Immediate
        ctrl.we=1;
        ctrl.alu_src=1;
             case(funct3)
            3'b000: ctrl.alu_op = ALU_ADD;   
            3'b010: ctrl.alu_op = ALU_SLT;   
            3'b011: ctrl.alu_op = ALU_SLTU;  
            3'b100: ctrl.alu_op = ALU_XOR;   
            3'b110: ctrl.alu_op = ALU_OR;    
            3'b111: ctrl.alu_op = ALU_AND;  
            3'b001: ctrl.alu_op = ALU_SLL;   
            3'b101: ctrl.alu_op = alu_op_t'(funct7_6 ? ALU_SRA : ALU_SRL);
    endcase
    end
    7'b0000011: begin // lw (Load Word)
                ctrl.we         = 1;
                ctrl.alu_src    = 1;   
                ctrl.mem_write  = 0;
                ctrl.mem_to_reg = 1;
                ctrl.alu_op     = ALU_ADD; 
            end

    7'b0100011: begin // sw (Store Word)
                ctrl.we         = 0;
                ctrl.alu_src    = 1;   
                ctrl.mem_write  = 1;
                ctrl.mem_to_reg = 0;
                ctrl.alu_op     = ALU_ADD; 
            end
    7'b1100011:begin //branch
               ctrl.branch=1;
               ctrl.we=0;
               case(funct3)
               3'b000:ctrl.alu_op=ALU_SUB;//beq
               3'b001:ctrl.alu_op=ALU_SUB;//bne
               3'b100:ctrl.alu_op=ALU_SLT;//blt
               3'b101:ctrl.alu_op=ALU_SLT;//bge
               3'b110:ctrl.alu_op=ALU_SLTU;//bltu
               3'b111:ctrl.alu_op=ALU_SLTU;//bgeu
               endcase
    end
    7'b1101111:begin // Jump
               ctrl.jal=1;
               ctrl.we=1;
    end
    7'b1100111: begin // JALR
        ctrl.jalr    = 1;
        ctrl.we      = 1;
        ctrl.alu_src = 1;
        ctrl.alu_op  = ALU_ADD;
    end

    7'b0110111: begin // LUI
        ctrl.we = 1;
        ctrl.lui= 1;

    end
    7'b0010111: begin
        ctrl.we = 1;
        ctrl.auipc= 1;
    end



         default:begin

        end

    

    endcase
    end

    
   


endmodule