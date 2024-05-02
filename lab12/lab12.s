.text

.globl _start

.set write_flag, 0xFFFF0100
.set write_byte, 0xFFFF0101
.set read_flag, 0xFFFF0102
.set read_byte, 0xFFFF0103
.align 4

exit:                       # finaliza o programa
    li a0, 0
    li a7, 93               # syscall
ecall

serial_read:                # a0: str* buffer    
    li t3, '\n'             # leitura até o primeiro \n
    mv t4, zero             # contador do tamanho

    3:                          
    li t1, 1                # flag de leitura
    li t2, read_flag        
    sb t1, (t2)

    1:                          # laço de espera da leitura                            
    li t2, read_flag
    lb t2, (t2)
    bnez t2, 1b             # desvia enquanto != 0
    
    li t2, read_byte
    lb t2, (t2)
    sb t2, (a0)             # guarda o byte lido
    addi a0, a0, 1          # avança para o prox end
    addi t4, t4, 1          # incrementa contador
    bne t3, t2, 3b          # continua lendo se != \n
    mv a0, t4               # retorna em a0 o contador
ret

serial_write:               # a0: str* buffer
    li t3, '\n'             # imprime até o primeiro \n
    1:
    lb t4, (a0)             # busca o byte a ser impresso
    addi a0, a0, 1          # incrementa a posição
    li t2, write_byte
    sb t4, (t2)             # coloca o byte na porta serial

    li t1, 1                # flag de escrita
    li t2, write_flag
    sb t1, (t2)             
    2:                          # laço de espera
    li t2, write_flag
    lb t2, (t2)
    bnez t2, 2b

    bne t4, t3, 1b          # continua se != \n
ret

atoi:                   # a0: str*
    mv t0, a0
    li t1, ' '          # espaço em branco para comparação
    1:                      # laço ignora os primeiros espaços
    lbu a1, (t0)         
    bne a1, t1, 6f      # desvia enquanto o char for ' '
    addi t0, t0, 1
    j 1b
    6:
    li t5, '+'
    li t6, '-'
    li t2, 1
    lb a0, (t0)         # primeiro char depois dos espaços
    beq a0, t5, 4f
    bne a0, t6, 5f
    li t2, -1
    4:
    addi t0, t0, 1      # pula o char de sinal
    5:
    mv t1, zero         # acumulador
    li t3, 10
    li t6, 58
    li t5, 47
    lb a0, (t0)

    2:
    mul t1, t1, t3
    addi a0, a0, -48
    add t1, t1, a0
    addi t0, t0, 1
    lb a0, (t0)
    bge a0, t6, 3f      # testa se maior que 58
    bgt a0, t5, 2b      # menor ou igual a 0
    3:
    mul a0, t1, t2
ret

itoa:                   # a0: int, a1: str*, a2: base
    mv t0, a0           # int -> a0 
    mv t1, a1           # str* -> t1
    li t6, 1
    li t5, 10
    mv t2, a2           # base -> t2
    bge t0, zero, 1f    # testa se negativo
    bne t2, t5, 1f      # testa se base 10
    li t6, -1
    li t2, '-'          # coloca o sinal de menos se negativo e base 10
    sb t2, (t1)         
    addi t1, t1, 1  
    1:
    mul t0, t0, t6
    mv t4, zero
    mv t2, a2
    li t6, 10
    2:
    addi sp, sp, -1
    remu t3, t0, t2     # t3 -> resto de t0 / t2
    divu t0, t0, t2
    bge t3, t6, 4f
    addi t3, t3, 48
    j 5f
    4:
    addi t3, t3, 55
    5: 
    sb t3, (sp)
    addi t4, t4, 1      # contador
    bgt t0, zero, 2b    # divide e guarda o char na pilha

    3:
    lbu t3, (sp)
    sb t3, (t1)
    addi t1, t1, 1
    addi sp, sp, 1
    addi t4, t4, -1
    bgt t4, zero, 3b

    li t3, '\n'
    sb t3, (t1)         # coloca um \0 no final da string
    mv a0, a1
ret


inver_string:           # a0: str* source; a1: str* destiny; a2: int tamanho
    add a3, a2, a0      # end do primeiro byte mais tamanho da string
    addi a3, a3, -2     # tira o \n no final e corrige a posição do último byte
    addi a0, a0, -1
    mv t0, zero

    1:
    lb t1, (a3)
    sb t1, (a1)
    addi a1, a1, 1
    addi a3, a3, -1
    bne a3, a0, 1b      # loop enquanto o primeiro byte não for impresso 
    li t1, '\n'
    sb t1, (a1)
ret

get_operator:           # a0: str*
    li t1, ' '
    1:
    lb t2, (a0)
    addi a0, a0, 1
    beqz t2, 2f
    bne t2, t1, 1b
    2:
    addi a1, a0, 2      # endereço do segundo número retorna em a1
    lb a0, (a0)         # retorna operador em a0
ret


_start:

    la a0, buffer_op        # leitura da operação
    jal serial_read

    la a0, buffer_entrada   # leitura do conteúdo
    jal serial_read

    la a1, tamanho          # tamanho da string de entrada (para caso 2)
    sw a0, (a1)

    la a0, buffer_op
    jal atoi
    mv a2, a0               # operação a ser executafa

operacoes:
    li t1, 1
    beq a2, t1, 1f          # desvia para operação 1

    li t1, 2
    beq a2, t1, 2f          # desvia para operação 2

    li t1, 3
    beq a2, t1, 3f          # desvia para operação 3

    li t1, 4
    beq a2, t1, 4f          # desvia para operação 4
    j 5f

1:                          # imprime a string de entrada
        la a0, buffer_entrada
        jal serial_write
        j 5f

2:                          # imprime a string ao contrário
        la a2, tamanho
        lw a2, (a2)
        la a0, buffer_entrada
        la a1, buffer_saida
        jal inver_string

        la a0, buffer_saida
        jal serial_write
        j 5f

3:                          # converte o número para hex e imprime
        la a0, buffer_entrada
        jal atoi
        la a1, buffer_saida
        li a2, 16
        jal itoa
        la a0, buffer_saida
        jal serial_write
        j 5f

4:
        la a0, buffer_entrada
        jal atoi
        la a1, num1
        sw a0, (a1)             # guarda o primeiro número da string

        la a0, buffer_entrada
        jal get_operator

        mv a2, a0               # operador em a2
        mv a0, a1
        jal atoi                # segundo número da string

        mv t4, a0               # segundo número em t4
        la a0, num1
        lw t3, (a0)             # primeiro número em t3

    match:
        li t1, '+'
        beq a2, t1, 6f          # desvia para operação '+'

        li t1, '-'
        beq a2, t1, 7f          # desvia para operação '-'

        li t1, '*'
        beq a2, t1, 8f          # desvia para operação '*'

        li t1, '/'
        beq a2, t1, 9f          # desvia para operação '/'
        j 5f

        6:                      # caso '+'
            add t3, t3, t4
            j 10f

        7:                      # caso '-'
            sub t3, t3, t4
            j 10f

        8:                      # caso '*'
            mul t3, t3, t4
            j 10f

        9:                      # caso '/'
            div t3, t3, t4
            j 10f

        10:                     # imprime o resultado do caso anterior
            mv a0, t3
            la a1, buffer_saida
            li a2, 10
            jal itoa

            la a0, buffer_saida
            jal serial_write
5:

jal exit


.bss

buffer_op:      .skip 4
buffer_entrada: .skip 127
buffer_saida:   .skip 127
tamanho:        .skip 4
num1:           .skip 4
num2:           .skip 4