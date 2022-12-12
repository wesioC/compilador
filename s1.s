.text
    .global _start

_start:
    call    teste

    movq    %rax, %rbx
    movq    $1,%rax 
    int     $0x80
   
teste:
    pushq	%rbp
	movq	%rsp, %rbp
    movl	$5, -8(%rbp)
	movl	$10, -4(%rbp)
	movl	-8(%rbp), %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax

    movq	%rbp, %rsp
	popq	%rbp
	ret
    

