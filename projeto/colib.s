.text

.globl set_engine
set_engine:

    /*
    Define values to vertical and horizontal movement of the car.
    Parameters: 
    * vertical:   a byte that defines the vertical movement of the car, between -1 and 1.
                    -1 makes the car go backwards and 1 forward. (Engine)
    * horizontal: defines the vertical movement of the car, between -127 and 127
                    Negative values make the car go to the left and positive to the right. (Steering Wheel)
    Returns:
    * 0 in case of a success.
    * -1 if any of the parameters are out of bounds.
    */

    addi sp, sp, -4
    sw ra, (sp)

    li a7, 10
    ecall

    lw ra, (sp)
    addi sp, sp, 4 
ret

.globl set_handbrake
set_handbrake:

    /*
    Set the handbrake of the car
    Parameters:
    * value:  a byte that defines if the brake will be triggered or not.
                1 to trigger the brake e 0 to stop using it.
    Returns:
    * 0 in case of success.
    * -1 if the value parameter is invalid.
    */

    addi sp, sp, -4
    sw ra, (sp)

    bltz a0, 1f                 # checa se menor que zero
    li t0, 1    
    bgt a0, t0, 1f              # checa se maior que 1

    li a7, 11
    ecall
    li a0, 0
    j 2f

    1:
    li a0, -1                   # parâmetros inválidos

    2:
    lw ra, (sp)
    addi sp, sp, 4 
ret

.globl read_sensors_distance
read_sensors_distance:

    /*
    Reads distnace from the ultrasonic sensor
    Parameters: 
        None
    Returns: 
        * the distance detected by the sensor, in cetimeters, if an object is detected.
        * -1, if no object is detected.
    */

    addi sp, sp, -4
    sw ra, (sp)

    li a7, 13
    ecall

    lw ra, (sp)
    addi sp, sp, 4 
ret

.globl get_position
get_position:

    /*
    Reads the approximate position of the car using a GPS device
    Parameters:
    * x: address of the variable that will store the value of the x position.
    * y: address of the variable that will store the value of the y position.
    * z: address of the variable that will store the value of the z position.
    Returns:
        Nothing
    */

    addi sp, sp, -4
    sw ra, (sp)

    li a7, 15
    ecall

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl get_rotation
get_rotation:

    /*
    Reads the global rotation of the gyroscope device
    Parameters:
    * x: address of the variable that will store the value of the Euler angle in x.
    * y: address of the variable that will store the value of the Euler angle in y.
    * z: address of the variable that will store the value of the Euler angle in z.
    Returns:
        Nothing
    */

    addi sp, sp, -4
    sw ra, (sp)

    li a7, 16
    ecall

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl get_time
get_time:

    /*
    Reads system time
    Parameters:
        None
    Returns:
        System time, in milliseconds.
    */

    addi sp, sp, -4
    sw ra, (sp)

    li a7, 20
    ecall

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl puts
puts:

    /*
    puts function from https://www.cplusplus.com/reference/cstdio/puts/ but in this 
    case it must use the Serial Port peripheral to perform writes.
    It prints a \n instead of the ending \0.
    Parameters:
        * str: string terminated in \0.
    Returns:
        Nothing
    */

    addi sp, sp, -4
    sw ra, (sp)

    mv t6, zero             # atua como flag
    mv t0, a0

    1:
    mv a0, t0
    li a1, 1
    li a7, 18
    lb t1, (a0)
    bnez t1, 2f             # testa se \0
    li t6, 1                # flag indicando ser o último byte

    2:
    ecall
    addi t0, t0, 1          # próx char
    beqz t6, 1b
    
    3:
    lw ra, (sp)
    addi sp, sp, 4

ret

