.syntax unified
.text
.align 2
.global BIGLIMB
.type BIGLIMB, %function

BIGLIMB:
    push    {r4-r11, lr}
    sub     sp, sp, #160

    str     r2, [sp, #0]@ 保存輸出指標

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
    add     r7, r5, r5, lsl#1     @ 3*g9
    add     r7, r7, r5, lsl#4     @ 19*g9
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #8]          @ f2
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #8]          @ g2
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #4]          @ g1
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #12]         @ f3
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #28]         @ g7
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #20]         @ g5
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #12]         @ g3
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #8]          @ g2
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #16]         @ f4
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #12]         @ g3
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #20]         @ f5
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #28]         @ g7
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #20]         @ g5
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #16]         @ g4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #24]         @ f6
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #20]         @ g5
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #28]         @ f7
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #28]         @ g7
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #24]         @ g6
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r6, r7

    ldr     r4, [r8, #32]         @ f8
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #28]         @ g7
    add     r6, r4, r4
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
    umlal   r10, r11, r4, r7

    ldr     r4, [r8, #36]         @ f9
    ldr     r5, [r9, #32]         @ g8
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    add     r7, r5, r5, lsl#1
    add     r7, r7, r5, lsl#4
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
    @ Carry propagation (64-bit correct version)
    @ -------------------------
    mov     r10, r12 @ r10 = Hbase (h0..h9 each 64-bit @ [r10 + k*8])

    @ r0 = 1<<25, r1 = 1<<24
    movw    r0, #0
    movt    r0, #0x0200
    movw    r1, #0
    movt    r1, #0x0100

    @ ===== carry0 (n=26) =====
    ldr     r4, [r10, #0]         @ h0_lo
    ldr     r5, [r10, #4]         @ h0_hi
    adds    r4, r4, r0            @ + 2^25
    adc     r5, r5, #0

    lsrs    r6, r4, #26 @ carry_lo = (h0_lo >> 26) | (h0_hi << 6)
    orr     r6, r6, r5, lsl#6
    lsrs    r3, r5, #26 @ carry_hi = h0_hi >> 26

    ldr     r7, [r10, #8]         @ h1_lo
    ldr     r8, [r10, #12]        @ h1_hi
    adds    r7, r7, r6            @ h1 += carry (64-bit)
    adc     r8, r8, r3

    lsl     r9, r6, #26           @ sub_lo = carry_lo << 26
    lsr     r12, r6, #6           @ part = carry_lo >> (32-26)
    lsl     r2, r3, #26           @ sub_hi = (carry_hi << 26) | part
    orr     r2, r2, r12
    subs    r4, r4, r9 @ h0 -= (carry << 26)
    sbc     r5, r5, r2

    str     r4, [r10, #0]
    str     r5, [r10, #4]
    str     r7, [r10, #8]
    str     r8, [r10, #12]

    @ ===== carry1 (n=25) =====
    adds    r7, r7, r1 @ h1 += 2^24
    adc     r8, r8, #0

    lsrs    r6, r7, #25 @ carry_lo = (h1_lo >> 25) | (h1_hi << 7)
    orr     r6, r6, r8, lsl#7
    lsrs    r3, r8, #25 @ carry_hi = h1_hi >> 25

    ldr     r4, [r10, #16]        @ h2_lo
    ldr     r5, [r10, #20]        @ h2_hi
    adds    r4, r4, r6            @ h2 += carry (64-bit)
    adc     r5, r5, r3

    lsl     r9, r6, #25           @ sub_lo = carry_lo << 25
    lsr     r12, r6, #7           @ part = carry_lo >> (32-25)
    lsl     r2, r3, #25           @ sub_hi = (carry_hi << 25) | part
    orr     r2, r2, r12
    subs    r7, r7, r9 @ h1 -= (carry << 25)
    sbc     r8, r8, r2

    str     r7, [r10, #8]
    str     r8, [r10, #12]
    str     r4, [r10, #16]
    str     r5, [r10, #20]

    @ ===== carry2 (n=26) =====
    adds    r4, r4, r0 @ h2 += 2^25
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6
    lsrs    r3, r5, #26

    ldr     r7, [r10, #24]        @ h3_lo
    ldr     r8, [r10, #28]        @ h3_hi
    adds    r7, r7, r6
    adc     r8, r8, r3

    lsl     r9, r6, #26
    lsr     r12, r6, #6
    lsl     r2, r3, #26
    orr     r2, r2, r12
    subs    r4, r4, r9
    sbc     r5, r5, r2

    str     r4, [r10, #16]
    str     r5, [r10, #20]
    str     r7, [r10, #24]
    str     r8, [r10, #28]

    @ ===== carry3 (n=25) =====
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7
    lsrs    r3, r8, #25

    ldr     r4, [r10, #32]        @ h4_lo
    ldr     r5, [r10, #36]        @ h4_hi
    adds    r4, r4, r6
    adc     r5, r5, r3

    lsl     r9, r6, #25
    lsr     r12, r6, #7
    lsl     r2, r3, #25
    orr     r2, r2, r12
    subs    r7, r7, r9
    sbc     r8, r8, r2

    str     r7, [r10, #24]
    str     r8, [r10, #28]
    str     r4, [r10, #32]
    str     r5, [r10, #36]

    @ ===== carry4 (n=26) =====
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6
    lsrs    r3, r5, #26

    ldr     r7, [r10, #40]        @ h5_lo
    ldr     r8, [r10, #44]        @ h5_hi
    adds    r7, r7, r6
    adc     r8, r8, r3

    lsl     r9, r6, #26
    lsr     r12, r6, #6
    lsl     r2, r3, #26
    orr     r2, r2, r12
    subs    r4, r4, r9
    sbc     r5, r5, r2

    str     r4, [r10, #32]
    str     r5, [r10, #36]
    str     r7, [r10, #40]
    str     r8, [r10, #44]

    @ ===== carry5 (n=25) =====
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7
    lsrs    r3, r8, #25

    ldr     r4, [r10, #48]        @ h6_lo
    ldr     r5, [r10, #52]        @ h6_hi
    adds    r4, r4, r6
    adc     r5, r5, r3

    lsl     r9, r6, #25
    lsr     r12, r6, #7
    lsl     r2, r3, #25
    orr     r2, r2, r12
    subs    r7, r7, r9
    sbc     r8, r8, r2

    str     r7, [r10, #40]
    str     r8, [r10, #44]
    str     r4, [r10, #48]
    str     r5, [r10, #52]

    @ ===== carry6 (n=26) =====
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6
    lsrs    r3, r5, #26

    ldr     r7, [r10, #56]        @ h7_lo
    ldr     r8, [r10, #60]        @ h7_hi
    adds    r7, r7, r6
    adc     r8, r8, r3

    lsl     r9, r6, #26
    lsr     r12, r6, #6
    lsl     r2, r3, #26
    orr     r2, r2, r12
    subs    r4, r4, r9
    sbc     r5, r5, r2

    str     r4, [r10, #48]
    str     r5, [r10, #52]
    str     r7, [r10, #56]
    str     r8, [r10, #60]

    @ ===== carry7 (n=25) =====
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7
    lsrs    r3, r8, #25

    ldr     r4, [r10, #64]        @ h8_lo
    ldr     r5, [r10, #68]        @ h8_hi
    adds    r4, r4, r6
    adc     r5, r5, r3

    lsl     r9, r6, #25
    lsr     r12, r6, #7
    lsl     r2, r3, #25
    orr     r2, r2, r12
    subs    r7, r7, r9
    sbc     r8, r8, r2

    str     r7, [r10, #56]
    str     r8, [r10, #60]
    str     r4, [r10, #64]
    str     r5, [r10, #68]

    @ ===== carry8 (n=26) =====
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6
    lsrs    r3, r5, #26

    ldr     r7, [r10, #72]        @ h9_lo
    ldr     r8, [r10, #76]        @ h9_hi
    adds    r7, r7, r6
    adc     r8, r8, r3

    lsl     r9, r6, #26
    lsr     r12, r6, #6
    lsl     r2, r3, #26
    orr     r2, r2, r12
    subs    r4, r4, r9
    sbc     r5, r5, r2

    str     r4, [r10, #64]
    str     r5, [r10, #68]
    str     r7, [r10, #72]
    str     r8, [r10, #76]

    @ ===== carry9 (n=25) + fold 19*carry9 into h0 =====
    adds    r7, r7, r1 @ h9 += 2^24
    adc     r8, r8, #0

    lsrs    r6, r7, #25 @ carry9_lo
    orr     r6, r6, r8, lsl#7
    lsrs    r3, r8, #25 @ carry9_hi

    @ h0 += 19 * carry9  (64-bit: c + 2c + 16c)
    ldr     r4, [r10, #0]         @ h0_lo
    ldr     r5, [r10, #4]         @ h0_hi

    @ + c
    adds    r4, r4, r6
    adc     r5, r5, r3

    @ + 2c
    lsl     r9, r6, #1            @ (2c)_lo
    lsr     r12, r6, #31          @ spill from lo
    lsl     r2, r3, #1            @ (2c)_hi (hi<<1 | spill)
    orr     r2, r2, r12
    adds    r4, r4, r9
    adc     r5, r5, r2

    @ + 16c
    lsl     r9, r6, #4 @ (16c)_lo
    lsr     r12, r6, #28
    lsl     r2, r3, #4 @ (16c)_hi
    orr     r2, r2, r12
    adds    r4, r4, r9
    adc     r5, r5, r2

    @ h9 -= (carry9 << 25)
    lsl     r9, r6, #25           @ sub_lo
    lsr     r12, r6, #7           @ part
    lsl     r2, r3, #25           @ sub_hi
    orr     r2, r2, r12
    subs    r7, r7, r9
    sbc     r8, r8, r2

    str     r4, [r10, #0]
    str     r5, [r10, #4]
    str     r7, [r10, #72]
    str     r8, [r10, #76]

    @ ===== carry0 (again, n=26) =====
    ldr     r4, [r10, #0]         @ h0_lo
    ldr     r5, [r10, #4]         @ h0_hi
    adds    r4, r4, r0
    adc     r5, r5, #0

    lsrs    r6, r4, #26
    orr     r6, r6, r5, lsl#6
    lsrs    r3, r5, #26

    ldr     r7, [r10, #8]         @ h1_lo
    ldr     r8, [r10, #12]        @ h1_hi
    adds    r7, r7, r6
    adc     r8, r8, r3

    lsl     r9, r6, #26
    lsr     r12, r6, #6
    lsl     r2, r3, #26
    orr     r2, r2, r12
    subs    r4, r4, r9
    sbc     r5, r5, r2

    str     r4, [r10, #0]
    str     r5, [r10, #4]
    str     r7, [r10, #8]
    str     r8, [r10, #12]

    @ ===== carry1 (again, n=25) =====
    adds    r7, r7, r1
    adc     r8, r8, #0

    lsrs    r6, r7, #25
    orr     r6, r6, r8, lsl#7
    lsrs    r3, r8, #25

    ldr     r4, [r10, #16]        @ h2_lo
    ldr     r5, [r10, #20]        @ h2_hi
    adds    r4, r4, r6
    adc     r5, r5, r3

    lsl     r9, r6, #25
    lsr     r12, r6, #7
    lsl     r2, r3, #25
    orr     r2, r2, r12
    subs    r7, r7, r9
    sbc     r8, r8, r2

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

    ldr     r2, [sp, #0]
    add     sp, sp, #160
    pop     {r4-r11, pc}

.size BIGLIMB, .-BIGLIMB
