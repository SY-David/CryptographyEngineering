.global fe25519_square_core_s
fe25519_square_core_s:
.macro UMUL_ADD acc_lo, acc_hi, rx, ry
    UMULL   r6, r7, \rx, \ry
    ADDS    \acc_lo, \acc_lo, r6
    ADC     \acc_hi, \acc_hi, r7
.endm

.macro SCALE19 rd, rs
    /* rd = rs*19 = rs*(16+2+1) */
    LSLS    \rd, \rs, #4      /* *16 */
    ADD     \rd, \rd, \rs, lsl #1  /* +*2 => *18 */
    ADD     \rd, \rd, \rs          /* +*1 => *19 */
.endm

.macro UMUL_ADD_19 acc_lo, acc_hi, rx, ry
    SCALE19 r5, \ry
    UMUL_ADD \acc_lo, \acc_hi, \rx, r5
.endm

.macro UMUL_ADD_38 acc_lo, acc_hi, rx, ry
    SCALE19 r5, \ry
    LSLS    r5, r5, #1        /* *38 = 2*19 */
    UMUL_ADD \acc_lo, \acc_hi, \rx, r5
.endm

.macro UMUL_ADD_76 acc_lo, acc_hi, rx, ry
    SCALE19 r5, \ry
    LSLS    r5, r5, #2        /* *76 = 4*19 */
    UMUL_ADD \acc_lo, \acc_hi, \rx, r5
.endm

.macro UMUL_ADD_2 acc_lo, acc_hi, rx, ry
    LSLS    r5, \ry, #1
    UMUL_ADD \acc_lo, \acc_hi, \rx, r5
.endm

.macro UMUL_ADD_4 acc_lo, acc_hi, rx, ry
    LSLS    r5, \ry, #2
    UMUL_ADD \acc_lo, \acc_hi, \rx, r5
.endm

