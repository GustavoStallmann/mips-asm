.macro read_int(%register)
	li $v0, 5
	syscall 
	
	move %register, $v0
.end_macro

.macro print_int(%register)
	move $a0, %register
	li $v0, 1 
	syscall
.end_macro

.macro print_str(%label)
	la $a0, %label
	li $v0, 4
	syscall 
.end_macro

.data 
	req_n: .asciiz "Insira um valor para n:"
	req_p: .asciiz "Insira um valor para p:"
	result: .asciiz "Resultado corresponde a: "
	jump_line: .asciiz "\n"

.globl main
.text

main: 
	# read n
	print_str(req_n)
	read_int($s0)
	
	# read p 
	print_str(req_p)
	read_int($s1)
	
	# calc factorial of n 
	move $a0, $s0 
	jal factorial
	move $s2, $v0
	
	# calc factorial of (n-p)
	sub $a0, $s0, $s1 # $t0 = n - p 
	jal factorial 
	move $s3, $v0 
	
	div $s4, $s2, $s3 # n! / (n-p)!
	
	# print result
	print_str(result) 
	print_int($s4)

	# halt program
	li $v0, 10 
	syscall

#------------------------------------------
# Subprogram: factorial
# Brief: calculates the factorial of the given number
# Registers used: 
# 	$a0 - the number to calc the factorial
# Returns:
#	$v0 - the result 
#------------------------------------------
factorial:
    addi $sp, $sp, -8 # alloc mem on the stack
    sw $ra, 4($sp) # Save $ra
    sw $s0, 0($sp) # Save $s0
    
    # Verifies base case
    beqz $a0, factorial_base_case_logic
    
    # Recursive case
    move $s0, $a0 # save actual n value
    addi $a0, $a0, -1 # n -= 1 
    jal factorial # factorial(n-1)
    
    mul $v0, $s0, $v0 # n * factorial(n-1)
    
    b factorial_exit_logic
    
factorial_base_case_logic:
    li $v0, 1                 # $v0 = 1 

factorial_exit_logic:
    lw $s0, 0($sp) # restore $s0
    lw $ra, 4($sp) # restore $ra
    addi $sp, $sp, 8  # free stack
    
    jr $ra

