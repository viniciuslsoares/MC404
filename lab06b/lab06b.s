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

sinal:                  # a0 -> num; a1 -> *str do sinal
    lb a1, (a1)         # carrega o sinal a ser testado em a1
    li a2, '+'
    beq a1, a2, fim_sinal
    li a2, -1           # se continuou é porque o sinal é negativo
    mul a0, a0, a2      # valor de retorno em a0
fim_sinal:
ret                     # retorna em a0

calc_dist:              # a0 -> endereço
    mv t1, a0           # endereço para t1
    lw a0, (a0)         # carrega o valor do tempo
    la a3, valorR       
    lw a3, (a3)         # carrega o tempo tr
    sub a0, a3, a0      # subtrai de tr o tempo recebido
    la a2, v_luz        # endereço de v_luz
    lw a1, (a2)         # v_luz -> a2
    mul a0, a0, a1      # tempo * v_luz -> a0
    li a1, 10           # 10 -> a2
    div a0, a0, a1      # divide a distância por 10 para ajustar a unidade
    sw a0, (t1)         # guarda o valor da distância no endereço original
ret

calc_y:                 # não precisa de parâmetros, pega os valores da memória
    la a0, Yb
    lw a0, (a0)
    la a1, valorA
    lw a1, (a1)
    la a2, valorB
    lw a2, (a2)
    li a3, 2
    mul a1, a1, a1      # da^2
    mul a2, a2, a2      # db^2
    mul a3, a0, a3      # 2Yb
    mul a0, a0, a0      # Yb^2
    add a0, a0, a1      # da^2 + Yb^2
    sub a0, a0, a2      # (da^2 + Yb^2) - db^2
    div a0, a0, a3      #(da^2 + Yb^2 - db^2)/2Yb
    la t1, Y_saida
    sw a0, (t1)         # resultado em a0 e em Y_saida
ret

calc_x:
    la a0, Y_saida
    lw a0, (a0)
    la a1, valorA
    lw a1, (a1)
    mul a0, a0, a0      # Y^2
    mul a1, a1, a1      # da^2
    sub a0, a1, a0      # da^2 - Y^2 -> a0
    li a1, 21
    mv t1, ra
    jal sqrt            # calcula a raiz com 21 iterações
    mv ra, t1
    la t1, X1
    sw a0, (t1)         # armazena X1
    li t2, -1
    mul a0, a0, t2
    la t2, X2
    sw a0, (t2)         # armazena X2
ret

teste_x:                # a0 -> x que está sendo testado
    la a1, Xc
    lw a1, (a1)
    la a2, Y_saida
    lw a2, (a2)
    la a3, valorC
    lw a3, (a3)
    sub a0, a0, a1      # x - Xc
    mul a0, a0, a0      # (x - Xc)^2
    mul a2, a2, a2      # Y^2
    add a0, a0, a2      # (x - Xc)^2 + Y^2
    mul a3, a3, a3      # dc^2
    sub a0, a3, a0      # dc^2 - ((x - Xc)^2 + Y^2)  "erro" de X
ret                     # retorna em a0 o "erro" do X

check_sinal:            # num ->  a0, *str -> a1
    blt a0, zero, negativo
#positivo:
    li a2, '+'          # coloca o sinal na string
    sb a2, (a1)
    j retorno_sinal
negativo:
    li a2, -1
    mul a0, a0, a2      # módulo do número negativo
    li a2, '-'          # coloca o sinal na string
    sb a2, (a1)
    j retorno_sinal
positivo:

modulo:                 # a0 -> num
    bgt a0, zero, mais
    li a1, -1
    mul a0, a0, a1
mais:
ret

retorno_sinal:
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

    la a1, posicoes     
    li a2, 12           
    jal read            # recebe os valores das posições

    la a1, tempos
    li a2, 20
    jal read            # recebe os valores de tempo

    la a0, posicoes     
    mv a1, a0           # copio o endereço em a1
    addi a0, a0, 1      # leitura do primeiro número com sinal
    jal to_int          # recebo o número em a0
    jal sinal           # testo o sinal
    la a2, Yb
    sw a0, (a2)         # armazena a posição Yb recebida

    la a0, posicoes     
    mv a1, a0           # copio o endereço em a1
    addi a0, a0, 7      # leitura do segundo número com sinal
    addi a1, a1, 6      # posição do sinal a ser testado
    jal to_int          # recebo o número em a0
    jal sinal           # testo o sinal
    la a2, Xc
    sw a0, (a2)         # armazena a posição Xc recebida

    la a0, tempos
    jal to_int
    la a1, valorA
    sw a0, (a1)         # guarda o valor de Ta

    la a0, tempos
    addi a0, a0, 5
    jal to_int
    la a1, valorB
    sw a0, (a1)         # guarda o valor de Tb

    la a0, tempos
    addi a0, a0, 10
    jal to_int
    la a1, valorC
    sw a0, (a1)         # guarda o valor de Tc

    la a0, tempos
    addi a0, a0, 15
    jal to_int
    la a1, valorR
    sw a0, (a1)         # guarda o valor de Tr

    la a0, valorA       # calculas as distâncias a partir do tempo
    jal calc_dist
    la a0, valorB
    jal calc_dist
    la a0, valorC
    jal calc_dist

    jal calc_y          # calcula X e armazena na memória
    jal calc_x          # calculas as possibilidades de X

    la a0, X1
    lw a0, (a0)
    jal teste_x         # testa o erro de X1
    jal modulo          # pega o módulo do erro
    mv t1, a0           # t1 tem o erro de X1

    la a0, X2
    lw a0, (a0)
    jal teste_x         # testa o erro de X1
    jal modulo          # pega o módulo do erro
    mv t2, a0           # t2 tem o erro de X2

    la t3, X_saida
    blt t1, t2, X1_certo    # vê qual erro é menor

#X2_certo:
    la t2, X2
    lw t2, (t2)
    sw t2, (t3)         # carrega X2 como certo
    j volta

X1_certo:
    la t1, X1
    lw t1, (t1)
    sw t1, (t3)         # carrega X1 como certo

volta:

    la a0, Y_saida      # armazena o valor de Y na string de saída (com sinal)
    lw a0, (a0)
    la a1, saida
    addi a1, a1, 6
    jal check_sinal
    addi a1, a1, 1
    jal to_string

    la a0, X_saida      # armazena o valor de X na string de saída (com sinal)
    lw a0, (a0)
    la a1, saida
    jal check_sinal
    addi a1, a1, 1
    jal to_string

    la a1, saida        # coloca o espaço e \n na string
    li a2, '\n'
    sb a2, 11(a1)
    li a2, ' '
    sb a2, 5(a1)

    la a1, saida        # imprime a string de saída
    li a2, 12
    jal write


jal exit

.data
posicoes: .skip 12
tempos: .skip 20
valorA: .word 0
valorB: .word 0
valorC: .word 0
valorR: .word 0
Xc: .word 0
Yb: .word 0
Y_saida: .word 0
X_saida: .word 0
X1: .word 0
X2: .word 0
saida: .skip 12

.rodata
v_luz: .word 3                      # suprimi a potência de 10 para simplificar na multiplicação por nano

