addi x1,zero,0 #a
addi x2,zero,1 #b
addi x3,zero,0 #i for increment
addi x4,zero,10 #how many sequence no.
addi x5,zero,0

loop:
sw x1,0(x5)
add x6,x1,x2 #temp=a+b
add x1,zero,x2#a=b
add x2,zero,x6#b=temp
addi x3,x3,1
addi x5,x5,4
bne x4,x3,loop

done:
jal x0,done