/* =============== 主函式開始 =============== */
fe25519_square_core:
    push    {r4-r11, lr}
    /* 備份 a 指標於 r10；r0, r1 是引數 */
    mov     r10, r0           /* r10 = a */
    /* 配置 80B 暫存：H0..H9 各 64-bit */
    sub     sp, sp, #80

    /* 常數 */
    ldr     r12, =0x03FFFFFF  /* mask26 */
    ldr     r11, =0x01FFFFFF  /* mask25 */

    /* -------- 安全讀取 w0..w7：r2..r9 -------- */
    /* 用內聯小片段避免重複：每組 4 bytes -> rX */
    /* 宏在 GAS 需 .irp/.rept 才能展開，這裡手寫避免過度複雜 */

    /* r2 = w0 */
    ldrb    r2, [r10, #0]
    ldrb    r3, [r10, #1]
    ldrb    r4, [r10, #2]
    ldrb    r5, [r10, #3]
    orr     r2, r2, r3, lsl #8
    orr     r2, r2, r4, lsl #16
    orr     r2, r2, r5, lsl #24
    /* r3 = w1 */
    ldrb    r3, [r10, #4]
    ldrb    r4, [r10, #5]
    ldrb    r5, [r10, #6]
    ldrb    r6, [r10, #7]
    orr     r3, r3, r4, lsl #8
    orr     r3, r3, r5, lsl #16
    orr     r3, r3, r6, lsl #24
    /* r4 = w2 */
    ldrb    r4, [r10, #8]
    ldrb    r5, [r10, #9]
    ldrb    r6, [r10, #10]
    ldrb    r7, [r10, #11]
    orr     r4, r4, r5, lsl #8
    orr     r4, r4, r6, lsl #16
    orr     r4, r4, r7, lsl #24
    /* r5 = w3 */
    ldrb    r5, [r10, #12]
    ldrb    r6, [r10, #13]
    ldrb    r7, [r10, #14]
    ldrb    r8, [r10, #15]
    orr     r5, r5, r6, lsl #8
    orr     r5, r5, r7, lsl #16
    orr     r5, r5, r8, lsl #24
    /* r6 = w4 */
    ldrb    r6, [r10, #16]
    ldrb    r7, [r10, #17]
    ldrb    r8, [r10, #18]
    ldrb    r9, [r10, #19]
    orr     r6, r6, r7, lsl #8
    orr     r6, r6, r8, lsl #16
    orr     r6, r6, r9, lsl #24
    /* r7 = w5 */
    ldrb    r7, [r10, #20]
    ldrb    r8, [r10, #21]
    ldrb    r9, [r10, #22]
    ldrb    r0, [r10, #23]
    orr     r7, r7, r8, lsl #8
    orr     r7, r7, r9, lsl #16
    orr     r7, r7, r0, lsl #24
    /* r8 = w6 */
    ldrb    r8, [r10, #24]
    ldrb    r9, [r10, #25]
    ldrb    r0, [r10, #26]
    ldrb    r14,[r10, #27]
    orr     r8, r8, r9,  lsl #8
    orr     r8, r8, r0,  lsl #16
    orr     r8, r8, r14, lsl #24
    /* r9 = w7 */
    ldrb    r9,  [r10, #28]
    ldrb    r0,  [r10, #29]
    ldrb    r14, [r10, #30]
    ldrb    r10, [r10, #31]
    orr     r9,  r9,  r0,  lsl #8
    orr     r9,  r9,  r14, lsl #16
    orr     r9,  r9,  r10, lsl #24

    /* -------- limb f0..f9 取值，存入 S0..S9（scratch） -------- */
    /* f0 = w0 & mask26 */
    and     r0, r2, r12
    vmov    s0, r0

    /* f1 = ((w0>>26) | (w1<<6)) & mask25 */
    lsrs    r0, r2, #26
    orr     r0, r0, r3, lsl #6
    and     r0, r0, r11
    vmov    s1, r0

    /* f2 = ((w1>>19)|(w2<<13)) & mask26 */
    lsrs    r0, r3, #19
    orr     r0, r0, r4, lsl #13
    and     r0, r0, r12
    vmov    s2, r0

    /* f3 = ((w2>>13)|(w3<<19)) & mask25 */
    lsrs    r0, r4, #13
    orr     r0, r0, r5, lsl #19
    and     r0, r0, r11
    vmov    s3, r0

    /* f4 = (w3>>6) & mask26 */
    lsrs    r0, r5, #6
    and     r0, r0, r12
    vmov    s4, r0

    /* f5 = w4 & mask25 */
    and     r0, r6, r11
    vmov    s5, r0

    /* f6 = ((w4>>25)|(w5<<7)) & mask26 */
    lsrs    r0, r6, #25
    orr     r0, r0, r7, lsl #7
    and     r0, r0, r12
    vmov    s6, r0

    /* f7 = ((w5>>19)|(w6<<13)) & mask25 */
    lsrs    r0, r7, #19
    orr     r0, r0, r8, lsl #13
    and     r0, r0, r11
    vmov    s7, r0

    /* f8 = ((w6>>12)|(w7<<20)) & mask26 */
    lsrs    r0, r8, #12
    orr     r0, r0, r9, lsl #20
    and     r0, r0, r12
    vmov    s8, r0

    /* f9 = (w7>>6) & mask25 */
    lsrs    r0, r9, #6
    and     r0, r0, r11
    vmov    s9, r0

    /* =============== 計算 h0..h9，逐一累加→存棧 =============== */
    /*   規則（化簡後）：
     *   h0 = f0*f0 + 38*f5*f5 + 76*f1*f9 + 38*f2*f8 + 76*f3*f7 + 38*f4*f6
     *   h1 = 2*f0*f1 + 38*f2*f9 + 38*f3*f8 + 38*f4*f7 + 38*f5*f6
     *   h2 = 2*f1*f1 + 19*f6*f6 + 2*f0*f2 + 76*f3*f9 + 38*f4*f8 + 76*f5*f7
     *   h3 = 2*f0*f3 + 2*f1*f2 + 38*f4*f9 + 38*f5*f8 + 38*f6*f7
     *   h4 = f2*f2 + 38*f7*f7 + 2*f0*f4 + 4*f1*f3 + 76*f5*f9 + 38*f6*f8
     *   h5 = 2*f0*f5 + 2*f1*f4 + 2*f2*f3 + 38*f6*f9 + 38*f7*f8
     *   h6 = 2*f3*f3 + 19*f8*f8 + 2*f0*f6 + 4*f1*f5 + 2*f2*f4 + 76*f7*f9
     *   h7 = 2*f0*f7 + 2*f1*f6 + 2*f2*f5 + 2*f3*f4 + 38*f8*f9
     *   h8 = f4*f4 + 38*f9*f9 + 2*f0*f8 + 4*f1*f7 + 2*f2*f6 + 4*f3*f5
     *   h9 = 2*f0*f9 + 2*f1*f8 + 2*f2*f7 + 2*f3*f6 + 2*f4*f5
     */

    /* --- helper: 從 Sx 取回到 r2..r? --- */
    /* 我們會反覆 vmov Rx, Sx；每個 hK 計算時只取需要者 */

    /* h0 */
    movs    r2, #0      /* acc_lo */
    movs    r3, #0      /* acc_hi */
    vmov    r4, s0      /* f0 */
    UMUL_ADD r2, r3, r4, r4    /* f0*f0 */

    vmov    r4, s5      /* f5 */
    UMUL_ADD_38 r2, r3, r4, r4 /* +38*f5*f5 */

    vmov    r4, s1      /* f1 */
    vmov    r5, s9      /* f9 */
    UMUL_ADD_76 r2, r3, r4, r5

    vmov    r4, s2      /* f2 */
    vmov    r5, s8      /* f8 */
    UMUL_ADD_38 r2, r3, r4, r5

    vmov    r4, s3      /* f3 */
    vmov    r5, s7      /* f7 */
    UMUL_ADD_76 r2, r3, r4, r5

    vmov    r4, s4      /* f4 */
    vmov    r5, s6      /* f6 */
    UMUL_ADD_38 r2, r3, r4, r5

    /* store h0 -> [sp+0] */
    str     r2, [sp, #0]
    str     r3, [sp, #4]

    /* h1 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s0; vmov r5, s1
    UMUL_ADD_2  r2, r3, r4, r5   /* 2*f0*f1 */

    vmov    r4, s2; vmov r5, s9
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s3; vmov r5, s8
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s4; vmov r5, s7
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s5; vmov r5, s6
    UMUL_ADD_38 r2, r3, r4, r5
    str     r2, [sp, #8]
    str     r3, [sp, #12]

    /* h2 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s1
    UMUL_ADD_2  r2, r3, r4, r4   /* 2*f1*f1 */
    vmov    r4, s6
    UMUL_ADD_19 r2, r3, r4, r4   /* +19*f6*f6 */
    vmov    r4, s0; vmov r5, s2
    UMUL_ADD_2  r2, r3, r4, r5   /* +2*f0*f2 */
    vmov    r4, s3; vmov r5, s9
    UMUL_ADD_76 r2, r3, r4, r5
    vmov    r4, s4; vmov r5, s8
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s5; vmov r5, s7
    UMUL_ADD_76 r2, r3, r4, r5
    str     r2, [sp, #16]
    str     r3, [sp, #20]

    /* h3 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s0; vmov r5, s3
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s1; vmov r5, s2
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s4; vmov r5, s9
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s5; vmov r5, s8
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s6; vmov r5, s7
    UMUL_ADD_38 r2, r3, r4, r5
    str     r2, [sp, #24]
    str     r3, [sp, #28]

    /* h4 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s2
    UMUL_ADD   r2, r3, r4, r4    /* f2*f2 */
    vmov    r4, s7
    UMUL_ADD_38 r2, r3, r4, r4   /* +38*f7*f7 */
    vmov    r4, s0; vmov r5, s4
    UMUL_ADD_2  r2, r3, r4, r5   /* +2*f0*f4 */
    vmov    r4, s1; vmov r5, s3
    UMUL_ADD_4  r2, r3, r4, r5   /* +4*f1*f3 */
    vmov    r4, s5; vmov r5, s9
    UMUL_ADD_76 r2, r3, r4, r5
    vmov    r4, s6; vmov r5, s8
    UMUL_ADD_38 r2, r3, r4, r5
    str     r2, [sp, #32]
    str     r3, [sp, #36]

    /* h5 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s0; vmov r5, s5
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s1; vmov r5, s4
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s2; vmov r5, s3
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s6; vmov r5, s9
    UMUL_ADD_38 r2, r3, r4, r5
    vmov    r4, s7; vmov r5, s8
    UMUL_ADD_38 r2, r3, r4, r5
    str     r2, [sp, #40]
    str     r3, [sp, #44]

    /* h6 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s3
    UMUL_ADD_2  r2, r3, r4, r4    /* 2*f3*f3 */
    vmov    r4, s8
    UMUL_ADD_19 r2, r3, r4, r4    /* +19*f8*f8 */
    vmov    r4, s0; vmov r5, s6
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s1; vmov r5, s5
    UMUL_ADD_4  r2, r3, r4, r5
    vmov    r4, s2; vmov r5, s4
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s7; vmov r5, s9
    UMUL_ADD_76 r2, r3, r4, r5
    str     r2, [sp, #48]
    str     r3, [sp, #52]

    /* h7 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s0; vmov r5, s7
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s1; vmov r5, s6
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s2; vmov r5, s5
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s3; vmov r5, s4
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s8; vmov r5, s9
    UMUL_ADD_38 r2, r3, r4, r5
    str     r2, [sp, #56]
    str     r3, [sp, #60]

    /* h8 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s4
    UMUL_ADD   r2, r3, r4, r4    /* f4*f4 */
    vmov    r4, s9
    UMUL_ADD_38 r2, r3, r4, r4   /* +38*f9*f9 */
    vmov    r4, s0; vmov r5, s8
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s1; vmov r5, s7
    UMUL_ADD_4  r2, r3, r4, r5
    vmov    r4, s2; vmov r5, s6
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s3; vmov r5, s5
    UMUL_ADD_4  r2, r3, r4, r5
    str     r2, [sp, #64]
    str     r3, [sp, #68]

    /* h9 */
    movs    r2, #0; movs r3, #0
    vmov    r4, s0; vmov r5, s9
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s1; vmov r5, s8
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s2; vmov r5, s7
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s3; vmov r5, s6
    UMUL_ADD_2  r2, r3, r4, r5
    vmov    r4, s4; vmov r5, s5
    UMUL_ADD_2  r2, r3, r4, r5
    str     r2, [sp, #72]
    str     r3, [sp, #76]

    /* =============== carry 鏈（與 C 版一致） =============== */
    /* helper：從 [sp+off] 取 64-bit -> (r2=lo, r3=hi)；存回同位址。 */
    /* carry 計算：
       carry = (h + 2^(k-1)) >> k       (k=26 或 25)
       將 carry 加到下一個 h，然後 h -= carry<<k
       64 位右移 k： (hi<< (32-k)) | (lo >> k)
    */

    /* 宏：右移 26 得 32-bit carry 到 r4；輸入 (r2=lo, r3=hi)，會先加偏置 */
.macro CARRY26_WITH_ROUND
    /* r12/r11 是 mask，現不用；載入偏置 1<<25 */
    ldr     r5, =0x02000000       /* 1<<25 */
    ADDS    r2, r2, r5            /* 加偏置到 lo */
    ADC     r3, r3, #0            /* 進位進 hi */
    /* carry = (lo>>26) | (hi<<6) */
    LSRS    r4, r2, #26
    ORR     r4, r4, r3, lsl #6
.endm

    /* 宏：右移 25 得 32-bit carry 到 r4；輸入 (r2=lo, r3=hi)，會先加偏置 */
.macro CARRY25_WITH_ROUND
    ldr     r5, =0x01000000       /* 1<<24 */
    ADDS    r2, r2, r5
    ADC     r3, r3, #0
    LSRS    r4, r2, #25
    ORR     r4, r4, r3, lsl #7
.endm

    /* 宏：h -= (carry<<k)，k=25/26；輸入 (r2=lo, r3=hi)，carry 在 r4 */
.macro SUB_SHIFT acc_lo, acc_hi, k
    LSLS    r5, r4, #\k
    SUBS    \acc_lo, \acc_lo, r5
    SBC     \acc_hi, \acc_hi, #0
.endm

    /* --- carry0: h0 (k=26) --- */
    ldr     r2, [sp, #0];  ldr r3, [sp, #4]
    CARRY26_WITH_ROUND
    /* h1 += carry0 */
    ldr     r6, [sp, #8];  ldr r7, [sp, #12]
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #8];  str r7, [sp, #12]
    /* h0 -= carry0<<26 */
    SUB_SHIFT r2, r3, 26
    str     r2, [sp, #0];  str r3, [sp, #4]

    /* carry1: h1 (k=25) */
    ldr     r2, [sp, #8];  ldr r3, [sp, #12]
    CARRY25_WITH_ROUND
    /* h2 += carry1 */
    ldr     r6, [sp, #16]; ldr r7, [sp, #20]
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #16]; str r7, [sp, #20]
    /* h1 -= carry1<<25 */
    SUB_SHIFT r2, r3, 25
    str     r2, [sp, #8];  str r3, [sp, #12]

    /* carry2: h2 (k=26) */
    ldr     r2, [sp, #16]; ldr r3, [sp, #20]
    CARRY26_WITH_ROUND
    ldr     r6, [sp, #24]; ldr r7, [sp, #28]   /* h3 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #24]; str r7, [sp, #28]
    SUB_SHIFT r2, r3, 26
    str     r2, [sp, #16]; str r3, [sp, #20]

    /* carry3: h3 (k=25) */
    ldr     r2, [sp, #24]; ldr r3, [sp, #28]
    CARRY25_WITH_ROUND
    ldr     r6, [sp, #32]; ldr r7, [sp, #36]   /* h4 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #32]; str r7, [sp, #36]
    SUB_SHIFT r2, r3, 25
    str     r2, [sp, #24]; str r3, [sp, #28]

    /* carry4: h4 (k=26) */
    ldr     r2, [sp, #32]; ldr r3, [sp, #36]
    CARRY26_WITH_ROUND
    ldr     r6, [sp, #40]; ldr r7, [sp, #44]   /* h5 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #40]; str r7, [sp, #44]
    SUB_SHIFT r2, r3, 26
    str     r2, [sp, #32]; str r3, [sp, #36]

    /* carry5: h5 (k=25) */
    ldr     r2, [sp, #40]; ldr r3, [sp, #44]
    CARRY25_WITH_ROUND
    ldr     r6, [sp, #48]; ldr r7, [sp, #52]   /* h6 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #48]; str r7, [sp, #52]
    SUB_SHIFT r2, r3, 25
    str     r2, [sp, #40]; str r3, [sp, #44]

    /* carry6: h6 (k=26) */
    ldr     r2, [sp, #48]; ldr r3, [sp, #52]
    CARRY26_WITH_ROUND
    ldr     r6, [sp, #56]; ldr r7, [sp, #60]   /* h7 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #56]; str r7, [sp, #60]
    SUB_SHIFT r2, r3, 26
    str     r2, [sp, #48]; str r3, [sp, #52]

    /* carry7: h7 (k=25) */
    ldr     r2, [sp, #56]; ldr r3, [sp, #60]
    CARRY25_WITH_ROUND
    ldr     r6, [sp, #64]; ldr r7, [sp, #68]   /* h8 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #64]; str r7, [sp, #68]
    SUB_SHIFT r2, r3, 25
    str     r2, [sp, #56]; str r3, [sp, #60]

    /* carry8: h8 (k=26) */
    ldr     r2, [sp, #64]; ldr r3, [sp, #68]
    CARRY26_WITH_ROUND
    ldr     r6, [sp, #72]; ldr r7, [sp, #76]   /* h9 */
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #72]; str r7, [sp, #76]
    SUB_SHIFT r2, r3, 26
    str     r2, [sp, #64]; str r3, [sp, #68]

    /* carry9: h9 (k=25)；h0 += carry9*19，h9 -= carry9<<25 */
    ldr     r2, [sp, #72]; ldr r3, [sp, #76]   /* h9 */
    CARRY25_WITH_ROUND           /* r4 = carry9 */
    /* h0 += carry9*19 */
    ldr     r6, [sp, #0];  ldr r7, [sp, #4]
    SCALE19 r5, r4
    ADDS    r6, r6, r5
    ADC     r7, r7, #0
    str     r6, [sp, #0];  str r7, [sp, #4]
    /* h9 -= carry9<<25 */
    SUB_SHIFT r2, r3, 25
    str     r2, [sp, #72]; str r3, [sp, #76]

    /* 再做一次 carry0, carry1（與 C 相同） */
    /* carry0 again (k=26) */
    ldr     r2, [sp, #0];  ldr r3, [sp, #4]
    CARRY26_WITH_ROUND
    /* h1 += carry0' */
    ldr     r6, [sp, #8];  ldr r7, [sp, #12]
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #8];  str r7, [sp, #12]
    SUB_SHIFT r2, r3, 26
    str     r2, [sp, #0];  str r3, [sp, #4]

    /* carry1 again (k=25) */
    ldr     r2, [sp, #8];  ldr r3, [sp, #12]
    CARRY25_WITH_ROUND
    /* h2 += carry1' */
    ldr     r6, [sp, #16]; ldr r7, [sp, #20]
    ADDS    r6, r6, r4
    ADC     r7, r7, #0
    str     r6, [sp, #16]; str r7, [sp, #20]
    SUB_SHIFT r2, r3, 25
    str     r2, [sp, #8];  str r3, [sp, #12]

    /* =========== 寫出最終 h[0..9] 到呼叫者緩衝區 =========== */
    /* r1 = h */
    /* h0..h9 位於 [sp + 0..76] */
    /* 逐一存回（小端 64-bit）： */
    ldr     r2, [sp, #0];  ldr r3, [sp, #4]
    str     r2, [r1, #0];  str r3, [r1, #4]
    ldr     r2, [sp, #8];  ldr r3, [sp, #12]
    str     r2, [r1, #8];  str r3, [r1, #12]
    ldr     r2, [sp, #16]; ldr r3, [sp, #20]
    str     r2, [r1, #16]; str r3, [r1, #20]
    ldr     r2, [sp, #24]; ldr r3, [sp, #28]
    str     r2, [r1, #24]; str r3, [r1, #28]
    ldr     r2, [sp, #32]; ldr r3, [sp, #36]
    str     r2, [r1, #32]; str r3, [r1, #36]
    ldr     r2, [sp, #40]; ldr r3, [sp, #44]
    str     r2, [r1, #40]; str r3, [r1, #44]
    ldr     r2, [sp, #48]; ldr r3, [sp, #52]
    str     r2, [r1, #48]; str r3, [r1, #52]
    ldr     r2, [sp, #56]; ldr r3, [sp, #60]
    str     r2, [r1, #56]; str r3, [r1, #60]
    ldr     r2, [sp, #64]; ldr r3, [sp, #68]
    str     r2, [r1, #64]; str r3, [r1, #68]
    ldr     r2, [sp, #72]; ldr r3, [sp, #76]
    str     r2, [r1, #72]; str r3, [r1, #76]

    /* 尾聲 */
    add     sp, sp, #80
    pop     {r4-r11, pc}