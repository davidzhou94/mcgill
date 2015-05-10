	.text
main:
	#ask for and store value of a
	li	$v0, 4
	la	$a0, msg1
	syscall
	li	$v0, 6
	syscall
	mov.s	$f1, $f0		#$f1 = a
	
	#ask for and store value of b
	li	$v0, 4
	la	$a0, msg2
	syscall
	li	$v0, 6
	syscall
	mov.s	$f2, $f0		#$f2 = b
	
	#initialize constant ints and constant floats
	lw	$t3, heap		#address in $t3 initialized to beginning of heap memory
	lw	$s2, widt		#$s2 initialized to display width
	lw	$s3, heig		#$s3 initialized to display height
	lw	$s4, limi		#$s4 initialized to iteration limit
	
	lwc1	$f7, const2		#$f7 = 1.5
	lwc1	$f31, const3		#$f31 = 1000000.0
	
	#convert frequently reused float calculation constants to floats
	lwc1	$f13, const1		#$f13 = 3.0
	mtc1	$s2, $f14		#$copy the width over to FPU for calculations
	cvt.s.w	$f14, $f14		#$f14 = width in floating point
	div.s	$f5, $f13, $f14		#$f5 = 3.0 / width
	
	mtc1	$s3, $f14		#$copy the height over to FPU for calculations
	cvt.s.w	$f14, $f14		#$f14 = height in floating point
	div.s	$f6, $f13, $f14		#$f6 = 3.0 / height
		
	li	$t2, 0			#counter $t2 => j initialized to zero
loopj:
	li	$t1, 0			#counter $t1 => i initialized to zero
	addiu	$t2, $t2, 1		#j++
	mtc1	$t2, $f9		#copy value of j to FPU
	cvt.s.w	$f9, $f9		#convert $f9 to float
	
	mul.s	$f13, $f6, $f9		#$f13 = (3 / h) * j
	sub.s	$f11, $f13, $f7		#$f11 = y0 = (3 / h ) * j - 1.5
loopi:
	addiu	$t1, $t1, 1		#i++
	mtc1	$t1, $f8		#copy value of i to FPU
	cvt.s.w	$f8, $f8		#convert $f8 to float
	
	mul.s	$f13, $f5, $f8		#$f13 = (3 / w) * i
	sub.s	$f3, $f13, $f7		#$f3 = x0 = (3 / w ) * i - 1.5
	mov.s	$f4, $f11		#avoids recalculating y_i which does not change for this row
	
	addiu	$t5, $zero, 1		#initialize counter to 1
iterate:
	bgt	$t5, $s4, exit		#loop while counter $t5 < n
	
	#calculate new x and store it in $f17
	mul.s	$f13, $f3, $f3		#$f13 = x^2
	mul.s	$f14, $f4, $f4		#$f14 = y^2
	sub.s	$f13, $f13, $f14	#$f13 = x^2 - y^2
	add.s	$f17, $f13, $f1		#$f17 = x^2 - y^2 + a
	
	#calculate new y and store it in $f4, also updates y_i
	mul.s	$f13, $f3, $f4		#$f13 = (x * y)
	add.s	$f13, $f13, $f13	#$f13 = (x * y) * 2
	add.s	$f4, $f13, $f2		#$f18 = (x * y) * 2 + b
	
	#calculate (x_i)^2 + (y_i)^2 and store it in $f19
	mul.s	$f13, $f17, $f17	#$f13 = (x_i)^2
	mul.s	$f14, $f4, $f4		#$f14 = (y_i)^2
	add.s	$f19, $f13, $f14	#$f19 = (x_i)^2 + (y_i)^2
	
	#determine if (x_i)^2 + (y_i)^2 > 1000000 and branch if unbounded growth is detected
	sub.s	$f20, $f31, $f19	#set $f20 = 1000000.0 - (x_i)^2 + (y_i)^2
	mfc1	$t6, $f20		#move the float to a temp register to work on it
	ori	$t6, $t6, 0x7fffffff	#we only care about the leading bit ie. is the number negative
	bne	$t6, 0x7fffffff, colour	#colour the pixel if unbounded growth is detected
	
	mov.s 	$f3, $f17		#update x_i
	
	#increment counter and loop to next iteration
	addiu	$t5, $t5, 1
	j	iterate	
colour:
	sll	$t5, $t5, 12		#multiply the iteration count by 0x1000
	sw	$t5, ($t3)		#colour pixel with colour in $t5
exit:
	addiu	$t3, $t3, 4		#update pixel address
	
	bne	$t1, $s2, loopi		#inner loop if we have not yet iterated through the entire row
	
	bne	$t2, $s3, loopj		#outer loop if we have not yet iterated through all the rows
	
	li	$v0, 10
	syscall
	
	.data
heap: .word 0x10040000
widt: .word 0x100
heig: .word 0x100
limi: .word 0x100
msg1: .asciiz "Enter the value of a: "
msg2: .asciiz "Enter the value of b: "
const1: .float 3.0		#0x40400000 = 3.0 in single precision floating point
const2:	.float 1.5		#0x3fc00000 = 1.5 in single precision floating point
const3: .float 1000000.0	#0x49742400 = 1000000.0 in single precision floating point
