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

.global poly_basemul_montgomery_s
.type poly_basemul_montgomery_s, %function
poly_basemul_montgomery_s:
    push        {r4-r11, lr}

    @ r0 = poly *r
    @ r1 = const poly *a
    @ r2 = const poly *b

    @ QINV, Q 給 montgomery macro 用
    movw        r6, #3327      @ QINV
    movw        r7, #3329      @ q

    @ zeta2 就是 zetas[64] 的開頭
    ldr         r3, =zeta2     @ r3 = &zetas[64]
    movs        r4, #64        @ loop counter = KYBER_N/4

loop_poly_basemul:
    @ 取本輪 zeta 與 -zeta
    ldrsh       r5, [r3], #2   @ r5 = zeta = zetas[64+i]，r3 += 2
    rsb         r8, r5, #0     @ r8 = -zeta

    @ ===================== 第一組 basemul：r[0], r[1] =====================
    @ r[0] = mont(mont(a1,b1), zeta) + mont(a0,b0)

    @ t1 = mont(a1, b1)
    ldrsh       r9, [r1, #2]   @ a1
    ldrsh       r10, [r2, #2]  @ b1
    mov         r11, r9
    montgomery  r11, r10, r12 @ r11 = a1*b1 (Montgomery)

    @ t1 = mont(t1, zeta)
    montgomery  r11, r5, r12 @ r11 = a1*b1*zeta

    @ t0 = mont(a0, b0)
    ldrsh       r9, [r1, #0]   @ a0
    ldrsh       r10, [r2, #0]  @ b0
    mov         r12, r9
    montgomery  r12, r10, r9 @ r12 = a0*b0

    add         r11, r11, r12 @ r11 = r[0]
    strh        r11, [r0, #0]

    @ r[1] = mont(a0,b1) + mont(a1,b0)

    @ t2 = mont(a0, b1)
    ldrsh       r9, [r1, #0]   @ a0
    ldrsh       r10, [r2, #2]  @ b1
    mov         r11, r9
    montgomery  r11, r10, r12 @ r11 = a0*b1

    @ t3 = mont(a1, b0)
    ldrsh       r9, [r1, #2]   @ a1
    ldrsh       r10, [r2, #0]  @ b0
    mov         r12, r9
    montgomery  r12, r10, r9 @ r12 = a1*b0

    add         r11, r11, r12
    strh        r11, [r0, #2]

    @ ===================== 第二組 basemul：r[2], r[3] =====================
    @ r[2] = mont(mont(a3,b3), -zeta) + mont(a2,b2)

    @ t1 = mont(a3, b3)
    ldrsh       r9, [r1, #6]   @ a3
    ldrsh       r10, [r2, #6]  @ b3
    mov         r11, r9
    montgomery  r11, r10, r12 @ r11 = a3*b3

    @ t1 = mont(t1, -zeta)
    montgomery  r11, r8, r12 @ r11 = a3*b3*(-zeta)

    @ t0 = mont(a2, b2)
    ldrsh       r9, [r1, #4]   @ a2
    ldrsh       r10, [r2, #4]  @ b2
    mov         r12, r9
    montgomery  r12, r10, r9 @ r12 = a2*b2

    add         r11, r11, r12
    strh        r11, [r0, #4]

    @ r[3] = mont(a2,b3) + mont(a3,b2)

    @ t2 = mont(a2, b3)
    ldrsh       r9, [r1, #4]   @ a2
    ldrsh       r10, [r2, #6]  @ b3
    mov         r11, r9
    montgomery  r11, r10, r12 @ r11 = a2*b3

    @ t3 = mont(a3, b2)
    ldrsh       r9, [r1, #6]   @ a3
    ldrsh       r10, [r2, #4]  @ b2
    mov         r12, r9
    montgomery  r12, r10, r9 @ r12 = a3*b2

    add         r11, r11, r12
    strh        r11, [r0, #6]

    @ ---- 前進到下一組 4 coeffs / 下一個 zeta ----
    adds        r0, r0, #8     @ r += 4 * sizeof(int16_t)
    adds        r1, r1, #8     @ a += 4 * sizeof(int16_t)
    adds        r2, r2, #8     @ b += 4 * sizeof(int16_t)

    subs        r4, r4, #1
    bne         loop_poly_basemul

    pop         {r4-r11, pc}

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

    // r0 = r[256]
    // r1 = counter
    movs        r1, #0
    movw        r2, #3327
    movw        r3, #3329
    movw        r8, #758

.p2align 2
invloop1start:
    cmp         r1, #256
    bge         invloop1end

    add         r11, r0, r1, lsl#1

    ldr         r4, [r11]
    ldr         r5, [r11, #4]
    ldr         r6, [r11, #8]
    ldr         r7, [r11, #12]

    uadd16      r4, r4, r5
    uadd16      r5, r5, r5
    usub16      r5, r4, r5

    uadd16      r6, r6, r7
    uadd16      r7, r7, r7
    usub16      r7, r6, r7

    doublemont  r7, r9, r11, r3, r2, r8

    uadd16      r4, r4, r6
    uadd16      r6, r6, r6
    usub16      r6, r4, r6

    uadd16      r5, r5, r7
    uadd16      r7, r7, r7
    usub16      r7, r5, r7

    add         r11, r0, r1, lsl#1

    str         r4, [r11]
    str         r5, [r11, #4]
    str         r6, [r11, #8]
    str         r7, [r11, #12]

    add         r1, r1, #8
    b           invloop1start
invloop1end:
    movs        r1, #0
.p2align 2
invoutloop2start:
    cmp         r1, #256
    bge         invoutloop2end

    movs        r14, #0 @ inner-loop index
.p2align 2
invinnerloop2start:
    cmp         r14, #8
    bge         invinnerloop2end

    ldr         r4, =inv_zeta_layer2
    ldrsh       r5, [r4, r14]
    add         r8, r4, #8 // inv_zeta_layer3
    add         r4, r14, #8
    ldrsh       r6, [r8, r14]
    ldrsh       r7, [r8, r4]

    add         r8, r1, r14
    add         r8, r0, r8, lsl#1 @ r8 = base pointer for this butterfly

    ldr         r9, [r8]             @ a0|a1
    ldr         r10, [r8, #16]       @ a16|a17
    ldr         r11, [r8, #32]       @ a32|a33
    ldr         r12, [r8, #48]       @ a48|a49

    doublemont  r10, r8, r4, r3, r2, r5
    doublemont  r12, r8, r4, r3, r2, r5

    uadd16      r9, r9, r10
    uadd16      r10, r10, r10
    usub16      r10, r9, r10

    uadd16      r11, r11, r12
    uadd16      r12, r12, r12
    usub16      r12, r11, r12

    doublemont  r11, r8, r4, r3, r2, r6
    doublemont  r12, r8, r4, r3, r2, r7

    uadd16      r9, r9, r11
    uadd16      r11, r11, r11
    usub16      r11, r9, r11

    uadd16      r10, r10, r12
    uadd16      r12, r12, r12
    usub16      r12, r10, r12

    add         r8, r1, r14
    add         r8, r0, r8, lsl#1

    str         r9, [r8]
    str         r10, [r8, #16]
    str         r11, [r8, #32]
    str         r12, [r8, #48]

    add         r14, r14, #2
    b           invinnerloop2start
invinnerloop2end:
    add         r1, r1, #32
    b           invoutloop2start
invoutloop2end:
.p2align 2
    movs        r1, #0
invoutloop3start:
    cmp         r1, #256
    bge         invoutloop3end

    movs        r14, #0 @ inner-loop index
.p2align 2
invinnerloop3start:
    cmp         r14, #32
    bge         invinnerloop3end

    ldr         r4, =inv_zeta_layer4
    ldrsh       r5, [r4, r14]
    add         r8, r4, #32 // inv_zeta_layer5
    add         r4, r14, #32
    ldrsh       r6, [r8, r14]
    ldrsh       r7, [r8, r4]

    add         r8, r1, r14
    add         r8, r0, r8, lsl#1 @ r8 = base pointer for this butterfly

    ldr         r9, [r8]             @ a0|a1
    ldr         r10, [r8, #64]       @ a16|a17
    ldr         r11, [r8, #128]      @ a32|a33
    ldr         r12, [r8, #192]      @ a48|a49

    doublemont  r10, r8, r4, r3, r2, r5
    doublemont  r12, r8, r4, r3, r2, r5

    uadd16      r9, r9, r10
    uadd16      r10, r10, r10
    usub16      r10, r9, r10

    uadd16      r11, r11, r12
    uadd16      r12, r12, r12
    usub16      r12, r11, r12

    doublemont  r11, r8, r4, r3, r2, r6
    doublemont  r12, r8, r4, r3, r2, r7

    uadd16      r9, r9, r11
    uadd16      r11, r11, r11
    usub16      r11, r9, r11

    uadd16      r10, r10, r12
    uadd16      r12, r12, r12
    usub16      r12, r10, r12

    add         r8, r1, r14
    add         r8, r0, r8, lsl#1

    str         r9, [r8]
    str         r10, [r8, #64]
    str         r11, [r8, #128]
    str         r12, [r8, #192]

    add         r14, r14, #2
    b           invinnerloop3start
invinnerloop3end:
    add         r1, r1, #128
    b           invoutloop3start
invoutloop3end:
    movs        r1, #0
    ldr         r8, =inv_zeta_layer6
    ldr         r14, =twist_table
.p2align 2
invloop4start:
    cmp         r1, #128
    bge         invloop4end

    ldrsh       r10, [r8, r1]@ zeta2[r1/2]

    add         r9, r0, r1, lsl#1 @ r9 = &a[r1]，4-byte 對齊

    @ ==== 2×32-bit load ====
    ldr         r4, [r9]@ a0|a1
    ldr         r5, [r9, #256]@ a2|a3

    doublemont  r5, r11, r12, r3, r2, r10

    uadd16      r4, r4, r5          @ a + t
    uadd16      r5, r5, r5          @ 2t
    usub16      r5, r4, r5          @ a - t

    @ ==== 2×32-bit store ====
    ldrsh       r10, [r14, r1]

    doublemont  r4, r11, r12, r3, r2, r10

    add         r12, r1, #128
    ldrsh       r10, [r14, r12]
    doublemont  r5, r11, r12, r3, r2, r10
    str         r4, [r9]
    str         r5, [r9, #256]

    adds        r1, #2 @ Thumb-16 adds, OK
    b           invloop4start
invloop4end:

    pop         {r4-r12, pc}
