.syntax unified
.thumb
.text

.global poly_add_s
.type poly_add_s, %function
poly_add_s:
    push            {r4, lr}
    movs            r12, #128
.p2align 2
1:
    ldr             r3, [r1], #4
    ldr             r4, [r2], #4

    sadd16          r3, r3, r4

    str             r3, [r0], #4

    subs            r12, r12, #1
    bne             1b

    pop             {r4, pc}
.size poly_add_s, .-poly_add_s

.global poly_sub_s
.type poly_sub_s, %function
poly_sub_s:
    push            {r4, lr}
    movs            r12, #128
.p2align 2

1:
    ldr             r3, [r1], #4
    ldr             r4, [r2], #4

    ssub16          r3, r3, r4

    str             r3, [r0], #4

    subs            r12, r12, #1
    bne             1b

    pop             {r4, pc}
.size poly_sub_s, .-poly_sub_s

.macro COMPRESS_NIBBLE reg
    ldrsh           \reg, [r1], #2
    asr             r7, \reg, #15
    and             r7, r7, r3
    add             \reg, \reg, r7
    add             \reg, \reg, #104 @ reg = a' + 104
    mul             r7, \reg, r5 @ r5 = 16 * 80635 = 1290160
    lsr             \reg, r7, #28

.endm

.global poly_compress_s
.type poly_compress_s, %function
poly_compress_s:
    push            {r5, r7, lr}
    movs            r2, #32
    ldr             r3, =#3329

    ldr             r5, =#1290160
.p2align 2
loop_comp:
    COMPRESS_NIBBLE r6

    COMPRESS_NIBBLE r12
    orr             r6, r6, r12, lsl#4
    strb            r6, [r0], #1

    COMPRESS_NIBBLE r6

    COMPRESS_NIBBLE r12
    orr             r6, r6, r12, lsl#4
    strb            r6, [r0], #1

    COMPRESS_NIBBLE r6

    COMPRESS_NIBBLE r12
    orr             r6, r6, r12, lsl#4
    strb            r6, [r0], #1

    COMPRESS_NIBBLE r6

    COMPRESS_NIBBLE r12
    orr             r6, r6, r12, lsl#4
    strb            r6, [r0], #1

    subs            r2, r2, #1
    bne             loop_comp
    pop             {r5, r7, pc}
.size poly_compress_s, .-poly_compress_s

.global poly_decompress_s
.type poly_decompress_s, %function
poly_decompress_s:
    push            {r4-r7, lr}
    movs            r2, #128
    ldr             r3, =3329
    movs            r4, #8
.p2align 2
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

.macro COMPRESS5_ITEM offset
    ldrsh           r6, [r1], #2
    asr             r7, r6, #15
    and             r7, r7, r3
    add             r6, r6, r7      @ r6 = a'
    add             r6, r6, #52     @ r6 = a' + 52
    mul             r6, r6, r5      @ r5 = 1290176 = 32 * 40318
    lsr             r6, r6, #27     @ top 5 bits already在低位，其餘全 0

    strb            r6, [sp, #\offset]
.endm

.global poly_compress160_s
.type poly_compress160_s, %function
poly_compress160_s:
    push            {r5-r11, lr}@ r4 不再用到，不必存
    sub             sp, sp, #8
    movs            r2, #32
    ldr             r3, =3329
    ldr             r5, =1290176 @ 32 * 40318
.p2align 2
loop_comp160:
    COMPRESS5_ITEM  0
    COMPRESS5_ITEM  1
    COMPRESS5_ITEM  2
    COMPRESS5_ITEM  3
    COMPRESS5_ITEM  4
    COMPRESS5_ITEM  5
    COMPRESS5_ITEM  6
    COMPRESS5_ITEM  7

    ldrb            r6, [sp, #0]
    ldrb            r7, [sp, #1]
    lsls            r12, r7, #5
    orr             r6, r6, r12
    strb            r6, [r0], #1

    lsrs            r6, r7, #3
    ldrb            r8, [sp, #2]
    lsls            r12, r8, #2
    orr             r6, r6, r12
    ldrb            r9, [sp, #3]
    lsls            r12, r9, #7
    orr             r6, r6, r12
    strb            r6, [r0], #1

    lsrs            r6, r9, #1
    ldrb            r10, [sp, #4]
    lsls            r12, r10, #4
    orr             r6, r6, r12
    strb            r6, [r0], #1

    lsrs            r6, r10, #4
    ldrb            r11, [sp, #5]
    lsls            r12, r11, #1
    orr             r6, r6, r12
    ldrb            r9, [sp, #6]
    lsls            r12, r9, #6
    orr             r6, r6, r12
    strb            r6, [r0], #1

    lsrs            r6, r9, #2
    ldrb            r8, [sp, #7]
    lsls            r12, r8, #3
    orr             r6, r6, r12
    strb            r6, [r0], #1

    subs            r2, r2, #1
    bne             loop_comp160
    add             sp, sp, #8
    pop             {r5-r11, pc}
.size poly_compress160_s, .-poly_compress160_s

.global poly_decompress160_s
.type poly_decompress160_s, %function
poly_decompress160_s:
    push            {r4-r11, lr}
    movs            r2, #32
    ldr             r3, =3329
    movs            r4, #16
loop_decomp160:
    ldrb            r6, [r1], #1
    ldrb            r7, [r1], #1
    ldrb            r8, [r1], #1
    ldrb            r9, [r1], #1
    ldrb            r10, [r1], #1

    mov             r11, r6
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r6, #5
    orr             r11, r11, r7, lsl#3
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r7, #2
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r7, #7
    orr             r11, r11, r8, lsl#1
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r8, #4
    orr             r11, r11, r9, lsl#4
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r9, #1
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r9, #6
    orr             r11, r11, r10, lsl#2
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    lsr             r11, r10, #3
    and             r11, r11, #31
    mul             r11, r11, r3
    add             r11, r11, r4
    lsr             r11, r11, #5
    strh            r11, [r0], #2

    subs            r2, r2, #1
    bne             loop_decomp160
    pop             {r4-r11, pc}
.size poly_decompress160_s, .-poly_decompress160_s
