.syntax unified
.thumb
.text

.global poly_add_s
.type poly_add_s, %function
poly_add_s:
    push        {r4-r5, lr}
    movs        r12, #128
loop1:
    ldrh        r3, [r1], #2
    ldrh        r4, [r1], #2
    pkhbt       r3, r3, r4

    ldrh        r4, [r2], #2
    ldrh        r5, [r2], #2
    pkhbt       r4, r4, r5

    uadd16      r3, r3, r4
    strh        r3, [r0], #2
    lsr         r4, r3, #16
    strh        r4, [r0], #2

    subs        r12, r12, #1
    bne         loop1
    pop         {r4-r5, pc}
.size poly_add_s, .-poly_add_s

.global poly_sub_s
.type poly_sub_s, %function
poly_sub_s:
    push        {r4-r5, lr}
    movs        r12, #128
loop2:
    ldrh        r3, [r1], #2
    ldrh        r4, [r1], #2
    pkhbt       r3, r3, r4

    ldrh        r4, [r2], #2
    ldrh        r5, [r2], #2
    pkhbt       r4, r4, r5

    usub16      r3, r3, r4
    strh        r3, [r0], #2
    lsr         r4, r3, #16
    strh        r4, [r0], #2

    subs        r12, r12, #1
    bne         loop2
    pop         {r4-r5, pc}
.size poly_sub_s, .-poly_sub_s
