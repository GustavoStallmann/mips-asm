.data
	vector:      .word -2, 4, 7, -3, 0, -3, 5, 6
	vector_size: .word 8
	positive_prompt: .asciiz "Quantidade de positivos: "
	negative_prompt: .asciiz "Quantidade de negativos: "
	newline:     .asciiz "\n"

.text
.globl main
main:
    li $s0, 0          # i = $s0 
    lw $s1, vector_size # n_elements = $s1
    li $s2, 0          # positive_count = $s2 
    li $s3, 0          # negative_count = $s3 
    la $s4, vector     # base_address_vector = $s4

start_loop:
    # i < n_elements? ($s0 < $s1)
    slt $t0, $s0, $s1  # $t0 = 1 if $s0 < $s1, else $t0 = 0
    beqz $t0, end_loop # if $t0 == 0 (i >= n_elements) goto end_loop

    # Load actual array element
    sll $t1, $s0, 2    # $t1 = i * 4 
    add $t2, $s4, $t1  # $t2 = base_address_vector + offset
    lw $a0, 0($t2)     # current_element = $a0

    bgtz $a0, is_positive # if current_element > 0, goto is_positive
    bltz $a0, is_negative # if current_element < 0, goto is_negative
    # caso 0 continue_loop

continue_loop:
    addi $s0, $s0, 1   # i++
    b start_loop       # goto start_loop

is_positive:
    addi $s2, $s2, 1   # positive_count++
    b continue_loop    # goto start_loop

is_negative:
    addi $s3, $s3, 1   # negative_count++
    b continue_loop    # goto start_loop

end_loop:
	# print negative count
    la $a0, positive_prompt
    li $v0, 4
    syscall

    move $a0, $s2
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    # print positive count
    la $a0, negative_prompt
    li $v0, 4
    syscall

    move $a0, $s3
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10         # syscall <- exit
    syscall