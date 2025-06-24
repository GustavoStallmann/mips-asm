.macro print_str(%str)
	la $a0, %str
	li $v0, 4 
	syscall
.end_macro

.macro print_int(%val)
    move $a0, %val
    li $v0, 1
    syscall
.end_macro

.macro malloc(%size, %reg_save_arr)
	move $a0, %size 
	li $v0, 9 # alloc 
	syscall 
	move %reg_save_arr, $v0 # save array pointer
.end_macro	

.data
	req_size: .asciiz "Insira o tamanho do vetor: \n"
	req_value: .asciiz "Insira um valor inteiro: \n"
	open_arr: .asciiz "["
	close_arr: .asciiz "]"
	even_result: .asciiz "Soma de pares: "
	odd_result: .asciiz "Soma de impares: "
	
	jump_line: .asciiz "\n"

.globl main 
.text

main: 
	# read array size
	print_str(req_size)	
	li $v0, 5 
	syscall
	move $s0, $v0

	# alloc array
	malloc($s0, $s1) # alloc array 

	# read array
	move $a0, $s1 # arg: *array
	move $a1, $s0 # arg: array.length
	jal read_array
	
	#print array 
	move $a0, $s1 # arg: *array
	move $a1, $s0 # arg: array.length
	jal print_array
	
	# sum even odd index elements
	move $a0, $s1 # arg: *array
	move $a1, $s0 # arg: array.length
	jal sum_elements_even_odd_index
	move $s2, $v0 
    move $s3, $v1
	
	print_str(even_result)
	print_int($s2) 
	print_str(jump_line)
	
	print_str(odd_result)
	print_int($s3)
	print_str(jump_line) 
		
	# halt program
	li $v0, 10 
	syscall
	
#---------------------------------
# Subprogram: sum_elements_even_odd_index
# Brief: sums the elements in a odd or even index of the given array
# Registers used: 
# 	$a0 - *array
# 	$a1 - array.length
# Returns: 
#  	$v0 - sum of even elements
# 	$v1 - sum of odd elements
#---------------------------------
sum_elements_even_odd_index:
	addi $sp, $sp, -12 # alloc space on stack 
	sw $s0, 0($sp) # save $s0 
	sw $s1, 4($sp) # save $s1 
	sw $ra, 8($sp) # save $ra 
	
	# save args
	move $s0, $a0 
	move $s1, $a1 
	
	li $t0, 0 # index = 0 
	li $v0, 0 # sum_even = 0
	li $v1, 0 # sum_odd = 0

sum_elements_even_odd_index_loop: 
	bge $t0, $s1, sum_elements_even_odd_index_end_loop
	
	sll $t1, $t0, 2 # array index offset
	add $t2, $s0, $t1 # *array + offset
	
	lw $t3, 0($t2) # $t3 = array[i]
	rem $t4, $t0, 2
	beqz $t4, is_even 
	
is_odd:
	add $v1, $v1, $t3 # sum_odd += $t3
	j next_iter

is_even: 
	add $v0, $v0, $t3 # sum_even += $t3
	j next_iter

next_iter: 	
	addi $t0, $t0, 1 # index += 1 
	j sum_elements_even_odd_index_loop # iter again

sum_elements_even_odd_index_end_loop: 
	lw $s0, 0($sp) # recover $s0
	lw $s1, 4($sp) # recover $s1
	lw $ra, 8($sp) # recover $ra
	addi $sp, $sp, 12 # free stack mem
	
	jr $ra # end of subprog

#---------------------------------
# Subprogram: print_array
# Brief: print the given array
# Registers used: 
# 	$a0 - *arr
# 	$a1 - array.length
#---------------------------------
print_array: 
	addi $sp, $sp, -12 # alloc mem on stack
	sw $s0, 0($sp) # save $s0
	sw $s1, 4($sp) # save $s1 
	sw $ra, 8($sp) # save $sp 
	
	move $s0, $a0 # store *array
	move $s1, $a1 # store array.length
	li $t0, 0 # index = 0 

print_array_loop: 
	bge $t0, $s1, print_array_end_loop # check end of iteration
	
	sll $t1, $t0, 2 # array offset
	add $t2, $s0, $t1 # *array + offset
	
	print_str(open_arr)
	lw $t2, 0($t2)
	print_int($t2) 	
	print_str(close_arr)
	
	addi $t0, $t0, 1 # index += 1 
	j print_array_loop # iter again

print_array_end_loop: 
	lw $s0, 0($sp) # restore $s0 
	lw $s1, 4($sp) # restore $s1 
	lw $ra, 8($sp) # restore $ra
	addi $sp, $sp, 12 # free stack
	
	print_str(jump_line)
	
	jr $ra # end of subprog

#-----------------------------------------
# Subprogram: read_array
# Brief: read values for the given array
# Arguments: 
# 	$a0 - *arr 
#	$a1 - array.length
#-----------------------------------------
read_array: 
	addi $sp, $sp, -12 # alloc mem on stack
	sw $s0, 0($sp) # save $s0
	sw $s1, 4($sp) # save $s1 
	sw $ra, 8($sp) # save $ra
	
	li $t0, 0 # index = 0 
	move $s0, $a0 # store *array ($a0)
	move $s1, $a1 # store array.length ($a1)

read_array_loop: 
	bge $t0, $s1, read_array_end_loop # end loop
	
	sll $t1, $t0, 2 # array index offset
	add $t2, $s0, $t1 # $t2 = *array + offset
	
	# read value
	print_str(req_value)
	li $v0, 5 
	syscall
	
	# save the readed value
	sw $v0, 0($t2)
	
	addi $t0, $t0, 1 # index += 1
	j read_array_loop # iter again

read_array_end_loop: 
	lw $s0, 0($sp) # restore $s0
	lw $s1, 4($sp) # restore $s1
	lw $ra, 8($sp) # restore $ra 
	addi $sp, $sp, 12 # free 
	
	jr $ra #return