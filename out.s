.text
    .global _start

_start:

    pushq	%rbp
    movq	%rsp, %rbp
    subq    $4, %rsp
    movl	$2, -4(%rbp)

    pushq    $3
    pushq    $2
    pushq    $1
    popq    %rax
    popq    %rbx
    addl    %ebx, %eax
    pushq     %rax

    popq    %rax
    popq    %rbx
    imull    %ebx, %eax
    pushq     %rax

    popq    %rax
    movl	%eax, -4(%rbp)

    pushq    -4(%rbp)
    popq    %rbx
    movl    $1, %eax
    int     $0x80

