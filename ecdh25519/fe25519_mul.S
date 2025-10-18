.syntax unified
.text
.thumb
.align 2
.global fe25519_mul_core_s
.type fe25519_mul_core_s, %function

// Cortex-M4 implementation scaffold for fe25519_mul_core.
// Step 1: load 32 bytes from a and b into 8x uint64_t temporaries each.
fe25519_mul_core_s:
    push    {r4-r11, lr}          // save callee-saved state
    sub     sp, sp, #4            // maintain 8-byte stack alignment
    sub     sp, sp, #352          // locals: ax[8], bx[8], f[10], g[10], g*_19, f*_2, h pointer, h[10]

    str     r2, [sp, #264]        // spill h pointer for later steps
    movs    r3, #0                // constant zero, used for upper 32 bits
    movw    r12, #0xffff          // mask 0x03ffffff
    movt    r12, #0x03ff
    movw    r10, #0xffff // mask 0x01ffffff
    movt    r10, #0x01ff

    // Load ax[0..7] = load4(a + i*4)
    ldr     r4, [r0, #0]
    str     r4, [sp, #0]
    str     r3, [sp, #4]

    ldr     r4, [r0, #4]
    str     r4, [sp, #8]
    str     r3, [sp, #12]

    ldr     r4, [r0, #8]
    str     r4, [sp, #16]
    str     r3, [sp, #20]

    ldr     r4, [r0, #12]
    str     r4, [sp, #24]
    str     r3, [sp, #28]

    ldr     r4, [r0, #16]
    str     r4, [sp, #32]
    str     r3, [sp, #36]

    ldr     r4, [r0, #20]
    str     r4, [sp, #40]
    str     r3, [sp, #44]

    ldr     r4, [r0, #24]
    str     r4, [sp, #48]
    str     r3, [sp, #52]

    ldr     r4, [r0, #28]
    str     r4, [sp, #56]
    str     r3, [sp, #60]

    // Load bx[0..7] = load4(b + i*4)
    ldr     r4, [r1, #0]
    str     r4, [sp, #64]
    str     r3, [sp, #68]

    ldr     r4, [r1, #4]
    str     r4, [sp, #72]
    str     r3, [sp, #76]

    ldr     r4, [r1, #8]
    str     r4, [sp, #80]
    str     r3, [sp, #84]

    ldr     r4, [r1, #12]
    str     r4, [sp, #88]
    str     r3, [sp, #92]

    ldr     r4, [r1, #16]
    str     r4, [sp, #96]
    str     r3, [sp, #100]

    ldr     r4, [r1, #20]
    str     r4, [sp, #104]
    str     r3, [sp, #108]

    ldr     r4, [r1, #24]
    str     r4, [sp, #112]
    str     r3, [sp, #116]

    ldr     r4, [r1, #28]
    str     r4, [sp, #120]
    str     r3, [sp, #124]

    // Step 2: derive radix-25/26 limbs f[0..9] from ax values.
    ldr     r4, [sp, #0]// ax0
    ands    r4, r4, r12
    str     r4, [sp, #128]// f0

    ldr     r4, [sp, #0]          // ax0
    ldr     r5, [sp, #8]          // ax1
    lsrs    r6, r4, #26
    lsls    r7, r5, #6
    orrs    r6, r6, r7
    ands    r6, r6, r10
    str     r6, [sp, #132]// f1

    ldr     r4, [sp, #8]          // ax1
    ldr     r5, [sp, #16]         // ax2
    lsrs    r6, r4, #19
    lsls    r7, r5, #13
    orrs    r6, r6, r7
    ands    r6, r6, r12
    str     r6, [sp, #136]// f2

    ldr     r4, [sp, #16]         // ax2
    ldr     r5, [sp, #24]         // ax3
    lsrs    r6, r4, #13
    lsls    r7, r5, #19
    orrs    r6, r6, r7
    ands    r6, r6, r10
    str     r6, [sp, #140]// f3

    ldr     r4, [sp, #24]// ax3
    lsrs    r4, r4, #6
    ands    r4, r4, r12
    str     r4, [sp, #144]// f4

    ldr     r4, [sp, #32]// ax4
    ands    r4, r4, r10
    str     r4, [sp, #148]// f5

    ldr     r4, [sp, #32]         // ax4
    ldr     r5, [sp, #40]         // ax5
    lsrs    r6, r4, #25
    lsls    r7, r5, #7
    orrs    r6, r6, r7
    ands    r6, r6, r12
    str     r6, [sp, #152]// f6

    ldr     r4, [sp, #40]         // ax5
    ldr     r5, [sp, #48]         // ax6
    lsrs    r6, r4, #19
    lsls    r7, r5, #13
    orrs    r6, r6, r7
    ands    r6, r6, r10
    str     r6, [sp, #156]// f7

    ldr     r4, [sp, #48]         // ax6
    ldr     r5, [sp, #56]         // ax7
    lsrs    r6, r4, #12
    lsls    r7, r5, #20
    orrs    r6, r6, r7
    ands    r6, r6, r12
    str     r6, [sp, #160]// f8

    ldr     r4, [sp, #56]// ax7
    lsrs    r4, r4, #6
    ands    r4, r4, r10
    str     r4, [sp, #164]// f9

    // Step 2: derive radix-25/26 limbs g[0..9] from bx values.
    ldr     r4, [sp, #64]// bx0
    ands    r4, r4, r12
    str     r4, [sp, #168]// g0

    ldr     r4, [sp, #64]         // bx0
    ldr     r5, [sp, #72]         // bx1
    lsrs    r6, r4, #26
    lsls    r7, r5, #6
    orrs    r6, r6, r7
    ands    r6, r6, r10
    str     r6, [sp, #172]// g1

    ldr     r4, [sp, #72]         // bx1
    ldr     r5, [sp, #80]         // bx2
    lsrs    r6, r4, #19
    lsls    r7, r5, #13
    orrs    r6, r6, r7
    ands    r6, r6, r12
    str     r6, [sp, #176]// g2

    ldr     r4, [sp, #80]         // bx2
    ldr     r5, [sp, #88]         // bx3
    lsrs    r6, r4, #13
    lsls    r7, r5, #19
    orrs    r6, r6, r7
    ands    r6, r6, r10
    str     r6, [sp, #180]// g3

    ldr     r4, [sp, #88]// bx3
    lsrs    r4, r4, #6
    ands    r4, r4, r12
    str     r4, [sp, #184]// g4

    ldr     r4, [sp, #96]// bx4
    ands    r4, r4, r10
    str     r4, [sp, #188]// g5

    ldr     r4, [sp, #96]         // bx4
    ldr     r5, [sp, #104]        // bx5
    lsrs    r6, r4, #25
    lsls    r7, r5, #7
    orrs    r6, r6, r7
    ands    r6, r6, r12
    str     r6, [sp, #192]// g6

    ldr     r4, [sp, #104]        // bx5
    ldr     r5, [sp, #112]        // bx6
    lsrs    r6, r4, #19
    lsls    r7, r5, #13
    orrs    r6, r6, r7
    ands    r6, r6, r10
    str     r6, [sp, #196]// g7

    ldr     r4, [sp, #112]        // bx6
    ldr     r5, [sp, #120]        // bx7
    lsrs    r6, r4, #12
    lsls    r7, r5, #20
    orrs    r6, r6, r7
    ands    r6, r6, r12
    str     r6, [sp, #200]// g8

    ldr     r4, [sp, #120]// bx7
    lsrs    r4, r4, #6
    ands    r4, r4, r10
    str     r4, [sp, #204]// g9

    // Step 3: precompute g[*]_19 and f[*]_2.
    movs    r4, #19
    movs    r5, #2

    ldr     r6, [sp, #172]// g1
    mul     r6, r6, r4
    str     r6, [sp, #208]// g1_19

    ldr     r6, [sp, #176]// g2
    mul     r6, r6, r4
    str     r6, [sp, #212]// g2_19

    ldr     r6, [sp, #180]// g3
    mul     r6, r6, r4
    str     r6, [sp, #216]// g3_19

    ldr     r6, [sp, #184]// g4
    mul     r6, r6, r4
    str     r6, [sp, #220]// g4_19

    ldr     r6, [sp, #188]// g5
    mul     r6, r6, r4
    str     r6, [sp, #224]// g5_19

    ldr     r6, [sp, #192]// g6
    mul     r6, r6, r4
    str     r6, [sp, #228]// g6_19

    ldr     r6, [sp, #196]// g7
    mul     r6, r6, r4
    str     r6, [sp, #232]// g7_19

    ldr     r6, [sp, #200]// g8
    mul     r6, r6, r4
    str     r6, [sp, #236]// g8_19

    ldr     r6, [sp, #204]// g9
    mul     r6, r6, r4
    str     r6, [sp, #240]// g9_19

    ldr     r6, [sp, #132]// f1
    mul     r6, r6, r5
    str     r6, [sp, #244]// f1_2

    ldr     r6, [sp, #140]// f3
    mul     r6, r6, r5
    str     r6, [sp, #248]// f3_2

    ldr     r6, [sp, #148]// f5
    mul     r6, r6, r5
    str     r6, [sp, #252]// f5_2

    ldr     r6, [sp, #156]// f7
    mul     r6, r6, r5
    str     r6, [sp, #256]// f7_2

    ldr     r6, [sp, #164]// f9
    mul     r6, r6, r5
    str     r6, [sp, #260]// f9_2

    // Step 4: Comba accumulation for h[0..9].

    // h0
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #244]        // f1_2
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #248]        // f3_2
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #228]        // g6_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #252]        // f5_2
    ldr     r1, [sp, #224]        // g5_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #220]        // g4_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #256]        // f7_2
    ldr     r1, [sp, #216]        // g3_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #212]        // g2_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #260]        // f9_2
    ldr     r1, [sp, #208]        // g1_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #272]        // h0 lo
    str     r9, [sp, #276]        // h0 hi

    // h1
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #132]        // f1
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #140]        // f3
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #148]        // f5
    ldr     r1, [sp, #228]        // g6_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #224]        // g5_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #156]        // f7
    ldr     r1, [sp, #220]        // g4_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #216]        // g3_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #164]        // f9
    ldr     r1, [sp, #212]        // g2_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #280]        // h1 lo
    str     r9, [sp, #284]        // h1 hi

    // h2
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #244]        // f1_2
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #248]        // f3_2
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #252]        // f5_2
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #228]        // g6_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #256]        // f7_2
    ldr     r1, [sp, #224]        // g5_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #220]        // g4_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #260]        // f9_2
    ldr     r1, [sp, #216]        // g3_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #288]        // h2 lo
    str     r9, [sp, #292]        // h2 hi

    // h3
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #132]        // f1
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #140]        // f3
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #148]        // f5
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #156]        // f7
    ldr     r1, [sp, #228]        // g6_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #224]        // g5_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #164]        // f9
    ldr     r1, [sp, #220]        // g4_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #296]        // h3 lo
    str     r9, [sp, #300]        // h3 hi

    // h4
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #184]        // g4
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #244]        // f1_2
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #248]        // f3_2
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #252]        // f5_2
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #256]        // f7_2
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #228]        // g6_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #260]        // f9_2
    ldr     r1, [sp, #224]        // g5_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #304]        // h4 lo
    str     r9, [sp, #308]        // h4 hi

    // h5
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #188]        // g5
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #132]        // f1
    ldr     r1, [sp, #184]        // g4
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #140]        // f3
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #148]        // f5
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #156]        // f7
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #164]        // f9
    ldr     r1, [sp, #228]        // g6_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #312]        // h5 lo
    str     r9, [sp, #316]        // h5 hi

    // h6
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #192]        // g6
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #244]        // f1_2
    ldr     r1, [sp, #188]        // g5
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #184]        // g4
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #248]        // f3_2
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #252]        // f5_2
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #256]        // f7_2
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #260]        // f9_2
    ldr     r1, [sp, #232]        // g7_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #320]        // h6 lo
    str     r9, [sp, #324]        // h6 hi

    // h7
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #196]        // g7
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #132]        // f1
    ldr     r1, [sp, #192]        // g6
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #188]        // g5
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #140]        // f3
    ldr     r1, [sp, #184]        // g4
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #148]        // f5
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #156]        // f7
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #164]        // f9
    ldr     r1, [sp, #236]        // g8_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #328]        // h7 lo
    str     r9, [sp, #332]        // h7 hi

    // h8
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #200]        // g8
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #244]        // f1_2
    ldr     r1, [sp, #196]        // g7
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #192]        // g6
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #248]        // f3_2
    ldr     r1, [sp, #188]        // g5
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #184]        // g4
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #252]        // f5_2
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #256]        // f7_2
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #260]        // f9_2
    ldr     r1, [sp, #240]        // g9_19
    smlal   r8, r9, r0, r1
    str     r8, [sp, #336]        // h8 lo
    str     r9, [sp, #340]        // h8 hi

    // h9
    eor     r8, r8, r8
    eor     r9, r9, r9
    ldr     r0, [sp, #128]        // f0
    ldr     r1, [sp, #204]        // g9
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #132]        // f1
    ldr     r1, [sp, #200]        // g8
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #136]        // f2
    ldr     r1, [sp, #196]        // g7
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #140]        // f3
    ldr     r1, [sp, #192]        // g6
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #144]        // f4
    ldr     r1, [sp, #188]        // g5
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #148]        // f5
    ldr     r1, [sp, #184]        // g4
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #152]        // f6
    ldr     r1, [sp, #180]        // g3
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #156]        // f7
    ldr     r1, [sp, #176]        // g2
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #160]        // f8
    ldr     r1, [sp, #172]        // g1
    smlal   r8, r9, r0, r1
    ldr     r0, [sp, #164]        // f9
    ldr     r1, [sp, #168]        // g0
    smlal   r8, r9, r0, r1
    str     r8, [sp, #344]        // h9 lo
    str     r9, [sp, #348]        // h9 hi
    // Step 5: carry propagation (first pass).
    movw    r11, #0
    movt    r11, #0x0200 // 1 << 25
    movw    r12, #0
    movt    r12, #0x0100 // 1 << 24

    // carry0: (h0 + 2^25) >> 26
    ldr     r0, [sp, #272]
    ldr     r1, [sp, #276]
    movs    r3, #0
    adds    r0, r0, r11
    adc     r1, r1, r3
    lsrs    r4, r0, #26
    lsls    r5, r1, #6
    orrs    r4, r4, r5
    lsrs    r5, r1, #26
    lsls    r2, r4, #26
    lsrs    r6, r4, #6
    lsls    r7, r5, #26
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #272]
    str     r1, [sp, #276]
    ldr     r6, [sp, #280]
    ldr     r7, [sp, #284]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #280]
    str     r7, [sp, #284]

    // carry1: (h1 + 2^24) >> 25
    ldr     r0, [sp, #280]
    ldr     r1, [sp, #284]
    movs    r3, #0
    adds    r0, r0, r12
    adc     r1, r1, r3
    lsrs    r4, r0, #25
    lsls    r5, r1, #7
    orrs    r4, r4, r5
    lsrs    r5, r1, #25
    lsls    r2, r4, #25
    lsrs    r6, r4, #7
    lsls    r7, r5, #25
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #280]
    str     r1, [sp, #284]
    ldr     r6, [sp, #288]
    ldr     r7, [sp, #292]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #288]
    str     r7, [sp, #292]

    // carry2: (h2 + 2^25) >> 26
    ldr     r0, [sp, #288]
    ldr     r1, [sp, #292]
    movs    r3, #0
    adds    r0, r0, r11
    adc     r1, r1, r3
    lsrs    r4, r0, #26
    lsls    r5, r1, #6
    orrs    r4, r4, r5
    lsrs    r5, r1, #26
    lsls    r2, r4, #26
    lsrs    r6, r4, #6
    lsls    r7, r5, #26
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #288]
    str     r1, [sp, #292]
    ldr     r6, [sp, #296]
    ldr     r7, [sp, #300]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #296]
    str     r7, [sp, #300]

    // carry3: (h3 + 2^24) >> 25
    ldr     r0, [sp, #296]
    ldr     r1, [sp, #300]
    movs    r3, #0
    adds    r0, r0, r12
    adc     r1, r1, r3
    lsrs    r4, r0, #25
    lsls    r5, r1, #7
    orrs    r4, r4, r5
    lsrs    r5, r1, #25
    lsls    r2, r4, #25
    lsrs    r6, r4, #7
    lsls    r7, r5, #25
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #296]
    str     r1, [sp, #300]
    ldr     r6, [sp, #304]
    ldr     r7, [sp, #308]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #304]
    str     r7, [sp, #308]

    // carry4: (h4 + 2^25) >> 26
    ldr     r0, [sp, #304]
    ldr     r1, [sp, #308]
    movs    r3, #0
    adds    r0, r0, r11
    adc     r1, r1, r3
    lsrs    r4, r0, #26
    lsls    r5, r1, #6
    orrs    r4, r4, r5
    lsrs    r5, r1, #26
    lsls    r2, r4, #26
    lsrs    r6, r4, #6
    lsls    r7, r5, #26
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #304]
    str     r1, [sp, #308]
    ldr     r6, [sp, #312]
    ldr     r7, [sp, #316]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #312]
    str     r7, [sp, #316]

    // carry5: (h5 + 2^24) >> 25
    ldr     r0, [sp, #312]
    ldr     r1, [sp, #316]
    movs    r3, #0
    adds    r0, r0, r12
    adc     r1, r1, r3
    lsrs    r4, r0, #25
    lsls    r5, r1, #7
    orrs    r4, r4, r5
    lsrs    r5, r1, #25
    lsls    r2, r4, #25
    lsrs    r6, r4, #7
    lsls    r7, r5, #25
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #312]
    str     r1, [sp, #316]
    ldr     r6, [sp, #320]
    ldr     r7, [sp, #324]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #320]
    str     r7, [sp, #324]

    // carry6: (h6 + 2^25) >> 26
    ldr     r0, [sp, #320]
    ldr     r1, [sp, #324]
    movs    r3, #0
    adds    r0, r0, r11
    adc     r1, r1, r3
    lsrs    r4, r0, #26
    lsls    r5, r1, #6
    orrs    r4, r4, r5
    lsrs    r5, r1, #26
    lsls    r2, r4, #26
    lsrs    r6, r4, #6
    lsls    r7, r5, #26
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #320]
    str     r1, [sp, #324]
    ldr     r6, [sp, #328]
    ldr     r7, [sp, #332]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #328]
    str     r7, [sp, #332]

    // carry7: (h7 + 2^24) >> 25
    ldr     r0, [sp, #328]
    ldr     r1, [sp, #332]
    movs    r3, #0
    adds    r0, r0, r12
    adc     r1, r1, r3
    lsrs    r4, r0, #25
    lsls    r5, r1, #7
    orrs    r4, r4, r5
    lsrs    r5, r1, #25
    lsls    r2, r4, #25
    lsrs    r6, r4, #7
    lsls    r7, r5, #25
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #328]
    str     r1, [sp, #332]
    ldr     r6, [sp, #336]
    ldr     r7, [sp, #340]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #336]
    str     r7, [sp, #340]

    // carry8: (h8 + 2^25) >> 26
    ldr     r0, [sp, #336]
    ldr     r1, [sp, #340]
    movs    r3, #0
    adds    r0, r0, r11
    adc     r1, r1, r3
    lsrs    r4, r0, #26
    lsls    r5, r1, #6
    orrs    r4, r4, r5
    lsrs    r5, r1, #26
    lsls    r2, r4, #26
    lsrs    r6, r4, #6
    lsls    r7, r5, #26
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #336]
    str     r1, [sp, #340]
    ldr     r6, [sp, #344]
    ldr     r7, [sp, #348]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #344]
    str     r7, [sp, #348]

    // carry9: (h9 + 2^24) >> 25
    ldr     r0, [sp, #344]
    ldr     r1, [sp, #348]
    movs    r3, #0
    adds    r0, r0, r12
    adc     r1, r1, r3
    lsrs    r4, r0, #25
    lsls    r5, r1, #7
    orrs    r4, r4, r5
    lsrs    r5, r1, #25
    lsls    r2, r4, #25
    lsrs    r6, r4, #7
    lsls    r7, r5, #25
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #344]
    str     r1, [sp, #348]

    // h0 += carry9 * 19   ; 保守正確版
    movs    r2, #19

    // p = (uint64)r4 * 19  → p_lo=r6, p_hi=r7
    umull   r6, r7, r4, r2

    // q = (uint64)r5 * 19  → q_lo=r8, q_hi=r9  （之後要左移 32 位才併入）
    umull   r8, r9, r5, r2

    // h0 += p
    ldr     r0, [sp, #272]        // h0_lo
    ldr     r1, [sp, #276]        // h0_hi
    adds    r0, r0, r6            // h0_lo += p_lo
    adcs    r1, r1, r7            // h0_hi += p_hi + carry(來自上一行)

    // h0 += (q << 32)   ⇒ 高 32 位加 q_lo，再把 q_hi 也併入（理論上應為 0，但完整保留）
    adcs    r1, r1, r8            // h0_hi += q_lo + carry
    adc     r1, r1, r9            // h0_hi += q_hi + carry

    str     r0, [sp, #272]
    str     r1, [sp, #276]

    // Step 6: second carry pass (only h0, h1).
    // carry0 again
    ldr     r0, [sp, #272]
    ldr     r1, [sp, #276]
    movs    r3, #0
    adds    r0, r0, r11
    adc     r1, r1, r3
    lsrs    r4, r0, #26
    lsls    r5, r1, #6
    orrs    r4, r4, r5
    lsrs    r5, r1, #26
    lsls    r2, r4, #26
    lsrs    r6, r4, #6
    lsls    r7, r5, #26
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #272]
    str     r1, [sp, #276]
    ldr     r6, [sp, #280]
    ldr     r7, [sp, #284]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #280]
    str     r7, [sp, #284]

    // carry1 again
    ldr     r0, [sp, #280]
    ldr     r1, [sp, #284]
    movs    r3, #0
    adds    r0, r0, r12
    adc     r1, r1, r3
    lsrs    r4, r0, #25
    lsls    r5, r1, #7
    orrs    r4, r4, r5
    lsrs    r5, r1, #25
    lsls    r2, r4, #25
    lsrs    r6, r4, #7
    lsls    r7, r5, #25
    orrs    r6, r6, r7
    subs    r0, r0, r2
    sbc     r1, r1, r6
    str     r0, [sp, #280]
    str     r1, [sp, #284]
    ldr     r6, [sp, #288]
    ldr     r7, [sp, #292]
    adds    r6, r6, r4
    adc     r7, r7, r5
    str     r6, [sp, #288]
    str     r7, [sp, #292]

    // Step 7: store output limbs.
    ldr     r2, [sp, #264]
    ldr     r0, [sp, #272]
    ldr     r1, [sp, #276]
    str     r0, [r2, #0]
    str     r1, [r2, #4]
    ldr     r0, [sp, #280]
    ldr     r1, [sp, #284]
    str     r0, [r2, #8]
    str     r1, [r2, #12]
    ldr     r0, [sp, #288]
    ldr     r1, [sp, #292]
    str     r0, [r2, #16]
    str     r1, [r2, #20]
    ldr     r0, [sp, #296]
    ldr     r1, [sp, #300]
    str     r0, [r2, #24]
    str     r1, [r2, #28]
    ldr     r0, [sp, #304]
    ldr     r1, [sp, #308]
    str     r0, [r2, #32]
    str     r1, [r2, #36]
    ldr     r0, [sp, #312]
    ldr     r1, [sp, #316]
    str     r0, [r2, #40]
    str     r1, [r2, #44]
    ldr     r0, [sp, #320]
    ldr     r1, [sp, #324]
    str     r0, [r2, #48]
    str     r1, [r2, #52]
    ldr     r0, [sp, #328]
    ldr     r1, [sp, #332]
    str     r0, [r2, #56]
    str     r1, [r2, #60]
    ldr     r0, [sp, #336]
    ldr     r1, [sp, #340]
    str     r0, [r2, #64]
    str     r1, [r2, #68]
    ldr     r0, [sp, #344]
    ldr     r1, [sp, #348]
    str     r0, [r2, #72]
    str     r1, [r2, #76]

    add     sp, sp, #352
    add     sp, sp, #4
    pop     {r4-r11, pc}

.size fe25519_mul_core_s, .-fe25519_mul_core_s
