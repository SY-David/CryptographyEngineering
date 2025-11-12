.data
zetas:
    .short -1044, -758, -359, -1517, 1493, 1422, 287, 202
    .short -171, 622, 1577, 182, 962, -1202, -1474, 1468
    .short 573, -1325, 264, 383, -829, 1458, -1602, -130
    .short -681, 1017, 732, 608, -1542, 411, -205, -1571
    .short 1223, 652, -552, 1015, -1293, 1491, -282, -1544
    .short 516, -8, -320, -666, -1618, -1162, 126, 1469
    .short -853, -90, -271, 830, 107, -1421, -247, -951
    .short -398, 961, -1508, -725, 448, -1065, 677, -1275
    .short -1103, 430, 555, 843, -1251, 871, 1550, 105
    .short 422, 587, 177, -235, -291, -460, 1574, 1653
    .short -246, 778, 1159, -147, -777, 1483, -602, 1119
    .short -1590, 644, -872, 349, 418, 329, -156, -75
    .short 817, 1097, 603, 610, 1322, -1285, -1465, 384
    .short -1215, -136, 1218, -1335, -874, 220, -1187, -1659
    .short -1185, -1530, -1278, 794, -1510, -854, -870, 478
    .short -108, -308, 996, 991, 958, -1460, 1522, 1628

.syntax unified
.thumb
.text

.macro montgomery acc, mult, tmp
    smulbb      \acc, \acc, \mult
    smulbb      \tmp, \acc, r6         @ r6 = QINV
    smlabb      \acc, \tmp, r7, \acc   @ r7 = q
    asr         \acc, \acc, #16
.endm

.macro mul_pair result, pair, zeta, tmp
    smulbb      \result, \pair, \zeta
    smulbb      \tmp, \result, r10
    smlabb      \result, \tmp, r9, \result
    asr         \result, \result, #16
    sxth        \result, \result
    smultb      \tmp, \pair, \zeta
    smulbb      \tmp, \tmp, r10
    smlabb      \tmp, \tmp, r9, \tmp
    asr         \tmp, \tmp, #16
    sxth        \tmp, \tmp
    pkhbt       \result, \result, \tmp, lsl#16
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
loop1start:
    ldr         r2, [r4]            @ top pair (a0|a1)
    add.w       r5, r4, #256        @ base + 128 coeffs
    ldr         r3, [r5]            @ bottom pair (b0|b1)
    add.w       r5, r4, #128        @ base + 64
    ldr         r5, [r5]            @ mid-top pair (a2|a3)
    add.w       r6, r4, #384        @ base + 192
    ldr         r6, [r6]            @ mid-bottom pair (b2|b3)

    smulbb      r14, r3, r1 @ t128 low
    smulbb      r7, r14, r10
    smlabb      r14, r7, r9, r14
    asr         r14, r14, #16
    sxth        r14, r14
    smultb      r7, r3, r1 @ t128 high
    smulbb      r3, r7, r10
    smlabb      r7, r3, r9, r7
    asr         r7, r7, #16
    sxth        r7, r7
    pkhbt       r14, r14, r7, lsl#16

    mov         r0, r2
    uadd16      r2, r2, r14         @ top pair
    usub16      r0, r0, r14         @ bottom pair

    smulbb      r14, r6, r1 @ mid t128 low
    smulbb      r3, r14, r10
    smlabb      r14, r3, r9, r14
    asr         r14, r14, #16
    sxth        r14, r14
    smultb      r7, r6, r1
    smulbb      r3, r7, r10
    smlabb      r7, r3, r9, r7
    asr         r7, r7, #16
    sxth        r7, r7
    pkhbt       r14, r14, r7, lsl#16

    mov         r6, r5
    uadd16      r5, r5, r14         @ top_mid
    usub16      r6, r6, r14         @ bot_mid

    smulbb      r14, r5, r11 @ t64 top low
    smulbb      r3, r14, r10
    smlabb      r14, r3, r9, r14
    asr         r14, r14, #16
    sxth        r14, r14
    smultb      r7, r5, r11
    smulbb      r3, r7, r10
    smlabb      r7, r3, r9, r7
    asr         r7, r7, #16
    sxth        r7, r7
    pkhbt       r14, r14, r7, lsl#16

    smulbb      r3, r6, r12 @ t64 bottom low
    smulbb      r5, r3, r10
    smlabb      r3, r5, r9, r3
    asr         r3, r3, #16
    sxth        r3, r3
    smultb      r5, r6, r12
    smulbb      r6, r5, r10
    smlabb      r5, r6, r9, r5
    asr         r5, r5, #16
    sxth        r5, r5
    pkhbt       r3, r3, r5, lsl#16

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
    bne         loop1start

    sub         r4, r4, #128 @ reset pointer to block start
    ldr         r5, =zetas
    add         r5, r5, #8 @ skip zeta128 (1) + zeta64 (2)
    mov         r6, r5
    add         r6, r6, #8          @ move to zeta16 region
    movs        r8, #4              @ four blocks
