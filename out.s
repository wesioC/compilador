.text
    .global _start

_start:

    movq    $20, %rbx
    mult    $2, %rbx
    movq    $1, %rax
    int     $0x80

