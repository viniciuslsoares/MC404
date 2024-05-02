.text

.globl _start

read:                   # str* -> a1; size -> a2
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
    li a7, 93
ecall

to_bin:                 # *str -> a0, tam -> a1
    add a1, a1, a0      # endereço final da string
retorno1:
    lw t1, (a0)         # carrega o valor da posição em a1
    addi t1, t1, -48        
    sb t1, (a0)         # guarda o valor binário
    addi a0, a0, 1
    bne a0, a1, retorno1 # vê se percorreu a string toda
ret

to_string:  	        # *str -> a0, tam -> a1
    add a1, a1, a0      # endereço final da string
retorno2:
    lw t1, (a0)         # carrega o valor da posição em a1
    addi t1, t1, 48        
    sb t1, (a0)         # guarda o valor binário
    addi a0, a0, 1
    bne a0, a1, retorno2 # vê se percorreu a string toda
ret

paridade:               # a0 -> 1o bit; a1 -> 2o bit; a2 -> 3o bit
    xor a0, a0, a1
    xor a0, a0, a2
ret

check_paridade:         # a0 -> px; a1 -> 1o bit; a2 -> 2o bit; a3 -> 3o bit
    xor a0, a0, a1
    xor a0, a0, a2
    xor a0, a0, a3
ret

_start:

    la a1, decoded
    li a2, 5
    jal read
    la a0, decoded
    li a1, 5
    jal to_bin          # corrige os valores ASCII para binário

    la a1, coded
    li a2, 8
    jal read
    la a0, coded    
    li a1, 8
    jal to_bin          # corrige os valores ASCII para binário

codificacao:
    la t1, saida
    la t2, decoded

    lb a0, (t2)
    sb a0, 2(t1)
    lb a1, 1(t2)
    sb a1, 4(t1)
    lb a2, 3(t2)
    sb a2, 6(t1)
    jal paridade
    sb a0, (t1)          # primeiro bit de paridade na string final

    lb a0, (t2)
    lb a1, 2(t2)
    sb a1, 5(t1)
    lb a2, 3(t2)
    jal paridade
    sb a0, 1(t1)        # segundo bit de paridade na string final

    lb a0, 1(t2)
    lb a1, 2(t2)
    lb a2, 3(t2)
    jal paridade
    sb a0, 3(t1)        # terceiro bit de paridade na string final

decodificacao:          # 01 2 3 456 \n 89ab \n d \n
    la t1, saida
    la t2, coded
    li t3, 1
    sb zero, 13(t1)

    lb a0, (t2)
    lb a1, 2(t2)        # d1
    sb a1, 8(t1)
    lb a2, 4(t2)        # d2
    sb a2, 9(t1)
    lb a3, 6(t2)        # d4
    sb a3, 11(t1)
    jal check_paridade
    beq a0, t3, erro

    lb a0, 1(t2)
    lb a1, 2(t2)        
    lb a2, 5(t2)        # d3
    sb a2, 10(t1)        
    lb a3, 6(t2)
    jal check_paridade
    beq a0, t3, erro

    lb a0, 3(t2)
    lb a1, 4(t2)
    lb a2, 5(t2)
    lb a3, 6(t2)
    jal check_paridade
    beq a0, t3, erro

    j print_final       # se não houve erro mantém o bit de erro como zero

erro:
    li t3, 1
    sb t3, 13(t1)     # se erro seta o bit de erro como 1

print_final:

    la a0, saida
    li a1, 15
    jal to_string

    la a1, saida

    li t3, '\n'
    sb t3, 7(a1)
    sb t3, 12(a1)
    sb t3, 14(a1)
    li a2, 15
    jal write

jal exit

to_int:                 # *str -> a0   // números de três dígitos
    lb a2, (a0)         # busca o dígito da centena
    addi a2, a2, -48    # corrige o valor ascii
    li a3, 100          # 100 -> a3
    mul a2, a2, a3      # a2 * 100 ->  a2
    mv a4, a2           # a2 -> a4
    lb a2, 1(a0)        # busca o dígito da dezena
    addi a2, a2, -48    # corrige o valor ascii
    li a3, 10           # 10 -> a3
    mul a2, a2, a3      # a2 * 10 -> a2
    add a4, a4, a2      # a4 + a2 -> a4
    lb a2, 2(a0)        # busca o dígito da unidade
    addi a2, a2, -48    # corrige o valor ascii
    add a4, a4, a2      # a4 + a2 -> a4
    mv a0, a4           # retorna o valor em a0  
ret

.data
decoded: .skip 5
coded: .skip 8
saida: .skip 15