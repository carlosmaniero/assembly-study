%include "./string.asm"
%include "./testing.asm"
    global _start

    section .data
testing_char_message:       db  "Testing char"
testing_char_len:           equ $ - testing_char_message

testing_length_message:     db  "Testing length"
testing_length_len:         equ $ - testing_length_message

testing_freeing_message:    db  "Testing free string on stack"
testing_freeing_len:        equ $ - testing_freeing_message

item_before_string          equ 13

    section .text

_exit:
    mov     rax, 60             ; exit code syscall code
    xor     rdi, rdi            ; return 0
    syscall

_exitError:
    mov     rax, 60             ; exit code syscall code
    mov     rdi, 1              ; return 1
    syscall

_start:
    mov  rbp, rsp

    ;; add something to stack to make sure the free method works
    push item_before_string

    ;; create a 2-length string
    mov     rdi, 2
    call    string__new_onto_stack

_test_add_char_1:
    mov     rdi, rsp
    mov     rsi, 76
    call    string__insert_char

    mov     rdi, rsp
    call    testing__debug_string

_test_compare_string_length:
    mov     rsi, testing_length_message
    mov     rdx, testing_length_len
    call    testing__test

    mov     rdi, rsp
    call    string__length

    mov     rbx, 1
    call    testing__eq_rax_rbx

_test_add_char_2:
    mov     rdi, rsp
    mov     rsi, 85
    call    string__insert_char

    mov     rdi, rsp
    call    string__length

    mov     rdi, rsp
    call    testing__debug_string

_test_char_at_1:
    mov     rsi, testing_char_message
    mov     rdx, testing_char_len
    call    testing__test

    mov     rdi, rsp
    mov     rsi, 0
    call    string__char_at

    mov     rbx, 76
    call    testing__eq_rax_rbx

_test_char_at_2:
    mov     rsi, testing_char_message
    mov     rdx, testing_char_len
    call    testing__test

    mov     rdi, rsp
    mov     rsi, 1
    call    string__char_at

    mov     rbx, 85
    call    testing__eq_rax_rbx

_test_get_previous_stack_pointer:
    mov     rdi, rsp

    call string__previous_reference

    lea     rbx, [rbp - 8]
    call    testing__eq_rax_rbx

    mov     rax, [rbx]
    mov     rbx, item_before_string
    call    testing__eq_rax_rbx

_test_freeing_string:
    mov     rsi, testing_freeing_message
    mov     rdx, testing_freeing_len
    call    testing__test

    mov     rdi, rsp
    call    string__stack_free

    pop     rax
    mov     rbx, item_before_string
    call    testing__eq_rax_rbx

_bye:
    jmp     _exit
