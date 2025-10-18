fe25519_mul_core_s:
    push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
    mov     fp, r2
    ldrb    r6, [r0]            @ zero_extendqisi2
    ldrb    r2, [r0, #1]        @ zero_extendqisi2
    orr     r6, r6, r2, lsl#8
    ldrb    r2, [r0, #2]@ zero_extendqisi2
    orr     r6, r6, r2, lsl#16
    ldrb    r2, [r0, #3]        @ zero_extendqisi2
    ldrb    r5, [r0, #4]        @ zero_extendqisi2
    orr     r6, r6, r2, lsl#24
    ldrb    r2, [r0, #5]@ zero_extendqisi2
    orr     r5, r5, r2, lsl#8
    ldrb    r2, [r0, #6]@ zero_extendqisi2
    orr     r5, r5, r2, lsl#16
    ldrb    r2, [r0, #7]        @ zero_extendqisi2
    ldrb    r8, [r0, #8]        @ zero_extendqisi2
    orr     r5, r5, r2, lsl#24
    ldrb    r2, [r0, #9]@ zero_extendqisi2
    orr     r8, r8, r2, lsl#8
    ldrb    r2, [r0, #10]       @ zero_extendqisi2
    ldrb    lr, [r0, #13]       @ zero_extendqisi2
    orr     r8, r8, r2, lsl#16
    ldrb    r2, [r0, #12]       @ zero_extendqisi2
    ldrb    ip, [r0, #11]       @ zero_extendqisi2
    orr     r2, r2, lr, lsl#8
    ldrb    lr, [r0, #14]@ zero_extendqisi2
    orr     ip, r8, ip, lsl#24
    orr     r2, r2, lr, lsl#16
    lsr     ip, ip, #13
    orr     ip, ip, r2, lsl#19
    sub     sp, sp, #292
    bic     ip, ip, #-33554432
    str     ip, [sp, #56]
    ldrb    ip, [r0, #15]@ zero_extendqisi2
    orr     r2, r2, ip, lsl#24
    lsr     r2, r2, #6
    str     r2, [sp]
    ldrb    lr, [r0, #16]       @ zero_extendqisi2
    ldrb    r2, [r0, #17]       @ zero_extendqisi2
    orr     lr, lr, r2, lsl#8
    ldrb    r2, [r0, #18]@ zero_extendqisi2
    orr     lr, lr, r2, lsl#16
    ldrb    r2, [r0, #19]       @ zero_extendqisi2
    ldrb    r4, [r0, #20]       @ zero_extendqisi2
    orr     lr, lr, r2, lsl#24
    ldrb    r2, [r0, #21]@ zero_extendqisi2
    mov     r3, #0
    orr     r4, r4, r2, lsl#8
    ldrb    r2, [r0, #22]@ zero_extendqisi2
    orr     r4, r4, r2, lsl#16
    ldrb    r2, [r0, #23]       @ zero_extendqisi2
    ldrb    r7, [r0, #24]       @ zero_extendqisi2
    orr     r4, r4, r2, lsl#24
    ldrb    r2, [r0, #25]@ zero_extendqisi2
    orr     r7, r7, r2, lsl#8
    ldrb    r2, [r0, #26]@ zero_extendqisi2
    orr     r7, r7, r2, lsl#16
    str     r4, [sp, #8]
    ldrb    ip, [r0, #27]@ zero_extendqisi2
    str     r7, [sp, #16]
    ldrb    r9, [r0, #29]       @ zero_extendqisi2
    ldrb    r2, [r0, #28]       @ zero_extendqisi2
    orr     r2, r2, r9, lsl#8
    ldrb    r9, [r0, #30]@ zero_extendqisi2
    orr     ip, r7, ip, lsl#24
    ldrb    r0, [r0, #31]@ zero_extendqisi2
    orr     r2, r2, r9, lsl#16
    lsr     ip, ip, #12
    orr     ip, ip, r2, lsl#20
    orr     r2, r2, r0, lsl#24
    lsr     r2, r2, #6
    bic     r0, r2, #-33554432
    str     r0, [sp, #20]
    ldrb    r2, [r1, #4]        @ zero_extendqisi2
    ldrb    r0, [r1, #5]        @ zero_extendqisi2
    orr     r2, r2, r0, lsl#8
    ldrb    r0, [r1, #6]        @ zero_extendqisi2
    ldrb    r9, [r1]            @ zero_extendqisi2
    orr     r2, r2, r0, lsl#16
    ldrb    r0, [r1, #7]@ zero_extendqisi2
    str     r9, [sp, #28]
    orr     r9, r2, r0, lsl#24
    ldrb    r2, [r1, #9]        @ zero_extendqisi2
    ldrb    r0, [r1, #8]        @ zero_extendqisi2
    orr     r0, r0, r2, lsl#8
    ldrb    r2, [r1, #10]@ zero_extendqisi2
    orr     r0, r0, r2, lsl#16
    lsr     r2, r9, #19
    orr     r2, r2, r0, lsl#13
    bic     r7, ip, #-67108864
    bic     ip, r2, #-67108864
    lsl     r2, ip, #3
    adds    r2, r2, ip
    str     r9, [sp, #52]
    mov     r4, ip
    movcc   r9, r3
    movcs   r9, #1
    ldrb    ip, [r1, #11]       @ zero_extendqisi2
    ldrb    r10, [r1, #13]      @ zero_extendqisi2
    orr     r0, r0, ip, lsl#24
    ldrb    ip, [r1, #12]@ zero_extendqisi2
    orr     ip, ip, r10, lsl#8
    ldrb    r10, [r1, #14]@ zero_extendqisi2
    lsr     r0, r0, #13
    orr     ip, ip, r10, lsl#16
    orr     r0, r0, ip, lsl#19
    bic     r0, r0, #-33554432
    adds    r2, r2, r2
    adc     r9, r9, r9
    adds    r10, r2, r4
    lsl     r2, r0, #3
    adc     r9, r9, #0
    adds    r2, r2, r0
    str     r4, [sp, #60]
    mov     r4, r0
    movcc   r0, r3
    movcs   r0, #1
    str     r10, [sp, #172]
    str     r9, [sp, #176]
    ldrb    r10, [r1, #17]      @ zero_extendqisi2
    ldrb    r9, [r1, #16]       @ zero_extendqisi2
    orr     r9, r9, r10, lsl#8
    ldrb    r10, [r1, #15]@ zero_extendqisi2
    orr     ip, ip, r10, lsl#24
    lsr     r10, ip, #6
    ldrb    ip, [r1, #18]@ zero_extendqisi2
    adds    r2, r2, r2
    orr     ip, r9, ip, lsl#16
    adc     r0, r0, r0
    adds    r9, r2, r4
    adc     r0, r0, #0
    str     r0, [sp, #128]
    ldrb    r2, [r1, #20]       @ zero_extendqisi2
    ldrb    r0, [r1, #21]       @ zero_extendqisi2
    orr     r2, r2, r0, lsl#8
    ldrb    r0, [r1, #19]@ zero_extendqisi2
    str     r4, [sp, #24]
    orr     ip, ip, r0, lsl#24
    str     r9, [sp, #80]
    ldrb    r0, [r1, #22]@ zero_extendqisi2
    orr     r0, r2, r0, lsl#16
    ldrb    r2, [r1, #23]@ zero_extendqisi2
    orr     r0, r0, r2, lsl#24
    lsr     r2, ip, #25
    orr     r2, r2, r0, lsl#7
    bic     r9, r2, #-67108864
    mov     r4, r9
    lsl     r2, r10, #3
    adds    r2, r2, r10
    bic     r9, ip, #-33554432
    adc     ip, r3, r3
    adds    r2, r2, r2
    adc     ip, ip, ip
    adds    r2, r2, r10
    str     r2, [sp, #132]
    lsl     r2, r4, #3
    adc     ip, ip, #0
    adds    r2, r2, r4
    str     r9, [sp, #76]
    str     r10, [sp, #100]
    mov     r9, r4
    ldrb    r10, [r1, #25]@ zero_extendqisi2
    movcc   r9, r3
    str     ip, [sp, #136]
    movcs   r9, #1
    ldrb    ip, [r1, #24]@ zero_extendqisi2
    orr     ip, ip, r10, lsl#8
    ldrb    r10, [r1, #26]@ zero_extendqisi2
    lsr     r0, r0, #19
    orr     ip, ip, r10, lsl#16
    orr     r0, r0, ip, lsl#13
    bic     r0, r0, #-33554432
    str     r4, [sp, #124]
    mov     r4, r0
    ldrb    r10, [r1, #27]@ zero_extendqisi2
    orr     ip, ip, r10, lsl#24
    ldr     r10, [sp, #124]
    adds    r2, r2, r2
    adc     r9, r9, r9
    adds    r2, r2, r10
    adc     r10, r9, #0
    str     r2, [sp, #88]
    str     r10, [sp, #92]
    ldrb    r2, [r1, #28]       @ zero_extendqisi2
    ldrb    r10, [r1, #29]      @ zero_extendqisi2
    orr     r2, r2, r10, lsl#8
    ldrb    r10, [r1, #30]@ zero_extendqisi2
    lsl     r0, r0, #3
    orr     r2, r2, r10, lsl#16
    lsr     ip, ip, #12
    adds    r0, r0, r4
    orr     ip, ip, r2, lsl#20
    movcc   r9, r3
    movcs   r9, #1
    bic     ip, ip, #-67108864
    str     r4, [sp, #108]
    mov     r4, ip
    ldrb    r10, [r1, #31]@ zero_extendqisi2
    orr     r2, r2, r10, lsl#24
    ldr     r10, [sp, #108]
    adds    r0, r0, r0
    adc     r9, r9, r9
    lsl     ip, ip, #3
    adds    r10, r0, r10
    adc     r0, r9, #0
    str     r4, [sp, #152]
    adds    ip, ip, r4
    mov     r4, #19
    movcc   r9, r3
    movcs   r9, #1
    str     r10, [sp, #40]
    lsr     r10, r6, #26
    orr     r10, r10, r5, lsl#6
    lsr     r5, r5, #19
    orr     r5, r5, r8, lsl#13
    bic     r8, r6, #-67108864
    ldr     r6, [sp, #76]
    bic     r5, r5, #-67108864
    str     r5, [sp, #4]
    str     r8, [sp, #12]
    umull   r8, r5, r6, r4
    lsr     r2, r2, #6
    ldr     r6, [sp, #28]
    str     r5, [sp, #84]
    str     r8, [sp, #36]
    ldrb    r5, [r1, #1]@ zero_extendqisi2
    ldr     r8, [sp, #152]
    bic     r2, r2, #-33554432
    adds    ip, ip, ip
    str     r0, [sp, #64]
    orr     r5, r6, r5, lsl#8
    adc     r9, r9, r9
    lsl     r0, r2, #3
    adds    r6, ip, r8
    adc     ip, r9, #0
    adds    r0, r0, r2
    str     r6, [sp, #44]
    str     ip, [sp, #48]
    movcc   ip, r3
    movcs   ip, #1
    ldr     r4, [sp, #8]
    bic     r9, lr, #-33554432
    lsr     lr, lr, #25
    adds    r0, r0, r0
    orr     lr, lr, r4, lsl#7
    str     r9, [sp, #32]
    adc     ip, ip, ip
    bic     r9, lr, #-67108864
    adds    lr, r0, r2
    mov     r0, lr
    ldr     r8, [sp, #16]
    lsr     r4, r4, #19
    orr     r4, r4, r8, lsl#13
    bic     r4, r4, #-33554432
    str     r4, [sp, #16]
    adc     r4, ip, #0
    mov     ip, r4
    ldrb    r6, [r1, #2]@ zero_extendqisi2
    bic     r10, r10, #-33554432
    ldrb    r1, [r1, #3]@ zero_extendqisi2
    adds    r8, r10, r10
    orr     r6, r5, r6, lsl#16
    orr     r1, r6, r1, lsl#24
    adc     r6, r3, r3
    mul     r0, r6, r0
    mla     ip, r8, ip, r0
    ldr     r5, [sp, #56]
    str     r10, [sp, #104]
    ldr     r10, [sp, #40]
    mov     r0, ip
    adds    ip, r5, r5
    str     r8, [sp, #116]
    mov     r8, ip
    mov     ip, r10
    str     r6, [sp, #140]
    ldr     r6, [sp, #64]
    adc     r5, r3, r3
    mul     ip, r5, ip
    str     r5, [sp, #144]
    mov     r5, r6
    mla     r5, r8, r5, ip
    str     r5, [sp, #156]
    ldr     r5, [sp, #32]
    adds    ip, r5, r5
    str     r8, [sp, #96]
    adc     r8, r3, r3
    mov     r5, ip
    mov     ip, r8
    ldr     r8, [sp, #36]
    mul     r8, ip, r8
    str     ip, [sp, #148]
    mov     ip, r8
    ldr     r8, [sp, #84]
    mla     r8, r5, r8, ip
    ldr     ip, [sp, #16]
    adds    ip, ip, ip
    str     ip, [sp, #28]
    lsr     ip, r1, #26
    bic     r1, r1, #-67108864
    str     r1, [sp, #8]
    adc     r1, r3, r3
    str     r5, [sp, #72]
    mov     r5, r1
    ldr     r1, [sp, #80]
    mul     r1, r5, r1
    str     r8, [sp, #160]
    ldr     r8, [sp, #52]
    orr     ip, ip, r8, lsl#6
    bic     r8, ip, #-33554432
    str     r5, [sp, #120]
    ldr     ip, [sp, #28]
    ldr     r5, [sp, #128]
    mla     r5, ip, r5, r1
    ldr     r1, [sp, #20]
    str     r5, [sp, #168]
    adds    r5, r1, r1
    mov     r1, lr
    mov     ip, r4
    str     r5, [sp, #52]
    ldr     r5, [sp, #144]
    mul     r1, r5, r1
    ldr     r5, [sp, #96]
    mla     ip, r5, ip, r1
    mov     r1, r10
    str     ip, [sp, #196]
    ldr     ip, [sp, #148]
    mul     r1, ip, r1
    mov     ip, r6
    ldr     r5, [sp, #72]
    mla     ip, r5, ip, r1
    ldr     r1, [sp, #36]
    str     ip, [sp, #200]
    ldr     ip, [sp, #120]
    mul     r1, ip, r1
    ldr     r5, [sp, #28]
    ldr     ip, [sp, #84]
    mla     ip, r5, ip, r1
    ldr     r1, [sp, #80]
    adc     r3, r3, r3
    mul     r1, r3, r1
    ldr     r5, [sp, #52]
    str     ip, [sp, #204]
    ldr     ip, [sp, #128]
    mla     ip, r5, ip, r1
    mov     r1, lr
    str     ip, [sp, #208]
    ldr     ip, [sp, #148]
    mul     r1, ip, r1
    ldr     r5, [sp, #72]
    mov     ip, r4
    mla     r4, r5, r4, r1
    mov     r1, r10
    str     r4, [sp, #212]
    mov     r4, r10
    ldr     r10, [sp, #120]
    mul     r1, r10, r1
    mov     r10, r6
    ldr     r5, [sp, #28]
    mla     r10, r5, r10, r1
    ldr     r1, [sp, #36]
    mul     r1, r3, r1
    ldr     r5, [sp, #52]
    ldr     r6, [sp, #84]
    mla     r6, r5, r6, r1
    mov     r1, lr
    str     r10, [sp, #216]
    mov     r10, ip
    str     r6, [sp, #220]
    ldr     r6, [sp, #120]
    mul     r1, r6, r1
    ldr     r5, [sp, #28]
    mla     r10, r5, r10, r1
    mov     r1, r4
    mul     r1, r3, r1
    ldr     r5, [sp, #52]
    str     r10, [sp, #224]
    ldr     r10, [sp, #64]
    mla     r10, r5, r10, r1
    mov     r1, lr
    mov     r6, ip
    mul     r1, r3, r1
    mla     r6, r5, r6, r1
    str     r10, [sp, #228]
    str     ip, [sp, #112]
    str     r6, [sp, #232]
    ldr     ip, [sp, #12]
    umull   r4, r1, ip, r2
    str     r4, [sp, #280]
    mov     r4, lr
    str     lr, [sp, #68]
    ldr     lr, [sp, #116]
    str     r1, [sp, #284]
    umull   r1, r2, r4, lr
    add     r0, r0, r2
    mov     r2, r1
    mov     r1, r0
    ldr     r0, [sp, #8]
    umlal   r2, r1, ip, r0
    ldr     r10, [sp, #4]
    ldr     r6, [sp, #44]
    mov     r0, r1
    mov     r1, r2
    umull   ip, r2, r10, r6
    ldr     lr, [sp, #48]
    mla     lr, r10, lr, r2
    adds    r1, r1, ip
    ldr     r2, [sp]
    adc     r0, lr, r0
    ldr     lr, [sp, #88]
    str     r0, [sp, #236]
    umull   r0, r10, r2, lr
    str     r0, [sp, #240]
    ldr     r0, [sp, #92]
    mla     r0, r2, r0, r10
    ldr     lr, [sp, #132]
    mov     r10, r0
    umull   r0, r2, r9, lr
    ldr     lr, [sp, #136]
    mla     lr, r9, lr, r2
    str     lr, [sp, #164]
    umull   r6, lr, r8, r5
    ldr     r5, [sp, #172]
    str     r0, [sp, #244]
    umull   r0, r2, r7, r5
    str     r0, [sp, #248]
    ldr     r0, [sp, #176]
    mla     lr, r8, r3, lr
    mov     r3, r0
    mla     r3, r7, r3, r2
    str     r3, [sp, #172]
    ldr     r3, [sp, #20]
    umull   r4, r2, r3, r5
    mla     r0, r3, r0, r2
    str     r4, [sp, #276]
    str     r0, [sp, #192]
    ldr     r4, [sp, #68]
    ldr     r0, [sp, #4]
    umull   r3, r2, r0, r4
    ldr     r4, [sp, #112]
    mla     r4, r0, r4, r2
    ldr     r5, [sp, #44]
    str     r3, [sp, #252]
    ldr     r3, [sp, #56]
    str     r4, [sp, #176]
    umull   r4, r2, r3, r5
    str     r4, [sp, #256]
    ldr     r4, [sp, #48]
    mla     r4, r3, r4, r2
    ldr     r0, [sp]
    str     r4, [sp, #180]
    ldr     r4, [sp, #40]
    umull   r5, r2, r0, r4
    ldr     r3, [sp, #64]
    mla     r3, r0, r3, r2
    str     r5, [sp, #260]
    ldr     r0, [sp, #88]
    ldr     r5, [sp, #32]
    str     r3, [sp, #184]
    umull   r3, r2, r5, r0
    str     r3, [sp, #264]
    mov     r3, r4
    ldr     r0, [sp, #92]
    mla     r0, r5, r0, r2
    str     r0, [sp, #188]
    ldr     r0, [sp, #96]
    umull   r2, r4, r3, r0
    adds    r2, r1, r2
    ldr     r1, [sp, #156]
    ldr     r0, [sp, #236]
    add     r1, r1, r4
    ldr     r4, [sp, #240]
    adc     r1, r1, r0
    adds    r2, r2, r4
    adc     r10, r10, r1
    ldr     r1, [sp, #36]
    str     r2, [sp, #156]
    umull   r2, r5, r9, r1
    ldr     r0, [sp, #84]
    mla     r0, r9, r0, r5
    str     r2, [sp, #268]
    mov     r5, r0
    ldr     r2, [sp, #132]
    ldr     r0, [sp, #16]
    umull   r3, r4, r0, r2
    str     r3, [sp, #272]
    ldr     r3, [sp, #136]
    mla     r3, r0, r3, r4
    mov     r4, r3
    mov     r3, r1
    ldr     r2, [sp, #72]
    umull   r1, r0, r3, r2
    ldr     r2, [sp, #156]
    adds    r1, r2, r1
    ldr     r2, [sp, #160]
    add     r0, r2, r0
    ldr     r2, [sp, #244]
    adc     r0, r0, r10
    adds    r1, r1, r2
    ldr     r2, [sp, #164]
    adc     r0, r2, r0
    ldr     r2, [sp, #80]
    str     r1, [sp, #156]
    umull   r1, r10, r7, r2
    str     r1, [sp, #164]
    ldr     r1, [sp, #128]
    mla     r1, r7, r1, r10
    str     r1, [sp, #128]
    mov     r1, r2
    ldr     r3, [sp, #28]
    umull   r2, r10, r1, r3
    ldr     r1, [sp, #156]
    adds    r2, r1, r2
    ldr     r1, [sp, #168]
    add     r1, r1, r10
    adc     r1, r1, r0
    ldr     r0, [sp, #248]
    ldr     r3, [sp, #172]
    adds    r2, r2, r0
    adc     r1, r3, r1
    lsl     ip, lr, #3
    lsl     r3, r6, #3
    adds    r3, r3, r6
    orr     ip, ip, r6, lsr#29
    adc     ip, lr, ip
    adds    r3, r3, r3
    adc     ip, ip, ip
    adds    r3, r3, r6
    adc     lr, lr, ip
    adds    r2, r2, r3
    str     r2, [sp, #236]
    adc     r2, r1, lr
    str     r2, [sp, #240]
    ldr     r1, [sp, #80]
    ldr     r2, [sp, #52]
    umull   ip, r3, r1, r2
    ldr     r1, [sp, #208]
    add     r1, r1, r3
    str     r1, [sp, #160]
    ldr     r1, [sp, #116]
    str     ip, [sp, #248]
    umull   r2, ip, r8, r1
    str     r2, [sp, #172]
    ldr     r2, [sp, #140]
    mla     r2, r8, r2, ip
    ldr     r1, [sp, #44]
    str     r2, [sp, #80]
    ldr     r2, [sp]
    umull   ip, r0, r2, r1
    ldr     r3, [sp, #48]
    mla     r3, r2, r3, r0
    ldr     r2, [sp, #88]
    umull   r6, r1, r9, r2
    ldr     r2, [sp, #92]
    mla     r2, r9, r2, r1
    str     ip, [sp, #208]
    ldr     r1, [sp, #8]
    ldr     ip, [sp, #104]
    str     r2, [sp, #156]
    ldr     r2, [sp, #12]
    mov     r0, r3
    str     r6, [sp, #244]
    umull   r3, r6, r2, r8
    umull   lr, r2, ip, r1
    ldr     r1, [sp, #252]
    adds    r3, r3, lr
    ldr     lr, [sp, #176]
    adc     r2, r6, r2
    adds    r3, r3, r1
    adc     r2, lr, r2
    ldr     lr, [sp, #256]
    adds    r3, r3, lr
    ldr     lr, [sp, #180]
    adc     r2, lr, r2
    ldr     lr, [sp, #260]
    adds    r3, r3, lr
    ldr     lr, [sp, #184]
    adc     r2, lr, r2
    ldr     lr, [sp, #264]
    adds    r3, r3, lr
    ldr     lr, [sp, #188]
    adc     r2, lr, r2
    ldr     lr, [sp, #268]
    adds    r3, r3, lr
    ldr     lr, [sp, #272]
    adc     r2, r5, r2
    adds    r3, r3, lr
    ldr     lr, [sp, #164]
    ldr     ip, [sp, #128]
    adc     r2, r4, r2
    adds    r3, r3, lr
    ldr     lr, [sp, #276]
    adc     r10, ip, r2
    adds    lr, r3, lr
    str     lr, [sp, #176]
    ldr     lr, [sp, #192]
    ldr     r5, [sp, #136]
    adc     lr, lr, r10
    str     lr, [sp, #180]
    mov     lr, r5
    ldr     r1, [sp, #132]
    umull   r10, r2, r7, r1
    mla     lr, r7, lr, r2
    str     lr, [sp, #128]
    ldr     lr, [sp, #20]
    umull   r2, r3, lr, r1
    mla     r5, lr, r5, r3
    ldr     r4, [sp, #68]
    str     r5, [sp, #168]
    ldr     r5, [sp]
    umull   r1, r3, r5, r4
    ldr     lr, [sp, #112]
    mla     lr, r5, lr, r3
    str     r2, [sp, #260]
    str     lr, [sp, #132]
    ldr     r2, [sp, #44]
    ldr     lr, [sp, #32]
    str     r1, [sp, #184]
    umull   r1, r3, lr, r2
    ldr     r5, [sp, #48]
    mla     r5, lr, r5, r3
    ldr     r3, [sp, #40]
    umull   lr, r6, r9, r3
    ldr     r3, [sp, #64]
    mla     r3, r9, r3, r6
    str     r1, [sp, #188]
    str     r5, [sp, #136]
    str     lr, [sp, #192]
    str     r3, [sp, #164]
    ldr     r6, [sp, #12]
    ldr     lr, [sp, #60]
    umull   r3, r5, r6, lr
    ldr     lr, [sp, #172]
    ldr     r1, [sp, #16]
    ldr     r2, [sp, #88]
    adds    r3, r3, lr
    ldr     lr, [sp, #80]
    adc     r5, lr, r5
    umull   lr, ip, r1, r2
    str     lr, [sp, #252]
    ldr     lr, [sp, #92]
    mla     lr, r1, lr, ip
    ldr     r6, [sp, #4]
    ldr     r1, [sp, #8]
    str     lr, [sp, #80]
    umull   lr, ip, r6, r1
    adds    r3, r3, lr
    ldr     lr, [sp, #36]
    adc     r5, r5, ip
    mov     r6, r4
    umull   r2, ip, r7, lr
    ldr     lr, [sp, #84]
    mla     lr, r7, lr, ip
    ldr     ip, [sp, #96]
    str     lr, [sp, #84]
    umull   r4, lr, r6, ip
    ldr     r6, [sp, #196]
    adds    r3, r3, r4
    ldr     r4, [sp, #208]
    ldr     r1, [sp, #116]
    add     lr, r6, lr
    ldr     r6, [sp, #24]
    adc     lr, lr, r5
    adds    r3, r3, r4
    adc     lr, r0, lr
    str     r2, [sp, #256]
    umull   r2, r0, r6, r1
    ldr     r5, [sp, #40]
    str     r2, [sp, #196]
    ldr     r1, [sp, #140]
    ldr     r2, [sp, #72]
    mla     r1, r6, r1, r0
    umull   r0, r4, r5, r2
    adds    r0, r3, r0
    ldr     r3, [sp, #200]
    add     r3, r3, r4
    ldr     r4, [sp, #244]
    adc     r3, r3, lr
    adds    r0, r0, r4
    umull   r4, r5, r8, ip
    ldr     r2, [sp, #144]
    mla     r2, r8, r2, r5
    str     r1, [sp, #172]
    mov     r5, r2
    ldr     r1, [sp, #156]
    ldr     r2, [sp, #28]
    str     r4, [sp, #200]
    ldr     r4, [sp, #36]
    adc     r1, r1, r3
    umull   r3, lr, r4, r2
    adds    r3, r0, r3
    ldr     r0, [sp, #204]
    ldr     r2, [sp, #128]
    add     r0, r0, lr
    adc     r0, r0, r1
    adds    r3, r3, r10
    adc     r2, r2, r0
    ldr     r0, [sp, #248]
    adds    r3, r3, r0
    ldr     r0, [sp, #160]
    str     r3, [sp, #128]
    adc     r3, r0, r2
    mov     r2, r4
    ldr     r4, [sp, #52]
    umull   ip, lr, r2, r4
    ldr     r2, [sp, #220]
    add     lr, r2, lr
    ldr     r2, [sp, #44]
    str     r3, [sp, #156]
    umull   r3, r4, r9, r2
    ldr     r2, [sp, #48]
    mla     r2, r9, r2, r4
    ldr     r10, [sp, #60]
    str     ip, [sp, #244]
    mov     r4, r2
    ldr     ip, [sp, #104]
    ldr     r2, [sp, #12]
    str     r3, [sp, #204]
    umull   r3, r0, r2, r6
    umull   r1, r2, ip, r10
    ldr     r10, [sp, #4]
    adds    r3, r3, r1
    adc     r0, r0, r2
    umull   r1, r2, r10, r8
    ldr     ip, [sp, #88]
    adds    r3, r3, r1
    adc     r0, r0, r2
    umull   r2, r1, r7, ip
    ldr     r10, [sp, #92]
    str     r2, [sp, #208]
    mov     r2, r10
    mla     r2, r7, r2, r1
    ldr     r6, [sp, #20]
    str     r3, [sp, #160]
    mov     r1, r2
    umull   r3, r2, r6, ip
    mla     r10, r6, r10, r2
    ldr     ip, [sp, #56]
    ldr     r6, [sp, #8]
    str     r10, [sp, #36]
    umull   r10, r2, ip, r6
    str     r3, [sp, #220]
    ldr     r3, [sp, #160]
    adds    r3, r3, r10
    adc     r2, r0, r2
    ldr     r0, [sp, #184]
    adds    r3, r3, r0
    ldr     r0, [sp, #132]
    adc     r2, r0, r2
    ldr     r0, [sp, #188]
    adds    r3, r3, r0
    ldr     r0, [sp, #136]
    adc     r2, r0, r2
    ldr     r0, [sp, #192]
    ldr     ip, [sp, #164]
    adds    r3, r3, r0
    ldr     r0, [sp, #252]
    adc     r2, ip, r2
    adds    r3, r3, r0
    ldr     r0, [sp, #80]
    adc     r2, r0, r2
    ldr     r0, [sp, #256]
    adds    r3, r3, r0
    ldr     r0, [sp, #84]
    adc     ip, r0, r2
    ldr     r0, [sp, #260]
    adds    r0, r3, r0
    str     r0, [sp, #84]
    ldr     r0, [sp, #168]
    ldr     r3, [sp, #100]
    ldr     r6, [sp, #104]
    adc     r0, r0, ip
    str     r0, [sp, #88]
    umull   r2, r0, r3, r6
    mov     r6, r0
    ldr     ip, [sp, #12]
    ldr     r0, [sp, #76]
    umlal   r2, r6, ip, r0
    mov     r0, ip
    str     r6, [sp, #136]
    umull   r6, ip, r3, r0
    ldr     r0, [sp, #196]
    adds    r6, r6, r0
    ldr     r0, [sp, #172]
    adc     r0, r0, ip
    str     r0, [sp, #80]
    ldr     ip, [sp, #60]
    ldr     r0, [sp, #4]
    umull   r3, r10, r0, ip
    ldr     r0, [sp, #80]
    adds    r3, r6, r3
    adc     ip, r0, r10
    ldr     r0, [sp, #200]
    ldr     r10, [sp]
    adds    r3, r3, r0
    ldr     r0, [sp, #8]
    adc     ip, r5, ip
    umull   r5, r6, r10, r0
    ldr     r10, [sp, #68]
    ldr     r0, [sp, #72]
    adds    r5, r3, r5
    adc     ip, ip, r6
    umull   r3, r6, r10, r0
    adds    r3, r5, r3
    ldr     r5, [sp, #212]
    ldr     r0, [sp, #204]
    add     r5, r5, r6
    adc     ip, r5, ip
    ldr     r6, [sp, #40]
    adds    r3, r3, r0
    ldr     r0, [sp, #28]
    adc     r4, r4, ip
    umull   ip, r5, r6, r0
    adds    ip, r3, ip
    ldr     r3, [sp, #216]
    add     r3, r3, r5
    ldr     r5, [sp, #208]
    adc     r3, r3, r4
    ldr     r4, [sp, #244]
    adds    ip, ip, r5
    adc     r1, r1, r3
    adds    r4, ip, r4
    str     r4, [sp, #92]
    adc     r4, lr, r1
    str     r4, [sp, #132]
    ldr     ip, [sp, #4]
    ldr     r4, [sp, #24]
    umull   r3, r1, ip, r4
    add     r4, sp, #56
    ldm     r4, {r4, ip}
    adds    r3, r2, r3
    ldr     r2, [sp, #136]
    adc     r2, r2, r1
    umull   r0, r1, r4, ip
    ldr     r4, [sp]
    adds    r3, r3, r0
    adc     r2, r2, r1
    umull   r1, r0, r4, r8
    ldr     r5, [sp, #32]
    adds    r3, r3, r1
    ldr     r1, [sp, #8]
    adc     r2, r2, r0
    umlal   r3, r2, r5, r1
    umull   r0, r1, r9, r10
    adds    r3, r3, r0
    ldr     r0, [sp, #112]
    mla     r0, r9, r0, r1
    ldr     lr, [sp, #16]
    ldr     r5, [sp, #44]
    adc     r2, r0, r2
    umull   r1, r0, lr, r5
    adds    r3, r3, r1
    ldr     r1, [sp, #48]
    mla     r1, lr, r1, r0
    adc     r0, r1, r2
    umull   r2, r1, r7, r6
    ldr     r5, [sp, #64]
    mla     r5, r7, r5, r1
    mov     r4, r10
    adds    r2, r3, r2
    ldr     r3, [sp, #220]
    adc     r1, r5, r0
    adds    r2, r2, r3
    str     r2, [sp, #136]
    ldr     r2, [sp, #36]
    adc     r2, r2, r1
    str     r2, [sp, #160]
    ldr     r2, [sp, #52]
    umull   r1, ip, r6, r2
    ldr     r3, [sp, #228]
    str     r1, [sp, #164]
    add     ip, r3, ip
    ldr     r1, [sp, #140]
    umull   r10, r3, r4, r2
    mov     r2, r1
    ldr     r6, [sp, #232]
    ldr     r4, [sp, #116]
    str     r10, [sp, #172]
    ldr     r10, [sp, #76]
    add     r3, r6, r3
    str     r3, [sp, #80]
    umull   r5, r3, r10, r4
    mla     r2, r10, r2, r3
    ldr     lr, [sp, #108]
    mov     r3, r2
    umull   r0, r2, lr, r4
    mla     r1, lr, r1, r2
    ldr     r4, [sp, #144]
    str     r1, [sp, #52]
    mov     r1, r4
    ldr     lr, [sp, #96]
    str     r0, [sp, #168]
    ldr     r0, [sp, #24]
    umull   r6, r2, r0, lr
    mla     r1, r0, r1, r2
    str     r1, [sp, #36]
    umull   r0, r1, r10, lr
    ldr     r2, [sp, #148]
    mla     r4, r10, r4, r1
    mov     lr, r2
    ldr     r1, [sp, #72]
    str     r0, [sp, #144]
    str     r4, [sp, #64]
    umull   r0, r4, r8, r1
    mla     lr, r8, lr, r4
    mov     r4, lr
    mov     lr, r1
    str     r0, [sp, #96]
    ldr     r0, [sp, #24]
    umull   r10, r1, r0, lr
    str     r10, [sp, #148]
    mov     r10, r2
    ldr     r2, [sp, #44]
    mla     r10, r0, r10, r1
    umull   lr, r0, r7, r2
    str     lr, [sp, #116]
    ldr     lr, [sp, #48]
    mov     r1, lr
    mla     r1, r7, r1, r0
    mov     r0, r2
    str     r10, [sp, #72]
    ldr     r10, [sp, #20]
    str     r1, [sp, #40]
    umull   r2, r1, r10, r0
    mla     lr, r10, lr, r1
    mov     r1, r10
    ldr     r10, [sp, #8]
    str     r2, [sp, #140]
    umull   r2, r0, r1, r10
    ldr     r10, [sp, #12]
    str     r0, [sp, #192]
    ldr     r0, [sp, #124]
    str     lr, [sp, #44]
    umull   lr, r1, r10, r0
    ldr     r10, [sp, #100]
    ldr     r0, [sp, #4]
    adds    lr, lr, r5
    adc     r3, r3, r1
    umull   r1, r5, r10, r0
    adds    r1, lr, r1
    ldr     lr, [sp, #36]
    adc     r3, r3, r5
    adds    r1, r1, r6
    str     r2, [sp, #188]
    adc     r2, lr, r3
    ldr     lr, [sp, #68]
    umull   r5, r3, r7, lr
    str     r5, [sp, #48]
    ldr     r5, [sp, #112]
    mla     r5, r7, r5, r3
    mov     r3, lr
    ldr     r0, [sp, #28]
    str     r5, [sp, #20]
    umull   r5, lr, r3, r0
    ldr     r6, [sp, #224]
    add     lr, r6, lr
    mov     r6, r0
    umull   r0, r3, r8, r6
    ldr     r6, [sp, #120]
    mla     r6, r8, r6, r3
    str     r0, [sp, #112]
    str     r6, [sp, #28]
    ldr     r0, [sp]
    ldr     r10, [sp, #60]
    umull   r3, r6, r0, r10
    adds    r3, r1, r3
    ldr     r1, [sp, #96]
    adc     r2, r2, r6
    ldr     r6, [sp, #8]
    adds    r3, r3, r1
    adc     r2, r4, r2
    umull   r1, r4, r9, r6
    adds    r3, r3, r1
    ldr     r1, [sp, #116]
    ldr     r0, [sp, #40]
    adc     r2, r2, r4
    adds    r3, r3, r5
    adc     r2, lr, r2
    adds    r3, r3, r1
    adc     r0, r0, r2
    ldr     r2, [sp, #164]
    adds    r3, r3, r2
    adc     r1, ip, r0
    str     r1, [sp, #40]
    ldr     r1, [sp, #12]
    mov     ip, r1
    ldr     lr, [sp, #108]
    ldr     r5, [sp, #152]
    str     r3, [sp, #36]
    umull   r3, r2, r1, lr
    umull   r6, r1, ip, r5
    ldr     ip, [sp, #104]
    str     r6, [sp, #68]
    umull   r6, r4, ip, r5
    str     r6, [sp, #96]
    mov     r6, ip
    ldr     r5, [sp, #124]
    umull   ip, r0, r6, r5
    adds    r3, r3, ip
    mov     ip, lr
    ldr     r6, [sp, #4]
    adc     r2, r2, r0
    umull   lr, r0, r6, ip
    ldr     r10, [sp, #76]
    str     r0, [sp, #116]
    umull   ip, r0, r6, r10
    adds    r3, r3, ip
    mov     ip, r5
    str     lr, [sp, #108]
    umull   lr, r5, r6, ip
    ldr     r6, [sp, #56]
    str     lr, [sp, #4]
    adc     r2, r2, r0
    umull   lr, r0, r6, ip
    str     r5, [sp, #76]
    ldr     r5, [sp, #100]
    str     r0, [sp, #120]
    umull   ip, r0, r5, r6
    str     r4, [sp, #104]
    ldr     r4, [sp]
    adds    r3, r3, ip
    umull   ip, r6, r4, r10
    str     lr, [sp, #56]
    ldr     lr, [sp, #24]
    str     ip, [sp, #100]
    adc     r2, r2, r0
    umull   ip, r0, r4, lr
    adds    r3, r3, ip
    adc     r2, r2, r0
    mov     r0, r5
    umull   ip, r10, r4, r5
    ldr     r4, [sp, #32]
    str     ip, [sp]
    umull   ip, r5, r0, r4
    str     r5, [sp, #152]
    mov     r5, r4
    ldr     r4, [sp, #60]
    str     ip, [sp, #124]
    umull   ip, r0, r5, r4
    adds    r3, r3, ip
    adc     r2, r2, r0
    mov     r0, lr
    umull   lr, ip, r9, r0
    str     ip, [sp, #164]
    umull   ip, r0, r9, r8
    adds    r3, r3, ip
    adc     r2, r2, r0
    mov     r0, r4
    str     lr, [sp, #60]
    umull   r4, lr, r9, r0
    ldr     ip, [sp, #16]
    str     lr, [sp, #32]
    str     r4, [sp, #24]
    umull   r4, lr, ip, r0
    str     r4, [sp, #184]
    mov     r4, ip
    ldr     r9, [sp, #8]
    umull   ip, r0, r4, r9
    ldr     r5, [sp, #48]
    adds    r3, r3, ip
    adc     r0, r2, r0
    ldr     r2, [sp, #20]
    adds    r3, r3, r5
    ldr     r5, [sp, #140]
    adc     r2, r2, r0
    adds    r3, r3, r5
    str     r3, [sp, #8]
    ldr     r3, [sp, #44]
    ldr     r5, [sp, #68]
    ldr     ip, [sp, #168]
    adc     r3, r3, r2
    str     r3, [sp, #12]
    ldr     r2, [sp, #52]
    adds    r3, r5, ip
    ldr     r5, [sp, #4]
    adc     r1, r2, r1
    adds    r3, r3, r5
    ldr     r5, [sp, #76]
    ldr     ip, [sp, #144]
    ldr     r4, [sp, #64]
    adc     r1, r1, r5
    ldr     r5, [sp]
    adds    r3, r3, ip
    adc     r1, r4, r1
    ldr     ip, [sp, #148]
    adds    r3, r3, r5
    adc     r1, r1, r10
    ldr     r10, [sp, #72]
    adds    r3, r3, ip
    adc     r2, r10, r1
    umull   r1, r0, r7, r9
    ldr     r5, [sp, #24]
    ldr     ip, [sp, #112]
    adds    r3, r3, r5
    ldr     r5, [sp, #32]
    ldr     r10, [sp, #28]
    adc     r2, r2, r5
    adds    r3, r3, ip
    adc     r2, r10, r2
    ldr     r10, [sp, #172]
    ldr     ip, [sp, #80]
    adds    r1, r3, r1
    adc     r2, r2, r0
    adds    r0, r1, r10
    adc     r10, ip, r2
    str     r10, [sp, #16]
    ldr     r3, [sp, #280]
    ldr     r9, [sp, #96]
    ldr     r1, [sp, #284]
    adds    r3, r3, r9
    ldr     r9, [sp, #104]
    adc     r2, r1, r9
    ldr     r9, [sp, #108]
    adds    r3, r3, r9
    ldr     r9, [sp, #116]
    adc     r2, r2, r9
    ldr     r9, [sp, #56]
    adds    r3, r3, r9
    ldr     r9, [sp, #120]
    adc     r2, r2, r9
    ldr     r9, [sp, #100]
    adds    r3, r3, r9
    ldr     r9, [sp, #124]
    ldr     r4, [sp, #152]
    adc     r2, r2, r6
    adds    r3, r3, r9
    ldr     r9, [sp, #60]
    ldr     r1, [sp, #164]
    adc     r2, r2, r4
    adds    r3, r3, r9
    adc     r2, r2, r1
    umull   r1, ip, r7, r8
    ldr     r9, [sp, #184]
    adds    r3, r3, r9
    adc     r2, r2, lr
    adds    r1, r3, r1
    adc     r2, r2, ip
    ldr     ip, [sp, #188]
    ldr     r4, [sp, #236]
    ldr     r8, [sp, #192]
    ldr     r5, [sp, #240]
    adds    ip, r1, ip
    adc     lr, r2, r8
    adds    r1, r4, #33554432
    adc     r3, r5, #0
    ldr     r6, [sp, #176]
    lsr     r2, r1, #26
    orr     r2, r2, r3, lsl#6
    adds    r2, r2, r6
    ldr     r6, [sp, #180]
    and     r1, r1, #-67108864
    adc     r6, r6, r3, asr#26
    subs    r8, r4, r1
    sbc     r10, r5, r3
    adds    r4, r2, #16777216
    adc     r5, r6, #0
    ldr     r1, [sp, #128]
    lsr     r3, r4, #25
    orr     r3, r3, r5, lsl#7
    adds    r3, r3, r1
    ldr     r1, [sp, #156]
    and     r4, r4, #-33554432
    adc     r1, r1, r5, asr#25
    subs    r4, r2, r4
    sbc     r9, r6, r5
    adds    r5, r3, #33554432
    adc     r2, r1, #0
    ldr     r7, [sp, #84]
    lsr     r6, r5, #26
    orr     r6, r6, r2, lsl#6
    adds    r6, r6, r7
    ldr     r7, [sp, #88]
    and     r5, r5, #-67108864
    adc     r7, r7, r2, asr#26
    subs    r5, r3, r5
    sbc     r1, r1, r2
    adds    r3, r6, #16777216
    str     r5, [sp, #28]
    str     r1, [sp, #32]
    ldr     r5, [sp, #92]
    adc     r1, r7, #0
    lsr     r2, r3, #25
    orr     r2, r2, r1, lsl#7
    adds    r2, r2, r5
    ldr     r5, [sp, #132]
    and     r3, r3, #-33554432
    adc     r5, r5, r1, asr#25
    str     r3, [sp, #76]
    adds    r3, r2, #33554432
    str     r6, [sp, #20]
    str     r7, [sp, #24]
    str     r1, [sp]
    str     r2, [sp, #44]
    ldr     r6, [sp, #136]
    str     r5, [sp, #48]
    lsr     r2, r3, #26
    adc     r5, r5, #0
    orr     r2, r2, r5, lsl#6
    adds    r2, r2, r6
    ldr     r6, [sp, #160]
    and     r3, r3, #-67108864
    adc     r6, r6, r5, asr#26
    str     r3, [sp, #80]
    adds    r3, r2, #16777216
    ldr     r7, [sp, #36]
    str     r2, [sp, #52]
    str     r6, [sp, #56]
    lsr     r2, r3, #25
    adc     r6, r6, #0
    orr     r2, r2, r6, lsl#7
    adds    r7, r2, r7
    ldr     r2, [sp, #40]
    and     r3, r3, #-33554432
    adc     r2, r2, r6, asr#25
    str     r3, [sp, #84]
    adds    r3, r7, #33554432
    str     r5, [sp, #4]
    str     r7, [sp, #36]
    adc     r5, r2, #0
    ldr     r7, [sp, #8]
    str     r2, [sp, #40]
    lsr     r2, r3, #26
    orr     r2, r2, r5, lsl#6
    adds    r7, r2, r7
    ldr     r2, [sp, #12]
    and     r3, r3, #-67108864
    adc     r2, r2, r5, asr#26
    str     r3, [sp, #88]
    adds    r3, r7, #16777216
    str     r2, [sp, #12]
    lsr     r1, r3, #25
    adc     r2, r2, #0
    str     r7, [sp, #8]
    orr     r1, r1, r2, lsl#7
    ldr     r7, [sp, #16]
    adds    r0, r1, r0
    adc     r7, r7, r2, asr#25
    and     r3, r3, #-33554432
    adds    r1, r0, #33554432
    str     r3, [sp, #92]
    str     r0, [sp, #16]
    adc     r3, r7, #0
    lsr     r0, r1, #26
    orr     r0, r0, r3, lsl#6
    adds    ip, r0, ip
    adc     lr, lr, r3, asr#26
    and     r0, r1, #-67108864
    adds    r1, ip, #16777216
    str     r7, [sp, #60]
    str     ip, [sp, #64]
    adc     r7, lr, #0
    str     lr, [sp, #68]
    and     ip, r1, #-33554432
    lsr     lr, r1, #25
    orr     lr, lr, r7, lsl#7
    str     ip, [sp, #100]
    asr     ip, r7, #25
    str     r0, [sp, #96]
    lsl     r1, lr, #3
    lsl     r0, ip, #3
    adds    r1, r1, lr
    orr     r0, r0, lr, lsr#29
    adc     r0, ip, r0
    adds    r1, r1, r1
    adc     r0, r0, r0
    adds    r1, r1, lr
    adc     ip, ip, r0
    adds    r1, r1, r8
    adc     ip, r10, ip
    adds    r8, r1, #33554432
    adc     r10, ip, #0
    lsr     r0, r8, #26
    orr     r0, r0, r10, lsl#6
    adds    r0, r0, r4
    adc     r4, r9, r10, asr#26
    and     r8, r8, #-67108864
    adds    lr, r0, #16777216
    adc     r9, r4, #0
    subs    r1, r1, r8
    sbc     ip, ip, r10
    stm     fp, {r1, ip}
    ldr     r8, [sp, #28]
    and     r1, lr, #-33554432
    lsr     lr, lr, #25
    subs    r0, r0, r1
    orr     lr, lr, r9, lsl#7
    sbc     r4, r4, r9
    adds    lr, lr, r8
    ldr     r8, [sp, #32]
    str     r0, [fp, #8]
    adc     r9, r8, r9, asr#25
    ldr     r0, [sp, #20]
    str     r4, [sp, #72]
    ldr     r8, [sp, #76]
    ldr     r1, [sp]
    subs    r10, r0, r8
    ldr     r0, [sp, #24]
    str     r10, [sp, #20]
    ldr     r8, [sp, #80]
    sbc     r10, r0, r1
    ldr     r0, [sp, #44]
    ldr     r1, [sp, #4]
    str     r10, [fp, #28]
    subs    r10, r0, r8
    ldr     r0, [sp, #48]
    ldr     r8, [sp, #84]
    str     r10, [sp]
    sbc     r10, r0, r1
    ldr     r1, [sp, #52]
    subs    ip, r1, r8
    ldr     r1, [sp, #56]
    ldr     r8, [sp, #88]
    sbc     r6, r1, r6
    ldr     r1, [sp, #36]
    subs    r0, r1, r8
    ldr     r1, [sp, #40]
    ldr     r8, [sp, #92]
    sbc     r5, r1, r5
    ldr     r1, [sp, #8]
    subs    r1, r1, r8
    ldr     r8, [sp, #12]
    sbc     r2, r8, r2
    str     r2, [fp, #60]
    ldr     r8, [sp, #96]
    ldr     r2, [sp, #16]
    subs    r2, r2, r8
    ldr     r8, [sp, #60]
    ldr     r4, [sp, #100]
    sbc     r8, r8, r3
    ldr     r3, [sp, #64]
    subs    r3, r3, r4
    ldr     r4, [sp, #68]
    str     lr, [fp, #16]
    sbc     r7, r4, r7
    ldr     lr, [sp, #20]
    ldr     r4, [sp, #72]
    str     r9, [fp, #20]
    str     r4, [fp, #12]
    str     lr, [fp, #24]
    ldr     lr, [sp]
    str     r10, [fp, #36]
    str     lr, [fp, #32]
    str     ip, [fp, #40]
    str     r6, [fp, #44]
    str     r0, [fp, #48]
    str     r5, [fp, #52]
    str     r1, [fp, #56]
    str     r2, [fp, #64]
    str     r8, [fp, #68]
    str     r3, [fp, #72]
    str     r7, [fp, #76]
    add     sp, sp, #292
    pop     {r4, r5, r6, r7, r8, r9, r10, fp, lr}
    bx      lr
