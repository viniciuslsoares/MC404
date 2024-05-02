.text


main_isr:
    csrrw sp, mscratch, sp      # Troca sp com mscratch
    addi sp, sp, -16
    sw t1, (sp)
    sw t2, 4(sp)

    la t1, GPT
    li t2, 1
    sb t2, (t1)

    1:
        lb t2, (t1)
        bnez t2, 1b

    lw t2, 4(t1)
    la t1, _system_time
    sw t2, (t1)

    li t2, 100
    la t1, GPT
    sw t2, 8(t1)

    lw t2, 4(sp)
    lw t1, (sp)
    addi sp, sp, 16
    csrrw sp, mscratch, sp          # Troca sp com mscratch novamente
mret

.globl play_note

play_note:          # a0: ch; a1: inst; a2: note; a3: vel; a4: duration
   
    la t1, MIDI

    #inst
    sh a1, 2(t1)

    #note
    sb a2, 4(t1)

    #vel
    sb a3, 5(t1)

    #dur
    sh a4, 6(t1)

    #trigger
    sb a0, (t1)

ret


exit:
    li a0, 0
    li a7, 93
ret

.globl _start
.globl main

_start:
    la t0, isr_stack_end        # t0 <= base da pilha
    csrw mscratch, t0           # mscratch <= t0

    csrr t1, mie
    li t2, 0x800                # seta o bit 11 (mie.MEIE)
    or t1, t1, t2               # interrupção externa
    csrw mie, t1

    csrr t1, mstatus            # seta o bit 3 (mstatus.MIE)
    ori t1, t1, 0x8             # interrupções globais
    csrw mstatus, t1

    la t0, GPT
    li t1, 100
    sw t1, 8(t0)

    la t0, main_isr             # endereç da main isr
    csrw mtvec, t0              # em mtvec

    jal main


jal exit


.data 


.globl _system_time
_system_time:   .word 0

.set GPT, 0xFFFF0100

.set MIDI, 0xFFFF0300


.bss    
isr_stack:                      # Final da pilha ISR
.skip   200
isr_stack_end:                  # Base da pilha ISR
