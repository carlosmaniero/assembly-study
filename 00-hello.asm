          global    _start

          section   .text
_exit:
          mov       rax, 60                 ; system call for exit
          mov       rdi, 0                  ; exit code 0
          syscall                           ; invoke operating system to exit
_start:   mov       rax, 1                  ; system call for write
          mov       rdi, 1                  ; file handle 1 is stdout
          mov       rsi, message            ; address of string to output
          mov       rdx, 13                 ; number of bytes
          syscall                           ; invoke operating system to do the write
          jmp       _exit

          section   .data
message:  db        "Hello, World", 10      ; note the newline at the end
