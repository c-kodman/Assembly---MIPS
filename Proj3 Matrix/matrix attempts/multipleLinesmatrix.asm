.data
	colArray:	.space 216
	colorArray:	.word    0x002200,0x003300,0x004400,0x005500,0x006600, 0x007700, 0x008800, 0x009900, 0x00AA00, 0x00BB00, 0x00CC00, 0x00DD00, 0x00EE00, 0x00FF00
	

.text
	
	addi $t8, $zero, 0x00001100	#t8 is used for subtraction of green colors in column
	jal _fillScreen
cont:	jal _column
	
	j cont

	addi $v0, $zero, 10	#stops the program
	syscall
	
	
	
_fillScreen:
	# Func enter
	addi $sp, $sp, -24
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $ra, 20($sp)
#a0 has random number in it
#s0 has location of first register in upper left corner of terminal screen.  This will be pushed by 4 to move across screen
#s1 hold dark green color for each character as of now
#s2- what the terminal is expecting...ascii and color
	li 	$s0, 0xffff8000	# first address of upper left hand of screen.
	li	$s1, 0x002200 	#dark green...later you will make bright green	

# Gets a number such that 33 <= x < 126, puts it in $a0.  Represents
# ASCII character
getNumber:
	addi $v0, $zero, 30
	syscall	
	add $a1, $zero, $a0
	addi $v0, $zero, 42 	# Syscall 42: Random int range
	add $a0, $zero, $zero	# Set RNG ID to 0
	addi $a1, $zero, 126 	# Set upper bound to 10 (exclusive)
	syscall 		# Generate a random number and put it in $a0
	#add $s1, $zero, $a0 	# Copy the random number to $s1
	blt $a0, 33, getNumber
	
	
	
	
placeLetter:	
	
	sll 	$a0, $a0, 24 	#pushes random number representing ascii far left
	or 	$s2, $s1, $a0	#combines the color with the letter	
	sw	$s2, 0($s0)	#puts colored letter into address location
	addi	$s0, $s0, 4	#increments address location to allow for new place for letter
	blt 	$s0, 0xffffb200, getNumber  #keeps looping till screen is full
	
# Once we get here, we've fully filled the screen with random dark characters
	
	# Func exit
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	jr $ra 
	
_column:
	# Func header
	
	addi $sp, $sp, -24
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $ra, 20($sp)

#a0 has random number in it
#s0 has location of first register in upper left corner of terminal screen.  This will be pushed by 4 to move across screen
#s1 hold dark green color for each character as of now
#s2- what the terminal is expecting...ascii and color
	add $t2, $zero, $zero
	li  $s0, 0xffff8000	# first address of upper left hand of screen.
	li  $s1, 0x0000ff00     #bright green...later you will make dull green	
	
getRandom:
	addi $v0, $zero, 30
	syscall	
	add $a1, $zero, $a0
	addi $v0, $zero, 42 	# Syscall 42: Random int range
	add $a0, $zero, $zero	# Set RNG ID to 0
	addi $a1, $zero, 80 	# Set upper bound to 80 (exclusive)
	syscall 		# Generate a random number and put it in $a0
	#add $s1, $zero, $a0 	# Copy the random number to $s1
	#bgt $a0, 79, getRandom
	beq $a0, $zero, getRandom
	mul $s2, $a0, 4		# (offset) takes the random number and multiplies by 4 since each letter is 4 wide
	add $s3, $s2, $s0	# random column memory location
	add $s4, $s3, $zero	#putting s3 into s4 for a comparison
	
	
