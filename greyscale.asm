.data 
    inputFile: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/sample_images/house_64_in_ascii_cr.ppm"
    outputFile: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testOutput.ppm"
    newLine: .asciiz "\n"
    fileWords: .space 65000
    bigBuffer: .space 65000
    smallBuffer: .space 6
    result_string: .space 20
.text
    .globl main
main:

    #Open input file to read
    li $v0, 13
    la $a0, inputFile
    li $a1, 0
    syscall
    move $s0, $v0

    #Read file contents
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    la $a2, 65000
    syscall

    #Close the input file
    li $v0, 16
    move $a0, $s0
    syscall

    #Initialise variables (registers) to be used
    move $t0, $a1                       # t0 will contatin a pointer to the fileWords in memory
    la $t1, bigBuffer                   # t1 contains a pointer to the bigBuffer in memory
    la $t3, smallBuffer                 # t3 contains a pointer to the smallBuffer in memory buffer
    move $t2, $zero                     # t2 will contain the number of bytes read from the inputFile
    move $s2, $zero                     # s2 will store the sum of the pixel values
    move $s3, $zero                     # s3 stores the sum of the brightened pixel values
    li $t7, 19                          # reserve a space of 19 in memory
    
get_header:
    # store the header, i.e. first 4 lines of the file                 
    beq $t2, 19, end_get_header
    beq $t2, 1, change_p                # jump to change_p to change from p3 to p2
    lb $t4, 0($t0)
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j get_header

change_p:                               # change 3 to 2 in second byte to change file to a greyscale file
    lb $t4, 0($t0)
    li $t5, 50
    sb $t5, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j get_header

end_get_header:

    move $t2, $zero                     # t2 stores the number of lines that have been read
    move $t9, $zero                     # t9 stores the number of pixels that have been summed
    move $s6, $zero                     # 6 stores the current running total of the pixels
    move $t6, $zero

main_loop:
    beq $t6, 12288, end_main_loop

    lb $t4, 0($t0)                      #load byte from bigBuffer (RAM)
    sb $t4, 0($t3)                      #store byte from bigBuffer in smallBuffer

    addi $t0, $t0, 1                    # increment position of fileWords
    addi $t2, $t2, 1                    # incrememnt the counter 
    addi $t3, $t3, 1                    # incrememnt pointer to the small buffer
    beq $t4, 13, pixel_manipulation     # if t4 = 13 (end of line) go to pixel_manipulation

    j main_loop

pixel_manipulation:
    addi $t6, $t6, 1                    # increment t6 by 1
    la $t3, smallBuffer                 # load smallBuffer address into t3
     
end_store_smallBuffer:
    # Initialize constant values             
    li  $s5, 13
    li $s4, 10  
    li  $s7, 48
    la  $t3, smallBuffer                # load smallBuffer address into t3

start_convert_string_to_int:              
    move $t8, $zero                     # initialize t8 to zero

str_to_int_loop:
    lb  $s0, 0($t3)
    addi $t3, $t3, 1
    beq $s0, $s5, end_str_to_int_loop
    sub $s1, $s0, $s7
    mul $t8, $t8, $s4
    add $t8, $t8, $s1
    j   str_to_int_loop

end_str_to_int_loop:    
    add $s6, $s6, $t8       
    addi $t9, $t9, 1        
    bne $t9, 3, reset  
    j find_average

reset:
    la $t3, smallBuffer                 # load smallBuffer address into t3
    j main_loop

find_average:
    move $t9, $zero                     # average stored here

    div $s3, $s6, 3
    move $s6, $zero
    mflo $t8
    
   # Initialize variables (registers) to be used
    la $a0, result_string   
    li $a2, 10              
    sb $zero, ($a0)                     # Null-terminate the string
    addi $a0, $a0, 10                   # Move to the end of the string

convert_loop:
    # Calculate the quotient and remainder
    div $t8, $a2                        # Divide $t8 by 10
    mflo $s4                            # quotient result gets stored in s4
    mfhi $s5                            # remainder of quotient gets stored in s5

    # Convert integer back to ASCII
    addi $s5, $s5, 48       
    sb $s5, -1($a0)                     # Store the ASCII value in the string

    # Move to next position in the string
    addi $a0, $a0, -1

    # Check if the quotient is zero - this marks the end of the conversion from integer to string
    beqz $s4, end_conversion

    # Otherwise, continue the loop
    move $t8, $s4
    j convert_loop

end_conversion:
    move $s7, $a0

add_to_big_buffer:
    lb $t8, 0($s7)                          
    beq $t8, $zero, end_add_to_big_buffer   
    sb $t8, 0($t1)                          
    addi $s7, $s7, 1                        
    addi $t1, $t1, 1                        
    addi $t7, $t7, 1
    j add_to_big_buffer


end_add_to_big_buffer:
    lb $t8, newLine                         
    sb $t8, 0($t1)                          
    addi $t1, $t1, 1                        
    addi $t7, $t7, 1
    la $t3, smallBuffer                    
    j main_loop 

end_main_loop:                             

write_to_outputFile:

    # Open output file
    li $v0, 13                              
    la $a0, outputFile
    li $a1, 1
    syscall
    move $s1, $v0

    # Write to output file
    li $v0, 15                               
    move $a0, $s1
    la $a1, bigBuffer
    move $a2, $t7                            
    syscall

    # Close output file
    li $v0, 16                               
    move $a0, $s1
    syscall

exit:
    li $v0, 10            
    syscall