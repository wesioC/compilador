.text
    .global _start

_start:

    pushq	%rbp
    movq	%rsp, %rbp
    movq	$10, -8(%rbp)
    movq	$11, -4(%rbp)
    pushq    -8(%rbp)
    pushq    -4(%rbp)
    popq    %rax
    popq    %rbx
    addq    %rbx, %rax
    pushq     %rax

    popq    %rbx
    movq    $1, %rax
    int     $0x80

