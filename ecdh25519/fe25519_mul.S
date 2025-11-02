.syntax unified
.thumb
.thumb_func
.arch armv7e-m
.fpu fpv4-sp-d16
.type fe25519_square_core_s, %function
.text

.global fe25519_square_core_s
fe25519_square_core_s:
    stmdb.w sp!, {r4-r11, lr}
    sub     sp, sp, #4
    vpush   {s16-s31}

    ldr     r3, [r0]         // ax0
    ldr     r4, [r0, #4]     // ax1
    ldr     r5, [r0, #8]     // ax2
    ldr     r6, [r0, #12]    // ax3
    ldr     r7, [r0, #16]    // ax4
    ldr     r8, [r0, #20]    // ax5
    ldr     r9, [r0, #24]    // ax6
    ldr     r10, [r0, #28]   // ax7
    mov.w   r0, r1

    ubfx.w  r2, r3, #0, #26

    lsr.w   r12, r3, #26
    orr.w   r3, r12, r4, lsl#6
    ubfx.w  r3, r3, #0, #25

    lsr.w   r12, r4, #19
    orr.w   r4, r12, r5, lsl#13
    ubfx.w  r4, r4, #0, #26

    lsr.w   r12, r5, #13
    orr.w   r5, r12, r6, lsl#19
    ubfx.w  r5, r5, #0, #25

    ubfx.w  r6, r6, #6, #26

    lsr.w   r12, r7, #25
    orr.w   r12, r12, r8, lsl#7
    ubfx.w  r12, r12, #0, #26

    lsr.w   r1, r8, #19
    orr.w   r8, r1, r9, lsl#13
    ubfx.w  r8, r8, #0, #25

    lsr.w   r1, r9, #12
    orr.w   r9, r1, r10, lsl#20
    ubfx.w  r9, r9, #0, #26

    ubfx.w  r11, r10, #6, #25

    ubfx.w  r7, r7, #0, #25

    //   r2=f0, r3=f1, r4=f2, r5=f3, r6=f4, r7=f5, r12=f6, r8=f7, r9=f8, r11=f9
    movw    r14, #19
    mul     r10, r3, r14
    vmov    s11, r10
    mul     r10, r4, r14
    vmov    s12, r10
    mul     r10, r5, r14
    vmov    s13, r10
    mul     r10, r6, r14
    vmov    s14, r10
    mul     r10, r7, r14
    vmov    s15, r10
    mul     r10, r12, r14
    vmov    s16, r10
    mul     r10, r8, r14
    vmov    s17, r10
    mul     r10, r9, r14
    vmov    s18, r10
    mul     r10, r11, r14
    vmov    s19, r10

    lsl.w   r10, r3, #1
    vmov    s6, r10
    lsl.w   r10, r5, #1
    vmov    s7, r10
    lsl.w   r10, r7, #1
    vmov    s8, r10
    lsl.w   r10, r8, #1
    vmov    s9, r10
    lsl.w   r10, r11, #1
    vmov    s10, r10

// ---------------------------------------
    vmov    s20, r0

    movs.w  r1, #0
    movs.w  r14, #0

    vmov    r0, s6
    vmov    r10, s19
    umull   r1, r14, r0, r10

    vmov    r10, s18
    umlal   r1, r14, r4, r10

    vmov    r10, s7
    vmov    r0, s17
    umlal   r1, r14, r0, r10

    vmov    r0, s16
    umlal   r1, r14, r0, r6

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    umlal   r1, r14, r2, r2

    vmov    r0, s8
    vmov    r10, s15
    umlal   r1, r14, r0, r10

    // store h0

    vmov    s21, r1
    vmov    s22, r14
// ---------------------------------------

    // acc = 0
    movs.w  r1, #0
    movs.w  r14, #0

    // + f0 * f1
    umull   r1, r14, r2, r3

    // + f2 * f9_19
    vmov    r0, s19 // r0 = f9_19
    umlal   r1, r14, r4, r0

    // + f3 * f8_19
    vmov    r10, s18
    umlal   r1, r14, r5, r10

    // + f4 * f7_19
    vmov    r0, s17
    umlal   r1, r14, r0, r6

    // + f5 * f6_19
    vmov    r10, s16
    umlal   r1, r14, r7, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    s23, r1
    vmov    s24, r14

// ---------------------------------------

    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r4

    vmov    r10, s19
    vmov    r0, s7
    umlal   r1, r14, r0, r10

    vmov    r0, s18
    umlal   r1, r14, r0, r6

    vmov    r10, s8
    vmov    r0, s17
    umlal   r1, r14, r0, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    r0, s6
    umlal   r1, r14, r0, r3

    vmov    r10, s16
    umlal   r1, r14, r12, r10
    // store h0

    vmov    s25, r1
    vmov    s26, r14
// ---------------------------------------

    // acc = 0
    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r5

    umlal   r1, r14, r3, r4

    vmov    r10, s19 // r10= f9_19
    umlal   r1, r14, r6, r10

    vmov    r0, s18
    umlal   r1, r14, r0, r7

    vmov    r10, s17
    umlal   r1, r14, r12, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    s27, r1
    vmov    s28, r14

// ---------------------------------------

    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r6

    vmov    r0, s6
    umlal   r1, r14, r0, r5

    vmov    r0, s8
    vmov    r10, s19
    umlal   r1, r14, r0, r10

    vmov    r0, s18
    umlal   r1, r14, r0, r12

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    umlal   r1, r14, r4, r4

    vmov    r0, s17
    vmov    r10, s9
    umlal   r1, r14, r0, r10
    // store h0

    vmov    s29, r1
    vmov    s30, r14
// ---------------------------------------

    // acc = 0
    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r7

    umlal   r1, r14, r3, r6

    umlal   r1, r14, r4, r5

    vmov    r0, s19
    umlal   r1, r14, r0, r12

    vmov    r10, s18
    umlal   r1, r14, r8, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    s31, r1
    vmov    s0, r14
// ---------------------------------------

    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r12

    vmov    r10, s6
    umlal   r1, r14, r10, r7

    umlal   r1, r14, r4, r6

    vmov    r0, s19
    vmov    r10, s9
    umlal   r1, r14, r0, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    r0, s7
    umlal   r1, r14, r0, r5

    vmov    r10, s18
    umlal   r1, r14, r9, r10
    // store h0

    vmov    s1, r1
    vmov    s2, r14
// ---------------------------------------

    // acc = 0
    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r8

    umlal   r1, r14, r3, r12

    umlal   r1, r14, r4, r7

    umlal   r1, r14, r5, r6

    vmov    r10, s19
    umlal   r1, r14, r9, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    s3, r1
    vmov    s4, r14
// ---------------------------------------

    // acc = 0
    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r9

    vmov    r0, s6
    umlal   r1, r14, r0, r8

    umlal   r1, r14, r4, r12

    vmov    r10, s7
    umlal   r1, r14, r7, r10

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    umlal   r1, r14, r6, r6

    vmov    r0, s10
    vmov    r10, s19
    umlal   r1, r14, r0, r10

    vmov    s5, r1
    vmov    s6, r14
// ---------------------------------------
    movs.w  r1, #0
    movs.w  r14, #0

    umull   r1, r14, r2, r11

    umlal   r1, r14, r3, r9

    umlal   r1, r14, r4, r8

    umlal   r1, r14, r5, r12

    umlal   r1, r14, r6, r7
    // store h0

    adds.w  r1, r1, r1
    adcs.w  r14, r14, r14

    vmov    s7, r1
    vmov    s8, r14
// ---------------------------------------
    ldr     r2, =0x02000000
    ldr     r3, =0x01000000
    ldr     r7, =0x13
    vmov    r12, s20

    vmov    r1, s21
    vmov    r14, s22

    vmov    s21, r1
    vmov    s22, r14
// ---------------------------------------
    vmov    r1, s23
    vmov    r14, s24

    vmov    s23, r1
    vmov    s24, r14
// ---------------------------------------
    vmov    r1, s25
    vmov    r14, s26

    vmov    s25, r1
    vmov    s26, r14

// ---------------------------------------
    vmov    r1, s27
    vmov    r14, s28

    str     r1, [r12, #24]
    str     r14, [r12, #28]
// ---------------------------------------
    vmov    r1, s29
    vmov    r14, s30

    str     r1, [r12, #32]
    str     r14, [r12, #36]
// ---------------------------------------
    vmov    r1, s31
    vmov    r14, s0

    str     r1, [r12, #40]
    str     r14, [r12, #44]
// ---------------------------------------
// ---------------------------------------
    vmov    r1, s1
    vmov    r14, s2

    str     r1, [r12, #48]
    str     r14, [r12, #52]
// ---------------------------------------
    vmov    r1, s3
    vmov    r14, s4

    str     r1, [r12, #56]
    str     r14, [r12, #60]
// ---------------------------------------
    vmov    r1, s5
    vmov    r14, s6

    str     r1, [r12, #64]
    str     r14, [r12, #68]
// ---------------------------------------
    vmov    r1, s7
    vmov    r14, s8

    str     r1, [r12, #72]
    str     r14, [r12, #76]
// ---------------------------------------
    vmov    r1, s21
    vmov    r14, s22

    str     r1, [r12]
    str     r14, [r12, #4]
// ---------------------------------------
    vmov    r1, s23
    vmov    r14, s24

    str     r1, [r12, #8]
    str     r14, [r12, #12]
// ---------------------------------------
    vmov    r1, s25
    vmov    r14, s26

    str     r1, [r12, #16]
    str     r14, [r12, #20]

    vpop    {s16-s31}
    add     sp, sp, #4
    ldmia.w sp!, {r4-r11, lr}

    bx      lr
