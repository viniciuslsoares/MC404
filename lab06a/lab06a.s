.text

.globl _start

sqrt:                   # n -> a0 e iterações -> a1
    li a3, 2            # 2 -> a3
    div a2, a0, a3      # a0 / 2 -> a2 (k)
laco_sqrt:              # começa laço de divisões
    addi a1, a1, -1     # decrementa o contador de iterações
    div a4, a0, a2      # n / k -> a4
    add a4, a4, a2      # k + n/k -> a4
    div a4, a4, a3      # (k + n/k)/2 -> a4
    mv a2, a4           # a4 -> a2 (a4 é o novo k)
    bnez a1, laco_sqrt  # if a1 != 0, volta pro laço
    mv a0, a4
ret                     # retorna função


to_string:              # num -> a0 e *str -> a1
    li a2, 1000         # 1000 -> a2
    div a3, a0, a2      # a0 / 1000 -> a3
    rem a0, a0, a2      # a0 % 1000 -> a0
    addi a3, a3, '0'
    sb a3, (a1)         # primeiro char da string
    li a2, 100          # 100 -> a2
    div a3, a0, a2      # a0 / 100 -> a3
    rem a0, a0, a2      # a0 % 100 -> a0
    addi a3, a3, '0'
    sb a3, 1(a1)        # segundo char da string
    li a2, 10           # 10 -> a2
    div a3, a0, a2      # a0 / 10 -> a3
    rem a0, a0, a2      # a0 % 10 -> a0
    addi a3, a3, '0'
    sb a3, 2(a1)        # terceiro char da string
    addi a0, a0, '0'
    sb a0, 3(a1)        # quarto char da string
ret


to_int:                 # *str -> a0
    lb a2, (a0)         # busca o dígito do mihar
    addi a2, a2, -48    # corrige o valor ascii
    li a3, 1000         # 1000 -> a3
    mul a2, a2, a3      # a2 * 1000 ->  a2
    mv a4, a2           # a2 -> a4
    lb a2, 1(a0)        # busca o dígito da centena
    addi a2, a2, -48    # corrige o valor ascii
    li a3, 100          # 100 -> a3
    mul a2, a2, a3      # a2 * 100 -> a2
    add a4, a4, a2      # a4 + a2 -> a4
    lb a2, 2(a0)        # busca o dígito da dezena
    addi a2, a2, -48    # corrige o valor ascii
    li a3, 10           # 10 -> a3
    mul a2, a2, a3      # a2 * 10 ->  a2
    add a4, a4, a2      # a4 + a2 -> a4
    lb a2, 3(a0)        # busca o dígito da unidade
    addi a2, a2, -48    # corrige o valor ascii
    add a4, a4, a2      # adiciona a unidade 
    mv a0, a4           # retorna o valor em a0  
ret 

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

_start:

    la a1, numeros      # endereço de armazenamento
    li a2, 20           # tamanho da string a ser lida
    jal read            # lê os números do terminal

    la a0, numeros
    jal to_int
    li a1, 10
    jal sqrt
    la a1, numeros
    jal to_string

    la a0, numeros
    addi a0, a0, 5
    jal to_int
    li a1, 10
    jal sqrt
    la a1, numeros
    addi a1, a1, 5
    jal to_string

    la a0, numeros
    addi a0, a0, 10
    jal to_int
    li a1, 10
    jal sqrt
    la a1, numeros
    addi a1, a1, 10
    jal to_string

    la a0, numeros
    addi a0, a0, 15
    jal to_int
    li a1, 10
    jal sqrt
    la a1, numeros
    addi a1, a1, 15
    jal to_string

    la a1, numeros
    li a2, 20
    jal write

jal exit



.data
numeros: .skip 20