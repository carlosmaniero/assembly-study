%include "./string.asm"
%include "./testing.asm"
    global _start

    section .data
testing_char_message:           db  "Testing char"
testing_char_len:               equ $ - testing_char_message

testing_pop_char_message:       db  "Testing poping char"
testing_pop_char_len:           equ $ - testing_pop_char_message

testing_length_message:         db  "Testing length"
testing_length_len:             equ $ - testing_length_message

testing_freeing_message:        db  "Testing free string on stack"
testing_freeing_len:            equ $ - testing_freeing_message

testing_comparing_same_message: db  "Testing comparing same strings"
testing_comparing_same_len:     equ $ - testing_comparing_same_message

testing_comparing_0_message:    db  "Testing comparing zero length strings"
testing_comparing_0_len:        equ $ - testing_comparing_0_message

testing_comparing_diff_message: db  "Testing comparing not equals strings"
testing_comparing_diff_len:     equ $ - testing_comparing_diff_message

item_before_string              equ 13

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
    ;; add something to stack to make sure the free method works
    push item_before_string

    mov  rbp, rsp

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
    mov     rdi, testing_length_len
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
    mov     rdi, testing_char_len
    call    testing__test

    mov     rdi, rsp
    mov     rsi, 0
    call    string__char_at

    mov     rbx, 76
    call    testing__eq_rax_rbx

_test_char_at_2:
    mov     rsi, testing_char_message
    mov     rdi, testing_char_len
    call    testing__test

    mov     rdi, rsp
    mov     rsi, 1
    call    string__char_at

    mov     rbx, 85
    call    testing__eq_rax_rbx

_test_get_previous_stack_pointer:
    mov     rdi, rsp

    call string__previous_reference

_bp:
    lea     rbx, [rbp]
    call    testing__eq_rax_rbx

    mov     rax, [rbx]
    mov     rbx, item_before_string
    call    testing__eq_rax_rbx

_test_pop_char:
    mov     rsi, testing_pop_char_message
    mov     rdi, testing_pop_char_len
    call    testing__test

    mov     rax, [rsp]          ; add stirng length to rax
    cmp     rax, 2              ; compare rax with 2
    call    testing__true

    mov     rdi, rsp
    call    string__pop

    mov     rax, [rsp]          ; add string length to rax
    cmp     rax, 1              ; compare rax with 2
    call    testing__true

    mov     rdi, rsp
    call    string__pop
    call    string__pop

    mov     rax, [rsp]          ; add string length to rax
    cmp     rax, 0              ; is never lower then 0
    call    testing__true

_test_freeing_string:
    mov     rsi, testing_freeing_message
    mov     rdi, testing_freeing_len
    call    testing__test

    mov     rdi, rsp
    call    string__stack_free

    pop     rax
    mov     rbx, item_before_string
    call    testing__eq_rax_rbx

_test_compare_same_strings:
    mov     rsi, testing_comparing_same_message
    mov     rdi, testing_comparing_same_len
    call    testing__test

    ;; create a 1-length string
    mov     rdi, 1
    call    string__new_onto_stack

    mov     rdi, rsp
    mov     rsi, rsp

    call    string__equals
    call    testing__true

_test_compare_zero_length_strings:
    mov     rsi, testing_comparing_0_message
    mov     rdi, testing_comparing_0_len
    call    testing__test

    ;; create a 2-length string
    mov     rdi, 2
    call    string__new_onto_stack

    mov     rdi, rsp
    push    rsp

    call    string__previous_reference
    push    rax

    mov     rdi, [rsp]          ; move to rdi the previous string position
    mov     rsi, [rsp + 8]      ; move to rsi the current string position

    call    string__equals

    call    testing__true

_test_compare_not_equals_length_strings:
    mov     rsi, testing_comparing_diff_message
    mov     rdi, testing_comparing_diff_len
    call    testing__test

    mov     rdi, [rsp]          ; move to rdi the previous string position
    mov     rsi, 85
    call    string__insert_char
    call    testing__debug_string

    mov     rdi, [rsp]          ; move to rdi the previous string position
    mov     rsi, [rsp + 8]      ; move to rsi the current string position
    call    string__equals

    call    testing__false

    mov     rdi, [rsp + 8]      ; move to rdi the current string position
    mov     rsi, 86
    call    string__insert_char

    call    testing__debug_string

    mov     rdi, [rsp]          ; move to rdi the previous string position
    mov     rsi, [rsp + 8]      ; move to rsi the current string position

    call    string__equals

    call    testing__false

    ;; Add the same content to return true
    mov     rdi, [rsp + 8]      ; move to rdi the current string position
    call    string__pop

    mov     rdi, [rsp + 8]      ; move to rdi the current string position
    mov     rsi, 85
    call    string__insert_char
    call    testing__debug_string

    mov     rdi, [rsp]          ; move to rdi the previous string position
    mov     rsi, [rsp + 8]      ; move to rsi the current string position

    call    string__equals
    call    testing__true


_bye:
    jmp     _exit
