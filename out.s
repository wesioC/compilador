.text
    .global _start

_start:

    pushq	%rbp
    movq	%rsp, %rbp
    subq    $4, %rsp
    movl	$1, -4(%rbp)
    subq    $4, %rsp
    movl	$1, -8(%rbp)
    subq    $4, %rsp
    movl	$0, -12(%rbp)
    subq    $4, %rsp
    movl	$0, -16(%rbp)
    subq    $4, %rsp
    movl	$10, -12(%rbp)
    movl	-12(%rbp), %eax
    movl	 %eax, -16(%rbp)
    movl	-16(%rbp), %eax
    pushq    -8(%rbp)
    pushq    -4(%rbp)
    popq    %rax
    popq    %rbx
    addl    %ebx, %eax
    pushq     %rax

    pushq    $1
    popq    %rbx
    popq    %rax
    subl    %ebx, %eax
    pushq     %rax

    popq    %rax
    movl	%eax, -8(%rbp)

    pushq    $10
    pushq    $2
    popq    %rax
    popq    %rbx
    addl    %ebx, %eax
    pushq     %rax

    pushq    $1
    popq    %rbx
    popq    %rax
    subl    %ebx, %eax
    pushq     %rax

    popq    %rax
    movl	%eax, -12(%rbp)

    pushq    -12(%rbp)
    pushq    $2
    pushq    -8(%rbp)
    popq    %rbx
    popq    %rax
    subl    %ebx, %eax
    pushq     %rax

    popq    %rax
    popq    %rbx
    addl    %ebx, %eax
    pushq     %rax

    popq    %rax
    movl	%eax, -16(%rbp)

    pushq    -8(%rbp)
    pushq    -16(%rbp)
    pushq    -12(%rbp)
    popq    %rax
    popq    %rbx
    imull    %ebx, %eax
    pushq     %rax

    popq    %rax
    popq    %rbx
    addl    %ebx, %eax
    pushq     %rax

    popq    %rbx
    movl    $1, %eax
    int     $0x80

