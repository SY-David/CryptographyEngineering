.syntax unified
.thumb
.text

.global poly_add_s
.type poly_add_s, %function
poly_add_s:
    movs    r12, #128
loop1:
    ldrh    r3, [r1], #2
    ldrh    r4, [r1], #2
    pkhbt   r3, r3, r4

    ldrh    r4, [r2], #2
    ldrh    r5, [r2], #2
    pkhbt   r4, r4, r5

    uadd16  r3, r3, r4
    strh    r3, [r0], #2
    lsrs    r4, r3, #16
    strh    r4, [r0], #2

    subs    r12, r12, #1
    bne     loop1
    bx      lr

.global poly_sub_s
.type poly_sub_s, %function
poly_sub_s:
    movs    r12, #128
loop2:
    ldrh    r3, [r1], #2
    ldrh    r4, [r1], #2
    pkhbt   r3, r3, r4

    ldrh    r4, [r2], #2
    ldrh    r5, [r2], #2
    pkhbt   r4, r4, r5

    usub16  r3, r3, r4
    strh    r3, [r0], #2
    lsrs    r4, r3, #16
    strh    r4, [r0], #2

    subs    r12, r12, #1
    bne     loop2
    bx      lr
