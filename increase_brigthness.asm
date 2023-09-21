.data
    toWrite: .asciiz "Hello World was here"
    fileName: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/sample_images/house_64_in_ascii_cr.ppm"
    fileWords: .space 47435

.text
main:
    # Open the file
    li $v0, 13          # open file syscall code = 13
    la $a0, fileName    # get the file name
    li $a1, 0           # file_flag = read (0)
    syscall
    move $s0, $v0       # save the file descriptor $s0 = file

    # Read the file
    li $v0, 14          # read_file syscall code = 14
    move $a0, $s0       # file descriptor - identify which file is being read
    la $a1, fileWords   # The buffer that holds the string of the whole file
    la $a2, 1024        # hardcoded buffer length
    syscall

    # Print out what's in the file
    li $v0, 4           # read_string syscall code = 4
    la $a0, fileWords
    syscall

    # Close the file
    li $v0, 16          # close_file syscall code
    move $a0, $s0
    syscall

.exit:
    li $v0, 10
    syscall