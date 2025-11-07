.syntax unified
.thumb
.text

.global poly_add_s
.type poly_add_s, %function
poly_add_s:
    push            {r4-r5, lr}
    movs            r12, #128
loop1:
    ldrh            r3, [r1], #2 // r3 = a[i]
    ldrh            r4, [r1], #2 // r4 = a[i+1]
    // *** 修正 A ***
    pkhbt           r3, r3, r4, lsl#16 // r3 = [ a[i+1] | a[i] ]

    ldrh            r4, [r2], #2
    ldrh            r5, [r2], #2

    pkhbt           r4, r4, r5, lsl#16 // r4 = [ b[i+1] | b[i] ]

    sadd16          r3, r3, r4

    strh            r3, [r0], #2
    lsr             r4, r3, #16
    strh            r4, [r0], #2

    subs            r12, r12, #1
    bne             loop1
    pop             {r4-r5, pc}
.size poly_add_s, .-poly_add_s

.global poly_sub_s
.type poly_sub_s, %function
poly_sub_s:
    push            {r4-r5, lr}
    movs            r12, #128
loop2:
    ldrh            r3, [r1], #2
    ldrh            r4, [r1], #2
    pkhbt           r3, r3, r4, lsl#16

    ldrh            r4, [r2], #2
    ldrh            r5, [r2], #2
    pkhbt           r4, r4, r5, lsl#16

    ssub16          r3, r3, r4
    strh            r3, [r0], #2
    lsr             r4, r3, #16
    strh            r4, [r0], #2

    subs            r12, r12, #1
    bne             loop2
    pop             {r4-r5, pc}
.size poly_sub_s, .-poly_sub_s

.macro COMPRESS_NIBBLE reg
    ldrsh           \reg, [r1], #2
    asr             r12, \reg, #15
    and             r12, r12, r3
    add             \reg, \reg, r12
    lsl             r12, \reg, #4
    add             r12, r12, r4
    mul             r12, r12, r5
    lsr             \reg, r12, #28
    ubfx            \reg \reg
.endm

.global poly_compress_s
.type poly_compress_s, %function
poly_compress_s:
    push            {r4-r7, lr}
    movs            r2, #32
    ldr             r3, =3329
    ldr             r4, =1665
    ldr             r5, =80635
loop_comp:
    COMPRESS_NIBBLE r6
    mov             r12, r6
    COMPRESS_NIBBLE r6
    orr             r6, r12, r6, lsl#4
    strb            r6, [r0], #1

    COMPRESS_NIBBLE r6
    mov             r12, r6
    COMPRESS_NIBBLE r6
    orr             r6, r12, r6, lsl#4
    strb            r6, [r0], #1

    COMPRESS_NIBBLE r6
    mov             r12, r6
    COMPRESS_NIBBLE r6
    orr             r6, r12, r6, lsl#4
    strb            r6, [r0], #1

    COMPRESS_NIBBLE r6
    mov             r12, r6
    COMPRESS_NIBBLE r6
    orr             r6, r12, r6, lsl#4
    strb            r6, [r0], #1

    subs            r2, r2, #1
    bne             loop_comp
    pop             {r4-r7, pc}
.size poly_compress_s, .-poly_compress_s

.global poly_decompress_s
.type poly_decompress_s, %function
poly_decompress_s:
    push            {r4-r7, lr}
    movs            r2, #128
    ldr             r3, =3329
    movs            r4, #8
loop_decomp:
    ldrb            r6, [r1], #1
    and             r7, r6, #0x0F
    mul             r7, r7, r3
    add             r7, r7, r4
    lsr             r7, r7, #4
    strh            r7, [r0], #2

    lsrs            r6, r6, #4
    mul             r6, r6, r3
    add             r6, r6, r4
    lsr             r6, r6, #4
    strh            r6, [r0], #2

    subs            r2, r2, #1
    bne             loop_decomp
    pop             {r4-r7, pc}
.size poly_decompress_s, .-poly_decompress_s

.macro COMPRESS_5BIT reg
    ldrsh           \reg, [r1], #2
    asr             r12, \reg, #15
    and             r12, r12, r3
    add             \reg, \reg, r12
    lsl             r12, \reg, #5
    add             r12, r12, r4
    mul             r12, r12, r5
    lsr             \reg, r12, #27

.endm

.global poly_compress160_s
.type poly_compress160_s, %function
poly_compress160_s:
    push            {r4-r11, lr}
    movs            r2, #32
    ldr             r3, =3329
    ldr             r4, =1664
    ldr             r5, =40318
loop_comp160:
    COMPRESS_5BIT   r6          @ t0
    COMPRESS_5BIT   r7          @ t1
    mov             r12, r6
    orr             r12, r12, r7, lsl#5
    strb            r12, [r0], #1

    COMPRESS_5BIT   r8          @ t2
    COMPRESS_5BIT   r9          @ t3
    mov             r12, r7
    lsrs            r12, r12, #3
    orr             r12, r12, r8, lsl#2
    orr             r12, r12, r9, lsl#7
    strb            r12, [r0], #1

    COMPRESS_5BIT   r10 @ t4
    mov             r12, r9
    lsrs            r12, r12, #1
    orr             r12, r12, r10, lsl#4
    strb            r12, [r0], #1

    COMPRESS_5BIT   r11         @ t5
    COMPRESS_5BIT   r6          @ t6 (reuse r6)
    mov             r12, r10
    lsrs            r12, r12, #4
    orr             r12, r12, r11, lsl#1
    orr             r12, r12, r6, lsl#6
    strb            r12, [r0], #1

    COMPRESS_5BIT   r7 @ t7 (reuse r7)
    mov             r12, r6
    lsrs            r12, r12, #2
    orr             r12, r12, r7, lsl#3
    strb            r12, [r0], #1

    subs            r2, r2, #1
    bne             loop_comp160
    pop             {r4-r11, pc}
.size poly_compress160_s, .-poly_compress160_s

.macro DECOMP_STORE5 val, tmp
    mul             \tmp, \val, r3
    add             \tmp, \tmp, r4
    lsr             \tmp, \tmp, #5
    strh            \tmp, [r0], #2
.endm

.global poly_decompress160_s
.type poly_decompress160_s, %function
poly_decompress160_s:
    push            {r4-r11, lr}
    movs            r2, #32
    ldr             r3, =3329
    movs            r4, #16
loop_decomp160:
    ldrb            r5, [r1], #1
    ldrb            r6, [r1], #1
    ldrb            r7, [r1], #1
    ldrb            r8, [r1], #1
    ldrb            r9, [r1], #1

    mov             r10, r5
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r5
    lsrs            r10, r10, #5
    orr             r10, r10, r6, lsl#3
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r6
    lsrs            r10, r10, #2
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r6
    lsrs            r10, r10, #7
    orr             r10, r10, r7, lsl#1
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r7
    lsrs            r10, r10, #4
    orr             r10, r10, r8, lsl#4
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r8
    lsrs            r10, r10, #1
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r8
    lsrs            r10, r10, #6
    orr             r10, r10, r9, lsl#2
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    mov             r10, r9
    lsrs            r10, r10, #3
    and             r10, r10, #31
    DECOMP_STORE5   r10, r11

    subs            r2, r2, #1
    bne             loop_decomp160
    pop             {r4-r11, pc}
.size poly_decompress160_s, .-poly_decompress160_s
