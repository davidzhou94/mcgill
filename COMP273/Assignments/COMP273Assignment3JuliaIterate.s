	.text 
main:
	#ask for and store value of a
	li	$v0, 4
	la	$a0, msg1
	syscall
	li	$v0, 6
	syscall
	mov.s	$f1, $f0	#$f1 = a
	
	#ask for and store value of b
	li	$v0, 4
	la	$a0, msg2
	syscall
	li	$v0, 6
	syscall
	mov.s	$f2, $f0	#$f2 = b
	
	#ask for and store value of x0
	li	$v0, 4
	la	$a0, msg3
	syscall
	li	$v0, 6
	syscall
	mov.s	$f3, $f0	#$f3 = x0
	
	#ask for and store value of y0
	li	$v0, 4
	la	$a0, msg4
	syscall
	li	$v0, 6
	syscall
	mov.s	$f4, $f0	#$f4 = y0
	
	#ask for and store value of n
	li	$v0, 4
	la	$a0, msg5
	syscall
	li	$v0, 5
	syscall
	move	$s0, $v0	#$s0 = n
	
	#print out initial x0 and y0
	li	$v0, 4
	la	$a0, out1	#out1 = "\n(x"
	syscall
	li	$v0, 1
	li	$a0, 0		#since this is iteration 0
	syscall
	li	$v0, 4
	la	$a0, out2	#out2 = ", y"
	syscall
	li	$v0, 1
	li	$a0, 0		#since this is iteration 0
	syscall
	li	$v0, 4
	la	$a0, out3	#out3 = ") = ("
	syscall
	li	$v0, 2
	mov.s	$f12, $f3	#$f3 = x0
	syscall
	li	$v0, 4
	la	$a0, out4	#out4 = ", "
	syscall
	li	$v0, 2
	mov.s	$f12, $f4	#$f4 = y0
	syscall
	li	$v0, 4
	la	$a0, out5	#out5 = ")"
	syscall
	
	addi	$t1, $zero, 1
loop:	
	bgt	$t1, $s0, exit		#loop while counter t1 < n
	
	#calculate new x and store it in $f10
	mul.s	$f5, $f3, $f3		#$f5 = x^2
	mul.s	$f6, $f4, $f4		#$f6 = y^2
	sub.s	$f7, $f5, $f6		#$f7 = x^2 - y^2
	add.s	$f10, $f7, $f1		#$f10 = x^2 - y^2 + a
	
	#calculate new y and store it in $f11
	mul.s	$f5, $f3, $f4		#$f5 = x * y
	add.s	$f5, $f5, $f5		#$f5 = x * y + x * y = 2 * x * y
	add.s	$f11, $f5, $f2		#$f11 = 2 * x * y + b
	
	#print x_n and y_n with formatting
	li	$v0, 4
	la	$a0, out1		#out1 = "\n(x"
	syscall
	li	$v0, 1
	add	$a0, $t1, $zero		#set $a0 to current counter value
	syscall
	li	$v0, 4
	la	$a0, out2		#out2 = ", y"
	syscall
	li	$v0, 1
	add	$a0, $t1, $zero		#set $a0 to current counter value
	syscall
	li	$v0, 4
	la	$a0, out3		#out3 = ") = ("
	syscall
	li	$v0, 2
	mov.s	$f12, $f10		#$f10 = new x
	syscall
	li	$v0, 4
	la	$a0, out4		#out4 = ", "
	syscall
	li	$v0, 2
	mov.s	$f12, $f11		#$f11 = new y
	syscall
	li	$v0, 4
	la	$a0, out5		#out5 = ")"
	syscall
	
	mov.s	$f3, $f10		#update $f3 which stores x
	mov.s	$f4, $f11		#update $f4 which stores y
	
	addi	$t1, $t1, 1		#increment counter
	j	loop
	
exit:
	li	$v0, 10
	syscall
	
	.data
msg1: .asciiz "Enter the value of a: "
msg2: .asciiz "Enter the value of b: "
msg3: .asciiz "Enter the value of x0: "
msg4: .asciiz "Enter the value of y0: "
msg5: .asciiz "Enter the number of iterations n: "
out1: .asciiz "\n(x"
out2: .asciiz ", y"
out3: .asciiz ") = ("
out4: .asciiz ", "
out5: .asciiz ")"
	
