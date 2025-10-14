.syntax unified
.text
.align 2
.global BIGLIMB
.type BIGLIMB, %function

BIGLIMB:
    push    {r4-r11, lr}@ ...
    sub     sp, sp, #160

    mov     r8, sp              @ f limbs base
    add     r9, r8, #40         @ g limbs base
    add     r10, r9, #40        @ h limbs base (int64[10])
    mov     r11, #19            @ constant 19

    @ -------------------------
    @ f0..f4 from a (r0)
    @ -------------------------
    ldr     r4, [r0, #0]
    ldr     r5, [r0, #4]
    ldr     r6, [r0, #8]
    ldr     r7, [r0, #12]

    ubfx    r3, r4, #0, #26
    str     r3, [r8, #0]

    lsrs    r3, r4, #26
    orr     r3, r3, r5, lsl#6
    bfc     r3, #25, #7
    str     r3, [r8, #4]

    lsrs    r3, r5, #19
    orr     r3, r3, r6, lsl#13
    bfc     r3, #26, #6
    str     r3, [r8, #8]

    lsrs    r3, r6, #13
    orr     r3, r3, r7, lsl#19
    bfc     r3, #25, #7
    str     r3, [r8, #12]

    ubfx    r3, r7, #6, #26
    str     r3, [r8, #16]

    @ -------------------------
    @ f5..f9 from a (r0)
    @ -------------------------
    ldr     r4, [r0, #16]
    ldr     r5, [r0, #20]
    ldr     r6, [r0, #24]
    ldr     r7, [r0, #28]

    ubfx    r3, r4, #0, #25
    str     r3, [r8, #20]

    lsrs    r3, r4, #25
    orr     r3, r3, r5, lsl#7
    bfc     r3, #26, #6
    str     r3, [r8, #24]

    lsrs    r3, r5, #19
    orr     r3, r3, r6, lsl#13
    bfc     r3, #25, #7
    str     r3, [r8, #28]

    lsrs    r3, r6, #12
    orr     r3, r3, r7, lsl#20
    bfc     r3, #26, #6
    str     r3, [r8, #32]

    ubfx    r3, r7, #6, #25
    str     r3, [r8, #36]

    @ -------------------------
    @ g0..g4 from b (r1)
    @ -------------------------
    ldr     r4, [r1, #0]
    ldr     r5, [r1, #4]
    ldr     r6, [r1, #8]
    ldr     r7, [r1, #12]

    ubfx    r3, r4, #0, #26
    str     r3, [r9, #0]

    lsrs    r3, r4, #26
    orr     r3, r3, r5, lsl#6
    bfc     r3, #25, #7
    str     r3, [r9, #4]

    lsrs    r3, r5, #19
    orr     r3, r3, r6, lsl#13
    bfc     r3, #26, #6
    str     r3, [r9, #8]

    lsrs    r3, r6, #13
    orr     r3, r3, r7, lsl#19
    bfc     r3, #25, #7
    str     r3, [r9, #12]

    ubfx    r3, r7, #6, #26
    str     r3, [r9, #16]

    @ -------------------------
    @ g5..g9 from b (r1)
    @ -------------------------
    ldr     r4, [r1, #16]
    ldr     r5, [r1, #20]
    ldr     r6, [r1, #24]
    ldr     r7, [r1, #28]

    ubfx    r3, r4, #0, #25
    str     r3, [r9, #20]

    lsrs    r3, r4, #25
    orr     r3, r3, r5, lsl#7
    bfc     r3, #26, #6
    str     r3, [r9, #24]

    lsrs    r3, r5, #19
    orr     r3, r3, r6, lsl#13
    bfc     r3, #25, #7
    str     r3, [r9, #28]

    lsrs    r3, r6, #12
    orr     r3, r3, r7, lsl#20
    bfc     r3, #26, #6
    str     r3, [r9, #32]

    ubfx    r3, r7, #6, #25
    str     r3, [r9, #36]

    @ -------------------------
    @ Compute h = f * g (Comba style via convolution)
    @ -------------------------
    movs    r4, #0 @ i = 0

1:
    movs    r5, #0              @ j = 0
    movs    r6, #0              @ acc_lo
    movs    r7, #0              @ acc_hi

2:
    add     r12, r8, r5, lsl#2
    ldr     r0, [r12]@ f_j
    subs    r12, r4, r5
    bge     3f
    add     r12, r12, #10
    add     r3, r9, r12, lsl#2
    ldr     r3, [r3]
    mul     r3, r3, r11 @ 19 * g_k
    b       4f

3:
    add     r3, r9, r12, lsl#2
    ldr     r3, [r3]

4:
    umlal   r6, r7, r0, r3
    add     r5, r5, #1
    cmp     r5, #10
    blt     2b

    add     r12, r10, r4, lsl#3
    str     r6, [r12, #0]
    str     r7, [r12, #4]

    add     r4, r4, #1
    cmp     r4, #10
    blt     1b

    @ -------------------------
    @ Carry propagation (same as C implementation)
    @ -------------------------
    movw    r0, #0
    movt    r0, #0x0200 @ 1 << 25
    movw    r1, #0
    movt    r1, #0x0100 @ 1 << 24

    @ carry0
    ldr     r4, [r10, #0]
    ldr     r5, [r10, #4]
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6

    ldr     r7, [r10, #8]
    ldr     r8, [r10, #12]
    adds    r7, r7, r6
    adc     r8, r8, #0

    lsl     r9, r6, #26
    lsr     r3, r6, #6
    subs    r4, r4, r9
    sbc     r5, r5, r3

    str     r4, [r10, #0]
    str     r5, [r10, #4]
    str     r7, [r10, #8]
    str     r8, [r10, #12]

    @ carry1
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7

    ldr     r4, [r10, #16]
    ldr     r5, [r10, #20]
    adds    r4, r4, r6
    adc     r5, r5, #0

    lsl     r9, r6, #25
    lsr     r3, r6, #7
    subs    r7, r7, r9
    sbc     r8, r8, r3

    str     r7, [r10, #8]
    str     r8, [r10, #12]
    str     r4, [r10, #16]
    str     r5, [r10, #20]

    @ carry2
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6

    ldr     r7, [r10, #24]
    ldr     r8, [r10, #28]
    adds    r7, r7, r6
    adc     r8, r8, #0

    lsl     r9, r6, #26
    lsr     r3, r6, #6
    subs    r4, r4, r9
    sbc     r5, r5, r3

    str     r4, [r10, #16]
    str     r5, [r10, #20]
    str     r7, [r10, #24]
    str     r8, [r10, #28]

    @ carry3
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7

    ldr     r4, [r10, #32]
    ldr     r5, [r10, #36]
    adds    r4, r4, r6
    adc     r5, r5, #0

    lsl     r9, r6, #25
    lsr     r3, r6, #7
    subs    r7, r7, r9
    sbc     r8, r8, r3

    str     r7, [r10, #24]
    str     r8, [r10, #28]
    str     r4, [r10, #32]
    str     r5, [r10, #36]

    @ carry4
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6

    ldr     r7, [r10, #40]
    ldr     r8, [r10, #44]
    adds    r7, r7, r6
    adc     r8, r8, #0

    lsl     r9, r6, #26
    lsr     r3, r6, #6
    subs    r4, r4, r9
    sbc     r5, r5, r3

    str     r4, [r10, #32]
    str     r5, [r10, #36]
    str     r7, [r10, #40]
    str     r8, [r10, #44]

    @ carry5
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7

    ldr     r4, [r10, #48]
    ldr     r5, [r10, #52]
    adds    r4, r4, r6
    adc     r5, r5, #0

    lsl     r9, r6, #25
    lsr     r3, r6, #7
    subs    r7, r7, r9
    sbc     r8, r8, r3

    str     r7, [r10, #40]
    str     r8, [r10, #44]
    str     r4, [r10, #48]
    str     r5, [r10, #52]

    @ carry6
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6

    ldr     r7, [r10, #56]
    ldr     r8, [r10, #60]
    adds    r7, r7, r6
    adc     r8, r8, #0

    lsl     r9, r6, #26
    lsr     r3, r6, #6
    subs    r4, r4, r9
    sbc     r5, r5, r3

    str     r4, [r10, #48]
    str     r5, [r10, #52]
    str     r7, [r10, #56]
    str     r8, [r10, #60]

    @ carry7
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7

    ldr     r4, [r10, #64]
    ldr     r5, [r10, #68]
    adds    r4, r4, r6
    adc     r5, r5, #0

    lsl     r9, r6, #25
    lsr     r3, r6, #7
    subs    r7, r7, r9
    sbc     r8, r8, r3

    str     r7, [r10, #56]
    str     r8, [r10, #60]
    str     r4, [r10, #64]
    str     r5, [r10, #68]

    @ carry8
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6

    ldr     r7, [r10, #72]
    ldr     r8, [r10, #76]
    adds    r7, r7, r6
    adc     r8, r8, #0

    lsl     r9, r6, #26
    lsr     r3, r6, #6
    subs    r4, r4, r9
    sbc     r5, r5, r3

    str     r4, [r10, #64]
    str     r5, [r10, #68]
    str     r7, [r10, #72]
    str     r8, [r10, #76]

    @ carry9
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7

    mul     r3, r6, r11 @ carry9 * 19
    ldr     r4, [r10, #0]
    ldr     r5, [r10, #4]
    adds    r4, r4, r3
    adc     r5, r5, #0

    lsl     r9, r6, #25
    lsr     r3, r6, #7
    subs    r7, r7, r9
    sbc     r8, r8, r3

    str     r4, [r10, #0]
    str     r5, [r10, #4]
    str     r7, [r10, #72]
    str     r8, [r10, #76]

    @ carry0 (again)
    ldr     r4, [r10, #0]
    ldr     r5, [r10, #4]
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6

    ldr     r7, [r10, #8]
    ldr     r8, [r10, #12]
    adds    r7, r7, r6
    adc     r8, r8, #0

    lsl     r9, r6, #26
    lsr     r3, r6, #6
    subs    r4, r4, r9
    sbc     r5, r5, r3

    str     r4, [r10, #0]
    str     r5, [r10, #4]
    str     r7, [r10, #8]
    str     r8, [r10, #12]

    @ carry1 (again)
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7

    ldr     r4, [r10, #16]
    ldr     r5, [r10, #20]
    adds    r4, r4, r6
    adc     r5, r5, #0

    lsl     r9, r6, #25
    lsr     r3, r6, #7
    subs    r7, r7, r9
    sbc     r8, r8, r3

    str     r7, [r10, #8]
    str     r8, [r10, #12]
    str     r4, [r10, #16]
    str     r5, [r10, #20]

    @ -------------------------
    @ Store reduced limbs (low 32 bits) to out pointer (r2)
    @ -------------------------
    movs    r4, #0

5:
    add     r12, r10, r4, lsl#3
    ldr     r6, [r12, #0]
    str     r6, [r2, r4, lsl#2]
    add     r4, r4, #1
    cmp     r4, #10
    blt     5b

    add     sp, sp, #160
    pop     {r4-r11, pc}

.size BIGLIMB, .-BIGLIMB
