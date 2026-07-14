addi s0, zero, 0   
addi s1, zero, 20  
addi s3, zero, 0   

loop:
addi s3, s3, 1    
add  s0, s0, s3    
bne  s3, s1, loop  

done:
