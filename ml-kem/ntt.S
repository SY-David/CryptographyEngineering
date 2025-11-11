.syntax unified
.thumb
.text

.extern zetas

.macro montgomery acc, mult, tmp
    smulbb      \acc, \acc, \mult
    smulbb      \tmp, \acc, r6         @ r6 = QINV
    smlabb      \acc, \tmp, r7, \acc   @ r7 = q
    asr         \acc, \acc, #16
.endm

.global basemul_s
.type basemul_s, %function
basemul_s:
    push        {r4-r7, lr}
    movw        r6, #3327
    movw        r7, #3329

    ldrsh       r4, [r1, #2]
    ldrsh       r5, [r2, #2]
    montgomery  r4, r5, r5
    montgomery  r4, r3, r5

    ldrsh       r5, [r1]
    ldrsh       r3, [r2]
    montgomery  r5, r3, r3
    add         r4, r4, r5
    strh        r4, [r0]

    ldrsh       r4, [r1]
    ldrsh       r5, [r2, #2]
    montgomery  r4, r5, r5

    ldrsh       r5, [r1, #2]
    ldrsh       r3, [r2]
    montgomery  r5, r3, r3
    add         r4, r4, r5
    strh        r4, [r0, #2]

    pop         {r4-r7, pc}

.global ntt_layer0_2way_s
.type ntt_layer0_2way_s, %function
ntt_layer0_2way_s:
    push        {r4-r12, lr}
    mov         r4, r0              @ base pointer
    mov         r11, r2             @ zeta64_top
    mov         r12, r3             @ zeta64_bottom
    movw        r9, #3329           @ q
    movw        r10, #3327          @ qinv
    movs        r8, #32             @ 64 coefficients / 2 per loop
1:
    ldr         r2, [r4]            @ top pair (a0|a1)
    add.w       r5, r4, #256        @ base + 128 coeffs
    ldr         r3, [r5]            @ bottom pair (b0|b1)
    add.w       r5, r4, #128        @ base + 64
    ldr         r5, [r5]            @ mid-top pair (a2|a3)
    add.w       r6, r4, #384        @ base + 192
    ldr         r6, [r6]            @ mid-bottom pair (b2|b3)

    smulbb      r14, r3, r1         @ t128 low
    smulbb      r7, r14, r10
    smlabb      r14, r7, r9, r14
    asr         r14, r14, #16
    sxth        r14, r14
    smultb      r7, r3, r1          @ t128 high
    smulbb      r3, r7, r10
    smlabb      r7, r3, r9, r7
    asr         r7, r7, #16
    sxth        r7, r7
    pkhbt       r14, r14, r7, lsl #16

    mov         r0, r2
    uadd16      r2, r2, r14         @ top pair
    usub16      r0, r0, r14         @ bottom pair

    smulbb      r14, r6, r1         @ mid t128 low
    smulbb      r3, r14, r10
    smlabb      r14, r3, r9, r14
    asr         r14, r14, #16
    sxth        r14, r14
    smultb      r7, r6, r1
    smulbb      r3, r7, r10
    smlabb      r7, r3, r9, r7
    asr         r7, r7, #16
    sxth        r7, r7
    pkhbt       r14, r14, r7, lsl #16

    mov         r6, r5
    uadd16      r5, r5, r14         @ top_mid
    usub16      r6, r6, r14         @ bot_mid

    smulbb      r14, r5, r11        @ t64 top low
    smulbb      r3, r14, r10
    smlabb      r14, r3, r9, r14
    asr         r14, r14, #16
    sxth        r14, r14
    smultb      r7, r5, r11
    smulbb      r3, r7, r10
    smlabb      r7, r3, r9, r7
    asr         r7, r7, #16
    sxth        r7, r7
    pkhbt       r14, r14, r7, lsl #16

    smulbb      r3, r6, r12         @ t64 bottom low
    smulbb      r5, r3, r10
    smlabb      r3, r5, r9, r3
    asr         r3, r3, #16
    sxth        r3, r3
    smultb      r5, r6, r12
    smulbb      r6, r5, r10
    smlabb      r5, r6, r9, r5
    asr         r5, r5, #16
    sxth        r5, r5
    pkhbt       r3, r3, r5, lsl #16

    mov         r5, r2
    uadd16      r6, r2, r14
    usub16      r5, r5, r14
    str         r6, [r4]
    add.w       r7, r4, #128
    str         r5, [r7]

    mov         r5, r0
    uadd16      r6, r0, r3
    usub16      r5, r5, r3
    add.w       r7, r4, #256
    str         r6, [r7]
    add.w       r7, r4, #384
    str         r5, [r7]

    add         r4, r4, #4
    subs        r8, r8, #1
    bne         1b

    pop         {r4-r12, pc}
