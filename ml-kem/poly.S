.syntax unified
.thumb
.text

.global poly_add_s
.type poly_add_s, %function
poly_add_s:
    movs    r12, #128
loop1:
    ldr     r3, [r1], #4
    ldr     r4, [r2], #4
    uadd16  r3, r3, r4
    str     r3, [r0], #4
    subs    r12, r12, #1
    bne     loop1
    bx      lr

.global poly_sub_s
.type poly_sub_s, %function
poly_sub_s:
    movs    r12, #128
loop2:
    ldr     r3, [r1], #4
    ldr     r4, [r2], #4
    usub16  r3, r3, r4
    str     r3, [r0], #4
    subs    r12, r12, #1
    bne     loop2
    bx      lr
