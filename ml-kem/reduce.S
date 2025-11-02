.syntax unified
.thumb
.thumb_func
.text
.global montgomery
montgomery:
    smulbb  r2, r0, r1        @ r2 = a*b (32-bit)
    mov     r0, r2            @ 保存原乘積
    ldr     r1, =QINV         @ -3327
    smulbb  r3, r2, r1        @ r3 = r2 * QINV (低 16 bit)
    sxth    r3, r3            @ 取 t = (int16_t)r3
    ldr     r1, =KYBER_Q      @ 3329
    mls     r0, r3, r1, r0    @ r0 = r0 - t*q
    asr     r0, r0, #16
    bx      lr
