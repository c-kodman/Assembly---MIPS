.data
	#need arrays because there are too few registers to hold all of the information for 80 columns on the screen
	#if column is -1 then column is not active
	#if not -1 then the number represents where the brightest green is
	# this screen is X x Y...some start at say 5,6
	#speedCounter is speed counter
	start:	.asciiz  "!"
	time:	.word	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 #80 for each column
	speed:	.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 #80 for each column
	speedCounter:	.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.text
	addi $s0, $zero, 0xFFFF8000
	#li		$s0, 0xFFFF8000		# the memory regin on the screen
	addi $s1, $zero, 0x00002200		# the dark green color
	addi $s2, $zero, 0x41005500		# the lightest green color
######## below fills the screen
random_seed:	
	addi $a0, $zero, 63
	addi $a1, $zero, 62
	addi $v0, $zero, 40
	syscall	
screen:	
	addi $a1, $zero, 93
	addi $v0, $zero, 42
	syscall	
	la    	$t0, start     #loads first ascii number so I can then build the screen
	lb    	$t1, 0($t0)	# saves that character to t1
	or    	$t1, $t1, $a0	#adds random number to first ascii number to determine random ascii
	sll   	$t1, $t1, 24
	or	$t1, $t1, $s1
	sw	$t1, 0($s0)	#puts ascii on the screen
	beq	$s0, 0xFFFFb1fc, done #checks if screen is full
	addi	$s0, $s0, 4	
	j	screen
done:

screenLoop:	#biggest loop - changes whole screen
	addi $a0, $zero, 5	
	addi $v0, $zero, 32
#	syscall		#sleep
	la		$t0, time
	addi $t9, $zero, 0
gene:	
	beq	$t9, 82, gene_done	
	lw	$s0, 0($t0)
	bne	$s0, -1, already	# already active
	addi $a1, $zero, 10		# random number - lower the number the busier the screen - more often columns are chosen
	addi $v0, $zero, 42
	syscall
	beq		$a0, 0, where	# if 1: inactive, if 0: active
	j		rand_done
where:				# decide where to start
	addi $a1, $zero, 25	#The higher the number the wider the range of starting points
	addi $v0, $zero, 42
	syscall		
	sw	$a0, 0($t0)	#saves the starting place
	j	rand_done
already:
	addi	$s0, $s0, 1
	sw		$s0, 0($t0)
rand_done:	
	addi	$t0, $t0, 4
	addi	$t9, $t9, 1
	j		gene			
gene_done:	
	addi $s0, $zero, 0xFFFF8000	# restart from the beginning of the screen
	addi $s1, $zero, 0x00002200	# dark green
	add  $s2, $zero, $zero	# x 
	add  $s3, $zero, $zero	# y: when x = 80, y++ so when x is at the end of the line it goes to next y
	la   $t0, time
pixel:
	beq  $s0, 0xFFFFb1fc, screenLoop	
	lw   $s4, 0($t0)
	beq  $s4, -1, changeDone
# color change:
	lw   $s5, 0($s0)  # get the color
	sll  $t1, $s5, 8
	srl  $t1, $t1, 8
	beq  $t1, $s1, ff_or_22	# if the color is dark, then check if that should become bright or stay dark
colorReduce:					
	addi	$s5, $s5, -0x00001100	# reduce the color to next dimmest color green	
	sll	$t1, $s5, 8
	srl	$t1, $t1, 8
	beq	$t1, 0x00002200, saveChange	#check if it is darkest color
	j		update
ff_or_22:						
	bne	$s4, $s3, changeDone
	ori	$s5, 0x0000ff00	# if at the start, the color is bright green (ff)
	j	update
saveChange:
	beq	$s3, 39, reset	#check if at the bottom of the terminal
	j		update
reset:
	addi $s4, $zero, -1	#if darkest color and bottom terminal, change column to -1 to reset column to inactive
update:
	sw	$s4, 0($t0)
	sw	$s5, 0($s0)
		
changeDone:	
	addi	$t0, $t0, 4
	addi	$s0, $s0, 4
	addi	$s2, $s2, 1	
	bne	$s2, 80, keepY
	addi	$s3, $s3, 1
	la	$t0, time
	addi	$s2, $zero, 0
keepY:	
	j		pixel
	
screen_done:						
#	addi	$v0, $zero, 10
#	syscall
