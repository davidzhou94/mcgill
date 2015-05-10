# Yang David ZHOU 260517397
.globl MADD1
.text
MADD1: 	#( float*A, float* B, float* C, N )

	#$a0 = A
	#$a1 = B
	#$a2 = C
	#$a3 = N
	
	addi	$t3, $a3, -1	#$t3 = N - 1
	
	add	$t0, $0, $0	#$t0 = i = 0
loopi:
	bgt	$t0, $t3, loopi_exit	#if i > n - 1, exit loop
	
	add	$t1, $0, $0	#$t1 = j = 0
loopj:
	bgt	$t1, $t3, loopj_exit	#if j > n - 1, exit loop
	
	add	$t2, $0, $0	#$t2 = k = 0
	
	mtc1	$0, $f8
	cvt.s.w	$f8, $f8	#$f8 = tmp = 0
loopk:
	bgt	$t2, $t3, loopk_exit	#if k > n - 1, exit loop
	
	#compute address of A[i][k] and store it in $t4
	mul	$t8, $a3, $t0	#$t8 = N * i
	mul	$t8, $t8, 4	#$t8 = N * i * 4
	mul	$t9, $t2, 4	#$t9 = k * 4
	add	$t4, $t8, $t9	#$t4 = N * i * 4 + k * 4
	add	$t4, $t4, $a0	#$t4 = A_start + N * i * 4 + k * 4
	
	#compute address of B[k][j] and store it in $t5
	mul	$t8, $a3, $t2	#$t8 = N * k
	mul	$t8, $t8, 4	#$t8 = N * k * 4
	mul	$t9, $t1, 4	#$t9 = j * 4
	add	$t5, $t8, $t9	#$t5 = N * k * 4 + j * 4
	add	$t5, $t5, $a1	#$t5 = B_start + N * k * 4 + j * 4
	
	#load A[i][k] into $f9 and B[k][j] into $f10
	lwc1	$f9, ($t4)
	lwc1	$f10, ($t5)
	
	#multiply $f9 and $f10 and store result in $f11
	mul.s	$f11, $f9, $f10
	
	#add $f11 to $f8
	add.s	$f8, $f8, $f11
	
	addi	$t2, $t2, 1	#k++
	j	loopk
loopk_exit:
	
	#compute address of C[i][j] and store it in $t7
	mul	$t8, $a3, $t0	#$t8 = N * i
	mul	$t8, $t8, 4	#$t8 = N * i * 4
	mul	$t9, $t1, 4	#$t9 = j * 4
	add	$t7, $t8, $t9	#$t7 = N * k * 4 + j * 4
	add	$t7, $t7, $a2	#$t4 = C_start + N * k * 4 + j * 4
	
	#load value from address of $t7 into $f9
	#update C[i][j] with value in tmp = $f8
	lwc1	$f9, ($t7)
	add.s	$f9, $f9, $f8
	swc1	$f9, ($t7)
	
	addi	$t1, $t1, 1	#j++
	j	loopj
	
loopj_exit:
	
	addi	$t0, $t0, 1	#i++
	j	loopi
	
loopi_exit:
	
	jr	$ra
