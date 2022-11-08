%ifndef MANIIO
%define MANIIO
    section .data
IO__STDOUT_FD:          equ 1
IO__EXIT_CODE_FAIL:     equ 1
IO__WRITE_SYSCALL:      equ 1
IO__EXIT_SYSCALL:       equ 60
IO__NL:                 db 10

    section .text
;;; prints a string
;;;
;;; Arguments:
;;; rdi: the string length
;;; rsi: the string pointer
;;; rsp: the return position
io__print:
    push    rdi
    mov     rdx, [rsp]
    mov     rdi, IO__STDOUT_FD
    mov     rax, IO__WRITE_SYSCALL
    syscall
    pop     rdi
    ret
%endif
