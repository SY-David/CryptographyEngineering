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
    asr             r7, \reg, #15
    and             r7, r7, r3
    add             \reg, \reg, r7
    lsl             r7, \reg, #4
    add             r7, r7, r4
    mul             r7, r7, r5
    lsr             \reg, r7, #28
    uxth            \reg, \reg
.endm

.global poly_compress_s
.type poly_compress_s, %function
poly_compress_s:
    push            {r4-r7, lr}
    movs            r2, #32
    ldr             r3, =#3329
    ldr             r4, =#1664
    ldr             r5, =#80635
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
