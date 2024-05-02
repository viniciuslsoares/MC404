.text

.globl puts

puts:                   # a0: str*
    mv t0, a0           # endereço do primeiro char
    mv t1, zero         # contador
    mv t2, zero         # null character
2:
    addi t1, t1, 1      # incrementa contador
    lbu t3, (t0)        # carrega o character 
    beq t3, t2, 1f      # testa se é o '\0'
    addi t0, t0, 1      # end. prox char
    j 2b
1:                      # se encontrou o '\0'
    li t2, '\n'
    sw t2, (t0)
    # write
    mv a2, t1           # tamanho
    mv a1, a0           # endereço do char
    li a0, 1            # fd
    li a7, 64           # syscall
    ecall
    
    li t2, 0
    sw t2, (t0)

ret


.globl gets

gets:                   # a0: str*
    mv t0, a0
    mv t6, a0           # guarda o end original
    li a2, 1            # tamanho
    li a7, 63           # syscall
    li t2, '\n'
1:
    mv a1, t0           # char a ser lido
    li a0, 0            # fd 
    ecall
    lbu a1, (t0)        # carrega o char lido
    beq a1, t2, 2f      # compara com o \n
    addi t0, t0, 1      # prox char a ser lido
    j 1b
2:
    li a1, 0
    sb a1, (t0)         # tira o \n do final
    mv a0, t6           # retorna o endereço do 1o char

ret

.globl atoi

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


.globl itoa

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

    mv t3, zero
    sb t3, (t1)         # coloca um \0 no final da string
    mv a0, a1
ret

.globl linked_list_search

linked_list_search:     # a0: head_node, a1: val
    addi sp, sp, -4
    sw ra, (sp)

    mv t0, a0           # primeiro endereço
    mv t1, a1           # valor a ser procurado
    mv t5, zero         # contador de nós

1:
    lw t3, (t0)         # primeiro número
    lw t4, 4(t0)        # segundo número
    add t3, t3, t4      # num1 + num2
    beq t3, t1, 2f      # saí do loop se a soma == entrada
    addi t5, t5, 1      # número do prox nó
    lw t0, 8(t0)        # prox. nó
    beq t0, zero, 3f
    j 1b

2:  
    mv a0, t5           # se encontrou o resultado
    j 4f    

3:                      # se não encontrou o resultado
    li a0, -1

4:
    lw ra, (sp)
    addi sp, sp, 4
ret

.globl exit

exit:
    li a0, 0
    li a7, 93           # syscall
ret