.globl gets
gets:

    /*
    gets function from https://www.cplusplus.com/reference/cstdio/gets/ but in this 
    case it must use the Serial Port perifpheral to perform reads.
    Parameters:
        * str: Buffer to be filled.
    Returns:
        Filled buffer with a \0 terminated string.
    */

    addi sp, sp, -4
    sw ra, (sp)

    mv t6, a0
    mv t0, a0
    li a1, 1                    # imprime um char por vez
    li a7, 17

    1:
    mv a0, t0                   # guarda o end original
    ecall
    teste3:
    lbu t1, (t0)                # char que foi lido
    addi t0, t0, 1              # prox char
    bnez t1, 1b                 # desvia se não guardou nada

    mv a0, t6

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl atoi
atoi:

    /*
    atoi function from https://www.cplusplus.com/reference/cstdlib/atoi/?kw=atoi 
    Parameters:
        * str: \0 terminated string of the decimal representation of a number.
    Returns:
        The integer value represented by the string.
    */
    addi sp, sp, -4
    sw ra, (sp)

    mv t0, a0
    li t1, ' '          # espaço em branco para comparação
    1:                  # laço ignora os primeiros espaços
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

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl itoa
itoa:

    /*
    itoa function from https://www.cplusplus.com/reference/cstdlib/itoa/ 
    Parameters:
        * value: integer value to be converted.
        * str: Buffer to be filled with \0 terminated string of the representation of the number.
        * base: base to use, either 10 or 16.
    Returns:
        Filled butter with a \0 terminated string.
    */

    addi sp, sp, -4
    sw ra, (sp)
    

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

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl strlen_custom
strlen_custom:

    /*
    Custom implementation of the strlen function from https://cplusplus.com/reference/cstring/strlen/ 
    Parameters:
        * str: String terminated by \0
    Returns:
        Size of the string without counting the \0
    */

    addi sp, sp, -4
    sw ra, (sp)

    mv t1, zero

    1:
    lb t0, (a0)
    beqz t0, 2f
    addi a0, a0, 1
    addi t1, t1, 1
    j 1b

    2:
    mv a0, t1

    lw ra, (sp)
    addi sp, sp, 4
ret

.globl approx_sqrt
approx_sqrt:

    /*
    Approximate Square Root computation using the Babylonian Method.
    Parameters:
        * value: integer value
        * iterations: number of iterations to perform the Babylonian method
    Returns:
        Approximate square root of value.
    */

    addi sp, sp, -4
    sw ra, (sp)

    li t3, 2
    div t2, a0, t3

    1:
        addi a1, a1, -1
        div t4, a0, t2
        add t4, t4, t2
        div t4, t4, t3
        mv t2, t4
        bnez a1, 1b

    mv a0, t4

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl get_distance
get_distance:

    /*
    Euclidean Distance between two points, A and B, in a 3D space.
    Parameters:
        * x_a: X coordinate of point A.
        * y_a: Y coordinate of point A.
        * z_a: Z coordinate of point A.
        * x_b: X coordinate of point B.
        * y_b: Y coordinate of point B.
        * z_b: Z coordinate of point B.
    Returns:
        Euclidean distance between the two points.
    */

    addi sp, sp, -4
    sw ra, (sp)

    sub a0, a0, a3
    mul a0, a0, a0

    sub a1, a1, a4
    mul a1, a1, a1

    sub a2, a2, a5
    mul a2, a2, a2

    add a0, a0, a1
    add a0, a0, a2

    li a1, 15

    jal approx_sqrt

    lw ra, (sp)
    addi sp, sp, 4

ret

.globl fill_and_pop
fill_and_pop:

    /*
    It copies all fields from the head node to the fill node and 
    returns the next node on the linked list (head->next).
    Parameters:
        * head: current head of the linked list
        * fill: node struct to be filled with values from the current head node. 
    Returns:
        Next node on the linked list.
    */

    addi sp, sp, -4
    sw ra, (sp)

    lw t0, (a0)             # int x
    sw t0, (a1)

    lw t0, 4(a0)            # int y
    sw t0, 4(a1)

    lw t0, 8(a0)            # int z
    sw t0, 8(a1)        

    lw t0, 12(a0)           # a_x
    sw t0, 12(a1)

    lw t0, 16(a0)           # a_y
    sw t0, 16(a1)

    lw t0, 20(a0)           # a_z
    sw t0, 20(a1)

    lw t0, 24(a0)           # action
    sw t0, 24(a1)

    lw a0, 28(a0)           # *next
    sw a0, 28(a1)

    lw ra, (sp)
    addi sp, sp, 4

ret