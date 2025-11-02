
.data
prime_invr:
    .word -3327
r_prime:
    .word -1044
prime:
    .word 3329
.syntax unified
.thumb
.thumb_func
.arch armv7e-m
.fpu fpv4-sp-d16
.type fe25519_square_core_s, %function
.text
montgomery:
    stmdb.w sp!, {r4-r11, lr}
    ldr r4, =prime_invr
    ldr r5, =r_prime
    ldr r6, =prime
    smulbb r2, r0, r1
    smulbb r3, r2, r4
    smlabb r3, r3, r6, r2
    asr r0, r3, #16
    ldmia.w sp!, {r4-r11, lr}
    bx lr
