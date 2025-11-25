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

inv_zeta_layer0:
    .short -1044
inv_zeta_layer1:
    .short -1044, 758
inv_zeta_layer2:
    .short -1044, 1517, 758, 359
inv_zeta_layer3:
    .short -1044, -202, 1517, -1422, 758, -287, 359, -1493
inv_zeta_layer4:
    .short -1044, -1468, -202, -182, 1517, 1202, -1422, -622
    .short 758, 1474, -287, -1577, 359, -962, -1493, 171
inv_zeta_layer5:
    .short -1044, 1571, -1468, 130, -202, -608, -182, -383
    .short 1517, -411, 1202, -1458, -1422, -1017, -622, 1325
    .short 758, 205, 1474, 1602, -287, -732, -1577, -264
    .short 359, 1542, -962, 829, -1493, 681, 171, -573
inv_zeta_layer6:
    .short -1044, 1275, 1571, -1469, -1468, 951, 130, 1544
    .short -202, 725, -608, 666, -182, -830, -383, -1015
    .short 1517, 1065, -411, 1162, 1202, 1421, -1458, -1491
    .short -1422, -961, -1017, 8, -622, 90, 1325, -652
    .short 758, -677, 205, -126, 1474, 247, 1602, 282
    .short -287, 1508, -732, 320, -1577, 271, -264, 552
    .short 359, -448, 1542, 1618, -962, -107, 829, 1293
    .short -1493, 398, 681, -516, 171, 853, -573, -1223

