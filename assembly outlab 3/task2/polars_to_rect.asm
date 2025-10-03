section .data

complex1:
    complex1_name db 'a'
    complex1_pad  db 7 dup(0)  
    complex1_real dq 1.0
    complex1_img  dq 2.5

complex2:
    complex2_name db 'b'
    complex2_pad  db 7 dup(0)  
    complex2_real dq 3.5
    complex2_img  dq 4.0

polar_complx:
    polar_complx_name db 'c'
    polar_complx_pad db 7 dup(0)
    polar_complx_mag dq 10.0
    polar_complx_ang dq 0.0001

fmt db "%s => %f %f", 10, 0     ;
label_polar2rect db "Testing polars to rectangular",0
label_exp db "Testing exp",0
label_sin db "Testing sin",0
label_cos db "Testing cos",0

;;;;;;;;;;;;;
six dq 6.0
two dq 2.0
one dq 1.0
temp dq 0.0
three dq 3.0
onetwenty dq 120.0
fivezerofourzero dq 5040.0
twentyfour dq 24.0
seventwenty dq 720.0
;;;; Fill other constants needed 
;;;;;;;;;;;;;

temp_cmplx:
    temp_name db 'r'
    temp_pad  db 7 dup(0)
    temp_real dq 0.0
    temp_img  dq 0.0

section .text
    default rel
    extern print_cmplx,print_float
    global main

main:
    push rbp
    
    ; --- Test: Polar to Rectangular ---
    lea rdi, [polar_complx]         ; pointer to input polar struct
    lea rsi, [temp_cmplx]     ; pointer to output rect struct
    
    call polars_to_rect

    lea rdi, [label_polar2rect]
    lea rsi, [temp_cmplx]
    call print_cmplx          ; should show converted rectangular form

    ; --- Test: exp ---
    movups xmm0, [two]
    mov rdi, 0x6

    call exp

    movups [temp],xmm0 
    lea rdi, [label_exp]
    lea rsi , [temp]
    call print_float

    ; --- Test: sin ---
    movups xmm0, [two]

    call sin

    movups [temp],xmm0 
    lea rdi, [label_sin]
    lea rsi , [temp]
    call print_float

    ; --- Test: cos ---
    movups xmm0, [two]
    call cos

    movups [temp],xmm0 
    lea rdi, [label_cos]
    lea rsi , [temp]
    call print_float

    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FILL FUNCTIONS BELOW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
polars_to_rect:
;-------------------------------------------------
    push rbp
    push r12
    push r13
   

    mov r12,rdi
    mov r13,rsi
    mov rbp,rsp
    sub rsp,32
    movaps [rsp+16],xmm2
    movaps [rsp],xmm1
    movq xmm1,[r12+16]
    movq xmm2,[r12+8]

    movq xmm0,xmm1
    call cos

    mulsd xmm0,xmm2
    movq [r13+8],xmm0

    movq xmm0,xmm1
    call sin

    mulsd xmm0,xmm2
    movq [r13+16],xmm0

    movaps xmm2,[rsp+16]
    movaps xmm1,[rsp]
    add rsp,32

    pop r13
    pop r12
    pop rbp
exp:
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov rbp,rsp
    sub rsp,16

    movaps [rsp],xmm1

    mov r12,rdi
    movq xmm1, qword [one];xmm2=temp;
    jmp exp_loop
exp_loop:
    cmp r12,0
    je exp_end
    mulsd xmm1,xmm0
    dec r12
    jmp exp_loop
exp_end:
    movq xmm0,xmm1
    movaps xmm1,[rsp]
    add rsp,16
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

sin:
    push rbp
    push r12
    push r13
    push r14
    push r15

    movq r12,xmm0
    mov rbp,rsp
    sub rsp,16
    movaps [rsp],xmm1

    movq xmm1,xmm0

    mov rdi,0x3
    call exp

    divsd xmm0,[six]
    subsd xmm1,xmm0

    movq xmm0,r12
    mov rdi,0x5
    call exp

    divsd xmm0,[onetwenty]
    addsd xmm1,xmm0

    movq xmm0,r12
    mov rdi,0x7
    call exp

    divsd xmm0,[fivezerofourzero]
    subsd xmm1,xmm0

    movq xmm0,xmm1
    movaps xmm1,[rsp]
    add rsp,16
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

cos:
    push rbp
    push r12
    push r13
    push r14
    push r15

    movq r12,xmm0
    mov rbp,rsp
    sub rsp,16
    movaps [rsp],xmm1 

    movq xmm1,[one]

    mov rdi,0x2
    call exp

    divsd xmm0,[two]
    subsd xmm1,xmm0

    movq xmm0,r12
    mov rdi,0x4
    call exp

    divsd xmm0,[twentyfour]
    addsd xmm1,xmm0

    movq xmm0,r12
    mov rdi,0x6
    call exp

    divsd xmm0,[seventwenty]
    subsd xmm1,xmm0

    movq xmm0,xmm1
    movaps xmm1,[rsp]
    add rsp,16
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


;-------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CODE ENDS HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
