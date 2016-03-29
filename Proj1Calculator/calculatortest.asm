.text
	addi $a0, $zero, 5
	addi $a1, $zero, 5
	#jal _power
	add $a0, $zero, $v0
	addi $v0, $zero, 1
	syscall
	addi $v0, $zero, 10
	syscall

#ARguments:
# $a0:x
# 	$a1:7
#	Return Value
#	$v0 = x^y
_power:
	add $s7, $zero, $ra	#backup $ra
	add $s0, $zero, $a0   # s0 is x
	add $s1, $zero, $a1	# s1 is y
	addi $s2, $zero, 1 	# s2 is result
	add $s3, $zero, $zero	# s3 is counter
pLoop:	beq $s3, $s1, pDone
	add $a0, $zero, $s2
	add $a1, $zero, $s0
	jal  _multi
	add $s2, $zero, $v0
	addi $s3, $s3, 1
	j   pLoop
pDone:	add $v0, $zero, $s2
	add $ra, $zero, $s7	#resotre $ra
	jr $ra

_multi:
	add $t0, $zero, $a0	#$t0 is multpilcant
	add $t1, $zero, $a1	#$t1 is multiplier
	add $t2, $zero, $zero	#t2 - result
	add $t3, $zero, $zero	# t3 counter
	
mloop:	beq $t3, $t1, mDone
	add $t2, $t2, $t0	# result = result + multplicant
	addi $t3, $t3, 1	# counter ++
	j	mloop
	
	
mDone:	add $v0, $zero, $t2
	jr  $ra
	
