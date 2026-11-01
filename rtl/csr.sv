module csr(
    input logic clk,
    input logic rst,
    input logic [11:0]csr_addr,//CSR address,
    input logic [2:0]funct3,//Funct3
    input logic csr_en,
    input logic ecall,
    input logic mret,
    input logic ebreak,
    input logic [31:0]pc,
    input logic [31:0]csr_wdata,//data to write in csr
    input logic rs1_x0,//flag for rs1 to be x0
    output logic [31:0]csr_rdata,//data to read from csr
    output logic [31:0] mtvec,//
    output logic [31:0] mepc//return pc
);
logic [31:0] mscratch;
logic [31:0] mcause;
logic [31:0] mtval;
logic [31:0] mstatus;
logic [31:0] csr_new;
logic mie;
logic mpie;

//Csrnew assignment
always_comb begin
    case(funct3[1:0])
    2'b01:csr_new=csr_wdata;//csrrw
    2'b10:csr_new=csr_rdata|csr_wdata;//csrrs
    2'b11:csr_new=csr_rdata&(~csr_wdata);//csrrc
    2'b00:csr_new=csr_rdata;//default case
    endcase
end
//Mstatus assignment
assign mstatus={19'd0,2'b11,3'd0,mpie,3'd0,mie,3'd0};


//Write 
always_ff @(posedge clk ) begin : Wrcsr
    if(rst)begin
        mtvec<=0;
        mepc<=0;
        mscratch<=0;
        mcause<=0;
        mtval<=0;
        mie<=0;
        mpie<=0;
    end
    else if(csr_en)begin
        case(csr_addr)
        12'h300:begin
            mie<=csr_new[3];
            mpie<=csr_new[7];
        end
        12'h340:mscratch<=csr_new;
        12'h305:mtvec<=csr_new;
        12'h341:mepc<=csr_new;
        12'h342:mcause<=csr_new;
        12'h343:mtval<=csr_new;

        endcase
    end
    else if(ecall)begin
        mepc<=pc;
        mcause<=32'd11;
        mtval<=0;
        mpie<=mie;
        mie<=0;        
    end
    else if(ebreak)begin
        mepc<=pc;
        mcause<=32'd3;
        mtval<=0;
        mpie<=mie;
        mie<=0;        
    end
    
    else if(mret)begin
        mie<=mpie;
        mpie<=1;

    end
end
//Read
always_comb begin : Recsr
    case(csr_addr)
    12'h300:csr_rdata=mstatus;
    12'h340:csr_rdata=mscratch;
    12'h305:csr_rdata=mtvec;
    12'h341:csr_rdata=mepc;
    12'h342:csr_rdata=mcause;
    12'h343:csr_rdata=mtval;
    default:csr_rdata=0;
    endcase
end
endmodule