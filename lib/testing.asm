%include "./string.asm"

    section .data
testing__STDOUT_FD:          equ 1
testing__EXIT_CODE_FAIL:     equ 1
testing__WRITE_SYSCALL:      equ 1
testing__EXIT_SYSCALL:       equ 60
testing__NL:                 db 10

testing__eq_rax_rbx_message: db  "Expecting rax = rbx: "
testing__eq_rax_rbx_len:     equ $ - testing__eq_rax_rbx_message

testing__true_message:       db  "Expecting true: "
testing__true_len:           equ $ - testing__true_message

testing__false_message:      db  "Expecting false: "
testing__false_len:          equ $ - testing__false_message

testing__fail_message:       db  `\033[0;31mFailed!\033[0m`, 10
testing__fail_len:           equ $ - testing__fail_message

testing__success_message:    db  `\033[0;32mOk\033[0m`, 10
testing__success_len:        equ $ - testing__success_message

testing__test_message:       db  `\033[1;34m⚙ Test case: `
testing__test_len:           equ $ - testing__test_message

testing__debug_str_message:  db  10, `\033[1;36m⚠️ Debug string: \033[0m`
testing__debug_str_len:      equ $ - testing__debug_str_message

testing__split_message:      db 10, `\033[1;34m------------------------------------------------------------\033[0m`, 10
testing__split_len:          equ $ - testing__split_message

    section .text
testing__stdout:
    push    rax
    push    rdi
    mov     rdi, testing__STDOUT_FD
    mov     rax, testing__WRITE_SYSCALL
    syscall
    pop     rdi
    pop     rax
    ret

testing__print_div:
    mov     rdx, testing__split_len
    mov     rsi, testing__split_message
    call    testing__stdout
    ret

testing__test:
    push    rdx
    push    rsi

    call testing__print_div

    ;; print sufix
    mov     rdx, testing__test_len
    mov     rsi, testing__test_message
    call    testing__stdout

    ;; print test case
    pop     rsi
    pop     rdx
    call    testing__stdout

    call testing__print_div

    ret

testing__exit_fail:
    mov     rsi, testing__fail_message
    mov     rdx, testing__fail_len
    call    testing__stdout
    mov     rax, testing__EXIT_SYSCALL
    mov     rdi, testing__EXIT_CODE_FAIL
    syscall

;;; Just return to the callee
testing__success:
    mov     rsi, testing__success_message
    mov     rdx, testing__success_len
    call    testing__stdout
    ret

_check_equals_flag:
    jne testing__exit_fail
    jmp testing__success

_check_ne_flag:
    je  testing__exit_fail
    jmp testing__success

testing__true:
    ;; print message
    mov     rdx, testing__true_len
    mov     rsi, testing__true_message
    call    testing__stdout

    jmp _check_equals_flag

testing__false:
    ;; print message
    mov     rdx, testing__false_len
    mov     rsi, testing__false_message
    call    testing__stdout

    jmp _check_ne_flag

;;; Expects RAX to be equal RBX
testing__eq_rax_rbx:
    ;; print message
    mov     rdx, testing__eq_rax_rbx_len
    mov     rsi, testing__eq_rax_rbx_message
    call    testing__stdout

    cmp     rax, rbx
    jmp     _check_equals_flag

;;; Arguments:
;;; rdi: the string pointer
testing__debug_string:
    push    rax
    push    rdi
    push    rdx
    push    rsi

    mov     rsi, testing__debug_str_message
    mov     rdx, testing__debug_str_len
    mov     rdi, testing__STDOUT_FD
    mov     rax, testing__WRITE_SYSCALL
    syscall

    pop     rsi
    pop     rdx
    pop     rdi
    pop     rax

    call    string__print

    mov     rsi, testing__NL
    mov     rdx, 1
    mov     rdi, testing__STDOUT_FD
    mov     rax, testing__WRITE_SYSCALL
    syscall

    ret
