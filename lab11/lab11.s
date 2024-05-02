.text

.globl _start

.set car_adress, 0xFFFF0100

exit:                       # finaliza o programa
    li a0, 0
    li a7, 93               # syscall
ecall

_start:

    li a0, car_adress

    sb zero, 34(a0)         # freio de mão para zero
    li a7, 40000            # tempo de espera
    li a1, 1
    sb a1, 33(a0)
1:                          # acelera para frente
    addi a7, a7, -1
    bnez a7, 1b

    li a1, -117
    sb a1, 32(a0)           # vira para a esquerda
    li a7, 20000            # tempo de espera
    li a1, 1
    sb a1, 33(a0)           # liga o motor
2:                          # vira por um período
    addi a7, a7, -1
    bnez a7, 2b

    sb zero, 32(a0)         
    li a7, 25000            # tempo de espera
4:                          # acelera reto 
    addi a7, a7, -1
    bnez a7, 4b

    sb zero, 33(a0)
    li a7, 30000
6:
    addi a7, a7, -1
    bnez a7, 6b

    li a1, 1
    sb a1, 34(a0)           # freio de mão

jal exit