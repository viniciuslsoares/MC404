.text
.globl main

int_handler:
    ###### Syscall and Interrupts handler ######
    csrrw sp, mscratch, sp
    addi sp, sp, -64
    # TODO
    sw a7, (sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw t3, 16(sp)
    sw t4, 20(sp)
    sw t5, 24(sp)
    sw t6, 28(sp)
    sw ra, 32(sp)

    la t0, syscall_table
    addi a7, a7, -10            # ignora os 10 primieros códigos
    slli a7, a7, 2              # a7 * 4
    add t0, t0, a7              # endereço da syscall
    lw t0, (t0)
    jalr t0

    csrr t0, mepc               # carrega o endereço de retorno
    addi t0, t0, 4              
    csrw mepc, t0               # soma 4 e guarda o endereço novamente
    
    lw ra, 32(sp)
    lw t6, 28(sp)
    lw t5, 24(sp)
    lw t4, 20(sp)
    lw t3, 16(sp)
    lw t2, 12(sp)
    lw t1, 8(sp)
    lw t0, 4(sp)
    lw a7, (sp)
    addi sp, sp, 64
    csrrw sp, mscratch, sp
mret

set_engine_and_steering:
    
    li t0, -127                 # teste dos valores inválidos
    blt a1, t0, 1f              # a1 < -127

    li t0, 127
    bgt a1, t0, 1f              # a1 > 127

    li t0, -1
    blt a0, t0, 1f              # a0 < -1

    li t0, 1
    bgt a0, t0, 1f              # a0 > -1

    la t0, CAR_Engine
    sb a0, (t0)                 # define a direção do motor

    la t0, CAR_Wheel_direction
    sb a1, (t0)                 # define direção do volante

    li a0, 0                    # retorno de valores válidos
    j 2f

    1:
        li a0, -1               # retorno de valores inválidos

    2:
ret

set_handbrake:

    la t0, CAR_handbrake
    sb a0, (t0)

ret

read_sensors:

    la t0, CAR_Camera_trigger
    li t1, 1
    sb t1, (t0)                 # inicia a leitura da câmera

    1:
        lb t1, (t0)
        bnez t1, 1b             # espera a leitura

    la t0, CAR_Camera_read
    li t2, 256                  # valor para comparação
    li t1, 0                    # contador

    2:
        lb t3, (t0)             # lê o valor atual
        sb t3, (a0)             # guarda o valor lido
        addi t0, t0, 1          
        addi a0, a0, 1          
        addi t1, t1, 1          # incrementa o contador
        bne t1, t2, 2b          # compara com 256 para encerrar o loop

ret

read_sensors_distance:

    li t1, 1
    la t0, CAR_Sensor_trigger
    sb t1, (t0)                 # aciona a leitura do sensor

    1:
        lb t1, (t0)
        bnez t1, 1b

    la t0, CAR_Sensor_read
    lw a0, (t0)                 # retorna o valor lido em a0

ret

get_position:

    la t0, CAR_GPS_trigger
    li t1, 1
    sb t1, (t0)

    1:
        lb t1, (t0)
        bnez t1, 1b

    la t0, CAR_Xpos_read
    lw t1, (t0)
    sw t1, (a0)

    la t0, CAR_Ypos_read
    lw t1, (t0)
    sw t1, (a1)

    la t0, CAR_Zpos_read
    lw t1, (t0)
    sw t1, (a2)

ret

get_rotation:

    la t0, CAR_GPS_trigger
    li t1, 1
    sb t1, (t0)

    1:
        lb t1, (t0)
        bnez t1, 1b

    la t0, CAR_Xangle_read
    lw t1, (t0)
    sw t1, (a0)

    la t0, CAR_Yangle_read
    lw t1, (t0)
    sw t1, (a1)

    la t0, CAR_Zangle_read
    lw t1, (t0)
    sw t1, (a2)

ret

read_serial:

    li t3, '\n'
    mv t4, zero
    beqz a1, 2f                     # buffer de tamanho 0

    3:
    li t1, 1
    la t2, SERIAL_Read_trigger
    sb t1, (t2)

    1:
        lb t1, (t2)
        bnez t1, 1b

    la t2, SERIAL_Read_byte
    lb t2, (t2)
    beqz t2, 2f                     # encerra se leu \0
    beq t3, t2, 2f                  # encerra se leu \n
    sb t2, (a0)
    addi a0, a0, 1                  # prox char
    addi t4, t4, 1                  # contador de posições
    bne t4, a1, 3b                  # encerra se estourou o buffer

    2:
    sb zero, (a0)
    mv a0, t4                       # retorna em a0 a qnt de bytes lidos

ret

write_serial:

    li t3, '\n'
    li t1, 0

    1:
    la t0, SERIAL_Write_byte
    lb t4, (a0)
    bnez t4, 4f
    mv t4, t3                   # se \0 troca por \n
    4:
    sb t4, (t0)
    
    la t0, SERIAL_Write_trigger    
    li t2, 1
    sb t2, (t0)

    2:
        lb t2, (t0)
        bnez t2, 2b

    addi a0, a0, 1
    addi t1, t1, 1
    beq t1, a1, 3f              # se imprimiu a qnt em a1
    beqz t4, 3f                 # se imprimiu \0
    bne t4, t3, 1b              # se imprimiu \n
    3:
ret

get_systime:

    la t0, GPT_trigger
    li t1, 1
    sb t1, (t0)

    1:
        lb t1, (t0)
        bnez t1, 1b

    la t0, GPT_read
    lw a0, (t0)

ret

.globl _start
_start:

    la t0, int_handler              # endereço da main_isr
    csrw mtvec, t0                  # mtvec <= t0 (direct mode)
    
    la t0, isr_stack_end            # t0 <= base da pilha do sistema
    csrw mscratch, t0               # mscratch <= t0

    csrr t1, mstatus                # seta o bit 3 (mstatus.MIE)
    ori t1, t1, 0x8                 # interrupções globais
    csrw mstatus, t1                # mstatus.MIE <= t1

    csrr t1, mstatus                # seta o bit 7 (mstatus.MPIE)
    ori t1, t1, 0x40            
    csrw mstatus, t1                # mstatus.MPIE <= t1
    
    csrr t1, mstatus                # muda o modo de operação
    li t2, ~0x1800                  # para usuário
    and t1, t1, t2                  # do campo mstatus.MPP
    csrw mstatus, t1                # mstatus.MPP <= t1

    la t0, main                     # carrega o endereço de entrada
    csrw mepc, t0                   # no mepc

    li sp, 0x07FFFFFC               # user stack
    
mret                                # PC <= mepc; mode <= MPP; MIE <= MPIE


.bss    
isr_stack:                          # Final da pilha ISR
.skip   256
isr_stack_end:                      # Base da pilha ISR

.data
syscall_table:
.word   set_engine_and_steering     # code == 10
.word   set_handbrake               # code == 11
.word   read_sensors                # code == 12
.word   read_sensors_distance       # code == 13
.skip   4                           # code == 14
.word   get_position                # code == 15
.word   get_rotation                # code == 16
.word   read_serial                 # code == 17
.word   write_serial                # code == 18
.skip   4                           # code == 19
.word   get_systime                 # code == 20

    ### Posições de memória ###

# --- GPT ---
.set GPT_trigger, 0xFFFF0100            # 1 inicia leitura
.set GPT_read, 0xFFFF0104               # leitura do tempo
.set GPT_int, 0xFFFF0108                # tempo para int

# --- CAR ---
.set CAR_GPS_trigger, 0xFFFF0300        # 1 para leitura do GPs
.set CAR_Camera_trigger, 0xFFFF0301     # 1 para leitura da camera
.set CAR_Sensor_trigger, 0xFFFF0302     # 1 para leitura do sensor
.set CAR_Xangle_read, 0xFFFF0304        # ângulo X da leitura
.set CAR_Yangle_read, 0xFFFF0308        # ângulo Y da leitura
.set CAR_Zangle_read, 0xFFFF030c        # ângulo Z da leitura
.set CAR_Xpos_read, 0xFFFF0310          # posição X da leitura
.set CAR_Ypos_read, 0xFFFF0314          # posicção Y da leitura
.set CAR_Zpos_read, 0xFFFF0318          # posição Z da leitura
.set CAR_Sensor_read, 0xFFFF031c        # distância lida pelo sensor
.set CAR_Wheel_direction, 0xFFFF0320    # left: < 0; right: > 0
.set CAR_Engine, 0xFFFF0321             # direção do motor
.set CAR_handbrake, 0xFFFF0322          # handbreak: 1
.set CAR_Camera_read, 0xFFFF0324        # imagem lida pela câmera

# --- SERIAL PORT ---
.set SERIAL_Write_trigger, 0xFFFF0500   # 1 para escrita 
.set SERIAL_Write_byte, 0xFFFF0501      # byte a ser impresso
.set SERIAL_Read_trigger, 0xFFFF0502    # 1 para leitura
.set SERIAL_Read_byte, 0xFFFF0503       # byte lido
