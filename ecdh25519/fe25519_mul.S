fe25519_mul_core_s:
    push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
    ldr     r3, [r0]@ unaligned
    ldr     r8, [r1, #4]@ unaligned
    sub     sp, sp, #228
    mov     r9, r2
    bic     r2, r3, #-67108864
    str     r2, [sp, #20]
    ldr     r2, [r1, #8]@ unaligned
    lsr     r4, r8, #19
    orr     r4, r4, r2, lsl#13
    bic     r6, r4, #-67108864
    ldr     r4, [r1, #12]@ unaligned
    str     r6, [sp, #44]
    lsrs    r2, r2, #13
    orr     r2, r2, r4, lsl#19
    bic     r5, r2, #-33554432
    lsls    r2, r6, #3
    lsrs    r7, r4, #6
    adds    r2, r2, r6
    mov     r4, #0
    adc     r4, r4, #0
    adds    r2, r2, r2
    adcs    r4, r4, r4
    adds    r2, r2, r6
    adc     r4, r4, #0
    mov     r6, r5
    lsls    r5, r5, #3
    str     r4, [sp, #216]
    adds    r5, r5, r6
    mov     r4, #0
    adc     r4, r4, #0
    adds    r5, r5, r5
    str     r2, [sp, #212]
    adcs    r4, r4, r4
    ldr     r2, [r1, #16]@ unaligned
    str     r6, [sp, #16]
    adds    r5, r5, r6
    adc     ip, r4, #0
    ldr     r4, [r1, #20]@ unaligned
    str     r5, [sp, #120]
    lsrs    r5, r2, #25
    orr     r5, r5, r4, lsl#7
    bic     r5, r5, #-67108864
    mov     r6, r5
    bic     r5, r2, #-33554432
    ldr     r2, [r1, #24]@ unaligned
    str     r5, [sp, #24]
    lsrs    r4, r4, #19
    lsls    r5, r7, #3
    mov     r10, #0
    adds    r5, r5, r7
    orr     r4, r4, r2, lsl#13
    str     ip, [sp, #136]
    bic     ip, r4, #-33554432
    adc     r4, r10, r10
    adds    r5, r5, r5
    adcs    r4, r4, r4
    adds    r5, r5, r7
    str     r5, [sp, #140]
    lsl     r5, r6, #3
    str     ip, [sp, #92]
    adc     ip, r4, #0
    adds    r5, r5, r6
    adc     r4, r10, #0
    adds    r5, r5, r5
    adcs    r4, r4, r4
    adds    r5, r5, r6
    str     ip, [sp, #144]
    adc     ip, r4, #0
    ldr     r4, [r1, #28]@ unaligned
    str     r7, [sp, #88]
    lsrs    r2, r2, #12
    ubfx    r7, r4, #6, #25
    orr     r2, r2, r4, lsl#20
    ldr     r4, [sp, #92]
    str     r5, [sp, #96]
    lsls    r5, r4, #3
    str     ip, [sp, #100]
    adds    r5, r5, r4
    bic     ip, r2, #-67108864
    str     r6, [sp, #132]
    adc     r2, r10, #0
    mov     r6, ip
    adds    r5, r5, r5
    adcs    r2, r2, r2
    adds    fp, r5, r4
    lsl     r5, r6, #3
    adc     ip, r2, #0
    adds    r5, r5, r6
    adc     r2, r10, #0
    adds    r5, r5, r5
    adcs    r2, r2, r2
    adds    r5, r5, r6
    str     r5, [sp, #52]
    ldr     r5, [r0, #4]@ unaligned
    str     ip, [sp, #48]
    lsr     r3, r3, #26
    adc     ip, r2, #0
    orr     r3, r3, r5, lsl#6
    ldr     r2, [r0, #8]@ unaligned
    str     ip, [sp, #56]
    lsrs    r5, r5, #19
    bic     ip, r3, #-33554432
    lsls    r3, r7, #3
    adds    r3, r3, r7
    orr     r5, r5, r2, lsl#13
    mov     r4, ip
    bic     ip, r5, #-67108864
    adc     r5, r10, #0
    adds    r3, r3, r3
    str     r6, [sp, #204]
    adcs    r5, r5, r5
    adds    r6, r3, r7
    ldr     r1, [r1]@ unaligned
    str     ip, [sp, #28]
    adc     ip, r5, #0
    ldr     r5, [r0, #12]@ unaligned
    str     r6, [sp, #8]
    lsrs    r2, r2, #13
    orr     r2, r2, r5, lsl#19
    ldr     r6, [r0, #20]@ unaligned
    str     ip, [sp, #60]
    bic     ip, r2, #-33554432
    ldr     lr, [r0, #28]         @ unaligned
    ldr     r2, [r0, #16]         @ unaligned
    str     r7, [sp, #208]
    mov     r3, ip
    ldr     ip, [r0, #24]@ unaligned
    str     r3, [sp, #76]
    adds    r0, r4, r4
    str     r0, [sp, #84]
    lsr     r0, r6, #19
    adc     r10, r10, r10
    orr     r0, r0, ip, lsl#13
    str     r10, [sp, #104]
    bic     r10, r0, #-33554432
    lsr     r0, ip, #12
    ubfx    ip, lr, #6, #25
    str     ip, [sp, #36]
    orr     r0, r0, lr, lsl#20
    bic     ip, r2, #-33554432
    lsrs    r2, r2, #25
    str     r10, [sp, #32]
    orr     r2, r2, r6, lsl#7
    bic     r10, r0, #-67108864
    ldr     r6, [sp, #104]
    ldr     r0, [sp, #8]
    ldr     r7, [sp, #84]
    str     r4, [sp, #116]
    adds    r3, r3, r3
    mov     lr, #0
    mul     r6, r0, r6
    ldr     r0, [sp, #60]
    mov     r4, ip
    adc     ip, lr, lr
    mla     r0, r7, r0, r6
    mov     r6, ip
    bic     ip, r1, #-67108864
    lsrs    r1, r1, #26
    str     r0, [sp, #152]
    orr     r1, r1, r8, lsl#6
    ldr     r0, [sp, #32]
    str     r4, [sp, #72]
    str     ip, [sp, #12]
    adds    r4, r4, r4
    bic     ip, r1, #-33554432
    str     ip, [sp, #4]
    adc     ip, lr, lr
    adds    r7, r0, r0
    str     ip, [sp, #128]
    str     r4, [sp, #40]
    adc     ip, lr, lr
    ldr     r4, [sp, #48]
    str     r7, [sp, #64]
    str     ip, [sp, #112]
    ldr     r7, [sp, #36]
    mul     ip, fp, r6
    mla     ip, r3, r4, ip
    ldr     r4, [sp, #24]
    adds    r0, r7, r7
    mov     r1, #19
    str     r0, [sp, #68]
    adc     r0, lr, lr
    umull   r1, lr, r4, r1
    mov     r7, r1
    ldr     r1, [sp, #128]
    str     r7, [sp, #80]
    ldr     r4, [sp, #40]
    str     lr, [sp, #124]
    mul     r7, r7, r1
    mla     r1, r4, lr, r7
    str     r1, [sp, #156]
    ldr     r7, [sp, #112]
    ldr     r1, [sp, #120]
    str     r6, [sp, #148]
    mul     lr, r1, r7
    ldr     r7, [sp, #64]
    ldr     r1, [sp, #136]
    str     r3, [sp, #108]
    mla     lr, r7, r1, lr
    mov     r1, r6
    ldr     r6, [sp, #8]
    str     lr, [sp, #160]
    mul     lr, r6, r1
    ldr     r1, [sp, #60]
    ldr     r6, [sp, #80]
    mla     lr, r3, r1, lr
    ldr     r3, [sp, #128]
    str     lr, [sp, #164]
    mul     lr, fp, r3
    ldr     r3, [sp, #48]
    mla     lr, r4, r3, lr
    ldr     r3, [sp, #112]
    ldr     r4, [sp, #124]
    str     lr, [sp, #168]
    mul     lr, r6, r3
    ldr     r3, [sp, #120]
    mla     lr, r7, r4, lr
    str     lr, [sp, #172]
    ldr     r4, [sp, #68]
    mul     lr, r3, r0
    ldr     r3, [sp, #136]
    mla     lr, r4, r3, lr
    ldr     r3, [sp, #128]
    ldr     r4, [sp, #8]
    str     lr, [sp, #176]
    mul     lr, r4, r3
    ldr     r4, [sp, #40]
    ldr     r3, [sp, #48]
    mla     lr, r4, r1, lr
    ldr     r4, [sp, #112]
    str     lr, [sp, #180]
    mul     lr, fp, r4
    mla     lr, r7, r3, lr
    str     lr, [sp, #184]
    ldr     r3, [sp, #124]
    mul     lr, r6, r0
    ldr     r6, [sp, #68]
    ldr     r4, [sp, #112]
    mla     lr, r6, r3, lr
    ldr     r3, [sp, #8]
    str     lr, [sp, #188]
    mul     lr, r3, r4
    mla     lr, r7, r1, lr
    ldr     r3, [sp, #48]
    str     lr, [sp, #192]
    mul     lr, fp, r0
    mla     lr, r6, r3, lr
    ldr     r3, [sp, #8]
    str     lr, [sp, #196]
    mul     lr, r3, r0
    ldr     r7, [sp, #208]
    ldr     r3, [sp, #84]
    ldr     r4, [sp, #8]
    mla     lr, r6, r1, lr
    ldr     r1, [sp, #20]
    ldr     r6, [sp, #152]
    str     lr, [sp, #200]
    umull   lr, r8, r1, r7
    str     lr, [sp, #208]
    ldr     r7, [sp, #12]
    str     r8, [sp, #220]
    umull   r4, lr, r4, r3
    add     r6, r6, lr
    umlal   r4, r6, r1, r7
    ldr     r1, [sp, #28]
    ldr     r7, [sp, #52]
    ldr     r3, [sp, #108]
    umull   r8, lr, r1, r7
    ldr     r7, [sp, #56]
    adds    r4, r4, r8
    mla     lr, r1, r7, lr
    adc     lr, lr, r6
    umull   r6, r8, fp, r3
    adds    r4, r4, r6
    ldr     r6, [sp, #96]
    ldr     r3, [sp, #100]
    ldr     r7, [sp, #80]
    lsr     r5, r5, #6
    add     ip, ip, r8
    adc     lr, ip, lr
    umull   r6, ip, r5, r6
    adds    r6, r4, r6
    ldr     r4, [sp, #40]
    mla     ip, r5, r3, ip
    adc     ip, ip, lr
    umull   r4, lr, r7, r4
    ldr     r7, [sp, #156]
    adds    r4, r6, r4
    ldr     r6, [sp, #140]
    bic     r2, r2, #-67108864
    add     r7, r7, lr
    adc     r7, r7, ip
    umull   r6, ip, r2, r6
    adds    r3, r4, r6
    ldr     r6, [sp, #144]
    ldr     r4, [sp, #68]
    str     r3, [sp, #28]
    mla     ip, r2, r6, ip
    ldr     r6, [sp, #4]
    adc     ip, ip, r7
    umull   lr, r7, r6, r4
    mla     r7, r6, r0, r7
    lsl     r0, lr, #3
    str     r0, [sp, #152]
    ldr     r3, [sp, #120]
    ldr     r4, [sp, #64]
    umull   r0, r8, r3, r4
    ldr     r3, [sp, #28]
    str     r1, [sp, #28]
    adds    r4, r3, r0
    ldr     r3, [sp, #160]
    add     r8, r8, r3
    ldr     r3, [sp, #212]
    adc     ip, r8, ip
    mov     r0, ip
    umull   ip, r8, r10, r3
    adds    ip, r4, ip
    ldr     r4, [sp, #216]
    mla     r8, r10, r4, r8
    adc     r8, r8, r0
    ldr     r0, [sp, #152]
    lsls    r6, r7, #3
    adds    r0, r0, lr
    orr     r6, r6, lr, lsr#29
    adc     r6, r7, r6
    adds    r0, r0, r0
    adcs    r6, r6, r6
    adds    r0, r0, lr
    adc     r7, r7, r6
    adds    ip, ip, r0
    ldr     r0, [sp, #36]
    str     ip, [sp, #152]
    adc     ip, r8, r7
    str     ip, [sp, #156]
    umull   ip, r7, r0, r3
    mla     r7, r0, r4, r7
    ldr     r3, [sp, #116]
    ldr     r0, [sp, #20]
    ldr     r6, [sp, #4]
    ldr     r4, [sp, #12]
    umull   r0, r6, r0, r6
    umull   lr, r4, r3, r4
    ldr     r3, [sp, #8]
    adds    r0, r0, lr
    adc     r6, r6, r4
    umull   lr, r4, r1, r3
    adds    r8, r0, lr
    ldr     r0, [sp, #60]
    ldr     r3, [sp, #76]
    mla     r4, r1, r0, r4
    adc     r4, r4, r6
    ldr     r6, [sp, #52]
    ldr     r1, [sp, #56]
    umull   r6, lr, r3, r6
    adds    r0, r8, r6
    mla     lr, r3, r1, lr
    ldr     r3, [sp, #48]
    ldr     r1, [sp, #72]
    adc     lr, lr, r4
    umull   r4, r6, r5, fp
    mla     r6, r5, r3, r6
    ldr     r3, [sp, #96]
    adds    r4, r0, r4
    adc     r6, r6, lr
    umull   r0, lr, r1, r3
    ldr     r3, [sp, #100]
    adds    r0, r4, r0
    mla     r4, r1, r3, lr
    adc     r4, r4, r6
    ldr     r6, [sp, #80]
    ldr     r1, [sp, #32]
    ldr     r3, [sp, #144]
    umull   lr, r6, r2, r6
    adds    lr, r0, lr
    ldr     r0, [sp, #124]
    mla     r0, r2, r0, r6
    ldr     r6, [sp, #140]
    adc     r0, r0, r4
    umull   r4, r6, r1, r6
    mla     r6, r1, r3, r6
    ldr     r1, [sp, #120]
    ldr     r3, [sp, #136]
    adds    lr, lr, r4
    adc     r6, r6, r0
    umull   r0, r4, r10, r1
    adds    r0, lr, r0
    mla     r4, r10, r3, r4
    adc     r4, r4, r6
    adds    ip, r0, ip
    adc     r0, r7, r4
    str     ip, [sp, #120]
    str     r0, [sp, #136]
    ldr     r4, [sp, #68]
    ldr     r0, [sp, #176]
    ldr     r7, [sp, #20]
    ldr     r3, [sp, #104]
    umull   r6, r4, r1, r4
    add     r8, r4, r0
    ldr     r1, [sp, #84]
    ldr     r4, [sp, #4]
    ldr     r0, [sp, #44]
    umull   r0, ip, r7, r0
    umull   lr, r7, r4, r1
    mla     r7, r4, r3, r7
    ldr     r1, [sp, #28]
    ldr     r4, [sp, #12]
    ldr     r3, [sp, #108]
    adds    r0, r0, lr
    adc     r7, r7, ip
    umull   lr, ip, r1, r4
    ldr     r4, [sp, #8]
    adds    r0, r0, lr
    adc     r7, r7, ip
    umull   lr, ip, r4, r3
    ldr     r4, [sp, #164]
    ldr     r3, [sp, #96]
    adds    r0, r0, lr
    add     ip, ip, r4
    adc     ip, ip, r7
    ldr     r7, [sp, #52]
    ldr     r4, [sp, #56]
    umull   lr, r7, r5, r7
    mla     r7, r5, r4, r7
    ldr     r4, [sp, #40]
    adds    r0, r0, lr
    adc     r7, r7, ip
    umull   lr, ip, fp, r4
    ldr     r4, [sp, #168]
    adds    r0, r0, lr
    add     ip, ip, r4
    adc     ip, ip, r7
    umull   lr, r7, r2, r3
    ldr     r3, [sp, #100]
    ldr     r4, [sp, #64]
    mla     r7, r2, r3, r7
    ldr     r3, [sp, #80]
    adds    r0, r0, lr
    adc     r7, r7, ip
    umull   ip, lr, r3, r4
    ldr     r4, [sp, #172]
    ldr     r3, [sp, #144]
    add     lr, lr, r4
    ldr     r4, [sp, #140]
    adds    r0, r0, ip
    adc     lr, lr, r7
    umull   r7, ip, r10, r4
    adds    r7, r0, r7
    mla     ip, r10, r3, ip
    ldr     r0, [sp, #36]
    adc     ip, ip, lr
    adds    r6, r7, r6
    adc     ip, r8, ip
    str     ip, [sp, #144]
    umull   ip, r7, r0, r4
    mla     r7, r0, r3, r7
    ldrd    r4, r0, [sp, #16]
    ldr     r3, [sp, #116]
    str     r6, [sp, #140]
    ldr     r6, [sp, #44]
    umull   r0, r4, r0, r4
    umull   lr, r6, r3, r6
    adds    r0, r0, lr
    adc     r4, r4, r6
    mov     r6, r1
    ldr     r1, [sp, #4]
    ldr     r3, [sp, #76]
    umull   lr, r6, r6, r1
    ldr     r1, [sp, #12]
    adds    r0, r0, lr
    adc     r4, r4, r6
    umull   lr, r6, r3, r1
    ldr     r3, [sp, #8]
    ldr     r1, [sp, #60]
    adds    r0, r0, lr
    adc     r4, r4, r6
    umull   lr, r6, r5, r3
    mla     r6, r5, r1, r6
    ldr     r3, [sp, #72]
    ldr     r1, [sp, #52]
    adds    r0, r0, lr
    adc     r6, r6, r4
    umull   lr, r4, r3, r1
    ldr     r1, [sp, #56]
    adds    r8, r0, lr
    mla     r4, r3, r1, r4
    ldr     r3, [sp, #48]
    ldr     r1, [sp, #32]
    adc     r4, r4, r6
    umull   lr, r6, r2, fp
    mla     r0, r2, r3, r6
    ldr     r6, [sp, #96]
    ldr     r3, [sp, #100]
    adds    lr, r8, lr
    adc     r0, r0, r4
    umull   r4, r6, r1, r6
    mla     r6, r1, r3, r6
    ldr     r3, [sp, #80]
    ldr     r1, [sp, #124]
    adds    lr, lr, r4
    adc     r6, r6, r0
    umull   r0, r4, r10, r3
    adds    r0, lr, r0
    mla     r4, r10, r1, r4
    adc     r4, r4, r6
    adds    ip, r0, ip
    adc     r6, r7, r4
    ldr     r0, [sp, #68]
    str     r6, [sp, #124]
    ldr     r6, [sp, #188]
    ldr     r4, [sp, #16]
    ldr     r7, [sp, #88]
    str     ip, [sp, #80]
    umull   lr, r1, r3, r0
    add     r1, r1, r6
    ldr     r0, [sp, #20]
    ldr     r6, [sp, #84]
    ldr     r3, [sp, #104]
    umull   ip, r6, r4, r6
    umull   r0, r7, r7, r0
    adds    r0, r0, ip
    mla     r6, r4, r3, r6
    adc     r6, r6, r7
    ldr     r4, [sp, #44]
    ldr     r7, [sp, #28]
    ldr     r3, [sp, #108]
    umull   ip, r7, r7, r4
    ldr     r4, [sp, #4]
    adds    r0, r0, ip
    adc     r6, r6, r7
    umull   ip, r7, r4, r3
    ldr     r3, [sp, #148]
    adds    r0, r0, ip
    mla     r7, r4, r3, r7
    adc     r6, r7, r6
    ldr     r7, [sp, #12]
    ldr     r3, [sp, #8]
    ldr     r4, [sp, #180]
    umull   ip, r7, r5, r7
    adds    r0, r0, ip
    adc     r6, r6, r7
    ldr     r7, [sp, #40]
    umull   ip, r7, r3, r7
    adds    r0, r0, ip
    add     r7, r7, r4
    adc     r7, r7, r6
    ldr     r6, [sp, #52]
    ldr     r4, [sp, #56]
    umull   ip, r6, r2, r6
    mla     r6, r2, r4, r6
    ldr     r4, [sp, #64]
    ldr     r3, [sp, #96]
    adds    r0, r0, ip
    adc     r6, r6, r7
    umull   r7, ip, fp, r4
    adds    r0, r0, r7
    ldr     r7, [sp, #184]
    add     ip, ip, r7
    adc     ip, ip, r6
    umull   r6, r7, r10, r3
    adds    r6, r0, r6
    ldr     r0, [sp, #100]
    mla     r7, r10, r0, r7
    adc     r7, r7, ip
    adds    r6, r6, lr
    adc     r1, r1, r7
    str     r1, [sp, #100]
    ldr     r1, [sp, #36]
    str     r6, [sp, #96]
    umull   r8, r4, r1, r3
    ldr     r6, [sp, #88]
    ldr     r3, [sp, #76]
    mla     r4, r1, r0, r4
    ldr     r0, [sp, #116]
    umull   r1, r0, r6, r0
    ldrd    r6, r7, [sp, #20]
    umlal   r1, r0, r6, r7
    ldr     r6, [sp, #28]
    ldr     r7, [sp, #16]
    umull   ip, r7, r6, r7
    ldr     r6, [sp, #44]
    adds    r1, r1, ip
    adc     r0, r0, r7
    umull   ip, r7, r3, r6
    adds    r1, r1, ip
    adc     r0, r0, r7
    ldr     r7, [sp, #4]
    ldr     r6, [sp, #72]
    ldr     r3, [sp, #8]
    umull   r7, ip, r5, r7
    adds    r1, r1, r7
    ldr     r7, [sp, #12]
    adc     r0, r0, ip
    umlal   r1, r0, r6, r7
    ldr     r6, [sp, #60]
    umull   ip, r7, r2, r3
    mla     r7, r2, r6, r7
    adds    r1, r1, ip
    ldr     r6, [sp, #32]
    ldr     r3, [sp, #48]
    adc     lr, r7, r0
    ldr     r0, [sp, #52]
    umull   r7, ip, r6, r0
    ldr     r0, [sp, #56]
    adds    r1, r1, r7
    mla     ip, r6, r0, ip
    umull   r0, r7, r10, fp
    adc     ip, ip, lr
    mla     r7, r10, r3, r7
    adds    r0, r1, r0
    adc     r7, r7, ip
    adds    r1, r0, r8
    str     r1, [sp, #160]
    adc     r1, r4, r7
    str     r1, [sp, #164]
    ldr     r1, [sp, #68]
    ldr     r6, [sp, #196]
    ldr     r3, [sp, #8]
    umull   r0, fp, fp, r1
    add     fp, fp, r6
    ldr     r6, [sp, #200]
    umull   ip, r1, r3, r1
    str     ip, [sp, #172]
    add     lr, r6, r1
    ldr     r1, [sp, #20]
    ldr     r4, [sp, #132]
    ldr     r3, [sp, #84]
    umull   r1, r6, r1, r4
    ldr     r4, [sp, #24]
    umull   r7, r4, r4, r3
    adds    r1, r1, r7
    ldr     r3, [sp, #104]
    ldr     r7, [sp, #24]
    mla     r4, r7, r3, r4
    ldr     r7, [sp, #92]
    ldr     r3, [sp, #84]
    adc     r4, r4, r6
    umull   ip, r6, r7, r3
    ldr     r3, [sp, #104]
    str     ip, [sp, #168]
    mla     ip, r7, r3, r6
    ldr     r7, [sp, #88]
    ldr     r6, [sp, #28]
    ldr     r3, [sp, #108]
    str     ip, [sp, #48]
    umull   r7, r6, r7, r6
    adds    r1, r1, r7
    adc     r4, r4, r6
    ldr     r6, [sp, #16]
    umull   r7, r6, r6, r3
    adds    r1, r1, r7
    ldr     r3, [sp, #148]
    ldr     r7, [sp, #16]
    mla     r6, r7, r3, r6
    ldr     r7, [sp, #24]
    ldr     r3, [sp, #108]
    adc     r4, r6, r4
    umull   ip, r6, r7, r3
    ldr     r3, [sp, #148]
    str     ip, [sp, #104]
    mla     ip, r7, r3, r6
    ldr     r6, [sp, #44]
    ldr     r3, [sp, #128]
    str     ip, [sp, #68]
    umull   r7, r6, r5, r6
    adds    r1, r1, r7
    adc     r4, r4, r6
    ldr     r7, [sp, #40]
    ldr     r6, [sp, #4]
    umull   r7, r6, r6, r7
    adds    r1, r1, r7
    ldr     r7, [sp, #4]
    mla     r6, r7, r3, r6
    adc     r6, r6, r4
    ldr     r7, [sp, #40]
    ldr     r4, [sp, #16]
    umull   ip, r4, r4, r7
    ldr     r7, [sp, #16]
    str     ip, [sp, #108]
    mla     ip, r7, r3, r4
    ldr     r4, [sp, #12]
    str     ip, [sp, #40]
    umull   r7, r4, r2, r4
    adds    r1, r1, r7
    adc     r6, r6, r4
    ldr     r4, [sp, #64]
    ldr     r3, [sp, #8]
    umull   r7, r4, r3, r4
    ldr     r3, [sp, #192]
    adds    r1, r1, r7
    add     r4, r4, r3
    ldr     r3, [sp, #8]
    ldr     r7, [sp, #112]
    adc     r4, r4, r6
    ldr     r6, [sp, #60]
    umull   ip, r3, r10, r3
    str     ip, [sp, #84]
    mla     ip, r10, r6, r3
    ldr     r6, [sp, #4]
    ldr     r3, [sp, #64]
    str     ip, [sp, #8]
    umull   ip, r3, r6, r3
    str     ip, [sp, #64]
    mla     ip, r6, r7, r3
    ldr     r7, [sp, #52]
    str     ip, [sp, #60]
    umull   r3, r6, r10, r7
    adds    r3, r1, r3
    ldr     r1, [sp, #56]
    mla     r6, r10, r1, r6
    adc     r6, r6, r4
    adds    r3, r3, r0
    ldr     r0, [sp, #36]
    ldr     r4, [sp, #12]
    str     r3, [sp, #52]
    adc     ip, fp, r6
    str     ip, [sp, #56]
    umull   ip, r6, r0, r7
    ldr     r3, [sp, #20]
    ldr     r7, [sp, #92]
    str     ip, [sp, #36]
    mla     r6, r0, r1, r6
    umull   ip, r8, r0, r4
    ldr     r4, [sp, #116]
    ldr     r0, [sp, #204]
    str     r8, [sp, #192]
    str     ip, [sp, #188]
    umull   r1, ip, r3, r7
    umull   r3, fp, r3, r0
    umull   r8, r0, r4, r0
    str     r0, [sp, #112]
    mov     r0, r4
    ldr     r4, [sp, #132]
    str     r8, [sp, #92]
    umull   r0, r4, r0, r4
    adds    r1, r1, r0
    adc     ip, ip, r4
    ldr     r4, [sp, #28]
    umull   r8, r0, r4, r7
    str     r0, [sp, #128]
    ldr     r0, [sp, #24]
    str     r8, [sp, #116]
    mov     r7, r4
    umull   r4, r0, r4, r0
    adds    r1, r1, r4
    mov     r4, r7
    ldr     r7, [sp, #132]
    adc     ip, ip, r0
    ldr     r0, [sp, #76]
    umull   r4, r8, r4, r7
    str     r8, [sp, #28]
    umull   r8, r7, r0, r7
    str     r7, [sp, #148]
    ldr     r0, [sp, #88]
    ldr     r7, [sp, #76]
    str     r8, [sp, #132]
    umull   r0, r7, r0, r7
    adds    r1, r1, r0
    ldr     r0, [sp, #24]
    adc     r7, ip, r7
    umull   ip, r8, r5, r0
    ldr     r0, [sp, #16]
    str     ip, [sp, #76]
    umull   ip, r0, r5, r0
    adds    r1, r1, ip
    adc     r7, r7, r0
    ldr     r0, [sp, #88]
    str     r8, [sp, #176]
    umull   r8, r5, r5, r0
    str     r5, [sp, #24]
    mov     r5, r0
    ldr     r0, [sp, #72]
    umull   ip, r5, r5, r0
    str     r5, [sp, #88]
    ldr     r5, [sp, #44]
    str     ip, [sp, #72]
    umull   r5, ip, r0, r5
    adds    r1, r1, r5
    ldr     r5, [sp, #16]
    ldr     r0, [sp, #32]
    adc     r7, r7, ip
    umull   ip, r5, r2, r5
    str     r5, [sp, #184]
    ldr     r5, [sp, #4]
    str     ip, [sp, #180]
    umull   ip, r5, r2, r5
    adds    r1, r1, ip
    adc     r7, r7, r5
    ldr     r5, [sp, #44]
    umull   ip, r2, r2, r5
    str     ip, [sp, #16]
    umull   ip, r5, r0, r5
    str     r5, [sp, #44]
    ldr     r5, [sp, #12]
    str     ip, [sp, #32]
    umull   r5, ip, r0, r5
    adds    r1, r1, r5
    ldr     r5, [sp, #84]
    ldr     r0, [sp, #36]
    adc     ip, r7, ip
    adds    r1, r1, r5
    ldr     r5, [sp, #8]
    adc     r5, r5, ip
    adds    r1, r1, r0
    str     r1, [sp, #20]
    ldr     r1, [sp, #168]
    adc     r5, r6, r5
    adds    r3, r3, r1
    ldr     r1, [sp, #48]
    ldr     r6, [sp, #28]
    ldr     r0, [sp, #24]
    adc     r1, r1, fp
    adds    r3, r3, r4
    ldr     r4, [sp, #104]
    adc     r1, r1, r6
    adds    r3, r3, r4
    ldr     r4, [sp, #68]
    ldr     r6, [sp, #16]
    adc     r1, r4, r1
    ldr     r4, [sp, #108]
    adds    r3, r3, r8
    adc     r1, r1, r0
    adds    r3, r3, r4
    ldr     r4, [sp, #40]
    adc     r1, r4, r1
    adds    r3, r3, r6
    adc     r1, r1, r2
    ldr     r2, [sp, #64]
    ldr     r4, [sp, #12]
    ldr     r6, [sp, #4]
    adds    r3, r3, r2
    ldr     r2, [sp, #60]
    adc     r1, r2, r1
    umull   r2, r0, r10, r4
    ldr     r4, [sp, #172]
    adds    r3, r3, r2
    adc     r1, r1, r0
    ldr     r2, [sp, #92]
    adds    r0, r3, r4
    ldr     r3, [sp, #208]
    ldr     r4, [sp, #112]
    str     r0, [sp, #12]
    adc     lr, lr, r1
    adds    r3, r3, r2
    ldr     r2, [sp, #220]
    adc     r2, r2, r4
    ldr     r4, [sp, #116]
    adds    r3, r3, r4
    ldr     r4, [sp, #128]
    adc     r2, r2, r4
    ldr     r4, [sp, #132]
    adds    r3, r3, r4
    ldr     r4, [sp, #148]
    adc     r2, r2, r4
    ldr     r4, [sp, #76]
    adds    r3, r3, r4
    ldr     r4, [sp, #176]
    adc     r2, r2, r4
    ldr     r4, [sp, #72]
    adds    r3, r3, r4
    ldr     r4, [sp, #88]
    adc     r2, r2, r4
    ldr     r4, [sp, #180]
    adds    r3, r3, r4
    ldr     r4, [sp, #184]
    adc     r2, r2, r4
    ldr     r4, [sp, #32]
    adds    r3, r3, r4
    ldr     r4, [sp, #44]
    adc     r2, r2, r4
    umull   r1, r4, r10, r6
    adds    r1, r3, r1
    adc     r2, r2, r4
    ldr     r4, [sp, #188]
    ldr     r3, [sp, #192]
    adds    r4, r1, r4
    adc     r2, r2, r3
    str     r2, [sp, #24]
    ldr     r6, [sp, #152]
    ldr     r7, [sp, #156]
    ldr     r0, [sp, #120]
    adds    r1, r6, #33554432
    adc     r3, r7, #0
    lsrs    r2, r1, #26
    orr     r2, r2, r3, lsl#6
    adds    r2, r2, r0
    ldr     r0, [sp, #136]
    and     r1, r1, #-67108864
    adc     ip, r0, r3, asr#26
    subs    r8, r6, r1
    sbc     r10, r7, r3
    adds    r6, r2, #16777216
    adc     r7, ip, #0
    ldr     r1, [sp, #140]
    ldr     r0, [sp, #80]
    lsrs    r3, r6, #25
    orr     r3, r3, r7, lsl#7
    adds    r3, r3, r1
    ldr     r1, [sp, #144]
    and     r6, r6, #-33554432
    adc     r1, r1, r7, asr#25
    subs    r6, r2, r6
    sbc     r2, ip, r7
    str     r2, [sp, #28]
    adds    r2, r3, #33554432
    adc     r7, r1, #0
    lsr     ip, r2, #26
    orr     ip, ip, r7, lsl#6
    adds    ip, ip, r0
    ldr     r0, [sp, #124]
    str     ip, [sp, #4]
    adc     ip, r0, r7, asr#26
    str     ip, [sp, #8]
    ldr     r0, [sp, #4]
    and     r2, r2, #-67108864
    subs    ip, r3, r2
    ldr     r2, [sp, #8]
    str     ip, [sp, #32]
    sbc     ip, r1, r7
    adds    r3, r0, #16777216
    adc     fp, r2, #0
    ldr     r1, [sp, #96]
    ldr     r7, [sp, #100]
    str     ip, [sp, #36]
    lsrs    r2, r3, #25
    orr     r2, r2, fp, lsl#7
    adds    r1, r2, r1
    adc     ip, r7, fp, asr#25
    mov     r7, ip
    and     ip, r3, #-33554432
    adds    r3, r1, #33554432
    str     ip, [sp, #80]
    str     r7, [sp, #44]
    adc     ip, r7, #0
    lsrs    r2, r3, #26
    ldr     r7, [sp, #160]
    str     ip, [sp, #16]
    orr     r2, r2, ip, lsl#6
    adds    r2, r2, r7
    ldr     r7, [sp, #164]
    str     r2, [sp, #48]
    adc     ip, r7, ip, asr#26
    mov     r7, ip
    and     ip, r3, #-67108864
    adds    r3, r2, #16777216
    str     ip, [sp, #84]
    str     r7, [sp, #60]
    adc     ip, r7, #0
    lsrs    r2, r3, #25
    ldr     r7, [sp, #52]
    ldr     r0, [sp, #20]
    str     r1, [sp, #40]
    orr     r2, r2, ip, lsl#7
    adds    r2, r2, r7
    ldr     r7, [sp, #56]
    str     r2, [sp, #52]
    and     r3, r3, #-33554432
    adc     r7, r7, ip, asr#25
    str     r3, [sp, #88]
    adds    r3, r2, #33554432
    str     r7, [sp, #56]
    lsr     r2, r3, #26
    adc     r7, r7, #0
    orr     r2, r2, r7, lsl#6
    adds    r2, r2, r0
    and     r3, r3, #-67108864
    str     r3, [sp, #92]
    adc     r5, r5, r7, asr#26
    adds    r3, r2, #16777216
    ldr     r0, [sp, #12]
    str     r2, [sp, #20]
    lsr     r1, r3, #25
    adc     r2, r5, #0
    orr     r1, r1, r2, lsl#7
    str     r5, [sp, #64]
    adds    r5, r1, r0
    adc     lr, lr, r2, asr#25
    mov     r0, lr
    adds    r1, r5, #33554432
    and     lr, r3, #-33554432
    str     r0, [sp, #72]
    adc     r3, r0, #0
    lsrs    r0, r1, #26
    str     r5, [sp, #68]
    orr     r0, r0, r3, lsl#6
    ldr     r5, [sp, #24]
    str     lr, [sp, #96]
    adds    r4, r0, r4
    adc     lr, r5, r3, asr#26
    mov     r5, lr
    and     lr, r1, #-67108864
    adds    r1, r4, #16777216
    str     lr, [sp, #100]
    str     r4, [sp, #24]
    adc     lr, r5, #0
    str     r5, [sp, #76]
    and     r4, r1, #-33554432
    lsrs    r5, r1, #25
    orr     r5, r5, lr, lsl#7
    str     r4, [sp, #104]
    asr     r4, lr, #25
    lsls    r0, r4, #3
    lsls    r1, r5, #3
    adds    r1, r1, r5
    orr     r0, r0, r5, lsr#29
    adc     r0, r4, r0
    adds    r1, r1, r1
    adcs    r0, r0, r0
    adds    r1, r1, r5
    adc     r4, r4, r0
    adds    r1, r1, r8
    adc     r4, r10, r4
    adds    r8, r1, #33554432
    adc     r10, r4, #0
    lsr     r0, r8, #26
    orr     r0, r0, r10, lsl#6
    adds    r0, r0, r6
    ldr     r6, [sp, #28]
    str     r0, [sp, #12]
    and     r8, r8, #-67108864
    adc     r6, r6, r10, asr#26
    mov     r5, r8
    adds    r0, r0, #16777216
    adc     r8, r6, #0
    subs    r1, r1, r5
    sbc     r4, r4, r10
    strd    r1, r4, [r9]
    mov     r4, r0
    and     r1, r0, #-33554432
    ldr     r0, [sp, #12]
    subs    r0, r0, r1
    sbc     r6, r6, r8
    str     r6, [sp, #12]
    lsrs    r5, r4, #25
    ldr     r6, [sp, #32]
    str     r0, [r9, #8]
    orr     r5, r5, r8, lsl#7
    adds    r5, r5, r6
    ldr     r6, [sp, #36]
    ldr     r0, [sp, #4]
    ldr     r1, [sp, #16]
    adc     r8, r6, r8, asr#25
    ldr     r6, [sp, #80]
    str     r8, [r9, #20]
    subs    r8, r0, r6
    ldr     r0, [sp, #8]
    ldr     r6, [sp, #84]
    str     r8, [sp, #4]
    sbc     fp, r0, fp
    ldr     r0, [sp, #40]
    subs    r8, r0, r6
    ldr     r0, [sp, #44]
    str     r8, [sp, #8]
    sbc     r10, r0, r1
    ldr     r0, [sp, #88]
    ldr     r1, [sp, #48]
    subs    r4, r1, r0
    ldr     r1, [sp, #60]
    ldr     r0, [sp, #92]
    ldr     r6, [sp, #96]
    sbc     ip, r1, ip
    ldr     r1, [sp, #52]
    subs    r0, r1, r0
    ldr     r1, [sp, #56]
    sbc     r7, r1, r7
    ldr     r1, [sp, #20]
    subs    r1, r1, r6
    ldr     r6, [sp, #64]
    str     r1, [r9, #56]
    sbc     r2, r6, r2
    str     r2, [sp, #16]
    ldr     r6, [sp, #68]
    ldr     r2, [sp, #100]
    subs    r8, r6, r2
    ldr     r6, [sp, #72]
    ldr     r2, [sp, #104]
    str     r8, [sp, #20]
    sbc     r8, r6, r3
    ldr     r3, [sp, #24]
    ldr     r6, [sp, #76]
    subs    r3, r3, r2
    ldr     r2, [sp, #4]
    sbc     lr, r6, lr
    ldr     r6, [sp, #12]
    strd    r2, fp, [r9, #24]
    ldr     r2, [sp, #16]
    str     r2, [r9, #60]
    strd    r6, r5, [r9, #12]
    ldr     r2, [sp, #20]
    ldr     r6, [sp, #8]
    strd    r4, ip, [r9, #40]
    strd    r6, r10, [r9, #32]
    strd    r0, r7, [r9, #48]
    strd    r2, r8, [r9, #64]
    strd    r3, lr, [r9, #72]
    add     sp, sp, #228
    pop     {r4, r5, r6, r7, r8, r9, r10, fp, pc}
