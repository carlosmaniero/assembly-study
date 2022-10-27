            global _start
            section .text

_exit:      mov     rax, 60     ; exit code syscall code
            xor     rdi, rdi    ; return 0
            syscall

_write:
            mov     rdi, 1      ; stdout fd (stdout)
            mov     rax, 1      ; write syscall
            syscall
            ret

_writes:    
            pop     rbp
            pop     rsi
            pop     rdx
            mov     rdi, 1      ; stdout fd (stdout)
            mov     rax, 1      ; write syscall
            syscall
            jmp     rbp

_start:
            push    13
            push    message
            call    _writes
            jmp    _exit

            section .data
message:    db   "Hello, World", 10      ; note the newline at the end
