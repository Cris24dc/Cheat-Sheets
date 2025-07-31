.data
    n_string: .space 16
    n_int: .space 4
    value_string: .space 16
    value_int: .space 4
    max_string: .space 16
    max_int: .long 0
    array: .space 400
.text
.global main
stoi:
    test %eax, %eax

to_string:
    test %eax, %eax

main:
    movl $3, %eax
    movl $1, %ebx
    movl $n_string, %ecx
    movl $4, %edx
    int $0x80

    movzbl n_string, %eax
    subl $'0', %eax
    movl %eax, n_int

    movl $array, %edi
    movl $0, %ecx

    for_loop_read:
        cmpl n_int, %ecx
        jge exit_read

        push %ecx
        
        movl $3, %eax
        movl $1, %ebx
        movl $value_string, %ecx
        movl $4, %edx
        int $0x80

        pop %ecx

        movzbl value_string, %eax
        subl $'0', %eax
        movl %eax, value_int

        movl %ebx, (%edi, %ecx, 4)

        incl %ecx
        jmp for_loop_read
    
exit_read:
    movl $0, %ecx

    for_loop_even:
        cmpl n_int, %ecx
        jge exit

        movl (%edi, %ecx, 4), %ebx

        cmp %ebx, max_int
        jge continue
        movl %ebx, max_int

    continue:
        movl %ebx, (%edi, %ecx, 4)

        incl %ecx
        jmp for_loop_even

exit:
    movzbl max_int, %eax
    addl $'0', %eax
    movl %eax, max_string

    movl $4, %eax
    movl $1, %ebx
    movl $max_string, %ecx
    movl $1, %edx
    int $0x80

    movl $1, %eax
    movl $0, %ebx
    int $0x80
