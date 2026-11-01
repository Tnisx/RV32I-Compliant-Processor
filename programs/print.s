    .section .text
    .globl _start
_start:
    la    t0, handler
    csrw  mtvec, t0
    lui   s0, 0x10000        

    li    a0, 0x48           # 'H'
    ecall
    li    a0, 0x65           # 'e'
    ecall
    li    a0, 0x6c           # 'l'
    ecall
    li    a0, 0x6c           # 'l'
    ecall
    li    a0, 0x6f           # 'o'
    ecall
    li    a0, 0x20           # ' '
    ecall
    li    a0, 0x57           # 'W'
    ecall
    li    a0, 0x6f           # 'o'
    ecall
    li    a0, 0x72           # 'r'
    ecall
    li    a0, 0x6c           # 'l'
    ecall
    li    a0, 0x64           # 'd'
    ecall
    li    a0, 0x0a           # newline
    ecall
done:
    j     done

handler:
    sb    a0, 0(s0)          # UART write
    csrr  t1, mepc
    addi  t1, t1, 4
    csrw  mepc, t1
    mret