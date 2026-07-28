module data_mem (
    input  logic        clk,
    input  logic        mem_write,  // High when saving data (sw)
    input  logic [31:0] addr,       // Calculated address from the ALU
    input  logic [31:0] wdata,      // Data to store (comes from rs2)
    input  logic [1:0]  lsmem,      //01=byte,10=halfword,11=word
    input  logic        lsmem_signed,//sign extend or not
    output logic [31:0] rdata       // Data read out of memory (goes to mux)

);

logic [7:0] ram [0:4095];





//WRITE or S type Instruction   
always_ff@(posedge clk)begin
    if(mem_write)begin
        case(lsmem)
        2'b01:begin
            ram[addr]<=wdata[7:0];
        end
        2'b10:begin
             ram[addr+1]<=wdata[7:0];
             ram[addr+2]<=wdata[15:8];
        end
            
        2'b11:begin
             ram[addr]<=wdata[7:0];
             ram[addr+1]<=wdata[15:8];
             ram[addr+2]<=wdata[23:16];
             ram[addr+3]<=wdata[31:24];
        end
        default:;
        endcase

    end
end

// LOAD/LSMEM instructions
always_comb begin
    case (lsmem)
        2'b01: rdata = lsmem_signed
                        ? {{24{ram[addr][7]}}, ram[addr]}
                        : {24'b0,               ram[addr]};
        2'b10: rdata = lsmem_signed
                        ? {{16{ram[addr+1][7]}}, ram[addr+1], ram[addr]}
                        : {16'b0,                 ram[addr+1], ram[addr]};
        2'b11: rdata = {ram[addr+3], ram[addr+2], ram[addr+1], ram[addr]};
        default: rdata = 32'b0;
    endcase
end


endmodule