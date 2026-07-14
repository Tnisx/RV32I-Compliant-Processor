`include "cpu_defs.svh"
module ALU(
    input [31:0] a,b,
    input alu_op_t op,
    output logic [31:0] result,
    output logic zero);

    always_comb begin
        case(op)
        ALU_ADD:result=a+b;
        ALU_SUB:result=a-b;
        ALU_OR:result=a|b;
        ALU_AND:result=a&b;
        default:result=0;
        endcase

    end

    assign zero = (result==32'b0);
endmodule
