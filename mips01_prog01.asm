.data
	output: .asciiz "O resultado é: \n"
	const_mult: .word 4 
	const_sum: .word 2
	n: .word 20

.text
.globl main 

main: 
	li $s0, 0 # current index (i)
	lw $s1, n # total loops
	lw $s6, const_mult 
	lw $s7, const_sum
	
start_loop:
	sle $t1, $s0, $s1 # $t1 <- i <= n ($s0 <= $s1)
	beqz $t1, end_loop # if $t1 == true goto end_loop label

	# code block
	mul $s5, $s1, $s6 # $s5 <- 4*n
	add $s5, $s5, $s7 # $s5 <- (4n) + 2
	
	 
	addi $s0, $s0, 1 # i += 1
	b start_loop # goto start_loop
	
end_loop:
	la $a0, output # $a0 <- .word output
	li $v0, 4 # syscall <- print string
	syscall
	 
	move $a0, $s5 # $a0 <- $s5
    li $v0, 1 # Syscall <- print int
    syscall
	
	li $v0, 10 # syscall <- exit program
    syscall

