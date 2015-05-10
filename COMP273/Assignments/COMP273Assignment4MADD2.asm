# Yang David ZHOU 260517397
.globl MADD2
.text
MADD2: 	#( float*A, float* B, float* C, N )

	#$a0 = A
	#$a1 = B
	#$a2 = C
	#$a3 = N
	
	sw	$s6, 4($sp)	#just in case there was something in $s6
	addi	$s6, $a3, -1	#$s6 = N - 1
	sw	$s7, 8($sp)	#just in case there was something in $s7
	lw	$s7, block_size	#$s7 = block_size
	
	add	$t0, $0, $0	#$t0 = block_i = 0
loopbi:
	bge	$t0, $a3, loopbi_exit	#loop while block_i < N
	
	add	$t1, $0, $0	#$t1 = block_j = 0
loopbj:
	bge	$t1, $a3, loopbj_exit	#loop while block_j < N
	
	add	$t2, $0, $0	#$t1 = block_k = 0
loopbk:
	bge	$t2, $a3, loopbk_exit	#loop while block_k < N
	
	#****BEGIN INNER LOOPS****
	
	#save block_i, block_j, block_k to stack
	sw	$t0, 12($sp)	#save block_i to stack
	sw	$t1, 16($sp)	#save block_j to stack
	sw	$t2, 20($sp)	#save block_k to stack
	
	#add block_size to the block counters
	add	$t0, $t0, $s7	#$t0 = block_i + blocksize
	add	$t1, $t1, $s7	#$t1 = block_j + blocksize
	add	$t2, $t2, $s7	#$t2 = block_k + blocksize
	
	sub	$t3, $t0, $s7	#$t3 = i = block_i = $t0 - blocksize
loopi:
	bge	$t3, $t0, loopi_exit	#if i >= block_i + blocksize, exit loop
	bge	$t3, $a3, loopi_exit	#if i >= N, exit loop
	
	sub	$t4, $t1, $s7	#$t4 = j = block_j = $t1 - blocksize
loopj:
	bge	$t4, $t1, loopj_exit	#if j >= block_j + blocksize, exit loop
	bge	$t4, $a3, loopj_exit	#if j >= N, exit loop
	
	mtc1	$0, $f8
	cvt.s.w	$f8, $f8	#$f8 = tmp = 0
	
	sub	$t5, $t2, $s7	#$t5 = k = block_k = block_k = $t2 - blocksize
loopk:
	bge	$t5, $t2, loopk_exit	#if k >= block_k + blocksize, exit loop
	bge	$t5, $a3, loopk_exit	#if k >= N, exit loop
	
	#compute address of A[i][k] and store it in $t6
	mul	$v0, $a3, $t3	#$v0 = N * i
	mul	$v0, $v0, 4	#$v0 = N * i * 4
	mul	$v1, $t5, 4	#$v1 = k * 4
	add	$t6, $v0, $v1	#$t6 = N * i * 4 + k * 4
	add	$t6, $t6, $a0	#$t6 = A_start + N * i * 4 + k * 4
	
	#compute address of B[k][j] and store it in $t7
	mul	$v0, $a3, $t5	#$v0 = N * k
	mul	$v0, $v0, 4	#$v0 = N * k * 4
	mul	$v1, $t4, 4	#$v1 = j * 4
	add	$t7, $v0, $v1	#$t7 = N * k * 4 + j * 4
	add	$t7, $t7, $a1	#$t7 = B_start + N * k * 4 + j * 4
	
	#load A[i][k] into $f9 and B[k][j] into $f10
	lwc1	$f9, ($t6)
	lwc1	$f10, ($t7)
	
	#multiply $f9 and $f10 and store result in $f11
	mul.s	$f11, $f9, $f10
	
	#add $f11 to $f8
	add.s	$f8, $f8, $f11
	
	addi	$t5, $t5, 1	#k++
	j	loopk
loopk_exit:
	
	#compute address of C[i][j] and store it in $t8
	mul	$v0, $a3, $t3	#$v0 = N * i
	mul	$v0, $v0, 4	#$v0 = N * i * 4
	mul	$v1, $t4, 4	#$v1 = j * 4
	add	$t8, $v0, $v1	#$t8 = N * k * 4 + j * 4
	add	$t8, $t8, $a2	#$t8 = C_start + N * k * 4 + j * 4
	
	#load value from address of $t8=^C[i][j] into $f9
	#update C[i][j] with value in tmp = $f8
	lwc1	$f9, ($t8)
	add.s	$f9, $f9, $f8
	swc1	$f9, ($t8)
	
	addi	$t4, $t4, 1	#j++
	j	loopj
loopj_exit:

	addi	$t3, $t3, 1	#i++
	j	loopi
loopi_exit:
	
	#****END INNER LOOP****
	#put things back from the stack
	lw	$t2, 20($sp)
	lw	$t1, 16($sp)
	lw	$t0, 12($sp)
	
	add	$t2, $t2, $s7	#block_k += block_size
	j	loopbk
loopbk_exit:
	
	add	$t1, $t1, $s7	#block_j += block_size
	j	loopbj
loopbj_exit:
	
	add	$t0, $t0, $s7	#block_i += block_size
	j	loopbi
loopbi_exit:
	
	lw	$s7, 8($sp)	#put back $s7
	lw	$s6, 4($sp)	#put back $s6
	jr	$ra

.data
block_size: .word 0x4
