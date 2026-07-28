# this is with help with claude since my gcc compiler(c to assembly) wasnt really working for my .c bubble sort algorithm.

.section .text
.globl _start

_start:
    # ---- initialize unsorted array in data memory ----
    li   x10, 5
    sw   x10, 0(x0)
    li   x10, 3
    sw   x10, 4(x0)
    li   x10, 8
    sw   x10, 8(x0)
    li   x10, 1
    sw   x10, 12(x0)
    li   x10, 9
    sw   x10, 16(x0)
    li   x10, 2
    sw   x10, 20(x0)
    li   x10, 7
    sw   x10, 24(x0)
    li   x10, 4
    sw   x10, 28(x0)

    # ---- bubble sort ----
    li   x1, 0             # x1 = i (outer loop counter)
    li   x2, 8              # x2 = N (array length)
    addi x3, x2, -1         # x3 = N-1 (outer loop bound)

outer_loop:
    bge  x1, x3, done_sort  # if i >= N-1, sorting finished

    li   x4, 0              # x4 = j (inner loop counter)
    sub  x5, x3, x1          # x5 = (N-1) - i (inner loop bound)

inner_loop:
    bge  x4, x5, outer_next  # if j >= inner bound, end this pass

    slli x6, x4, 2           # shifting left is same as multiply by 2
    lw   x7, 0(x6)            # x7 = arr[j]
    lw   x8, 4(x6)            # x8 = arr[j+1]

    blt  x8, x7, do_swap      # if arr[j+1] < arr[j], they're out of order
    jal  x0, no_swap

do_swap:
    sw   x8, 0(x6)
    sw   x7, 4(x6)

no_swap:
    addi x4, x4, 1
    jal  x0, inner_loop

outer_next:
    addi x1, x1, 1
    jal  x0, outer_loop

done_sort:
    jal  x0, done_sort        # end
