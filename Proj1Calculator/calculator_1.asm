.text

_clear:
	add $s0, $zero, $zero # s0 is operand1 and being set to zero
	add $s1, $zero, $zero   # s1 is operand2 and set to zero
	add $t8, $s0, $zero	# putting operand1 into t8
	add $t9, $zero, $zero	
	
loop1:	beq $t9, $zero, loop1
		
	andi $t1, $t9, 15   # set t1 to actual number entered
	#beq $t1, 10, addition
	#beq $t1, 12, _multi
	slti $t3, $t1, 10
	beq $t3, $zero, operator
	
	
	sll $t0, $s0, 3 	#this and next 3 lines multiply the operand1 by 10
	add $t0, $s0, $t0 
	add $s0, $s0, $t0 

	
	add $s0, $t1, $s0
	add $t8, $s0, $zero  #displays the number 
	add $t9, $zero, $zero # set t9 to zero 
	j loop1
	
loop2:	beq $t9, $zero, loop2
	
	andi $t1, $t9, 15   # set t1 to actual number entered

	slti $t3, $t1, 10 # if an operator is entered this will then go to calculate loop
	beq $t3, $zero, calculate
	
	#add $s3, $zero, $zero
	
	sll $t0, $s1, 3 	#this and next 3 lines multiply the operand1 by 10
	add $t0, $s1, $t0 
	add $s1, $s1, $t0 
	
	add $s1, $t1, $s1
	add $t8, $s1, $zero  #displays the number 
	#add $t8, $zero, $zero # set t8 to zer0 
	add $t9, $zero, $zero # set t9 to zero 
	j loop2
	
operator:
	
	add $s3, $t1, $zero #operator is in s3 now
	beq $s3, 15, _clear
	add $t9, $zero, $zero
	j loop2
	

calculate:
	
	beq $s3, 10, addition
	beq $s3, 11, subtract
	beq $s3, 12, _multi
	beq $s3, 13, divide
	beq $s3, 14, result
#	beq $s3, 15, _clear
	beq $t1, 15, _clear
	
addition:
	add $s0, $s1, $s0
	add $s1, $zero, $zero
	add $t8, $s0, $zero
	add $s3, $t1, $zero
	add $t9, $zero, $zero # set t9 to zero 
	j loop2
	
subtract:
	sub $s0, $s0, $s1
	add $s1, $zero, $zero
	add $t8, $s0, $zero
	add $s3, $t1, $zero
	add $t9, $zero, $zero # set t9 to zero  	
	j loop2	
	
_multi:
	add $t0, $zero, $s0	#$t0 is multiplicant
	add $s3, $t1, $zero	
	add $t1, $zero, $s1	#$t1 is multiplier
	add $t2, $zero, $zero	#t2 - result
	add $t3, $zero, $zero	# t3 counter
	
	#beq $s1, $sp, loop2
	
mloop:	beq $t3, $t1, mresult
	add $t2, $t2, $t0	# result = result + multplicant
	addi $t3, $t3, 1	# counter ++
	j	mloop	
mresult:
	add $s0, $zero, $t2
	add $s1, $zero, $zero
	add $t8, $s0, $zero

	add $t9, $zero, $zero # set t9 to zero 
	j	loop2
	
divide:
	add $t0, $zero, $s0	#$t0 number to be divided
	add $s3, $t1, $zero	
	add $t1, $zero, $s1	#$t1 is divisor
	add $t2, $zero, $zero	#set t2 to zero to be counter
dloop:	
	blt $t0, $t1, dresult
	sub $t0, $t0, $t1
	addi $t2, $t2, 1	# counter ++
	j	dloop
dresult:
	sub $s0, $t2, $zero	#below wrong
	add $t9, $zero, $zero # set t9 to zero 
	add $s1, $zero, $zero
	add $t8, $s0, $zero


	j	loop2
	
	
result:
	add $s0, $t2, $zero
	add $t8, $0, $t2
	#add $s1, $zero, $sp
	add $t9, $zero, $zero	
	beq $t1, 15, _clear
	
	j loop1
	
	
	
	
	
