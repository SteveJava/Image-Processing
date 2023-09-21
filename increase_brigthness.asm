.data
    fileToWrite: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/sample_images/house_64_in_ascii_cr.ppm"
    fileName: .asciiz "/Users/zakwan/Desktop/computerScience/csc2002s/mips/assignments/mips_1/testWriteFile"
    fileWords: .space 47435

.text
main:
    # Open the file to write to
    li $v0,13           # open_file syscall code = 13
    la $a0,fileName     # get the file name
    li $a1,1           	# file flag = write (1)
    syscall
    move $s1,$v0        # save the file descriptor. $s0 = file

    # Open the file to write
    li $v0,13           	# open_file syscall code = 13
    la $a0,fileToWrite     	# get the file name
    li $a1,0           	# file flag = read (0)
    syscall
    move $s0,$v0        	# save the file descriptor. $s0 = file
	
	#read the file contents
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1,fileWords  	# The buffer that holds the string of the WHOLE file
	la $a2,1024		# hardcoded buffer length
	syscall 

    #Write to the file
    li $v0,15		    # write_file syscall code = 15
    move $a0,$s1		# file descriptor
    la $a1,fileWords	# the string that will be written
    la $a2,47435		# length of the fileWords string
    syscall

    # Close the file
    li $v0, 16          # close_file syscall code
    move $a0, $s0
    syscall

.exit:
    li $v0, 10
    syscall