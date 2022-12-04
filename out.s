.text
    .global _start

_start:

    pushq    $5
    pushq    $4
    pushq    $2
    popq    %rax
    popq    %rbx
    subq    %rbx, %rax
    pushq     %rax

    pushq    $5
    pushq    $1
    popq    %rax
    popq    %rbx
    subq    %rbx, %rax
    pushq     %rax

    popq    %rax
    popq    %rbx
    imulq    %rbx, %rax
    pushq     %rax

    popq    %rax
    popq    %rbx
    addq    %rbx, %rax
    pushq     %rax

    popq    %rbx
    movq    $1, %rax
    int     $0x80

