#ADMSHA064
#23 September 2023
.data 
    readname: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/sample_images/house_64_in_ascii_cr.ppm"
    writename: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testOutput.ppm"
    fileWords: .space 65000
    big_buffer: .space 65000
    small_buffer: .space 6
    newline: .asciiz "\n"
    result_string: .space 20
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
    move $t2, $zero           # t2 stores the number of lines that have been read
    la $t3, small_buffer      # t3 contains the pointer to the small buffer
    move $s2, $zero           # s2 stores the sum of pixel values
    move $s3, $zero           # s2 stores the sum of buffed pixel values
    li $t7, 19
    
store_header:                 # store header into the big buffer  
    beq $t2, 19, end_store_header
    beq $t2, 1, fix_p
    lb $t4, 0($t0)
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j store_header

fix_p:                         # at the second byte, change the 3 to a 2 to make the file a grayscale image
    lb $t4, 0($t0)
    li $t5, 50
    sb $t5, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j store_header

end_store_header:

    move $t2, $zero     # t2 stores the number of lines that have been read
    move $t9, $zero     # t9 stores the number of pixels that have been summed
    move $s6, $zero     # 6 stores the current running total of the pixels
    move $t6, $zero

#Handle all the other shit
main_loop:

    beq $t6, 12288, end_main_loop

    lb $t4, 0($t0) #load byte from RAM
    sb $t4, 0($t3) #store byte in small buffer

    #DEBUGGING
    # li $v0, 11
    # move $a0, $t4 
    # syscall

    addi $t0, $t0, 1                 # incrememnt the pointer to the file in memory
    addi $t2, $t2, 1                 # incrememnt the counter for number of lines read
    addi $t3, $t3, 1                 # incrememnt pointer to the small buffer
    beq $t4, 13, pixel_processing    # process the pixel, finally storing it in the big buffer

    j main_loop

pixel_processing:
    addi $t6, $t6, 1                # increment the number of lines stores
    la $t3, small_buffer            # reset the pointer to the small buffer
     
end_store_small_buffer:             # loading constants here
    li  $s5, 13
    li $s4, 10  
    li  $s7, 48
    la  $t3, small_buffer           # resetting the pointer to the small

convert_string_to_int:              # convert the string into an integer in this block and the following block str_int_loop
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

# logic here to check if 3 numbers have accumulated. if so, calculate average. store into t8. then continue as normal
    
    add $s6, $s6, $t8       #add to running total
    addi $t9, $t9, 1        #incrememnt the number of pixels we've added together

    bne $t9, 3, cleanup_before_main   #if we havent summed up 3 yet, continue summing
    j average

cleanup_before_main:

    la $t3, small_buffer        # reset small buffer pointer
    j main_loop

average:
    move $t9, $zero             # calculating the average in this block

    div $s3, $s6, 3
    move $s6, $zero
    mflo $t8
    
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
    
 #DEBUGGING    
    # li $v0, 4
    # syscall

    # la $a0, newline
    # li $v0, 4
    # syscall
 #
    move $s7, $a0

add_to_big_buffer:

    lb $t8, 0($s7)                          #load byte from small buffer
    beq $t8, $zero, end_add_to_big_buffer   #branch if reached end of small buffer  
    sb $t8, 0($t1)                          #store byte in big buffer
    addi $s7, $s7, 1                        #increment pointer to the the string containing the string to write
    addi $t1, $t1, 1                        #increment pointer to the big buffer
    addi $t7, $t7, 1
    j add_to_big_buffer


end_add_to_big_buffer:
    lb $t8, newline                         #load a newline into register t8
    sb $t8, 0($t1)                          #write newline to buffer
    addi $t1, $t1, 1                        #increment pointer to the big buffer
    addi $t7, $t7, 1
    la $t3, small_buffer                    #reset the pointer to the small buffer for the next write-read cyce
    j main_loop 

end_main_loop:                              #end of the main loop. its not that deep

write_big_buffer:

    li $v0, 13                               # open file in write mode
    la $a0, writename
    li $a1, 1
    syscall
    move $s1, $v0

    li $v0, 15                               # write contents of big buffer to the file
    move $a0, $s1
    la $a1, big_buffer
    move $a2, $t7                            # specify how many bytes to write to the file
    syscall

    li $v0, 16                               # close the file 
    move $a0, $s1
    syscall

exit:

    li $v0, 10            # System call code for program exit
    syscall