.syntax unified
.thumb
.thumb_func
.arch armv7e-m
.fpu fpv4-sp-d16
.type fe25519_square_core_s, %function
.text
.global fe25519_mul_core_s
fe25519_mul_core_s:

    push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
    sub     sp, sp, #172
    ldr     r3, [r0]@ unaligned
    ldr     r4, [r0, #4]@ unaligned
    str     r2, [sp, #44]
    bic     lr, r3, #-67108864
    ldr     r2, [r0, #8]          @ unaligned
    ldr     r7, [r1, #24]         @ unaligned
    ldr     r5, [r1, #28]         @ unaligned
    ldr     r9, [r1, #20]         @ unaligned
    ldr     ip, [r1]@ unaligned
    ldr     r10, [r0, #28]@ unaligned
    str     lr, [sp, #28]
    lsrs    r3, r3, #26
    orr     r3, r3, r4, lsl#6
    lsrs    r4, r4, #19
    orr     r4, r4, r2, lsl#13
    bic     fp, r3, #-33554432
    bic     r3, r4, #-67108864
    ldr     r4, [r0, #12]         @ unaligned
    ldr     lr, [r0, #20]         @ unaligned
    str     fp, [sp, #32]
    lsrs    r2, r2, #13
    orr     r2, r2, r4, lsl#19
    bic     r2, r2, #-33554432
    str     r2, [sp, #36]
    lsrs    r2, r7, #12
    orr     r2, r2, r5, lsl#20
    lsrs    r4, r4, #6
    str     r4, [sp, #4]
    bic     r6, r2, #-67108864
    ubfx    r4, r5, #6, #25
    movs    r2, #19
    mov     r5, fp
    str     r4, [sp, #116]
    smull   r4, r2, r4, r2
    adds    r2, r5, r5
    lsr     r5, r9, #19
    orr     r5, r5, r7, lsl#13
    bic     fp, r5, #-33554432
    str     r6, [sp, #108]
    ldr     r5, [r0, #16]         @ unaligned
    ldr     r6, [r0, #24]         @ unaligned
    ldr     r0, [r1, #4]          @ unaligned
    ldr     r8, [r1, #16]         @ unaligned
    str     r2, [sp, #72]
    bic     r7, ip, #-67108864
    lsr     ip, ip, #26
    orr     ip, ip, r0, lsl#6
    bic     ip, ip, #-33554432
    str     ip, [sp, #16]
    lsr     ip, lr, #19
    orr     ip, ip, r6, lsl#13
    lsrs    r6, r6, #12
    orr     r6, r6, r10, lsl#20
    ubfx    r10, r10, #6, #25
    str     r10, [sp, #64]
    bic     r10, r6, #-67108864
    lsr     r6, r8, #25
    orr     r6, r6, r9, lsl#7
    bic     r9, r6, #-67108864
    str     r9, [sp, #88]
    ldr     r6, [r1, #8]@ unaligned
    str     r10, [sp, #12]
    bic     r9, r8, #-33554432
    bic     ip, ip, #-33554432
    str     ip, [sp, #60]
    str     r9, [sp, #52]
    lsrs    r0, r0, #19
    ldr     r1, [r1, #12]@ unaligned
    str     fp, [sp, #104]
    orr     r0, r0, r6, lsl#13
    lsrs    r6, r6, #13
    orr     r6, r6, r1, lsl#19
    bic     r10, r6, #-33554432
    ldr     r6, [sp, #108]
    str     r10, [sp, #24]
    bic     r9, r0, #-67108864
    lsrs    r1, r1, #6
    movs    r0, #19
    str     r1, [sp, #56]
    mov     ip, r9
    smull   r9, r1, r6, r0
    smull   r2, r1, fp, r0
    mov     r6, r0
    bic     r0, r5, #-33554432
    lsrs    r5, r5, #25
    ldr     r1, [sp, #36]
    str     r9, [sp]
    orr     r5, r5, lr, lsl#7
    bic     r8, r5, #-67108864
    ldr     r5, [sp, #88]
    ldr     r9, [sp, #52]
    str     r8, [sp, #8]
    mov     fp, r0
    adds    r0, r1, r1
    str     r0, [sp, #76]
    smull   r5, r1, r5, r6
    mov     r0, fp
    str     r5, [sp, #40]
    adds    r5, r0, r0
    str     r5, [sp, #96]
    ldr     r5, [sp, #60]
    str     fp, [sp, #48]
    mov     r8, r6
    adds    r6, r5, r5
    smull   r0, r1, r9, r8
    mov     r5, r6
    ldr     r1, [sp, #56]
    ldr     r6, [sp, #64]
    str     r0, [sp, #68]
    adds    r6, r6, r6
    smull   lr, r1, r1, r8
    mov     fp, lr
    str     r6, [sp, #84]
    smull   lr, r1, r10, r8
    smull   r6, r1, ip, r8
    ldr     r8, [sp, #72]
    str     lr, [sp, #112]
    ldr     lr, [sp, #28]
    ldr     r10, [sp]
    str     ip, [sp, #20]
    smull   r0, ip, r4, r8
    ldr     r1, [sp, #76]
    ldr     r9, [sp, #40]
    ldr     r8, [sp, #96]
    str     fp, [sp, #92]
    smlal   r0, ip, lr, r7
    smlal   r0, ip, r3, r10
    smlal   r0, ip, r2, r1
    ldr     r1, [sp, #4]
    smlal   r0, ip, r1, r9
    ldr     r1, [sp, #68]
    smlal   r0, ip, r1, r8
    ldr     r8, [sp, #8]
    smlal   r0, ip, r8, fp
    ldr     r8, [sp, #112]
    str     r5, [sp, #80]
    smlal   r0, ip, r8, r5
    ldr     r5, [sp, #32]
    ldr     r8, [sp, #16]
    str     r3, [sp, #100]
    smull   r1, r5, r5, r7
    smlal   r1, r5, lr, r8
    smlal   r1, r5, r3, r4
    ldr     r3, [sp, #36]
    ldr     fp, [sp, #12]
    ldr     lr, [sp, #48]
    str     r4, [sp, #120]
    smlal   r1, r5, r3, r10
    ldr     r3, [sp, #4]
    ldr     r10, [sp, #92]
    smlal   r1, r5, r3, r2
    smlal   r0, ip, fp, r6
    smlal   r1, r5, lr, r9
    ldr     fp, [sp, #8]
    ldr     lr, [sp, #68]
    ldr     r3, [sp, #112]
    smlal   r1, r5, fp, lr
    ldr     fp, [sp, #60]
    smlal   r1, r5, fp, r10
    ldr     r10, [sp, #12]
    ldr     fp, [sp, #64]
    smlal   r1, r5, r10, r3
    smlal   r1, r5, fp, r6
    ldr     fp, [sp, #84]
    mov     r10, r1
    smull   r1, lr, r8, fp
    mov     r3, r8
    lsls    r6, r1, #3
    lsl     r8, lr, #3
    adds    r6, r6, r1
    orr     r8, r8, r1, lsr#29
    adc     r8, lr, r8
    adds    r6, r6, r6
    adc     r8, r8, r8
    adds    r6, r6, r1
    adc     lr, lr, r8
    adds    r6, r0, r6
    adc     lr, ip, lr
    adds    r8, r6, #33554432
    adc     r0, lr, #0
    lsr     ip, r8, #26
    orr     ip, ip, r0, lsl#6
    adds    ip, ip, r10
    and     r1, r8, #-67108864
    adc     r5, r5, r0, asr#26
    subs    r6, r6, r1
    sbc     r0, lr, r0
    str     r0, [sp, #136]
    ldr     r0, [sp, #72]
    ldr     r10, [sp, #20]
    str     r6, [sp, #132]
    smull   r1, r0, r3, r0
    ldr     r3, [sp, #28]
    smlal   r1, r0, r3, r10
    ldr     r3, [sp, #100]
    ldr     r10, [sp, #76]
    smlal   r1, r0, r3, r7
    smlal   r1, r0, r4, r10
    ldrd    r4, r3, [sp]
    smlal   r1, r0, r3, r4
    ldr     r4, [sp, #96]
    ldr     r10, [sp, #12]
    smlal   r1, r0, r2, r4
    ldr     r4, [sp, #8]
    smlal   r1, r0, r4, r9
    ldr     r4, [sp, #68]
    ldr     r9, [sp, #80]
    smlal   r1, r0, r4, r9
    ldr     r9, [sp, #92]
    ldr     r4, [sp, #112]
    adds    lr, ip, #16777216
    adc     r8, r5, #0
    smlal   r1, r0, r10, r9
    lsr     r6, lr, #25
    smlal   r1, r0, r4, fp
    orr     r6, r6, r8, lsl#7
    adds    r6, r6, r1
    and     lr, lr, #-33554432
    adc     r0, r0, r8, asr#25
    subs    ip, ip, lr
    str     ip, [sp, #140]
    ldr     r10, [sp, #20]
    ldr     lr, [sp, #32]
    ldr     r4, [sp, #16]
    ldr     r9, [sp, #36]
    ldr     fp, [sp, #4]
    smull   r1, lr, lr, r10
    ldrd    r10, r3, [sp, #24]
    smlal   r1, lr, r3, r10
    ldr     r3, [sp, #100]
    smlal   r1, lr, r3, r4
    ldr     r4, [sp, #120]
    smlal   r1, lr, r9, r7
    smlal   r1, lr, fp, r4
    ldr     r9, [sp]
    ldr     fp, [sp, #48]
    smlal   r1, lr, fp, r9
    ldr     r9, [sp, #8]
    ldr     fp, [sp, #60]
    smlal   r1, lr, r9, r2
    ldr     r9, [sp, #40]
    smlal   r1, lr, fp, r9
    ldr     r9, [sp, #68]
    ldr     fp, [sp, #12]
    sbc     r8, r5, r8
    smlal   r1, lr, fp, r9
    adds    r5, r6, #33554432
    ldr     r9, [sp, #92]
    ldr     fp, [sp, #64]
    str     r8, [sp, #144]
    adc     ip, r0, #0
    lsr     r8, r5, #26
    smlal   r1, lr, fp, r9
    orr     r8, r8, ip, lsl#6
    adds    r1, r8, r1
    and     r5, r5, #-67108864
    adc     lr, lr, ip, asr#26
    subs    r5, r6, r5
    sbc     ip, r0, ip
    str     r1, [sp, #100]
    adds    r1, r1, #16777216
    and     r0, r1, #-33554432
    str     r5, [sp, #148]
    str     ip, [sp, #152]
    str     r0, [sp, #156]
    adc     ip, lr, #0
    ldr     r0, [sp, #72]
    ldr     r6, [sp, #56]
    str     ip, [sp, #92]
    lsrs    r5, r1, #25
    orr     r5, r5, ip, lsl#7
    ldr     ip, [sp, #28]
    ldr     r8, [sp, #20]
    str     lr, [sp, #112]
    smull   r1, r0, r10, r0
    ldr     lr, [sp, #16]
    ldr     fp, [sp, #4]
    smlal   r1, r0, r6, ip
    ldr     r6, [sp, #76]
    smlal   r1, r0, r3, r8
    smlal   r1, r0, lr, r6
    ldr     r6, [sp, #96]
    ldr     r9, [sp]
    ldr     r10, [sp, #12]
    smlal   r1, r0, fp, r7
    smlal   r1, r0, r4, r6
    ldr     r6, [sp, #8]
    ldr     fp, [sp, #84]
    smlal   r1, r0, r6, r9
    ldr     r6, [sp, #80]
    ldr     r9, [sp, #36]
    smlal   r1, r0, r2, r6
    ldr     r6, [sp, #40]
    smlal   r1, r0, r10, r6
    ldr     r10, [sp, #68]
    smlal   r1, r0, r10, fp
    adds    r6, r5, r1
    ldr     r5, [sp, #92]
    str     r6, [sp, #120]
    adc     r0, r0, r5, asr#25
    adds    r1, r6, #33554432
    str     r0, [sp, #124]
    lsr     r5, r1, #26
    adc     r0, r0, #0
    ldr     r6, [sp, #56]
    str     r0, [sp, #68]
    orr     r5, r5, r0, lsl#6
    ldr     r0, [sp, #32]
    ldr     r10, [sp, #24]
    ldr     fp, [sp, #4]
    and     r1, r1, #-67108864
    str     r1, [sp, #160]
    smull   r1, r0, r6, r0
    ldr     r6, [sp, #52]
    smlal   r1, r0, ip, r6
    smlal   r1, r0, r3, r10
    smlal   r1, r0, r9, r8
    smlal   r1, r0, fp, lr
    ldr     fp, [sp, #48]
    ldr     r10, [sp, #12]
    mov     r6, r8
    ldr     r8, [sp, #8]
    smlal   r1, r0, fp, r7
    smlal   r1, r0, r8, r4
    ldr     fp, [sp]
    ldr     r8, [sp, #60]
    smlal   r1, r0, r8, fp
    smlal   r1, r0, r10, r2
    ldr     r8, [sp, #40]
    ldr     r10, [sp, #64]
    smlal   r1, r0, r10, r8
    ldr     r8, [sp, #68]
    adds    r1, r5, r1
    adc     r8, r0, r8, asr#26
    str     r1, [sp, #40]
    adds    r1, r1, #16777216
    lsr     r5, r1, #25
    and     r1, r1, #-33554432
    ldr     r0, [sp, #52]
    str     r1, [sp, #164]
    ldr     r1, [sp, #72]
    str     r8, [sp, #128]
    ldr     r10, [sp, #88]
    ldr     r9, [sp, #56]
    smull   r1, r0, r0, r1
    smlal   r1, r0, ip, r10
    smlal   r1, r0, r9, r3
    ldr     r10, [sp, #24]
    ldr     r9, [sp, #76]
    smlal   r1, r0, r10, r9
    mov     r10, r6
    ldr     r6, [sp, #4]
    ldr     r9, [sp, #56]
    smlal   r1, r0, r6, r10
    ldr     r10, [sp, #96]
    mov     r6, lr
    smlal   r1, r0, lr, r10
    ldr     lr, [sp, #8]
    smlal   r1, r0, lr, r7
    ldr     lr, [sp, #80]
    smlal   r1, r0, r4, lr
    ldr     lr, [sp, #12]
    smlal   r1, r0, lr, fp
    ldr     fp, [sp, #84]
    ldr     lr, [sp, #104]
    adc     r8, r8, #0
    smlal   r1, r0, r2, fp
    orr     r5, r5, r8, lsl#7
    adds    r5, r5, r1
    adc     r2, r0, r8, asr#25
    str     r2, [sp, #84]
    ldr     r2, [sp, #72]
    ldr     r0, [sp, #76]
    str     r5, [sp, #56]
    smull   r2, r1, lr, r2
    mov     lr, ip
    ldr     ip, [sp, #108]
    smlal   r2, r1, lr, ip
    ldr     ip, [sp, #88]
    smlal   r2, r1, r3, ip
    ldr     ip, [sp, #52]
    smlal   r2, r1, ip, r0
    ldr     r0, [sp, #4]
    ldr     ip, [sp, #24]
    smlal   r2, r1, r0, r9
    smlal   r2, r1, ip, r10
    ldr     r10, [sp, #20]
    ldr     ip, [sp, #8]
    ldr     r0, [sp, #80]
    smlal   r2, r1, ip, r10
    ldr     r10, [sp, #12]
    smlal   r2, r1, r6, r0
    smlal   r2, r1, r10, r7
    ldr     r6, [sp, #84]
    mov     ip, r2
    adds    r2, r5, #33554432
    adc     r0, r6, #0
    ldr     r5, [sp, #32]
    str     r0, [sp, #28]
    ldr     r0, [sp, #108]
    smull   r6, r0, r5, r0
    ldr     r5, [sp, #116]
    smlal   ip, r1, r4, fp
    ldr     fp, [sp, #104]
    smlal   r6, r0, lr, r5
    mov     r10, r3
    smlal   r6, r0, r3, fp
    ldr     r3, [sp, #36]
    ldr     r5, [sp, #88]
    smlal   r6, r0, r3, r5
    ldr     r3, [sp, #32]
    smull   r3, r5, r3, r5
    smlal   r3, r5, lr, fp
    mov     lr, r10
    ldr     r10, [sp, #52]
    ldr     fp, [sp, #4]
    smlal   r3, r5, lr, r10
    ldr     lr, [sp, #36]
    smlal   r3, r5, r9, lr
    ldr     lr, [sp, #24]
    smlal   r6, r0, fp, r10
    smlal   r3, r5, fp, lr
    ldr     r10, [sp, #20]
    ldr     fp, [sp, #48]
    smlal   r6, r0, r9, fp
    smlal   r3, r5, fp, r10
    ldr     fp, [sp, #8]
    ldr     r9, [sp]
    smlal   r6, r0, fp, lr
    ldr     lr, [sp, #16]
    smlal   r3, r5, fp, lr
    ldr     fp, [sp, #60]
    smlal   r6, r0, fp, r10
    ldr     r10, [sp, #12]
    smlal   r3, r5, fp, r7
    smlal   r6, r0, r10, lr
    smlal   r3, r5, r10, r4
    ldr     r10, [sp, #64]
    mov     r4, r6
    smlal   r4, r0, r10, r7
    ldr     r7, [sp, #28]
    lsrs    r6, r2, #26
    smlal   r3, r5, r10, r9
    orr     r6, r6, r7, lsl#6
    adds    r3, r6, r3
    adc     r5, r5, r7, asr#26
    str     r3, [sp]
    and     r2, r2, #-67108864
    adds    r3, r3, #16777216
    adc     r6, r5, #0
    str     r2, [sp, #20]
    lsrs    r2, r3, #25
    orr     r2, r2, r6, lsl#7
    adds    r2, r2, ip
    adc     ip, r1, r6, asr#25
    and     r3, r3, #-33554432
    adds    r1, r2, #33554432
    str     r5, [sp, #4]
    str     r3, [sp, #24]
    lsr     r5, r1, #26
    adc     r3, ip, #0
    orr     r5, r5, r3, lsl#6
    adds    r4, r5, r4
    adc     r7, r0, r3, asr#26
    ldrd    fp, r10, [sp, #132]
    adds    r0, r4, #16777216
    and     lr, r1, #-67108864
    str     r7, [sp, #12]
    lsr     r1, r0, #25
    adc     r7, r7, #0
    str     lr, [sp, #32]
    orr     r1, r1, r7, lsl#7
    mov     lr, #19
    smlal   fp, r10, r1, lr
    mov     r9, r10
    str     r4, [sp, #8]
    adds    r4, fp, #33554432
    adc     r5, r9, #0
    and     r10, r0, #-33554432
    lsrs    r1, r4, #26
    ldr     r0, [sp, #140]
    ldr     lr, [sp, #144]
    str     r10, [sp, #36]
    orr     r1, r1, r5, lsl#6
    adds    r1, r1, r0
    adc     r10, lr, r5, asr#26
    and     r4, r4, #-67108864
    adds    r0, r1, #16777216
    adc     lr, r10, #0
    subs    r4, fp, r4
    sbc     r5, r9, r5
    ldr     r9, [sp, #44]
    strd    r4, r5, [r9]
    and     r4, r0, #-33554432
    subs    r1, r1, r4
    sbc     r10, r10, lr
    str     r10, [r9, #12]
    str     r1, [r9, #8]
    lsrs    r0, r0, #25
    ldr     r1, [sp, #148]
    ldr     r9, [sp, #152]
    ldr     r10, [sp, #100]
    ldr     r4, [sp, #120]
    ldr     fp, [sp, #124]
    orr     r0, r0, lr, lsl#7
    adds    r0, r0, r1
    adc     lr, r9, lr, asr#25
    ldr     r9, [sp, #156]
    ldr     r1, [sp, #40]
    subs    r10, r10, r9
    str     r10, [sp, #16]
    ldr     r9, [sp, #92]
    ldr     r10, [sp, #112]
    sbc     r10, r10, r9
    ldr     r9, [sp, #160]
    subs    r5, r4, r9
    ldr     r9, [sp, #68]
    ldr     r4, [sp, #164]
    sbc     r9, fp, r9
    ldr     fp, [sp, #128]
    subs    r4, r1, r4
    sbc     r8, fp, r8
    ldr     r1, [sp, #56]
    ldr     fp, [sp, #20]
    subs    r1, r1, fp
    str     r1, [sp, #20]
    ldr     fp, [sp, #84]
    ldr     r1, [sp, #28]
    sbc     r1, fp, r1
    ldr     fp, [sp, #44]
    str     r1, [fp, #52]
    ldr     fp, [sp, #24]
    ldr     r1, [sp]
    subs    r1, r1, fp
    ldr     fp, [sp, #4]
    sbc     r6, fp, r6
    ldr     fp, [sp, #32]
    subs    r2, r2, fp
    sbc     ip, ip, r3
    ldr     fp, [sp, #36]
    ldr     r3, [sp, #8]
    subs    r3, r3, fp
    ldr     fp, [sp, #12]
    sbc     r7, fp, r7
    ldr     fp, [sp, #44]
    strd    r0, lr, [fp, #16]
    ldr     r0, [sp, #16]
    strd    r0, r10, [fp, #24]
    ldr     r0, [sp, #20]
    str     r4, [fp, #40]
    strd    r5, r9, [fp, #32]
    strd    r6, r2, [fp, #60]
    strd    ip, r3, [fp, #68]
    str     r8, [fp, #44]
    str     r0, [fp, #48]
    str     r1, [fp, #56]
    str     r7, [fp, #76]
    add     sp, sp, #172
    pop     {r4, r5, r6, r7, r8, r9, r10, fp, pc}
.global fe25519_square_core_s
fe25519_square_core_s:
    push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
    ldr     r4, [r0]@ unaligned
    ldr     r2, [r0, #4]          @ unaligned
    ldr     r5, [r0, #24]         @ unaligned
    ldr     r6, [r0, #12]         @ unaligned
    lsrs    r3, r4, #26
    orr     r3, r3, r2, lsl#6
    bic     r7, r3, #-33554432
    ldr     r3, [r0, #8]@ unaligned
    lsrs    r2, r2, #19
    bic     fp, r4, #-67108864
    orr     r2, r2, r3, lsl#13
    ldr     r4, [r0, #28]@ unaligned
    mov     r10, r1
    bic     r9, r2, #-67108864
    ldr     r1, [r0, #20]         @ unaligned
    ldr     r0, [r0, #16]         @ unaligned
    lsrs    r2, r5, #12
    lsrs    r3, r3, #13
    sub     sp, sp, #108
    orr     r2, r2, r4, lsl#20
    orr     r3, r3, r6, lsl#19
    lsr     lr, r6, #6
    bic     ip, r2, #-67108864
    bic     r3, r3, #-33554432
    movs    r2, #19
    lsrs    r6, r1, #19
    str     r3, [sp, #4]
    str     ip, [sp, #24]
    orr     r6, r6, r5, lsl#13
    smull   ip, r3, ip, r2
    lsrs    r3, r0, #25
    bic     r6, r6, #-33554432
    orr     r3, r3, r1, lsl#7
    ubfx    r4, r4, #6, #25
    bic     r8, r3, #-67108864
    str     r4, [sp, #40]
    smull   r4, r3, r4, r2
    smull   r1, r3, r6, r2
    str     r6, [sp, #12]
    mov     r6, r1
    ldr     r1, [sp, #4]
    str     r7, [sp, #8]
    bic     r0, r0, #-33554432
    adds    r5, r7, r7
    str     r8, [sp, #16]
    adds    r7, r1, r1
    smull   r8, r3, r8, r2
    adds    r3, r0, r0
    str     r3, [sp, #36]
    ldr     r3, [sp, #12]
    str     r5, [sp, #32]
    adds    r1, r3, r3
    str     r1, [sp, #44]
    smull   r3, r1, r9, ip
    smlal   r3, r1, r4, r5
    mov     r2, r0
    smlal   r3, r1, r6, r7
    ldr     r0, [sp, #36]
    str     r7, [sp, #28]
    smlal   r3, r1, lr, r8
    adds    r5, r3, r3
    smull   r3, r7, r2, r0
    str     r5, [sp, #20]
    lsl     r0, r3, #3
    lsl     r5, r7, #3
    adcs    r1, r1, r1
    orr     r5, r5, r3, lsr#29
    adds    r0, r0, r3
    adc     r5, r7, r5
    adds    r0, r0, r0
    adcs    r5, r5, r5
    adds    r0, r0, r3
    adc     r7, r7, r5
    ldr     r5, [sp, #20]
    str     r6, [sp, #20]
    smlal   r0, r7, fp, fp
    adds    r0, r5, r0
    adc     r1, r1, r7
    ldr     r7, [sp, #8]
    str     r0, [sp, #48]
    smull   r5, r0, r9, r4
    smlal   r5, r0, fp, r7
    ldr     r7, [sp, #4]
    smlal   r5, r0, r7, ip
    smlal   r5, r0, lr, r6
    smlal   r5, r0, r2, r8
    adds    r5, r5, r5
    adc     r6, r0, r0
    str     r5, [sp, #64]
    str     r6, [sp, #68]
    ldr     r0, [sp, #16]
    ldr     r3, [sp, #32]
    ldr     r6, [sp, #36]
    smull   r8, r7, r0, r8
    ldr     r0, [sp, #8]
    smlal   r8, r7, r0, r3
    ldr     r0, [sp, #28]
    ldr     r3, [sp, #20]
    str     r2, [sp, #20]
    smull   r0, r5, r4, r0
    smlal   r0, r5, fp, r9
    smlal   r0, r5, lr, ip
    smlal   r0, r5, r3, r6
    adds    r0, r0, r0
    adcs    r5, r5, r5
    adds    r8, r0, r8
    adc     r0, r5, r7
    str     r0, [sp, #56]
    ldr     r0, [sp, #8]
    ldr     r7, [sp, #4]
    ldr     r6, [sp, #44]
    str     r8, [sp, #52]
    smull   r5, r0, r0, r9
    smlal   r5, r0, fp, r7
    smlal   r5, r0, lr, r4
    smlal   r5, r0, r2, ip
    ldr     r2, [sp, #16]
    smlal   r5, r0, r2, r3
    adds    r7, r5, r5
    adc     r8, r0, r0
    str     r7, [sp, #72]
    ldr     r0, [sp, #4]
    str     r8, [sp, #76]
    smull   r5, r7, r3, r6
    ldr     r3, [sp, #32]
    ldr     r6, [sp, #36]
    smull   r0, r8, r0, r3
    smlal   r0, r8, lr, fp
    smlal   r0, r8, r4, r6
    smlal   r0, r8, r2, ip
    smlal   r5, r7, r9, r9
    adds    r0, r0, r0
    adc     r8, r8, r8
    adds    r0, r0, r5
    ldr     r5, [sp, #8]
    ldr     r2, [sp, #20]
    str     r0, [sp, #32]
    adc     r6, r8, r7
    str     r6, [sp, #36]
    smull   r5, r0, lr, r5
    ldr     r6, [sp, #4]
    ldr     r8, [sp, #16]
    ldr     r7, [sp, #12]
    smlal   r5, r0, fp, r2
    smlal   r5, r0, r9, r6
    smlal   r5, r0, r8, r4
    smlal   r5, r0, r7, ip
    adds    r7, r5, r5
    adc     r5, r0, r0
    str     r7, [sp, #80]
    ldr     r7, [sp, #24]
    str     r5, [sp, #84]
    ldr     r5, [sp, #28]
    smull   r0, r7, r7, ip
    smlal   r0, r7, r6, r5
    smull   r5, ip, r2, r3
    ldr     r6, [sp, #44]
    smlal   r5, ip, fp, r8
    smlal   r5, ip, lr, r9
    smlal   r5, ip, r4, r6
    adds    r5, r5, r5
    adc     ip, ip, ip
    adds    r5, r5, r0
    adc     ip, ip, r7
    str     r5, [sp, #44]
    str     ip, [sp, #60]
    ldr     r6, [sp, #12]
    ldr     ip, [sp, #24]
    smull   r0, r5, r6, r3
    smlal   r0, r5, fp, ip
    ldr     ip, [sp, #8]
    ldr     r3, [sp, #28]
    smull   ip, r7, ip, r8
    smlal   r0, r5, r9, r8
    smlal   ip, r7, fp, r6
    ldr     r6, [sp, #4]
    smlal   r0, r5, r2, r3
    smlal   ip, r7, r9, r2
    ldr     r2, [sp, #24]
    smlal   ip, r7, lr, r6
    smlal   ip, r7, r2, r4
    adds    r3, ip, ip
    ldr     ip, [sp, #8]
    str     r3, [sp, #88]
    adcs    r7, r7, r7
    ldr     r3, [sp, #40]
    str     r7, [sp, #92]
    smull   r2, r7, ip, r2
    ldr     ip, [sp, #12]
    smlal   r2, r7, fp, r3
    smlal   r2, r7, r9, ip
    smlal   r2, r7, r6, r8
    ldr     r6, [sp, #20]
    ldr     fp, [sp, #56]
    ldr     r9, [sp, #72]
    smlal   r2, r7, lr, r6
    adds    r0, r0, r0
    smull   r6, r4, r3, r4
    adcs    r5, r5, r5
    adds    r6, r6, r6
    adc     ip, r4, r4
    smlal   r6, ip, lr, lr
    adds    r4, r0, r6
    adc     r3, r5, ip
    ldr     ip, [sp, #48]
    ldr     r5, [sp, #64]
    str     r3, [sp, #8]
    adds    r6, r2, r2
    adc     lr, r7, r7
    adds    r7, ip, #33554432
    adc     r0, r1, #0
    lsrs    r2, r7, #26
    ldr     r3, [sp, #68]
    str     lr, [sp, #96]
    orr     r2, r2, r0, lsl#6
    adds    r2, r2, r5
    and     r7, r7, #-67108864
    adc     r8, r3, r0, asr#26
    subs    lr, ip, r7
    sbc     r7, r1, r0
    adds    ip, r2, #16777216
    adc     r0, r8, #0
    ldr     r1, [sp, #52]
    lsr     r3, ip, #25
    orr     r3, r3, r0, lsl#7
    adds    r3, r3, r1
    and     ip, ip, #-33554432
    adc     r1, fp, r0, asr#25
    subs    ip, r2, ip
    sbc     fp, r8, r0
    adds    r2, r3, #33554432
    adc     r0, r1, #0
    lsr     r8, r2, #26
    orr     r8, r8, r0, lsl#6
    adds    r8, r8, r9
    ldr     r9, [sp, #76]
    str     r8, [sp, #12]
    and     r2, r2, #-67108864
    adc     r9, r9, r0, asr#26
    subs    r3, r3, r2
    sbc     r1, r1, r0
    str     r3, [sp, #68]
    adds    r3, r8, #16777216
    adc     r8, r9, #0
    ldr     r0, [sp, #32]
    str     r1, [sp, #72]
    lsrs    r2, r3, #25
    orr     r2, r2, r8, lsl#7
    adds    r2, r2, r0
    ldr     r0, [sp, #36]
    ldr     r1, [sp, #80]
    str     r9, [sp, #16]
    and     r3, r3, #-33554432
    adc     r0, r0, r8, asr#25
    str     r3, [sp, #76]
    adds    r3, r2, #33554432
    adc     r9, r0, #0
    str     r2, [sp, #20]
    lsrs    r2, r3, #26
    orr     r2, r2, r9, lsl#6
    adds    r1, r2, r1
    str     r8, [sp, #4]
    str     r0, [sp, #24]
    ldr     r2, [sp, #84]
    ldr     r5, [sp, #44]
    str     r1, [sp, #28]
    and     r3, r3, #-67108864
    adc     r2, r2, r9, asr#26
    str     r3, [sp, #80]
    adds    r3, r1, #16777216
    adc     r8, r2, #0
    str     r2, [sp, #32]
    lsrs    r2, r3, #25
    orr     r2, r2, r8, lsl#7
    adds    r0, r2, r5
    ldr     r5, [sp, #60]
    str     r0, [sp, #36]
    and     r3, r3, #-33554432
    adc     r5, r5, r8, asr#25
    str     r3, [sp, #84]
    adds    r3, r0, #33554432
    adc     r1, r5, #0
    str     r5, [sp, #40]
    lsrs    r2, r3, #26
    ldr     r5, [sp, #88]
    orr     r2, r2, r1, lsl#6
    adds    r5, r2, r5
    ldr     r2, [sp, #92]
    str     r5, [sp, #44]
    and     r3, r3, #-67108864
    adc     r2, r2, r1, asr#26
    str     r3, [sp, #88]
    adds    r3, r5, #16777216
    str     r2, [sp, #48]
    lsr     r0, r3, #25
    adc     r2, r2, #0
    orr     r0, r0, r2, lsl#7
    adds    r4, r0, r4
    ldr     r0, [sp, #8]
    str     r4, [sp, #52]
    adc     r5, r0, r2, asr#25
    and     r3, r3, #-33554432
    adds    r0, r4, #33554432
    str     r3, [sp, #92]
    lsr     r4, r0, #26
    adc     r3, r5, #0
    orr     r4, r4, r3, lsl#6
    adds    r6, r4, r6
    ldr     r4, [sp, #96]
    str     r5, [sp, #56]
    adc     r4, r4, r3, asr#26
    mov     r5, r4
    and     r4, r0, #-67108864
    str     r4, [sp, #96]
    adds    r4, r6, #16777216
    str     r6, [sp, #60]
    lsr     r0, r4, #25
    adc     r6, r5, #0
    str     r5, [sp, #64]
    orr     r0, r0, r6, lsl#7
    movs    r5, #19
    smlal   lr, r7, r0, r5
    adds    r5, lr, #33554432
    and     r4, r4, #-33554432
    str     r4, [sp, #100]
    lsr     r0, r5, #26
    adc     r4, r7, #0
    orr     r0, r0, r4, lsl#6
    adds    r0, r0, ip
    str     r4, [sp, #8]
    adc     fp, fp, r4, asr#26
    and     r5, r5, #-67108864
    adds    r4, r0, #16777216
    adc     ip, fp, #0
    subs    r5, lr, r5
    ldr     lr, [sp, #8]
    sbc     r7, r7, lr
    strd    r5, r7, [r10]
    ldr     r7, [sp, #68]
    ldr     lr, [sp, #72]
    and     r5, r4, #-33554432
    lsrs    r4, r4, #25
    subs    r0, r0, r5
    orr     r4, r4, ip, lsl#7
    sbc     fp, fp, ip
    adds    r4, r4, r7
    adc     ip, lr, ip, asr#25
    str     r0, [r10, #8]
    ldr     lr, [sp, #12]
    ldr     r0, [sp, #76]
    subs    lr, lr, r0
    str     lr, [sp, #8]
    ldr     r7, [sp, #4]
    ldr     lr, [sp, #16]
    ldr     r0, [sp, #24]
    str     ip, [r10, #20]
    sbc     lr, lr, r7
    str     lr, [r10, #28]
    ldr     r7, [sp, #20]
    ldr     lr, [sp, #80]
    subs    r5, r7, lr
    ldr     r7, [sp, #28]
    ldr     lr, [sp, #84]
    sbc     r9, r0, r9
    subs    r0, r7, lr
    ldr     r7, [sp, #32]
    ldr     lr, [sp, #88]
    str     r0, [sp, #4]
    ldr     r0, [sp, #36]
    sbc     r8, r7, r8
    ldr     r7, [sp, #40]
    subs    r0, r0, lr
    sbc     lr, r7, r1
    ldr     r7, [sp, #92]
    ldr     r1, [sp, #44]
    subs    r1, r1, r7
    ldr     r7, [sp, #48]
    sbc     r2, r7, r2
    str     r2, [r10, #60]
    ldr     r7, [sp, #96]
    ldr     r2, [sp, #52]
    subs    r2, r2, r7
    ldr     r7, [sp, #56]
    sbc     r3, r7, r3
    strd    fp, r4, [r10, #12]
    ldr     r7, [sp, #100]
    ldr     r4, [sp, #8]
    str     r3, [sp, #12]
    ldr     r3, [sp, #60]
    str     r4, [r10, #24]
    ldr     r4, [sp, #4]
    subs    r3, r3, r7
    ldr     r7, [sp, #64]
    strd    r5, r9, [r10, #32]
    strd    r4, r8, [r10, #40]
    str     r2, [r10, #64]
    ldr     r2, [sp, #12]
    str     r1, [r10, #56]
    sbc     r6, r7, r6
    strd    r0, lr, [r10, #48]
    strd    r2, r3, [r10, #68]
    str     r6, [r10, #76]
    add     sp, sp, #108
    pop     {r4, r5, r6, r7, r8, r9, r10, fp, pc}
