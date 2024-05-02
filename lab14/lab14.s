.text
.globl user_main

int_handler:
  ###### Syscall and Interrupts handler ######
  csrrw sp, mscratch, sp
  addi sp, sp, -16
  sw a7, (sp)
  sw t0, 4(sp)

  li t0, 10
  beq a7, t0, 10f             # syscall 10

  li t0, 11
  beq a7, t0, 11f             # syscall 11

  10: 
    li t0, -127
    blt a1, t0, 1f            # a1 < -127

    li t0, 127
    bgt a1, t0, 1f            # a1 > 127

    li t0, -1
    blt a0, t0, 1f            # a0 < -1

    li t0, 1
    bgt a0, t0, 1f            # a0 > -1

    la t0, CAR_engine
    sb a0, (t0)

    la t0, CAR_wheel
    sb a1, (t0)

    li a0, 0                  # retorno de valores válidos
    j 2f

    1:                        # retorno de erro
      li a0, -1               # parâmetros inválidos
      j 2f

  11:
    la t0, CAR_handbreak
    sb a0, (t0)
    j 2f



  2:
  csrr t0, mepc               # carrega o endereço de retorno
  addi t0, t0, 4              
  csrw mepc, t0               # soma 4 e guarda o endereço novamente
  
  lw t0, 4(sp)
  lw a7, (sp)
  addi sp, sp, 16
  csrrw sp, mscratch, sp
mret                          
  

.globl _start
_start:

  la t0, int_handler          # endereço da main_isr
  csrw mtvec, t0              # mtvec <= t0
  
  la t0, isr_stack_end        # t0 <= base da pilha
  csrw mscratch, t0           # mscratch <= t0

  csrr t1, mstatus            # seta o bit 3 (mstatus.MIE)
  ori t1, t1, 0x8             # interrupções globais
  csrw mstatus, t1            # mstatus.MIE <= t1

  csrr t1, mstatus            # seta o bit 7 (mstatus.MPIE)
  ori t1, t1, 0x40            
  csrw mstatus, t1            # mstatus.MPIE <= t1
  
  csrr t1, mstatus            # muda o modo de operação
  li t2, ~0x1800              # para usuário
  and t1, t1, t2              # do campo mstatus.MPP
  csrw mstatus, t1

  la t0, user_main            # carrega o endereço de entrada
  csrw mepc, t0               # no mepc
  
  mret                        # PC <= mepc; mode <= MPP; MIE <= MPIE

jal exit

exit:
  li a0, 0
  li a7, 93
  ecall



# Write here the code to change to user mode and call the function 
# user_main (defined in another file). Remember to initialize
# the user stack so that your program can use it.

.globl control_logic
control_logic:
  # implement your control logic here, using only the defined syscalls


  li a0, 0                            # desliga o freio de mão
  li a7, 11
  ecall

  li a0, 1
  li a1, 0
  li a7, 10
  ecall                               # acelera reto

  li t1, 40000                        # tempo de espera
  1:
    addi t1, t1, -1
    bnez t1, 1b


  li a0, 1
  li a1, -117
  li a7, 10
  ecall                               # acelera virando para esquerda

  li t1, 20000
  3:
    addi t1, t1, -1
    bnez t1, 3b

  li a0, 1
  li a1, 0
  li a7, 10
  ecall                               # acelere reto

  li t1, 25000
  4:
    addi t1, t1, -1
    bnez t1, 4b

  li a0, 0
  li a1, 0
  li a7, 10
  ecall                               # inércia reto

  li t1, 30000
  5:
    addi t1, t1, -1
    bnez t1, 5b

  li a0, 1
  li a7, 11
  ecall                               # puxa o freio de mão
  

ret


.data
.set CAR_engine, 0xFFFF0121           # base + 0x21
.set CAR_wheel, 0xFFFF0120            # base + 0x20
.set CAR_handbreak, 0xFFFF0122        # base + 0x22


.bss    
isr_stack:                      # Final da pilha ISR
.skip   200
isr_stack_end:                  # Base da pilha ISR




