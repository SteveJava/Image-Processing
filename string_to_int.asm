.data
    input_prompt:     .asciiz "Enter a string (first character =):\n"
    output_message:   .asciiz "The result is:\n"
    string: .space 40
.text
.globl main

main:
    move    $s7, $zero
    li      $v0, 4          #Prompt
    la		$a0, input_prompt
    syscall

    li  $v0, 8
    la  $a0, string
    li  $a1, 40
    syscall

    move $t4, $zero
    li  $t5, 10
    li  $t7, 48
    la  $t0, string
    addi  $t0, $t0, 1

start_loop:
    move $t6, $zero 

loop:
    lb  $s0, 0($t0)
    addi $t0, $t0, 1
    beq $s0, $t5, end_loop
    sub $s1, $s0, $t7
    mul $t6, $t6, $t5
    add $t6, $t6, $s1
    j   loop

end_loop:
    addi $t6, $t6, 1

    la      $a0, output_message
    li      $v0, 4
    syscall

    li  $v0, 1
    move $a0, $t6
    syscall

exit:
    li   $v0, 10
    syscall
