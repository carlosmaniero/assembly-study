            global _start
            section .text

_exit:      mov     rax, 60             ; exit code syscall code
            xor     rdi, rdi            ; return 0
            syscall

_write:
            mov     rax, 1              ; write syscall
            mov     rdi, 1              ; stdout fd
            syscall
            ret

_read:
            pop     r9                 ; pop return position
            pop     r8                 ; pop string len

            ; invert the stack keeping the return value at the bottom
            push    r9
            push    r8

_readLoop:
            mov     rax, 0              ; read syscall
            mov     rdi, 0              ; stdin fd
            mov     rdx, 1              ; reading size
            push    0                   ; make room in the stack for the char
            mov     rsi, rsp            ; points rsi to the stack position
            syscall

            pop     rax                 ; pop the result into rax
            pop     rdi                 ; pop string len

            cmp     rax, 0              ; is it eof?
            je     _str2int

            cmp     rax, 10             ; is it new line?
            je     _str2int

            ; increment the counter and keep it at the top of the stack
            push    rax
            inc     rdi
            push    rdi

            ; read next char
            jmp     _readLoop

; Function arguments:
; rdi = base number
; rsi = expoent number
;
; Return
; rax = solution
_powerLoop:
            cmp     rsi, 0
            je      _return
            mul     rdi
            dec     rsi
            jmp     _powerLoop

_power0:
            mov     rax, 1
            ret

_power:
            cmp     rsi, 0              ; deal with power zero case
            je      _power0

            mov     rax, rdi
            dec     rsi

            jmp     _powerLoop

; Function arguments:
; rsi = expoent number
;
; Return
; rax = solution
_power10:
            mov     rdi, 10
            jmp    _power

_str2int:
            mov     rsi, 0              ; counter iteration control
            mov     rax, 0              ; the number returned

_str2intLoop:
            cmp     rdi, rsi            ; stop the loop when the counter reaches the total numbers
            je      _return
            pop     r9                  ; get the char from stack
            sub     r9, 48              ; convert the char to int

            ; add the current registers to stack
            push    rax
            push    rdi
            push    rsi
            call    _power10
            ; Recover the registers
            pop     rsi
            pop     rdi
            pop     r8                  ; the rax is recovered at r8 once the result of mul is store in rax

            mul     r9                  ; rax = r9 * rax
            add     rax, r8

            inc     rsi                 ; update the iteration counter

            jmp     _str2intLoop


; Convert int to str
; rdi = the number to be converted
;
; Return Value
;
_int2Str:
            push 0                      ; the string len, it must always be at the top of the stack
_int2StrLoop:



; Just a helper to jump when need to return
_return:
            ret

_start:
            push    0                   ; reserve a space for the string len onto stack
            call    _read

            mov     rdx, messageLen
            mov     rsi, message
            call    _write
            jmp    _exit

            section .data
message:    db   "Hello, World", 10      ; note the newline at the end
messageLen: equ $ - message
