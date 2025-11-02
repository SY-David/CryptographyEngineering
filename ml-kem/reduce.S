.syntax unified
.thumb
.text
.global montgomery
montgomery:
    smulbb  r0, r0, r1
    movw    r2, #3327
    smulbb  r3, r0, r2
    movw    r2, #3329
    smlabb  r0, r3, r2, r0
    asr     r0, r0, #16
    bx      lr