loop2_block:
    ldrsh       r11, [r5], #2       @ zeta32 current
    ldrsh       r12, [r6], #2       @ zeta16 top
    ldrsh       r1, [r6], #2        @ zeta16 bottom
    sxth        r11, r11
    pkhbt       r11, r11, r11, lsl#16
    sxth        r12, r12
    pkhbt       r12, r12, r12, lsl#16
    sxth        r1, r1
    pkhbt       r1, r1, r1, lsl#16
    push        {r5, r6}            @ save advanced pointers
    movs        r2, #8              @ offsets within block
    mov         r7, r4
loop2_offset:
    @ --- Block 1 (Offset 0 & 64) ---
    ldr         r0, [r7]
    ldr         r14, [r7, #64]
    @ 修復關鍵：結果存入 r5 (Output)，輸入 r14 (Input) 保持不變
    mul_pair    r5, r14, r11, r3

    @ 蝴蝶運算 (Butterfly)
    @ r0 = a, r5 = b*zeta
    uadd16      r14, r0, r5         @ r14 = a + b (Sum)
    usub16      r5, r0, r5          @ r5 = a - b (Diff)
    str         r14, [r7]           @ Store Sum
    str         r5, [r7, #64]       @ Store Diff

    @ --- Block 2 (Offset 32 & 96) ---
    ldr         r0, [r7, #32]
    ldr         r14, [r7, #96]
    mul_pair    r5, r14, r11, r3 @ Output to r5

    uadd16      r14, r0, r5         @ Sum -> r14
    usub16      r5, r0, r5          @ Diff -> r5
    str         r14, [r7, #32]
    str         r5, [r7, #96]

    @ --- Block 3 (Offset 0 & 32 using zeta16_top) ---
    ldr         r0, [r7]
    ldr         r14, [r7, #32]
    mul_pair    r5, r14, r12, r3 @ Output to r5, using r12 (zeta16_top)

    uadd16      r14, r0, r5
    usub16      r5, r0, r5
    str         r14, [r7]
    str         r5, [r7, #32]

    @ --- Block 4 (Offset 64 & 96 using zeta16_bottom) ---
    ldr         r0, [r7, #64]
    ldr         r14, [r7, #96]
    mul_pair    r5, r14, r1, r3 @ Output to r5, using r1 (zeta16_bottom)

    uadd16      r14, r0, r5
    usub16      r5, r0, r5
    str         r14, [r7, #64]
    str         r5, [r7, #96]

    add         r7, r7, #4
    subs        r2, r2, #1
    bne         loop2_offset

    add         r4, r4, #128
    pop         {r5, r6}@ restore pointers for next block
    subs        r8, r8, #1
    bne         loop2_block

    pop         {r4-r12, pc}
