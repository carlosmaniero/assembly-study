%include "./string.asm"
%include "./testing.asm"
    global _start

    section .data
comparing_char_message:       db  "Comparing char"
comparing_char_len:           equ $ - comparing_char_message

comparing_length_message:     db  "Comparing length"
comparing_length_len:         equ $ - comparing_length_message

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
    ;; Create a 2-length string
    mov     rdi, 2
    call    string__new_onto_stack

_add_char1:
    mov     rdi, rsp
    mov     rsi, 76
    call    string__insert_char

    mov     rdi, rsp
    call    testing__debug_string

_compare_string_length:
    mov     rsi, comparing_length_message
    mov     rdx, comparing_length_len
    call    testing__test

    mov     rdi, rsp
    call    string__length

    mov     rbx, 1
    call    testing__eq_rax_rbx

    mov     rsi, comparing_char_message
    mov     rdx, comparing_char_len

_add_char2:
    mov     rdi, rsp
    mov     rsi, 85
    call    string__insert_char

    mov     rdi, rsp
    call    string__length

    mov     rdi, rsp
    call    testing__debug_string

_compare_char1:
    mov     rdi, rsp
    mov     rsi, 0
    call    string__char_at

    call    testing__test

    mov     rbx, 76
    call    testing__eq_rax_rbx

_compare_char2:
    mov     rdi, rsp
    mov     rsi, 1
    call    string__char_at

    mov     rbx, 84
    call    testing__eq_rax_rbx


_bye:
    jmp     _exit
