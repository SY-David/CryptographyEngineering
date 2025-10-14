.syntax unified
.text
.align 2
.global BIGLIMB
.type BIGLIMB, %function

BIGLIMB:
    push    {r4-r11, lr}
    sub     sp, sp, #160

    mov     r8, sp              @ f limbs base
    add     r9, r8, #40         @ g limbs base
    add     r10, r9, #40        @ h limbs base (int64[10])
    mov     r12, r10            @ preserve h base pointer

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

    @ ----- h0 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #36]         @ g9
    add     r6, r4, r4            @ 2*f1
    add     r7, r5, r5, lsl #1    @ 3*g9
    add     r7, r7, r5, lsl #4    @ 19*g9
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #8]          @ g2
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #4]          @ g1
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    str     r10, [r12, #0]
    str     r11, [r12, #4]

    @ ----- h1 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #4]          @ g1
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #36]         @ g9
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #28]         @ g7
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #20]         @ g5
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #12]         @ g3
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #8]          @ g2
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    str     r10, [r12, #8]
    str     r11, [r12, #12]

    @ ----- h2 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #4]          @ g1
    add     r6, r4, r4            @ 2*f1
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #36]         @ g9
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    str     r10, [r12, #16]
    str     r11, [r12, #20]

    @ ----- h3 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #12]         @ g3
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #4]          @ g1
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #36]         @ g9
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #28]         @ g7
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #20]         @ g5
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    str     r10, [r12, #24]
    str     r11, [r12, #28]

    @ ----- h4 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #16]         @ g4
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #4]          @ g1
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #36]         @ g9
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    str     r10, [r12, #32]
    str     r11, [r12, #36]

    @ ----- h5 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #20]         @ g5
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #16]         @ g4
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #12]         @ g3
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #4]          @ g1
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #36]         @ g9
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #28]         @ g7
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    str     r10, [r12, #40]
    str     r11, [r12, #44]

@ ----- h6 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #24]         @ g6
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #16]         @ g4
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #4]          @ g1
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #36]         @ g9
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    str     r10, [r12, #48]
    str     r11, [r12, #52]

    @ ----- h7 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #28]         @ g7
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #24]         @ g6
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #20]         @ g5
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #16]         @ g4
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #12]         @ g3
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #4]          @ g1
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #36]         @ g9
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r4, r7

    str     r10, [r12, #56]
    str     r11, [r12, #60]

    @ ----- h8 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #32]         @ g8
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #24]         @ g6
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #16]         @ g4
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #4]          @ g1
    add     r6, r4, r4
    umlal   r10, r11, r6, r5

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #36]         @ g9
    add     r6, r4, r4
    add     r7, r5, r5, lsl #1
    add     r7, r7, r5, lsl #4
    umlal   r10, r11, r6, r7

    str     r10, [r12, #64]
    str     r11, [r12, #68]

    @ ----- h9 -----
    movs    r10, #0
    movs    r11, #0

    ldr     r4, [r8, #0]          @ f0
    ldr     r5, [r9, #36]         @ g9
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #4]          @ f1
    ldr     r5, [r9, #32]         @ g8
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #28]         @ g7
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #24]         @ g6
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #20]         @ g5
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #16]         @ g4
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #12]         @ g3
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #8]          @ g2
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #4]          @ g1
    umlal   r10, r11, r4, r5

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #0]          @ g0
    umlal   r10, r11, r4, r5

    str     r10, [r12, #72]
    str     r11, [r12, #76]


    @ -------------------------
    @ Carry propagation (same as C implementation)
    @ -------------------------
    mov     r10, r12
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

    ldr     r4, [r10, #0]
    ldr     r5, [r10, #4]

    adds    r4, r4, r6             @ + carry9
    adc     r5, r5, #0

    mov     r9, r6, lsl #1         @ low(2*carry9)
    mov     r3, r6, lsr #31        @ high(2*carry9)
    adds    r4, r4, r9
    adc     r5, r5, r3

    mov     r9, r6, lsl #4         @ low(16*carry9)
    mov     r3, r6, lsr #28        @ high(16*carry9)
    adds    r4, r4, r9
    adc     r5, r5, r3

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
    ldr     r7, [r12, #4]
    add     r3, r2, r4, lsl#3
    str     r6, [r3, #0]
    str     r7, [r3, #4]
    add     r4, r4, #1
    cmp     r4, #10
    blt     5b

    add     sp, sp, #160
    pop     {r4-r11, pc}

.size BIGLIMB, .-BIGLIMB
