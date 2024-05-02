.text

.globl _start

read:                   # a0: fd, a1: *str, a2: size
    #li a0, 0            # file descriptor = 0 (stdin)
    li a7, 63           # syscall read (63)
    ecall
ret

write:                  # *str -> a1; size -> a2
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall    
ret

exit:                   # finaliza o programa
    li a0, 0
    li a7, 93           # syscall
ecall

lenght:                 # a0: *str
    mv t1, a0           # endereço da string
    mv t0, zero         # contador do tamanho
    li t2, ' '          # comparador de espaço e '\n'
    li t3, '\n'
lenght_:
    addi t0, t0, 1      # a0 ++
    addi t1, t1, 1      # a1 ++
    lbu t4, (t1)        # resgata o char de a1 + 1
    beq t4, t2, saida_
    bne t4, t3, lenght_
saida_:
    mv a0, t0
ret                     # tamanho em a0

to_int:                 # a0: *str
    mv t0, zero         # acumulador
    li t3, 10
    li t5, ' '
    li t6, '\n'
    lb t4, (a0)         # primeiro caractere
to_int_:                
    mul t0, t0, t3      # acc * 10
    addi t4, t4, -48    # corrige o valor
    add t0, t0, t4      # soma 
    addi a0, a0, 1      # anda 1 na string
    lb t4, (a0)
    beq t4, t5, out     # teste se igual a espaço
    bne t4, t6, to_int_ # testa se igual a \n
out:
    mv a0, t0
ret

_start:

    la a0, teste
    jal lenght
test1:
    nop

    la a0, teste + 6
    jal to_int
test2:
    nop

    la a0, teste + 10
    jal to_int
test3:
    nop

    la a0, teste + 12
    jal to_int
test4:
    nop

jal exit


.section .data
teste: .string "10293 394 9\n098309875\n"