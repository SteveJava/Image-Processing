.data
    inputFile: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/sample_images/house_64_in_ascii_cr.ppm"
    outputFile: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testOutput.ppm"
    fileWords: .space 47435
    bigBuffer: .space 47435
    smallBuffer: .space 6
    newLine: .asciiz "\n"
    resultString: .space 20
    resultMsgOriginal: .asciiz "Average pixel value of the original image: \n"
    resultMsgNew: .asciiz "Average pixel value of new image: \n"

.text
    .globl main
main:
    open:
        # Open input file to read
        li $v0,13           	# open_file syscall code = 13
        la $a0,inputFile     	# get the file name
        li $a1,0           	    # file flag = read (0)
        syscall
        move $s0,$v0        	# save the file descriptor. $s0 = file

    read:
        # Read the file contents 
        li $v0, 14		        # read_file syscall code = 14
        move $a0,$s0		    # file descriptor
        la $a1, fileWords    	# The buffer that holds the string of the WHOLE file
        la $a2,47435		    # hardcoded buffer length
        syscall

    close_inputFile:
        li $v0, 16              # close_file syscall code = 16
        move $a0, $s0           # file descriptor
        syscall
    
    get_pointers:
        move $t0, $a1           # t0 will contatin a pointer to the fileWords in memory
        la $t1, bigBuffer       # t1 contains a pointer to the bigBuffer in memory
        move $t2, $zero         # t2 acts as a  counter variable by storing the number of lines that have been read
        la $t3, smallBuffer     # t3 contains a pointer to the smallBuffer in memory
        move $s2, $zero         # s2 will store the sum of the pixel values
        move $s3, $zero         # s3 stores the sum of the brightened pixel values

    store_header:
        # store the header, i.e. first 3 lines of the file
        beq $t2, 19, end_store_header   # check if value in t2 (0 initially) is greater than 19 (number of characers in first 3 lines)
        lb $t4, 0($t0)          # load one byte from fileWords
        sb $t4, 0($t1)          # store one byte from fileWords
        addi $t1, $t1, 1        # increment the bigBuffer
        addi $t0, $t0, 1        # increment position of fileWords, i.e. go to next byte in file
        addi $t2, $t2, 1        # increment the counter
        j store_header
    
    end_store_header:
        move $t2, $zero         # t2 stores the number of lines that have been read
        li $t9, 10              # 10 is stored in t9
        move $t6, $zero         # initialize t6 to 0
    
    main_loop:
        beq $t6, 12288, end_main_loop   # if t6 is equal to 12288 --> exit the loop

        lb $t4, 0($t0)          # load byte from bigBuffer (RAM)
        sb $t4, 0($t3)          # store byte from bigBuffer in smallBuffer

        addi $t0, $t0, 1        # increment position of fileWords
        addi $t2, $t2, 1        # increment the counter
        addi $t3, $t3, 1        # increment the bigBuffer
        beq $t4, 13, pixel_processing       # if??????

        j main_loop             # jump back to main_loop label

    pixel_processing:
        addi $t6, $t6, 1        # increment t6 by 1
        la $t3, smallBuffer     # load smallBuffer address into t3

    end_store_small_buffer:
        li $s5, 13              # s5 = 13
        li $s4, 10              # s4 = 10
        li $s7, 48              # s7 = 48
        la $t3, smallBuffer     # load smallBuffer address into t3
    
    convert_string_to_int:
        move $t8, $zero         # intitialize t8 to zero

        str_int_loop:
            lb $s0, 0($t3)      # load bite from smallBuffer to 20
            addi $t3, $t3, 1    # increment bigBuffer by 1
            beq $s0, $s5, end_str_loop      # if smallBuffer == 13, jump to end_str_loop
            sub $s1, $s0, $s7   # subtract to get integer value
            mul $t8, $t8, $s4   # multply s4 by t8
            j str_int_loop
        
        end_str_loop:
            add $s2, $s2, $t8   # add t8 to s2
            addi $t8, $t8, 10   # converted integer stored in t8
            add $s3, $s3, $t8   # add t8 (integer) to s3
            bge $t8, 255, clamp # if t8 == 255 (max pixel value) --> jump to clamp
            j dont_clamp
        
        clamp:
            li $t8, 255             # hardcode t8 to 255, since max pixel value was reached
            j dont_clamp
        
        dont_clamp:
            # Define variables 
            la $a0, resultString   # load address of the result string
            li $a2, 10              # set value of a2 to 10
            sb $zero, ($a0)         # store value 0 in resultString
            addi $a0, $a0, 10       # increment string to move to the end of the string
        
        convert_loop:
            # Calculate the quotient and remainder
            div $t8, $a2            # divide t8 by 10
            mflo $s4                # quotient result gets stored in s4
            mfhi $s5                # remainder of quotient gets stored in s5

            # Convert integer back to ASCII
            addi $s5, $s5, 48       # set s5 = 48
            sb $s5, 1($a0)         # Store the ASCII value in the string

            # Move to next position in string
            addi $a0, $a0, -1

            # Check is the quotient is zero (end of conversion)
            beqz $s4, end_convert

            # Otherwise, continue loop
            move $t8, $s4
            j convert_loop
        
        end_convert:
            # a0 now points to the beginning of the string

            # li $v0, 4
            # syscall
            
            # la $a0, newLine
            # li v0, 4
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
            lb $t8, newLine
            sb $t8, 0($t1)
            addi $t1, $t1, 1
            la $t3, smallBuffer
            j main_loop
        
    end_main_loop:

        write_big_buffer:
            li $v0, 13          # set v0 = 13
            la $a0, outputFile  # load address of output file
            li $a1, 1           # set file to write using code 1
            syscall
            move $s1, $v0

            li $v0, 15          # set v0 = 15
            move $a0, $s1       
            la $a1, bigBuffer   
            la $a2, 65000
            syscall

            li $v0, 16
            move $a0, $s1
            syscall

.exit:
    mtc1 $s2, $f2
    mtc1 $s3, $f3
    mtc1 $t6, $f6 

    div.s $f5, $f2, $f6
    div.s $f7, $f3, $f6


    # Print the result for the original image 
    li $v0, 4
    la $a0, resultMsgOriginal
    syscall

    li $v0, 2
    mov.s $f12, $f5  # Load the result into $f12 for printing
    syscall

    la $a0, newLine
    li $v0, 4
    syscall

    # Print the result for the new image 
    li $v0, 4
    la $a0, resultMsgNew
    syscall

    li $v0, 2
    mov.s $f12, $f7  # Load the result into $f12 for printing
    syscall

    li $v0, 10
    syscall