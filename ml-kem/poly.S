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

.macro COMPRESS_NIBBLE dst
    ldrsh           \dst, [r1], #2
    asr             r7, \dst, #15
    and             r7, r7, r3
    add             \dst, \dst, r7
    add             \dst, \dst, #104
    mul             r7, \dst, r5
    lsr             \dst, r7, #28
.endm

.global poly_compress_s
.type poly_compress_s, %function
poly_compress_s:
    push            {r5, r7, lr}
    mov             r2, #32
    movw            r3, #3329
    ldr             r5, =1290160
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
    push            {r4, r6, r7, lr}
    mov             r2, #128
    movw            r3, #3329
    mov             r4, #8
    tst             r0, #3
    bne             loop_decomp_u
.p2align 2
loop_decomp_a:
    ldrb            r6, [r1], #1
    and             r7, r6, #0x0F
    mla             r7, r7, r3, r4
    lsr             r7, r7, #4
    lsr             r6, r6, #4
    mla             r6, r6, r3, r4
    lsr             r6, r6, #4
    orr             r7, r7, r6, lsl#16
    str             r7, [r0], #4
    subs            r2, r2, #1
    bne             loop_decomp_a
    pop             {r4, r6, r7, pc}
.p2align 2
loop_decomp_u:
    ldrb            r6, [r1], #1
    and             r7, r6, #0x0F
    mla             r7, r7, r3, r4
    lsr             r7, r7, #4
    strh            r7, [r0], #2
    lsr             r6, r6, #4
    mla             r6, r6, r3, r4
    lsr             r6, r6, #4
    strh            r6, [r0], #2
    subs            r2, r2, #1
    bne             loop_decomp_u
    pop             {r4, r6, r7, pc}
.size poly_decompress_s, .-poly_decompress_s

.macro COMPRESS5 dst
    ldrsh           \dst, [r1], #2
    asr             r12, \dst, #15
    and             r12, r12, r3
    add             \dst, \dst, r12
    add             \dst, \dst, #52
    mul             \dst, \dst, r5
    lsr             \dst, \dst, #27
.endm

.global poly_compress160_s
.type poly_compress160_s, %function
poly_compress160_s:
    push            {r5, r6, r7, lr}
    mov             r2, #32
    movw            r3, #3329
    ldr             r5, =1290176
.p2align 2
loop_comp160:
    COMPRESS5       r6
    COMPRESS5       r7
    orr             r12, r6, r7, lsl#5
    strb            r12, [r0], #1

    lsr             r12, r7, #3
    COMPRESS5       r6
    orr             r12, r12, r6, lsl#2
    COMPRESS5       r7
    orr             r12, r12, r7, lsl#7
    strb            r12, [r0], #1

    lsr             r12, r7, #1
    COMPRESS5       r6
    orr             r12, r12, r6, lsl#4
    strb            r12, [r0], #1

    lsr             r12, r6, #4
    COMPRESS5       r7
    orr             r12, r12, r7, lsl#1
    COMPRESS5       r6
    orr             r12, r12, r6, lsl#6
    strb            r12, [r0], #1

    lsr             r12, r6, #2
    COMPRESS5       r7
    orr             r12, r12, r7, lsl#3
    strb            r12, [r0], #1

    subs            r2, r2, #1
    bne             loop_comp160
    pop             {r5, r6, r7, pc}
.size poly_compress160_s, .-poly_compress160_s

.global poly_decompress160_s
.type poly_decompress160_s, %function
poly_decompress160_s:
    push            {r4, r5, r6, r7, lr}
    mov             r2, #32
    movw            r3, #3329
    mov             r4, #16
    tst             r0, #3
    bne             loop_decomp160_u
.p2align 2
loop_decomp160_a:
    ldrb            r6, [r1], #1
    ldrb            r5, [r1], #1
    orr             r6, r6, r5, lsl#8
    ldrb            r5, [r1], #1
    orr             r6, r6, r5, lsl#16
    ldrb            r5, [r1], #1
    orr             r6, r6, r5, lsl#24
    ldrb            r7, [r1], #1

    ubfx            r12, r6, #0, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    ubfx            r5, r6, #5, #5
    mla             r5, r5, r3, r4
    lsr             r5, r5, #5
    orr             r12, r12, r5, lsl#16
    str             r12, [r0], #4

    ubfx            r12, r6, #10, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    ubfx            r5, r6, #15, #5
    mla             r5, r5, r3, r4
    lsr             r5, r5, #5
    orr             r12, r12, r5, lsl#16
    str             r12, [r0], #4

    ubfx            r12, r6, #20, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    ubfx            r5, r6, #25, #5
    mla             r5, r5, r3, r4
    lsr             r5, r5, #5
    orr             r12, r12, r5, lsl#16
    str             r12, [r0], #4

    mov             lr, r7
    and             r7, r7, #7
    ubfx            r12, r6, #30, #2
    orr             r12, r12, r7, lsl#2
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    lsr             r5, lr, #3
    mla             r5, r5, r3, r4
    lsr             r5, r5, #5
    orr             r12, r12, r5, lsl#16
    str             r12, [r0], #4

    subs            r2, r2, #1
    bne             loop_decomp160_a
    pop             {r4, r5, r6, r7, pc}
.p2align 2
loop_decomp160_u:
    ldrb            r6, [r1], #1
    ldrb            r5, [r1], #1
    orr             r6, r6, r5, lsl#8
    ldrb            r5, [r1], #1
    orr             r6, r6, r5, lsl#16
    ldrb            r5, [r1], #1
    orr             r6, r6, r5, lsl#24
    ldrb            r7, [r1], #1

    ubfx            r12, r6, #0, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    ubfx            r12, r6, #5, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    ubfx            r12, r6, #10, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    ubfx            r12, r6, #15, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    ubfx            r12, r6, #20, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    ubfx            r12, r6, #25, #5
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    mov             lr, r7
    and             r7, r7, #7
    ubfx            r12, r6, #30, #2
    orr             r12, r12, r7, lsl#2
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    lsr             r12, lr, #3
    mla             r12, r12, r3, r4
    lsr             r12, r12, #5
    strh            r12, [r0], #2

    subs            r2, r2, #1
    bne             loop_decomp160_u
    pop             {r4, r5, r6, r7, pc}
.size poly_decompress160_s, .-poly_decompress160_s
