
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

    case(opcode)
    7'b0110011:begin
        case(funct3)
        3'b000:begin
            if(funct7_6==0)begin
                ctrl.alu_op=ALU_ADD;
                ctrl.we=1;
            end
            else begin
                ctrl.alu_op=ALU_SUB;
                ctrl.we=1;

            end
            end
        3'b111:begin
            ctrl.alu_op=ALU_AND;
            ctrl.we=1;

        end
        3'b110:begin
            ctrl.alu_op=ALU_OR;
            ctrl.we=1;
        end
        endcase
        
        end
    7'b0010011: begin//Immediate
        ctrl.we=1;
        ctrl.alu_src=1;
        case(funct3)
         3'b000:begin
                ctrl.alu_op=ALU_ADD;
                ctrl.we=1;
            end
        3'b111:begin
            ctrl.alu_op=ALU_AND;
            ctrl.we=1;

        end
        3'b110:begin
            ctrl.alu_op=ALU_OR;
            ctrl.we=1;
        end
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
               ctrl.alu_op= ALU_SUB;
               ctrl.we=0;
    end
    7'b1101111:begin // Jump
               ctrl.jal=1;
               ctrl.we=1;
    end

         



    default:begin

        end

    

    endcase
    end

    
   


endmodule