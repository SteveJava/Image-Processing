.data
    inputFileName:      .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testInput"
    outputFileName:     .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testOutput"
    buffer:             .space 128   # Assuming lines are not longer than 128 characters
    lineNumber:         .word 0

.text
    .globl main
main:
    # Open the input file for reading
    li $v0, 13             # syscall code for open file (13)
    la $a0, inputFileName  # load the input file name
    li $a1, 0              # open the file for reading (0)
    li $a2, 0              # file permissions (ignored)
    syscall
    move $s0, $v0          # store the file descriptor in $s0

    # Open the output file for writing
    li $v0, 13              # syscall code for open file (13)
    la $a0, outputFileName  # load the output file name
    li $a1, 1               # open the file for writing (1)
    li $a2, 0               # file permissions (ignored)
    syscall
    move $s1, $v0           # store the file descriptor in $s1

    # Initialize line counter
    li $t0, 0

read_loop:
    # Read a line from the input file
    li $v0, 14              # syscall code for read file (14)
    move $a0, $s0           # file descriptor of input file
    la $a1, buffer          # buffer to store the line
    li $a2, 128             # maximum line length (adjust as needed)
    syscall

    # Check if EOF (End of File)
    # beqz $v0, done

    # Convert the line (string) to an integer
    li $v0, 5               # syscall code for read integer (5)
    la $a0, buffer          # buffer containing the line
    syscall
    move $t1, $v0           # store the integer in $t1

    # Increment the line counter
    addi $t0, $t0, 1

    # Check if we are beyond the first 3 lines
    li $t2, 3               # Number of lines to skip
    bge $t0, $t2, process_line

    # Write the line to the output file as is (skip incrementing)
    li $v0, 4               # syscall code for print string (4)
    move $a0, $s1           # file descriptor of output file
    la $a1, buffer          # buffer containing the line
    syscall

    j read_loop

process_line:
    # Increment the integer by 10
    addi $t1, $t1, 10

    # Convert the integer back to a string
    li $v0, 10              # syscall code for print integer (10)
    move $a0, $t1           # integer to print
    syscall

    # Write the updated integer as a string to the output file
    li $v0, 4               # syscall code for print string (4)
    move $a0, $s1           # file descriptor of output file
    la $a1, buffer          # buffer containing the updated integer
    syscall

    j read_loop

done:
    # Close the input file
    li $v0, 16              # syscall code for close file (16)
    move $a0, $s0           # file descriptor of input file
    syscall

    # Close the output file
    li $v0, 16              # syscall code for close file (16)
    move $a0, $s1           # file descriptor of output file
    syscall

    # Exit the program
    li $v0, 10              # syscall code for exit (10)
    syscall
