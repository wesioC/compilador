.text
    .global _start

_start:

    pushq	%rbp
    movq	%rsp, %rbp
    movl	$0, -4(%rbp)
    movl	$2, -8(%rbp)
    pushq    -8(%rbp)
    pushq    $2
    popq    %rax
    popq    %rbx
    imull    %ebx, %eax
    pushq     %rax

    popq    %rax
    movl	%eax, -4(%rbp)

    pushq    -8(%rbp)
    pushq    -4(%rbp)
    popq    %rax
    popq    %rbx
    addl    %ebx, %eax
    pushq     %rax

    popq    %rbx
    movl    $1, %eax
    int     $0x80

