.section .text

.globl _start

read:                   # a1: *str, a2: size
    li a0, 0            # file descriptor = 0 (stdin)
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

to_char:                # a0: número, a1: end último byte
    li t0, '\n'
    sb t0, (a1)
    li t0, 10           # imediato 10
to_char_:
    addi a1, a1, -1     # volta um endereço na string    
    rem t1, a0, t0      # resto da divisão por 10
    div a0, a0, t0      # divisão por 10
    addi t1, t1, 48     # correção para ASCII
    sb t1, (a1)         # guarda o valor
    bne a0, zero, to_char_
    mv a0, a1
ret

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
ret 

_start: 

    la a1, entrada
    li a2, 7
    jal read

    la a0, entrada
    li a1, '-'
    lb a2, (a0)
    li a6, 1
    beq a1, a2, menos
    j mais
menos:
    addi a0, a0, 1
    li a6, -1
mais:
    jal to_int
    mul a0, a0, a6
    mv a3, a0
    mv a4, zero         # contador

    la a0, head_node
for:
    lw a1, (a0)         # primeiro número
    lw a2, 4(a0)        # segundo número
    add a1, a1, a2      # num1 + num2
    beq a1, a3, saida   # saí do for se a soma == entrada
    addi a4, a4, 1      # num do prox nó
    lw a0, 8(a0)        # prox nó
    beq a0, zero, erro  # testa se é o último nó
    j for

erro:                   # imprime -1 e encerra
    la a1, saida_erro
    li a2, 3
    jal write

jal exit

saida:            # imprime o contador
    mv a0, a4
    la a1, saida_certo
    addi a1, a1, 6
    jal to_char

    mv a1, a0
    jal lenght

    mv a2, a0
    addi a2, a2, 1
    jal write


jal exit

.bss
entrada:    .skip 7
saida_certo:   .skip 7

.data
saida_erro:     .ascii "-1\n"
