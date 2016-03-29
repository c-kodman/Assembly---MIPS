.data
	#need arrays because there are too few registers to hold all of the information for 80 columns on the screen
	#if column is -1 then column is not active
	#if not -1 then the number represents where the brightest green is
	# this screen is X x Y...some start at say 5,6
	#speedCounter is speed counter
	start:		.asciiz  "!"
	time:		.word	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	speed:		.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	counter:	.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

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
screen_int:	
	li		$a1, 93				# there are 94 characters totall
	li		$v0, 42
	syscall	
	la		$t0, start
	lb		$t1, 0($t0)
	or		$t1, $t1, $a0
	sll		$t1, $t1, 24
	or   	$t1, $t1, $s1
	sw		$t1, 0($s0)
	beq		$s0, 0xFFFFb1fc, int_done
	addi	$s0, $s0, 4	
	j	screen_int
int_done:

screen_loop:
################################################################
	li		$s0, 0xFFFFB204		
	lw		$s1, 0($s0)
	andi	$s1, $s1, 0x000000FF
	bne		$s1, $zero, screen_done		# if there is a keyboard input, terminate program
	li		$a0, 10
	li		$v0, 32			# sleep
	syscall
	la		$t0, time
################################################################
	la		$t1, speed
	la		$t2, counter
################################################################
	li		$t9, 0
gene:	
	beq		$t9, 80, gene_done	
	lw		$s0, 0($t0)
################################################################
	lw		$s1, 0($t1)
	lw		$s2, 0($t2)
################################################################
	bne		$s0, -1, already		# already be active
	li		$a1, 1					# get a random number to decide if to active
	li		$v0, 42
	syscall
	beq		$a0, 0, where			# if 1: don't active, if 0: active
	j		rand_done
where:								# decide where to start
	li		$a1, 25					# the upper number can be 40 actually, 20 just makes it more fancy
	li		$v0, 42
	syscall		
	sw		$a0, 0($t0)				# save the starting place
################################################################
	li		$a1, 3					# generate different speed(4 levels)
	li		$v0, 42
	syscall
	addi	$s1, $a0, 0							# when it needs to be active
	sw		$s1, 0($t1)				# generete a random number as the speed
	j		rand_done
already:
	beq		$s1, $s2, counter_rest
	addi	$s2, $s2, 1
	j		counter_update	
counter_rest:
	addi	$s0, $s0, 1
	sw		$s0, 0($t0)				# if that column is already active
	li		$s2, 0	
counter_update:
	sw		$s2, 0($t2)				# update the location and the counter number
################################################################
rand_done:	
	addi	$t0, $t0, 4
################################################################
	addi	$t1, $t1, 4
	addi	$t2, $t2, 4
################################################################
	addi	$t9, $t9, 1
	j		gene			
gene_done:	
	li		$s0, 0xFFFF8000		# restart from the beginning of the screen
	li		$s1, 0x00002200		# dark green
	add		$s2, $zero, $zero	# x [0, 79]
	add		$s3, $zero, $zero	# y: when x = 80, y++
	la		$t0, time
################################################################
	la		$t6, speed
	la		$t7, counter
################################################################
pixel:
	beq		$s0, 0xFFFFb1fc, screen_loop	
	lw		$s4, 0($t0)
	beq		$s4, -1, change_done
################################################################
	lw		$s6, 0($t6)
	lw		$s7, 0($t7)
	bne		$s6, $s7, change_done
################################################################
# color change:
	lw		$s5, 0($s0)			# get the color
	sll		$t1, $s5, 8
	srl		$t1, $t1, 8
	beq		$t1, $s1, ff_or_22	# if the color is 002200, it can be ff or stay 22
color_reduce:					
	addi	$s5, $s5, -0x00001100	# reduce the color number by 11	
	sll		$t1, $s5, 8
	srl		$t1, $t1, 8
	beq		$t1, 0x00002200, save_change
	j		update
ff_or_22:						
	bne		$s4, $s3, change_done
	ori		$s5, 0x0000ff00		# if the the place is the start place, the color is ff
	j		update
save_change:
	beq		$s3, 39, reset	
	j		update
reset:
	li		$s4, -1
################################################################
	li		$s7, 0
	sw		$s7, 0($t7)
################################################################
update:
	sw		$s4, 0($t0)
	sw		$s5, 0($s0)		
change_done:	
	addi	$t0, $t0, 4
################################################################	
	addi	$t6, $t6, 4
	addi	$t7, $t7, 4
################################################################
	addi	$s0, $s0, 4
	addi	$s2, $s2, 1	
	bne		$s2, 80, y_keep
	addi	$s3, $s3, 1
	la		$t0, time
################################################################
	la		$t6, speed
	la		$t7, counter
################################################################
	li		$s2, 0
y_keep:	
	j		pixel
	
screen_done:
################################################################					
	addi	$v0, $zero, 10		# terminate program
	syscall
################################################################
