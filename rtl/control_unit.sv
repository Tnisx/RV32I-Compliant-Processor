
`include "cpu_defs.svh"

module control_unit (
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic        funct7_6,
    input  logic [11:0] funct12,
    output  ctrl_t       ctrl
);






always_comb begin
    ctrl.we=1'b0;//Write Enable for Register
    ctrl.alu_op=ALU_ADD;//ALU Operation
    ctrl.alu_src=0;//rs2=imm_ext mux
    ctrl.mem_write=0;//Ram write enable
    ctrl.mem_to_reg=0;//Load instruction Ram to Register
    ctrl.branch=0;//Branch truth bit
    ctrl.jal=0;//Jal bit
    ctrl.jalr=0;//JALR bit
    ctrl.lui=0;//LUI bit
    ctrl.auipc=0;//AUIPC bit
    ctrl.lsmem=0;//0=byte,1=halfword,11=word
    ctrl.lsmem_signed=0;//Sign extend MUX
    ctrl.csr_en=0;//Enabling the special registers
    ctrl.ecall=0;//Calling the helper instructions
    ctrl.mret=0;//returing from helper instruction
    ctrl.ebreak=0;//Ebreak instructions
    case(opcode)//ALU Codes
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
    7'b0000011: begin //load
                ctrl.we         = 1;
                ctrl.alu_src    = 1;   
                ctrl.mem_write  = 0;
                ctrl.mem_to_reg = 1;
                ctrl.alu_op     = ALU_ADD; 
                ctrl.lsmem      = 0;
                ctrl.lsmem_signed= 0;

                case(funct3)
                3'b000:begin
                    ctrl.lsmem=2'b01; ctrl.lsmem_signed=1;//LB
                end
                3'b001:begin
                    ctrl.lsmem=2'b10; ctrl.lsmem_signed=1;//LH
                end
                3'b010:ctrl.lsmem=2'b11; //LW
                3'b100:begin 
                    ctrl.lsmem=2'b01; ctrl.lsmem_signed=0;//LBU
                end
                3'b101:begin
                    ctrl.lsmem=2'b10; ctrl.lsmem_signed=0;//LHU
                end
                default:;
                endcase
                end


    7'b0100011: begin // sw (Store Word)
                ctrl.we          = 0;
                ctrl.alu_src     = 1;   
                ctrl.mem_write   = 1;
                ctrl.mem_to_reg  = 0;
                ctrl.alu_op      = ALU_ADD;
                ctrl.lsmem       = 0;
                ctrl.lsmem_signed= 0;

                case(funct3)
                3'b000:ctrl.lsmem=2'b01;//SB
                3'b001:ctrl.lsmem=2'b10;//SH
                3'b010:ctrl.lsmem=2'b11;//SW
                default:;
                endcase

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
    7'b0010111: begin //AUIPC
        ctrl.we = 1;
        ctrl.auipc= 1;
    end
    7'b1110011: begin // Environmental Calls
           if(funct3==3'b000)begin
            case(funct12)
            12'h000:ctrl.ecall=1;
            12'h302:ctrl.mret=1;
            12'h001:ctrl.ebreak=1;
            default:begin
            end
          endcase
        end
           else begin
             ctrl.csr_en=1;
             ctrl.we=1;
        end
    end





         default:begin

        end
    endcase
end
    


    
   


endmodule