%include "./string.asm"
%include "./io.asm"

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

_testing__print_line:
    mov     rdi, testing__split_len
    mov     rsi, testing__split_message
    call    io__print
    ret

;;; Print a test case
;;;
;;; Arguments:
;;; rdi: the string length
;;; rsi: the string pointer
testing__test:
    push    rdi
    push    rsi

    call _testing__print_line

    ;; print sufix
    mov     rdi, testing__test_len
    mov     rsi, testing__test_message
    call    io__print

    ;; print test case
    pop     rsi
    pop     rdi
    call    io__print

    call _testing__print_line

    ret

;;; Show failure message and exit the application
testing__exit_fail:
    mov     rsi, testing__fail_message
    mov     rdi, testing__fail_len
    call    io__print
    mov     rax, testing__EXIT_SYSCALL
    mov     rdi, testing__EXIT_CODE_FAIL
    syscall

;;; Show sucess message and return to callee
testing__success:
    mov     rsi, testing__success_message
    mov     rdi, testing__success_len
    jmp     io__print

_check_equals_flag:
    jne testing__exit_fail
    jmp testing__success

_check_ne_flag:
    je  testing__exit_fail
    jmp testing__success

;;; Expects the ZF to be set
testing__true:
    ;; print message
    mov     rdi, testing__true_len
    mov     rsi, testing__true_message
    call    io__print

    jmp _check_equals_flag

;;; Expects the ZF to be not set
testing__false:
    ;; print message
    mov     rdi, testing__false_len
    mov     rsi, testing__false_message
    call    io__print

    jmp _check_ne_flag

;;; Expects RAX to be equal RBX
;;;
;;; Arguments:
;;; rax: first item
;;; rbx: seccond item
testing__eq_rax_rbx:
    ;; print message
    mov     rdi, testing__eq_rax_rbx_len
    mov     rsi, testing__eq_rax_rbx_message

    push    rax
    push    rbx
    call    io__print
    pop     rbx
    pop     rax

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
    mov     rdi, testing__debug_str_len
    call    io__print

    pop     rsi
    pop     rdx
    pop     rdi
    pop     rax

    call    string__print

    mov     rsi, testing__NL
    mov     rdi, 1
    jmp     io__print
