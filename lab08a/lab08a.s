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

    add a6, a7, a6
    addi a6, a6, 5

    lw t2, width
    lw t3, height   

    mv a0, t2
    mv a1, t3
    jal setCanvasSize

    mv a5, a6           # offsets    
    mv a3, zero         # coord x
    mv a4, zero         # coord y

    # primeiro for conta as linhas e o segundo itera nas colunas
    # a0: coord. x, a1: coord. y, a2: cor do pixel
for:    
    lbu a0, (a5)        # valor do pixel
    jal define_pixel    
    
    mv a2, a0           # carrega a cor em a2
    mv a0, a3            # coord x -> a0
    mv a1, a4            # coord y -> a1
    jal setPixel

    addi a3, a3, 1      # incrementa a coord x
    addi a5, a5, 1      # incrementa o pixel
    blt a3, t2, for     # itera enquando x != width

    mv a3, zero         # zera o x
    addi a4, a4, 1      # incrementa o y
    blt a4, t3, for     # itera enquanto y != height
fim:

jal exit

.section .bss

image: .skip 262159
width: .skip 4
height: .skip 4

.section .data
.section .rodata

input_file: .asciz "image.pgm"
