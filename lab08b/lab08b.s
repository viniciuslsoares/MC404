.text

.globl _start

read:                   # a0: fd, a1: *str, a2: size
    #li a0, 0           # file descriptor = 0 (stdin)
    li a7, 63           # syscall read (63)
    ecall
ret

exit:                   # finaliza o programa
    li a0, 0
    li a7, 93           # syscall
ecall

setPixel:               # a0: coord. x, a1: coord. y, a2: cor do pixel
    li a7, 2200         # syscall
    ecall
ret

setCanvasSize:          # a0: largura, a1: altura
    li a7, 2201         # syscall
    ecall
ret

setScalling:            # a0: escala horizontal, a1: escala vertical
    li a7, 2202          # syscall
    ecall
ret

open:                   # a0: endereço do path // retorn file descriptor in a0
    li a1, 0            # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0            # mode
    li a7, 1024         # syscall
    ecall
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

define_pixel:           # a0: valor do pixel em cinza
    mv t1, a0           # 24..31 -> a0 [red]
    slli t1, t1, 8
    add t1, t1, a0      # 16..23 -> a0 [green]
    slli t1, t1, 8
    add t1, t1, a0      # 8..15 -> a0 [blue]
    slli t1, t1, 8
    addi t1, t1, 255    #  0..7 -> 255 [alpha]
    mv a0, t1
ret

border:                 # a0: cor da borda, a1: width, a2: height
    mv a5, ra           # guarda o endereço de retorno
    mv t1, a1           # t1: width
    mv t2, a2           # t2: height
    mv a2, a0           # a2: cor da borda

    mv a1, zero         # primeira linha -> a1 = y = 0
    mv a0, zero         # x começa em 0
linha0:
    jal setPixel
    addi a0, a0, 1
    bne a0, t1, linha0

    mv a1, t2           # última linha
    addi a1, a1, -1
    mv a0, zero
linhan:
    jal setPixel
    addi a0, a0, 1
    bne a0, t1, linhan

    mv a0, zero         # coluna 0
    mv a1, zero         # linha 0
coluna0:
    jal setPixel
    addi a1, a1, 1      # prox coluna
    bne a1, t2, coluna0

    mv a0, t1
    addi a0, a0, -1     # coluna n
    mv a1, zero
colunan:
    jal setPixel
    addi a1, a1, 1
    bne a1, t2, colunan

    mv ra, a5           # devolve o endereço de retorno
ret 

filter:                 # a0: posição atual
    lw t6, width
    lbu t0, (a0)        # (1,1)
    lbu t1, -1(a0)      # (1,0)
    lbu t2, 1(a0)       # (1,2)

    li t3, 8
    mul t0, t0, t3      # (1,1) x 8
    sub t0, t0, t1      # -1 x (1,0)
    sub t0, t0, t2      # -1 x (1,2)

    add t5, t6, a0      # a0 + width
    lbu t1, (t5)        # (2,1)
    lbu t2, -1(t5)      # (2,0)
    lbu t3, 1(t5)       # (2,2)

    sub t0, t0, t1      # -1 x (2,1) 
    sub t0, t0, t2      # -1 x (2,0)
    sub t0, t0, t3      # -1 x (2,2)

    sub t5, a0, t6      # a0 - width
    lbu t1, (t5)        # (0,1)
    lbu t2, -1(t5)      # (0,0)
    lbu t3, 1(t5)       # (0,2)

    sub t0, t0, t1      # -1 x (0,1) 
    sub t0, t0, t2      # -1 x (0,0)
    sub t0, t0, t3      # -1 x (0,2)

    mv a0, t0           # valor final
    li t0, 255
    blt a0, t0, filter_ 
    li a0, 255          # se maior que 255
filter_:
    bgt a0, zero, filter_out
    li a0, 0            # se menor que 0
filter_out:
ret

_start:                

    la a0, input_file
    jal open
    la a1, image
    li a2, 262159
    jal read            # lê a imagem
    la a7, image        # offset da imagem
    addi a7, a7, 3      # end do primeiro número
    mv a0, a7
    jal lenght
    mv a6, a0           # tamanho do número em a6

    mv a0, a7
    jal to_int
    la t1, width
    sw a0, (t1)

    add a7, a7, a6       
    addi a7, a7, 1      # endereço do prox número

    mv a0, a7
    jal lenght
    mv a6, a0

    mv a0, a7
    jal to_int
    la t1, height
    sw a0, (t1)
parada:
    add a6, a7, a6
    addi a6, a6, 5

    lw t2, width
    lw t3, height   

dimensions:
    mv a0, t2
    mv a1, t3
    jal setCanvasSize

    # primeiro for conta as linhas e o segundo itera nas colunas
    # a0: coord. x, a1: coord. y, a2: cor do pixel

    li a0, 150
    mv a1, t2
    mv a2, t3
    jal border
    
    li a3, 1
    li a4, 1

    # O primeiro pixel a ser impresso é a posição (1,1), ou seja,
    # posição width + 1 no vetor armazenado
        
    lw s0, width
    addi s0, s0, -1
    lw s1, height
    addi s1, s1, -1

    mv a5, a6
    add a5, a5, s0
    addi a5, a5, 2
    
for:    
    mv a0, a5
    jal filter
filtro:
    jal define_pixel

    mv a2, a0
    mv a0, a3
    mv a1, a4
    jal setPixel

    addi a3, a3, 1
    addi a5, a5, 1
    blt a3, s0, for

    li a3, 1
    addi a4, a4, 1
    addi a5, a5, 2
    blt a4, s1, for
fim:

jal exit

.section .bss

image: .skip 262159
width: .skip 4
height: .skip 4

.section .data
.section .rodata

input_file: .asciz "image.pgm"
