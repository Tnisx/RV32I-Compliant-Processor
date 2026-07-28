// With the Help Of Claude

`timescale 1ns/1ps

module bubble_sort_tb;

logic clk;
logic rst;

// number of elements sorted by the assembly program (must match the .s file)
localparam int N = 8;

top dut (
    .clk(clk),
    .rst(rst)
);

// ---------------- clock generation ----------------
always #5 clk = ~clk;   // 10ns period

// ---------------- reset ----------------
initial begin
    clk = 0;
    rst = 1;

    #50;
    rst = 0;
end

// ---------------- waveform dump ----------------
initial begin
    $dumpfile("bubble_sort.vcd");
    $dumpvars(0, bubble_sort_tb);
end

// ---------------- completion detection ----------------
// The program ends with:
//     done_sort: jal x0, done_sort
// which is an infinite self-loop, so once pc stops changing for a
// few consecutive clock edges we know the sort finished and it's
// safe to check memory.
logic [31:0] pc_prev;
int          stable_count;

initial begin
    stable_count = 0;
    pc_prev      = 32'hFFFF_FFFF;

    @(negedge rst);   // wait until reset is released

    forever begin
        @(posedge clk);
        if (dut.pc === pc_prev)
            stable_count++;
        else
            stable_count = 0;

        pc_prev = dut.pc;

        if (stable_count == 3) begin
            $display("[%0t] pc stable at 0x%0h -> program finished", $time, dut.pc);
            check_results();
            $finish;
        end
    end
end

// safety net in case the CPU never reaches the self-loop
initial begin
    #100_000;
    $display("[%0t] TIMEOUT: never reached done_sort loop", $time);
    $finish;
end

// ---------------- result checking ----------------
task automatic check_results();
    logic [31:0] arr [0:N-1];
    bit          sorted;
    begin
        sorted = 1'b1;

        $display("---------------------------------------");
        $display(" Final contents of the array in memory:");
        for (int i = 0; i < N; i++) begin
            arr[i] = { dut.topdata.ram[i*4+3], dut.topdata.ram[i*4+2],
                       dut.topdata.ram[i*4+1], dut.topdata.ram[i*4+0] };
            $display("  arr[%0d] = %0d", i, arr[i]);
        end

        for (int i = 0; i < N-1; i++) begin
            if (arr[i] > arr[i+1])
                sorted = 1'b0;
        end

        if (sorted)
            $display(" PASS: array is sorted in ascending order");
        else
            $display(" FAIL: array is NOT sorted");
        $display("---------------------------------------");
    end
endtask

endmodule