twist_table:
    .short 1441, -1286, 316, -1548, -1266, 513, 226, -770
    .short 738, 1610, 878, -340, -20, -197, 1555, -496
    .short -225, -1384, -1648, 1078, 1630, 1075, 1434, 476
    .short 28, -390, 1152, -1303, 315, 606, -356, 1154
    .short 1047, -1505, -676, 1331, -705, 546, -947, -839
    .short -441, 1149, -1499, -284, -800, -1222, -1051, 134
    .short 987, 1233, 660, -157, -1380, -277, 767, -934
    .short 1120, 1045, -526, 1144, -716, 937, -924, -446
    .short -1397, -278, -408, -24, -1568, -1463, -1261, -270
    .short -995, -646, -38, -1373, 1290, 1055, 1237, -1298
    .short -468, -615, -232, 378, 1393, -1093, 719, -741
    .short 1523, -1477, -1066, -846, 1321, 861, -341, -1195
    .short 713, -1133, 325, -960, 531, 1402, -505, -813
    .short 148, 792, -1520, -1656, -1664, -1077, -455, 1344
    .short 1254, -1297, 707, -1525, -873, -443, -1201, 321
    .short 998, 842, 637, -550, -424, 1150, -324, -1194

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
.p2align 2
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
.p2align 2
.global ntt_s
.type ntt_s, %function
ntt_s:
    push        {r4-r12, lr}

    // r0 = r[256]
    // r1 = counter
    movs        r1, #0
    movw        r2, #3327
    movw        r3, #3329
    ldr         r8, =zetas
    ldrsh       r9, [r8, #2]     // zeta128 = zetas[1]
    ldrsh       r10, [r8, #4]    // zeta64_top    = zetas[2]
    ldrsh       r12, [r8, #6]    // zeta64_bottom = zetas[3]

.p2align 2
loop1start:
    cmp         r1, #64
    bge         loop1end

    add         r11, r0, r1, lsl#1

    @ 4× SWAR load：一次讀兩個 int16
    ldr         r4, [r11]          @ a0|a1
    ldr         r5, [r11, #128]    @ a64|a65
    ldr         r6, [r11, #256]    @ a128|a129
    ldr         r7, [r11, #384]    @ a192|a193

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

    uadd16      r4, r4, r5      @ top + t64_top
    uadd16      r5, r5, r5      @ 2 * t64_top
    usub16      r5, r4, r5      @ top - t64_top

    uadd16      r6, r6, r7      @ bot + t64_bottom
    uadd16      r7, r7, r7      @ 2 * t64_bottom
    usub16      r7, r6, r7      @ bot - t64_bottom

    @ 直接 32-bit store 回去
    add         r11, r0, r1, lsl#1

    str         r4, [r11]
    str         r5, [r11, #128]
    str         r6, [r11, #256]
    str         r7, [r11, #384]

    add         r1, r1, #2
    b           loop1start
loop1end:

    movs        r1, #0
.p2align 2
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

    movs        r14, #0 @ inner-loop index
.p2align 2
innerloop2start:
    cmp         r14, #16
    bge         innerloop2end

    add         r8, r1, r14
    add         r8, r0, r8, lsl#1 @ r8 = base pointer for this butterfly

    @ ==== 4×32-bit load，取代 ldrh+ldrh+pkhbt ====
    ldr         r9, [r8]             @ a0|a1
    ldr         r10, [r8, #32]       @ a16|a17
    ldr         r11, [r8, #64]       @ a32|a33
    ldr         r12, [r8, #96]       @ a48|a49

    @ doublemont 用 r8, r4 做暫存沒問題，因為 pointer 已用完
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

    uadd16      r9, r9, r10
    uadd16      r10, r10, r10
    usub16      r10, r9, r10

    uadd16      r11, r11, r12
    uadd16      r12, r12, r12
    usub16      r12, r11, r12

    @ ==== 4×32-bit store，取代 strh+asr+strh ====
    add         r8, r1, r14
    add         r8, r0, r8, lsl#1

    str         r9, [r8]
    str         r10, [r8, #32]
    str         r11, [r8, #64]
    str         r12, [r8, #96]

    add         r14, r14, #2
    b           innerloop2start
innerloop2end:
    add         r1, r1, #64 @ 注意這裡要寫完整 add r1,r1,#64
    b           outloop2start
outloop2end:

    movs        r1, #0
.p2align 2
outloop3start:
    cmp         r1, #256
    bge         outloop3end
    ldr         r8, =zeta8

    lsr         r4, r1, #3
    ldrsh       r5, [r8, r4]
    add         r8, r8, #32

    lsl         r4, r4, #1
    ldrsh       r6, [r8, r4]
    add         r4, r4, #2
    ldrsh       r7, [r8, r4]

    movs        r14, #0
.p2align 2
innerloop3start:
    cmp         r14, #4
    bge         innerloop3end

    add         r8, r1, r14
    add         r8, r0, r8, lsl#1 @ r8 4-byte aligned

    @ ==== 4×32-bit load ====
    ldr         r9, [r8]               @ a0|a1
    ldr         r10, [r8, #8]          @ a4|a5
    ldr         r11, [r8, #16]         @ a8|a9
    ldr         r12, [r8, #24]         @ a12|a13

    @ r4 只當 doublemont scratch
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

    uadd16      r9, r9, r10
    uadd16      r10, r10, r10
    usub16      r10, r9, r10

    uadd16      r11, r11, r12
    uadd16      r12, r12, r12
    usub16      r12, r11, r12

    @ ==== 4×32-bit store ====
    add         r8, r1, r14
    add         r8, r0, r8, lsl#1

    str         r9, [r8]
    str         r10, [r8, #8]
    str         r11, [r8, #16]
    str         r12, [r8, #24]

    add         r14, r14, #2
    b           innerloop3start
innerloop3end:
    add         r1, r1, #16
    b           outloop3start
outloop3end:
    movs        r1, #0
    ldr         r8, =zeta2
.p2align 2
loop4start:
    cmp         r1, #256
    bge         loop4end

    lsr         r9, r1, #1
    ldrsh       r10, [r8, r9]@ zeta2[r1/2]

    add         r9, r0, r1, lsl#1 @ r9 = &a[r1]，4-byte 對齊

    @ ==== 2×32-bit load ====
    ldr         r4, [r9]            @ a0|a1
    ldr         r5, [r9, #4]        @ a2|a3

    doublemont  r5, r11, r12, r3, r2, r10

    uadd16      r4, r4, r5          @ a + t
    uadd16      r5, r5, r5          @ 2t
    usub16      r5, r4, r5          @ a - t

    @ ==== 2×32-bit store ====
    str         r4, [r9]
    str         r5, [r9, #4]

    adds        r1, #4 @ Thumb-16 adds, OK
    b           loop4start
loop4end:
    pop         {r4-r12, pc}
.p2align 2
.global invntt_s
.type invntt_s, %function
invntt_s:
    push        {r4-r12, lr}
    mov         r4, r0              @ base pointer to polynomial
    movw        r10, #758           @ zeta64_bottom for first stage

    @ ------------ Stage 1: len = 4/8 ------------
    movs        r12, #0
inv_stage1_loop:
    cmp         r12, #256
    bge         inv_stage1_end

    add         r11, r4, r12, lsl#1

    ldrsh       r0, [r11]           @ a0
    ldrsh       r1, [r11, #2]       @ a1
    ldrsh       r2, [r11, #4]       @ b0
    ldrsh       r3, [r11, #6]       @ b1
    ldrsh       r5, [r11, #8]       @ a2
    ldrsh       r6, [r11, #10]      @ a3
    ldrsh       r7, [r11, #12]      @ b2
    ldrsh       r8, [r11, #14]      @ b3

    subs        r9, r0, r2          @ bot0
    adds        r0, r0, r2          @ top0

    subs        r2, r1, r3          @ bot1
    adds        r1, r1, r3          @ top1

    subs        r3, r5, r7          @ bot2
    adds        r5, r5, r7          @ top2

    subs        r7, r6, r8          @ bot3
    adds        r6, r6, r8          @ top3

    adds        r8, r0, r5          @ r[base]
    subs        r0, r0, r5          @ r[base+4]
    adds        r5, r1, r6          @ r[base+1]
    subs        r1, r1, r6          @ r[base+5]

    strh        r8, [r11]
    strh        r5, [r11, #2]
    strh        r0, [r11, #8]
    strh        r1, [r11, #10]

    mov         r0, r3
    mov         r1, r10
    bl          montgomery
    mov         r3, r0 @ t64_2

    mov         r0, r7
    mov         r1, r10
    bl          montgomery
    mov         r7, r0 @ t64_3

    adds        r0, r9, r3          @ r[base+2]
    subs        r3, r9, r3          @ r[base+6]
    adds        r1, r2, r7          @ r[base+3]
    subs        r2, r2, r7          @ r[base+7]

    strh        r0, [r11, #4]
    strh        r1, [r11, #6]
    strh        r3, [r11, #12]
    strh        r2, [r11, #14]

    adds        r12, r12, #8
    b           inv_stage1_loop
inv_stage1_end:

    @ ------------ Stage 2: len = 8/16 (block = 32) ------------
    movs        r1, #0 @ block index
inv_stage2_block:
    cmp         r1, #256
    bge         inv_stage2_end

    push        {r1, r14}@ save block index and maintain stack alignment
    add         r11, r4, r1, lsl#1
    ldr         r8, =inv_zeta_layer2
    ldr         r9, =inv_zeta_layer3
    add         r10, r9, #8         @ bottom zetas start at index 4
    movs        r14, #4             @ 4 iterations (offset 0,2,4,6)
    mov         r2, r11             @ current pointer within block
inv_stage2_inner:
    ldrsh       r5, [r8], #2        @ zeta32_cur
    ldrsh       r6, [r9], #2        @ zeta16_top
    ldrsh       r7, [r10], #2       @ zeta16_bottom

    ldrsh       r0, [r2]            @ x0
    ldrsh       r1, [r2, #2]        @ x1
    ldrsh       r3, [r2, #16]       @ y0
    ldrsh       r11, [r2, #18]      @ y1

    mov         r0, r3
    mov         r1, r5
    bl          montgomery
    mov         r3, r0 @ t32_0

    mov         r0, r11
    mov         r1, r5
    bl          montgomery
    mov         r11, r0 @ t32_1

    ldrsh       r0, [r2]            @ reload x0
    ldrsh       r1, [r2, #2]        @ reload x1
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1 @ r3 = (x0 + t32_0) - 2*t32_0 = x0 - t32_0
    adds        r1, r1, r11
    subs        r11, r1, r11, lsl#1 @ r11 = x1 - t32_1

    strh        r0, [r2]            @ idx0
    strh        r1, [r2, #2]        @ idx1
    strh        r3, [r2, #16]       @ idx2
    strh        r11, [r2, #18]      @ idx3

    ldrsh       r0, [r2, #32]       @ x2
    ldrsh       r1, [r2, #34]       @ x3
    ldrsh       r3, [r2, #48]       @ y2
    ldrsh       r12, [r2, #50]      @ y3

    mov         r0, r3
    mov         r1, r5
    bl          montgomery
    mov         r3, r0 @ t32_2

    mov         r0, r12
    mov         r1, r5
    bl          montgomery
    mov         r12, r0 @ t32_3

    ldrsh       r0, [r2, #32]       @ reload x2
    ldrsh       r1, [r2, #34]       @ reload x3
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2, #32]       @ idx4
    strh        r1, [r2, #34]       @ idx5
    strh        r3, [r2, #48]       @ idx6
    strh        r12, [r2, #50]      @ idx7

    @ zeta16_top
    ldrsh       r0, [r2]            @ u0
    ldrsh       r1, [r2, #2]        @ u1
    ldrsh       r3, [r2, #32]       @ v0
    ldrsh       r12, [r2, #34]      @ v1

    mov         r0, r3
    mov         r1, r6
    bl          montgomery
    mov         r3, r0 @ t0

    mov         r0, r12
    mov         r1, r6
    bl          montgomery
    mov         r12, r0 @ t1

    ldrsh       r0, [r2]            @ reload u0
    ldrsh       r1, [r2, #2]        @ reload u1
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2]            @ idx0
    strh        r1, [r2, #2]        @ idx1
    strh        r3, [r2, #32]       @ idx4
    strh        r12, [r2, #34]      @ idx5

    @ zeta16_bottom
    ldrsh       r0, [r2, #16]       @ u2
    ldrsh       r1, [r2, #18]       @ u3
    ldrsh       r3, [r2, #48]       @ v2
    ldrsh       r12, [r2, #50]      @ v3

    mov         r0, r3
    mov         r1, r7
    bl          montgomery
    mov         r3, r0

    mov         r0, r12
    mov         r1, r7
    bl          montgomery
    mov         r12, r0

    ldrsh       r0, [r2, #16]       @ reload u2
    ldrsh       r1, [r2, #18]       @ reload u3
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2, #16]       @ idx2
    strh        r1, [r2, #18]       @ idx3
    strh        r3, [r2, #48]       @ idx6
    strh        r12, [r2, #50]      @ idx7

    add         r2, r2, #4
    subs        r14, r14, #1
    bne         inv_stage2_inner

    pop         {r14, r1}@ restore block index
    adds        r1, r1, #32
    b           inv_stage2_block
inv_stage2_end:

    @ ------------ Stage 3: len = 16/32 (block = 128) ------------
    movs        r1, #0
inv_stage3_block:
    cmp         r1, #256
    bge         inv_stage3_end

    push        {r1, r14}@ save block index and keep alignment
    add         r11, r4, r1, lsl#1
    ldr         r8, =inv_zeta_layer4
    ldr         r9, =inv_zeta_layer5
    add         r10, r9, #32 @ bottom table starts at index 16

    movs        r14, #16
    mov         r2, r11
inv_stage3_inner:
    ldrsh       r5, [r8], #2        @ zeta8_cur
    ldrsh       r6, [r9], #2        @ zeta4_top
    ldrsh       r7, [r10], #2       @ zeta4_bottom

    ldrsh       r0, [r2]            @ x0
    ldrsh       r1, [r2, #2]        @ x1
    ldrsh       r3, [r2, #64]       @ y0
    ldrsh       r12, [r2, #66]      @ y1

    mov         r0, r3
    mov         r1, r5
    bl          montgomery
    mov         r3, r0 @ t8_0

    mov         r0, r12
    mov         r1, r5
    bl          montgomery
    mov         r12, r0 @ t8_1

    ldrsh       r0, [r2]            @ reload x0
    ldrsh       r1, [r2, #2]        @ reload x1
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2]
    strh        r1, [r2, #2]
    strh        r3, [r2, #64]
    strh        r12, [r2, #66]

    ldrsh       r0, [r2, #128]      @ x2
    ldrsh       r1, [r2, #130]      @ x3
    ldrsh       r3, [r2, #192]      @ y2
    ldrsh       r12, [r2, #194]     @ y3

    mov         r0, r3
    mov         r1, r5
    bl          montgomery
    mov         r3, r0 @ t8_2

    mov         r0, r12
    mov         r1, r5
    bl          montgomery
    mov         r12, r0 @ t8_3

    ldrsh       r0, [r2, #128]      @ reload x2
    ldrsh       r1, [r2, #130]      @ reload x3
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2, #128]
    strh        r1, [r2, #130]
    strh        r3, [r2, #192]
    strh        r12, [r2, #194]

    @ zeta4_top
    ldrsh       r0, [r2]            @ u0
    ldrsh       r1, [r2, #2]        @ u1
    ldrsh       r3, [r2, #128]      @ v0
    ldrsh       r12, [r2, #130]     @ v1

    mov         r0, r3
    mov         r1, r6
    bl          montgomery
    mov         r3, r0

    mov         r0, r12
    mov         r1, r6
    bl          montgomery
    mov         r12, r0

    ldrsh       r0, [r2]
    ldrsh       r1, [r2, #2]
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2]
    strh        r1, [r2, #2]
    strh        r3, [r2, #128]
    strh        r12, [r2, #130]

    @ zeta4_bottom
    ldrsh       r0, [r2, #64]       @ u2
    ldrsh       r1, [r2, #66]       @ u3
    ldrsh       r3, [r2, #192]      @ v2
    ldrsh       r12, [r2, #194]     @ v3

    mov         r0, r3
    mov         r1, r7
    bl          montgomery
    mov         r3, r0

    mov         r0, r12
    mov         r1, r7
    bl          montgomery
    mov         r12, r0

    ldrsh       r0, [r2, #64]
    ldrsh       r1, [r2, #66]
    adds        r0, r0, r3
    subs        r3, r0, r3, lsl#1
    adds        r1, r1, r12
    subs        r12, r1, r12, lsl#1

    strh        r0, [r2, #64]
    strh        r1, [r2, #66]
    strh        r3, [r2, #192]
    strh        r12, [r2, #194]

    add         r2, r2, #4
    subs        r14, r14, #1
    bne         inv_stage3_inner

    pop         {r14, r1}@ restore block index
    adds        r1, r1, #128
    b           inv_stage3_block
inv_stage3_end:

    @ ------------ Final Stage: len = 2 with twist ------------
    ldr         r8, =inv_zeta_layer6
    ldr         r9, =twist_table
    add         r10, r9, #128       @ twist pointer for upper half
    mov         r2, r4              @ ptr to lower half
    add         r3, r4, #256        @ ptr to upper half (index +128)
    movs        r12, #64            @ 64 iterations (j = 0..126 step 2)
inv_stage4_loop:
    ldrsh       r5, [r8], #2 @ zeta

    ldrsh       r0, [r2]            @ p0
    ldrsh       r1, [r2, #2]        @ p1
    ldrsh       r6, [r3]            @ q0
    ldrsh       r7, [r3, #2]        @ q1

    mov         r0, r6
    mov         r1, r5
    bl          montgomery
    mov         r6, r0 @ t0

    mov         r0, r7
    mov         r1, r5
    bl          montgomery
    mov         r7, r0 @ t1

    ldrsh       r11, [r9], #2       @ twist lower
    ldrsh       r14, [r10], #2      @ twist upper

    ldrsh       r0, [r2]            @ reload p0
    ldrsh       r1, [r2, #2]        @ reload p1

    mov         r3, r1              @ preserve p1
    adds        r5, r0, r6          @ sum0 = p0 + t0
    subs        r6, r0, r6          @ diff0 = p0 - t0
    adds        r0, r1, r7          @ sum1
    subs        r1, r3, r7          @ diff1
    mov         r7, r0              @ save sum1
    push        {r0, r1}            @ save (unused) sum1 copy and diff1, keep stack aligned

    mov         r0, r5 @ idx0
    mov         r1, r11
    bl          montgomery
    strh        r0, [r2]

    mov         r0, r6 @ idx2
    mov         r1, r14
    bl          montgomery
    strh        r0, [r3]

    mov         r0, r7 @ idx1
    mov         r1, r11
    bl          montgomery
    strh        r0, [r2, #2]

    pop         {r0, r1}            @ diff1 restored in r1
    mov         r0, r1              @ diff1 -> r0
    mov         r1, r14
    bl          montgomery
    strh        r0, [r3, #2]@ idx3

    add         r2, r2, #4
    add         r3, r3, #4
    subs        r12, r12, #1
    bne         inv_stage4_loop

    pop         {r4-r12, pc}
