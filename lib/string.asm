%include "./io.asm"

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

;;; Remove the last char of a string
;;;
;;; Arguments:
;;; rdi: string location pointer
;;;
;;; Return:
;;; zf: is set true case there is nothing to pop
string__pop:
    cmp     word [rdi], 0
    je      string___pop_ret
    push    rdx
    mov     rdx, [rdi]
    dec     rdx
    mov     [rdi], rdx
    pop     rdx
string___pop_ret:
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
    mov     rdi, [rdi]

    jmp     io__print

;;; Return a pointer to the previous location
;;;
;;; Arguments:
;;; rdi: string location pointer
;;;
;;; Return:
;;; rax: previous location
string__previous_reference:
    mov     rax, [rdi + STRING__SIZE_INDEX] ; store the string size onto rax
    add     rax, rdi                        ; size + string position
    add     rax, STRING__FIRST_ITEM_INDEX   ; size + string position + first item index
    ret

;;; Set the ZF=1 case rdi string equals rsi
;;;
;;; Arguments:
;;; rdi: first string location pointer
;;; rsi: seccond string location pointer
string__equals:
    push    rdi
    push    rsi

    ; return true if both points to the same string
    cmp     rdi, rsi
    je      string___equals_ret

    ; check if both has the same length
    mov     rax, [rdi]          ; first string length
    mov     rbx, [rsi]          ; second string length
    cmp     rax, rbx
    jne     string___equals_ret

    ; check if size is zero
    cmp     rbx, 0
    je      string___equals_ret

    xor     rax, rax            ; ACC = 0
string___equals_loop:
    push    rax

    ;; Store the rax char from the second string in r9
    mov     rdi, [rsp + 16]
    mov     rsi, [rsp]
    call    string__char_at
    mov     r9, rax

    ;; Store the rax char from the first string in r8
    mov     rdi, [rsp + 8]
    mov     rsi, [rsp]
    call    string__char_at
    mov     r8, rax

    pop     rax

    ;; compare chars
    cmp     r9, r8
    jne     string___equals_ret

    inc     rax

    cmp     rax, rbx
    jne     string___equals_loop

string___equals_ret:
    pop     rsi
    pop     rdi
    ret

;;; Free the stack
string__stack_free:
    pop     rdx                 ; pop the return location

    add     rsp, 8              ; remove the string length
    pop     rsi                 ; get the string size
    add     rsp, rsi            ; remove all chars from stack

    jmp     rdx                 ; jump to return location
%endif
