.syntax unified
.thumb
.text

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
    b.ge        loop1end

    add         r11, r0, r1, lsl#1
    fmov        s0, r11
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
    fmov        r11, s0

    strh        r4, [r11]
    mov         r8, r4
    asr         r8, r8, #16
    strh        r8, [r11, #2]

    strh        r5, [r11, #128]
    mov         r8, r5
    asr         r8, r8, #16
    strh        r8, [r11, #130]

    strh        r6, [r11, #256]
    mov         r8, r6
    asr         r8, r8, #16
    strh        r8, [r11, #258]

    strh        r7, [r11, #384]
    mov         r8, r7
    asr         r8, r8, #16
    strh        r8, [r11, #386]

    add         r1, r1, #2
    b           loop1start
loop1end:

    pop         {r4-r12, pc}
