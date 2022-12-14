.text
    .global _start

_start:

    pushq	%rbp
    movq	%rsp, %rbp
    movl	$12, -4(%rbp)
    movl	$0, -8(%rbp)
    pushq    -4(%rbp)
    pushq    $2
    popq    %rax
    popq    %rbx
    imull    %ebx, %eax
    pushq     %rax

    popq    %rax
    movl	%eax, -4(%rbp)
    
    movl	-8(%rbp), %eax
    pushq    -8(%rbp)
    popq    %rbx
    movl    $1, %eax
    int     $0x80

