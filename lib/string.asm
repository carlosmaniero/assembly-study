%ifndef MANISTRING
%define MANISTRING
    section .data
STRING__SIZE_INDEX:         equ 8
STRING__FIRST_ITEM_INDEX:   equ STRING__SIZE_INDEX + 8

    section .text

;;; Create a string onto stack
;;;
;;; Arguments:
;;; on the top of the stack: the return position
;;; rdi: string max size
;;;
;;; Usage:
;;; mov rdi 2
;;; call string__new_onto_stack
;;;
;;; Stack after calling:
;;; [00000000 00000002 00 00]
;;;  length   size     c1 c2
;;;
;;; this function does not clean the stack so then it may have anything on c1 and c2
string__new_onto_stack:
    pop     rdx                 ; pop the return position
    sub     rsp, rdi            ; make room in the stack for the string
    push    rdi                 ; push the string size
    push    0                   ; push the string length
    jmp     rdx

;;; Insert a char into the string
;;;
;;; Arguments:
;;; rdi: string location pointer
;;; rsi: char
;;;
;;; Usage:
;;; mov rdi, <THE_STRING_POINTER>
;;; mov rsi, 49
;;; call string__insert_char
;;;
;;; Stack before calling:
;;; [00000000 00000002 00 00]
;;;  length   size     c1 c2
;;;
;;; Stack after calling:
;;; [00000001 00000002 49 00]
;;;  length   size     c1 c2
string__insert_char:
    mov     rdx, [rdi]          ; store the string length
    ;; store the less significant byte of rsi into the right position
    ;; rdi + (8) length + (8) size + char position
    mov     [rdi + STRING__FIRST_ITEM_INDEX + rdx], sil
    inc     rdx                 ; increase string length
    mov     [rdi], rdx          ; store the new length
    ret

;;; Read a char given a position
;;;
;;; Arguments:
;;; rdi: string location pointer
;;; rsi: index
;;;
;;; Return:
;;; rax: the character
string__char_at:
    xor     rax, rax            ; reset rax
    mov     al, [rdi + STRING__FIRST_ITEM_INDEX + rsi]
    ret

;;; Return the string length
;;;
;;; Arguments:
;;; rdi: string location pointer
;;;
;;; Return:
;;; rax: the length
string__length:
    xor     rax, rax            ; reset rax
    mov     rax, [rdi]
    ret

;;; Return the string length
;;;
;;; Arguments:
;;; rdi: string location pointer
string__print:
    lea     rsi, [rdi + STRING__FIRST_ITEM_INDEX]
    mov     rdx, [rdi]

    mov     rdi, 1
    mov     rax, 1

    syscall
    ret

;;; Free the stack
;;;
;;; Arguments:
;;; rdi: string location pointer
string__stack_free:
    pop     rdx                 ; pop the return location

    pop     rsi                 ; get the string size
    add     rsp, 8              ; remove the string length
    add     rsp, rsi            ; remove all chars from stack

    jmp     rdx                 ; jump to return location
%endif
