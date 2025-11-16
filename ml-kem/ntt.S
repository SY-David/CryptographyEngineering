.syntax unified
.thumb
.thumb_func
.arch armv7e-m
.fpu fpv4-sp-d16
.text

.data
zetas:
    .short -1044
zeta128:
    .short -758
zeta64:
    .short -359, -1517
zeta32:
    .short 1493, 1422, 287, 202
zeta16:
    .short -171, 622, 1577, 182, 962, -1202, -1474, 1468
zeta8:
    .short 573, -1325, 264, 383, -829, 1458, -1602, -130
    .short -681, 1017, 732, 608, -1542, 411, -205, -1571
zeta4:
    .short 1223, 652, -552, 1015, -1293, 1491, -282, -1544
    .short 516, -8, -320, -666, -1618, -1162, 126, 1469
    .short -853, -90, -271, 830, 107, -1421, -247, -951
    .short -398, 961, -1508, -725, 448, -1065, 677, -1275
zeta2:
    .short -1103, 430, 555, 843, -1251, 871, 1550, 105
    .short 422, 587, 177, -235, -291, -460, 1574, 1653
    .short -246, 778, 1159, -147, -777, 1483, -602, 1119
    .short -1590, 644, -872, 349, 418, 329, -156, -75
    .short 817, 1097, 603, 610, 1322, -1285, -1465, 384
    .short -1215, -136, 1218, -1335, -874, 220, -1187, -1659
    .short -1185, -1530, -1278, 794, -1510, -854, -870, 478
    .short -108, -308, 996, 991, 958, -1460, 1522, 1628

.macro montgomery acc, mult, tmp
    smulbb      \acc, \acc, \mult
    smulbb      \tmp, \acc, r6         // r6 = QINV
    smlabb      \acc, \tmp, r7, \acc   // r7 = q
    asr         \acc, \acc, #16
.endm

.macro doublemont a, tmp, tmp2, q, qinv, mult

    smulbb      \tmp2, \a, \mult

    smulbb      \tmp, \tmp2, \qinv

    smlabb      \tmp2, \q, \tmp, \tmp2

    smultb      \tmp, \a, \mult

    smulbb      \a, \tmp, \qinv

    smlabb      \tmp, \q, \a, \tmp

    pkhtb       \a, \tmp, \tmp2, asr#16
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

.global ntt_s
.type ntt_s, %function
ntt_s:
    push        {r4-r12, lr}

    // r0 = r[256]
    // r1 = counter
    movw        r1, #0
    movw        r2, #3327
    movw        r3, #3329
    ldr         r8, =zetas
    ldrsh       r9, [r8, #2]    // zeta128 = zetas[1]
    ldrsh       r10, [r8, #4]   // zeta64_top    = zetas[2]
    ldrsh       r12, [r8, #6]   // zeta64_bottom = zetas[3]

loop1start:
    cmp         r1, #64
    bge         loop1end

    add         r11, r0, r1, lsl#1

    ldrh        r4, [r11]
    ldrh        r5, [r11, #2]
    pkhbt       r4, r4, r5, lsl#16

    ldrh        r5, [r11, #128]
    ldrh        r6, [r11, #130]
    pkhbt       r5, r5, r6, lsl#16

    ldrh        r6, [r11, #256]
    ldrh        r7, [r11, #258]
    pkhbt       r6, r6, r7, lsl#16

    ldrh        r7, [r11, #384]
    ldrh        r8, [r11, #386]
    pkhbt       r7, r7, r8, lsl#16

    doublemont  r6, r8, r11, r3, r2, r9
    doublemont  r7, r8, r11, r3, r2, r9

    uadd16      r4, r4, r6
    uadd16      r6, r6, r6
    usub16      r6, r4, r6

    uadd16      r5, r5, r7
    uadd16      r7, r7, r7
    usub16      r7, r5, r7

    doublemont  r5, r8, r11, r3, r2, r10
    doublemont  r7, r8, r11, r3, r2, r12

    uadd16      r4, r4, r5      // r4 = top + t64_top
    uadd16      r5, r5, r5      // r5 = 2 * t64_top
    usub16      r5, r4, r5      // r5 = top - t64_top

    uadd16      r6, r6, r7      // r6 = bot + t64_bottom
    uadd16      r7, r7, r7      // r7 = 2 * t64_bottom
    usub16      r7, r6, r7      // r7 = bot - t64_bottom
    add         r11, r0, r1, lsl#1

    strh        r4, [r11]
    asr         r4, r4, #16
    strh        r4, [r11, #2]

    strh        r5, [r11, #128]

    asr         r5, r5, #16
    strh        r5, [r11, #130]

    strh        r6, [r11, #256]

    asr         r6, r6, #16
    strh        r6, [r11, #258]

    strh        r7, [r11, #384]

    asr         r7, r7, #16
    strh        r7, [r11, #386]

    add         r1, r1, #2
    b           loop1start
loop1end:

    movw        r1, #0
outloop2start:
    cmp         r1, #256
    bge         outloop2end
    ldr         r8, =zeta32

    lsr         r4, r1, #5
    ldrsh       r5, [r8, r4]
    add         r8, r8, #8

    lsl         r4, r4, #1
    ldrsh       r6, [r8, r4]
    add         r4, r4, #2
    ldrsh       r7, [r8, r4]

    mov         r4, #0
innerloop2start:
    cmp         r4, #16
    bge         innerloop2end

    add         r8, r1, r4
    add         r8, r0, r8, lsl#1
    vmov        lr, r4
    ldrh        r9, [r8]
    ldrh        r10, [r8, #2]
    pkhbt       r9, r9, r10, lsl#16

    ldrh        r10, [r8, #32]
    ldrh        r11, [r8, #34]
    pkhbt       r10, r10, r11, lsl#16

    ldrh        r11, [r8, #64]
    ldrh        r12, [r8, #66]
    pkhbt       r11, r11, r12, lsl#16

    ldrh        r12, [r8, #96]
    ldrh        r8, [r8, #98]
    pkhbt       r12, r12, r8, lsl#16

    doublemont  r11, r8, r4, r3, r2, r5
    doublemont  r12, r8, r4, r3, r2, r5

    uadd16      r9, r9, r11
    uadd16      r11, r11, r11
    usub16      r11, r9, r11

    uadd16      r10, r10, r12
    uadd16      r12, r12, r12
    usub16      r12, r10, r12

    doublemont  r10, r8, r4, r3, r2, r6
    doublemont  r12, r8, r4, r3, r2, r7

    uadd16      r9, r9, r10 // r4 = top + t64_top
    uadd16      r10, r10, r10 // r5 = 2 * t64_top
    usub16      r10, r9, r10 // r5 = top - t64_top

    uadd16      r11, r11, r12 // r6 = bot + t64_bottom
    uadd16      r12, r12, r12 // r7 = 2 * t64_bottom
    usub16      r12, r11, r12

    add         r8, r1, r4
    add         r8, r8, r0

    strh        r9, [r8]
    asr         r9, r9, #16
    strh        r9, [r8, #2]

    strh        r10, [r8, #32]
    asr         r10, r10, #16
    strh        r10, [r8, #34]

    strh        r11, [r8, #64]
    asr         r11, r11, #16
    strh        r11, [r8, #66]

    strh        r12, [r8, #96]
    asr         r12, r12, #16
    strh        r12, [r8, #98]

    vmov        r4, lr
    add         r4, r4, #2
    b           innerloop2start
innerloop2end:
    add         r1, r1, #64

    b           outloop2start
outloop2end:
    pop         {r4-r12, pc}
