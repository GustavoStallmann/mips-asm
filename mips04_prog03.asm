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
	sll $a0, $a0, 2 
	li $v0, 9 # alloc 
	syscall 
	move %reg_save_arr, $v0 # save array pointer
.end_macro	

.data
	req_size: .asciiz "Insira o tamanho do vetor: \n"
	req_value: .asciiz "Insira um valor inteiro: \n"
	open_arr: .asciiz "["
	close_arr: .asciiz "]"
	bigger_result: .asciiz "O maior numero e: "
	smaller_result: .asciiz "O menor numero e: "
	
	jump_line: .asciiz "\n"

.globl main 
.text

main: 
	# read array size
	print_str(req_size)	
	li $v0, 5 
	syscall
	move $s0, $v0

	# alloc first_array
	malloc($s0, $s1) # alloc array 

	# read array
	move $a0, $s1 # arg: *array
	move $a1, $s0 # arg: array.length
	jal read_array
	
	#print array 
	move $a0, $s1 # arg: *array
	move $a1, $s0 # arg: array.length
	jal print_array
	
	# alloc sec_array
	malloc($s0, $s2)
	
	# read array
	move $a0, $s2 # arg: *array
	move $a1, $s0 # arg: array.length
	jal read_array
	
	#print array 
	move $a0, $s2 # arg: *array
	move $a1, $s0 # arg: array.length
	jal print_array
	
	move $a0, $s1 # arg: *array
	move $a1, $s0 # arg: array.length
	move $a2, $s2 # arg: *sec_array
	move $a3, $s0 # arg: sec_array.length
	jal merge_arrays
	
	#print array 
	move $a0, $v0 # arg: *array
	move $a1, $v1 # arg: array.length
	jal print_array
		
	# halt program
	li $v0, 10 
	syscall

#----------------------------------
# Subprogram: merge_arrays
# Brief: 
#	creates a new array setting the even indexes values from the first array, 
#	and the odd indexes form the second one
# Registers used:
#	$a0 - *first_array
# 	$a1 - first_array.length
# 	$a2 - *second_array
# 	$a3 - second_array.length
# Returns: 
# 	$v0 - *new_merged_array
#	$v1 - new_merged_array.length
#------------------------------------
merge_arrays:
	addi $sp, $sp, -20 # alloc stack mem
	sw $s0, 0($sp) # save $s0
	sw $s1, 4($sp) # save $s1 
	sw $s2, 8($sp) # save $s2
	sw $s3, 12($sp) # save $s3
	sw $ra, 16($sp) # save $ra
	
	# save parameters
	move $s0, $a0 
	move $s1, $a1 
	move $s2, $a2
	move $s3, $a3
	
	# new_merged_array.length = first_array.length + second_array.length
	add $v1, $s1, $s3 
	
	# $s5 = *new_merged_array
	malloc($v1, $s5) 
	
	li $t0, 0 # index = 0  
	li $t4, 0 # even_index = 0
	li $t5, 0 # odd_index = 0
	
merge_arrays_loop:
	bge $t0, $v1, merge_arrays_end_loop
	
	sll $t1, $t0, 2 # $t1 = index_offset
	add $t2, $t1, $s5 # $t2 = new_merged_array + index_offset
	
	rem $t3, $t0, 2 # $t1 = index % 2 
	beqz $t3, is_even
	
is_odd:
	sll $t6, $t5, 2 # $t6 = odd_index offset
	add $t7, $s2, $t6 # $t7 = *sec_vec + odd_offset
	lw $t6, 0($t7) # $t6 = sec_arr[odd_index]
	
	sw $t6, 0($t2) # new_merged_array[i] = sec_arr[odd_index]
	
	addi $t5, $t5, 1 # odd_index++
	j next_iter
	
is_even:
	sll $t6, $t4, 2 # $t6 = even index offset
	add $t7, $s0, $t6 # $t7 = *first_arr + offset
	lw $t6, 0($t7) # $t6 = first_arr[even_index]
	
	sw $t6, 0($t2) # new_merged_array[i] = first_arr[even_index]
	
	addi $t4, $t4, 1 # even_index++
	j next_iter

next_iter: 	
	addi $t0, $t0, 1 # index += 1
	j merge_arrays_loop

merge_arrays_end_loop:
	lw $s0, 0($sp) # restore $s0
	lw $s1, 4($sp) # restore $s1 
	lw $s2, 8($sp) # restore $s2
	lw $s3, 12($sp) # restore $s3
	lw $ra, 16($sp) # restore $ra
	addi $sp, $sp, 20 # free mem from stack
	
	move $v0, $s5
	
	jr $ra
	
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