jump:	add $t3, $zero, $s3	#copying s3 into t3 (temp variable)
	la $t1, 0($s3)	
	bgt $t1, 0xffffb1fc, jumpSkip
	lw $t1, 0($s3)		# letter at that location and stored into t1	
	#add $t1, $t1, 320
	or $t1, $t1, $s1	#making character bright green
	#or  $s2, $s1, $a0	#combines the color with the letter
	sw $t1, 0($s3)		# sends the bright green character to the terminal	
	jumpSkip:
	#addi $t2, $t2, 1	#counter ++
	li $a0, 40		# syscall for miliseconds
	li $v0, 32
	syscall			# slow down the fall of the letters
	bgt  $t2, 53, done
	add $t5, $zero, $zero
	
	innerLoop:
		beq $s3, $s4, reset	#to go and increment counter and row
		#add $t3, $zero, $s3	#copying s3 into t3 (temp variable)
		sub $s3, $s3, 320	#moves back a row 
		#la $t1, 0($s3)	
		#bgt $t1, 0xffffb1fc, innerSkip
		lw  $t1, 0($s3)		#grabs character in back row
		
		# Extracts color, subs offset from $t8 at beginning,
		# Stores back in location
		andi $t4, $t1, 0x00ffffff
		beq $t5, 13, skip
		addi $t5, $t5, 1
		sub $t1, $t1, $t8	#adjusts color to dimmer color for letter behind
	skip:
		sw $t1, 0($s3)		#sends updated dimmer character to terminal
	#innerSkip:	
		#add $s3, $t3, $zero	#gets back to current position
		#beq $s3, $s4, reset	#to go and increment counter and row
		j innerLoop
	reset:
		add $s3, $t3, $zero     #current position in the column	
		addi $t2, $t2, 1	#counter ++
		addi $s3, $s3, 320
		beq $s3, 0xffffb200, exception	# move to next row in same column
		#lw $t1, 0($s3)		# grab character and put into t1
		
j jump
	exception:
	
_column1:
	# Func header
	addi $sp, $sp, -24
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $ra, 20($sp)

#a0 has random number in it
#s0 has location of first register in upper left corner of terminal screen.  This will be pushed by 4 to move across screen
#s1 hold dark green color for each character as of now
#s2- what the terminal is expecting...ascii and color
	add $t2, $zero, $zero
	li  $s0, 0xffff8000	# first address of upper left hand of screen.
	li  $s1, 0x0000ff00     #bright green...later you will make dull green	
	
getRandom1:
	addi $v0, $zero, 30
	syscall	
	add $a1, $zero, $a0
	addi $v0, $zero, 42 	# Syscall 42: Random int range
	add $a0, $zero, $zero	# Set RNG ID to 0
	addi $a1, $zero, 80 	# Set upper bound to 80 (exclusive)
	syscall 		# Generate a random number and put it in $a0
	#add $s1, $zero, $a0 	# Copy the random number to $s1
	#bgt $a0, 79, getRandom
	beq $a0, $zero, getRandom1
	mul $s2, $a0, 4		# (offset) takes the random number and multiplies by 4 since each letter is 4 wide
	add $s3, $s2, $s0	# random column memory location
	add $s4, $s3, $zero	#putting s3 into s4 for a comparison
	
	
jump1:	add $t3, $zero, $s3	#copying s3 into t3 (temp variable)
	la $t1, 0($s3)	
	bgt $t1, 0xffffb1fc, jumpSkip1
	lw $t1, 0($s3)		# letter at that location and stored into t1	
	#add $t1, $t1, 320
	or $t1, $t1, $s1	#making character bright green
	#or  $s2, $s1, $a0	#combines the color with the letter
	sw $t1, 0($s3)		# sends the bright green character to the terminal	
	jumpSkip1:
	#addi $t2, $t2, 1	#counter ++
	li $a0, 1		# syscall for miliseconds
	li $v0, 32
	syscall			# slow down the fall of the letters
	bgt  $t2, 53, done
	add $t5, $zero, $zero
	
	innerLoop1:
		beq $s3, $s4, reset1	#to go and increment counter and row
		#add $t3, $zero, $s3	#copying s3 into t3 (temp variable)
		sub $s3, $s3, 320	#moves back a row 
		#la $t1, 0($s3)	
		#bgt $t1, 0xffffb1fc, innerSkip
		lw  $t1, 0($s3)		#grabs character in back row
		
		# Extracts color, subs offset from $t8 at beginning,
		# Stores back in location
		andi $t4, $t1, 0x00ffffff
		beq $t5, 13, skip
		addi $t5, $t5, 1
		sub $t1, $t1, $t8	#adjusts color to dimmer color for letter behind
	skip1:
		sw $t1, 0($s3)		#sends updated dimmer character to terminal
	#innerSkip:	
		#add $s3, $t3, $zero	#gets back to current position
		#beq $s3, $s4, reset	#to go and increment counter and row
		j innerLoop1
	reset1:
		add $s3, $t3, $zero     #current position in the column	
		addi $t2, $t2, 1	#counter ++
		addi $s3, $s3, 320
		#beq $s3, 0xffffb200, exception	# move to next row in same column
		#lw $t1, 0($s3)		# grab character and put into t1
j jump
	#exception:
		
done:
	#j getRandom
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	jr $ra 


          

	
