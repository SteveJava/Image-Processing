.data 
    readname: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/sample_images/house_64_in_ascii_cr.ppm"
    writename: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testOutput.ppm"
    fileWords: .space 65000
    big_buffer: .space 65000
    small_buffer: .space 6
    newline: .asciiz "\n"
    result_string: .space 20
    result_msg_original: .asciiz "Average pixel value of the original image:\n"
    result_msg_new: .asciiz "Average pixel value of new image:\n"
.text
.globl main
main:

file_reading:
    #Open File
    li $v0, 13
    la $a0, readname
    li $a1, 0
    syscall
    move $s0, $v0

    #Read entire file
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    la $a2, 65000
    syscall

    #Close file
    li $v0, 16
    move $a0, $s0
    syscall

    move $t0, $a1             # t0 contains the pointer to the file in RAM
    la $t1, big_buffer        # t1 containts pointer to big buffer
    move $t2, $zero           # t2 stores the number of lines that have been read // counter
    la $t3, small_buffer      # t3 contains the pointer to the small buffer
    move $s2, $zero           # s2 stores the sum of pixel values
    move $s3, $zero           # s3 stores the sum of buffed pixel values
    
store_header:
    beq $t2, 19, end_store_header
    lb $t4, 0($t0)
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j store_header

end_store_header:

    move $t2, $zero     # t2 stores the number of lines that have been read

    li $t9, 10
    move $t6, $zero

#Handle all the other stuff
main_loop:

    beq $t6, 12288, end_main_loop

    lb $t4, 0($t0) #load byte from RAM
    sb $t4, 0($t3) #store byte in small buffer

    #DEBUGGING
    # li $v0, 11
    # move $a0, $t4 
    # syscall

    addi $t0, $t0, 1
    addi $t2, $t2, 1
    addi $t3, $t3, 1
    beq $t4, 13, pixel_processing

    j main_loop

pixel_processing:
    addi $t6, $t6, 1
    la $t3, small_buffer
     
end_store_small_buffer:
    li  $s5, 13
    li  $s4, 10
    li  $s7, 48
    la  $t3, small_buffer

convert_string_to_int:
    move $t8, $zero 

str_int_loop:
    lb  $s0, 0($t3)
    addi $t3, $t3, 1
    beq $s0, $s5, end_str_loop
    sub $s1, $s0, $s7
    mul $t8, $t8, $s4
    add $t8, $t8, $s1
    j   str_int_loop

end_str_loop:
    add $s2, $s2, $t8
    addi $t8, $t8, 10 # the integer result is stored in t8
    add $s3, $s3, $t8
    bge $t8, 255, clamp
    j dont_clamp

clamp:
    li $t8, 255
    j dont_clamp

dont_clamp:
 # Initialize variables
    la $a0, result_string   # Load the address of the result string
    li $a2, 10              # Load 10 (base 10)
    sb $zero, ($a0)         # Null-terminate the string
    addi $a0, $a0, 10       # Move to the end of the string

convert_loop:
    # Calculate the remainder (digit) and quotient
    div $t8, $a2            # Divide $t8 by 10
    mflo $s4                # Quotient goes to $s4
    mfhi $s5                # Remainder (digit) goes to $s5

    # Convert the digit to ASCII and store it in the string
    addi $s5, $s5, 48       # Convert to ASCII
    sb $s5, -1($a0)         # Store the digit in the string

    # Move to the next position in the string
    addi $a0, $a0, -1

    # Check if the quotient is zero (end of conversion)
    beqz $s4, end_convert

    # Otherwise, continue the loop
    move $t8, $s4
    j convert_loop

end_convert:
    # $a0 now points to the beginning of the string
    
    # li $v0, 4
    # syscall

    # la $a0, newline
    # li $v0, 4
    # syscall

    move $s7, $a0

add_to_big_buffer:
    
    lb $t8, 0($s7)
    beq $t8, $zero, end_add_to_big_buffer
    sb $t8, 0($t1)
    addi $s7, $s7, 1
    addi $t1, $t1, 1
    j add_to_big_buffer


end_add_to_big_buffer:
    lb $t8, newline
    sb $t8, 0($t1)
    addi $t1, $t1, 1
    la $t3, small_buffer   
    j main_loop 

end_main_loop:

write_big_buffer:

    li $v0, 13
    la $a0, writename
    li $a1, 1
    syscall
    move $s1, $v0

    li $v0, 15
    move $a0, $s1
    la $a1, big_buffer
    la $a2, 65000
    syscall

    li $v0, 16
    move $a0, $s1
    syscall

exit:

    mtc1 $s2, $f2
    mtc1 $s3, $f3
    mtc1 $t6, $f6 

    div.s $f5, $f2, $f6
    div.s $f7, $f3, $f6


    # Print the result for the original image 
    li $v0, 4
    la $a0, result_msg_original
    syscall

    li $v0, 2
    mov.s $f12, $f5  # Load the result into $f12 for printing
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    # Print the result for the new image 
    li $v0, 4
    la $a0, result_msg_new
    syscall

    li $v0, 2
    mov.s $f12, $f7  # Load the result into $f12 for printing
    syscall


    li $v0, 10            # System call code for program exit
    syscall