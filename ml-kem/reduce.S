.syntax unified
.thumb
.thumb_func
.arch armv7e-m
.fpu fpv4-sp-d16
.text
.global montgomery
montgomery:
    stmdb.w sp!, {r4-r6, lr}
    ldr r4, =-3327
    ldr r5, =-1044
    ldr r6, =3329

    smulbb r2, r0, r1
    smulbb r3, r2, r4
    smlabb r3, r3, r6, r2
    asr r0, r3, #16
    ldmia.w sp!, {r4-r6, lr}
    bx lr
