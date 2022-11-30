.text
    .global _start

_start:

    pushq    $20
    pushq    $2
    popq    %rax
    popq    %rbx
    addq    %rbx, %rax
    pushq     %rax

    pushq    $2
    popq    %rax
    popq    %rbx
    imulq    %rbx, %rax
    pushq     %rax

    popq    %rbx
    movq    $1, %rax
    int     $0x80

