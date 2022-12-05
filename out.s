.text
    .global _start

_start:

    pushq    $10
    pushq    $5
    popq    %rax
    popq    %rbx
    addq    %rbx, %rax
    pushq     %rax

    pushq    $5
    popq    %rax
    popq    %rbx
    imulq    %rbx, %rax
    pushq     %rax

    popq    %rbx
    movq    $1, %rax
    int     $0x80

