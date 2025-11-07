.syntax unified
.thumb
.text

.macro montgomery acc, mult, tmp
    smulbb      \acc, \acc, \mult
    smulbb      \tmp, \acc, r6         @ r6 = QINV
    smlabb      \acc, \tmp, r7, \acc   @ r7 = q
    asr         \acc, \acc, #16
.endm

.global basemul_s
.type basemul_s, %function
basemul_s:
    push        {r4-r7, lr}
    movw        r6, #0xF301           @ QINV = -3327
    movw        r7, #3329             @ q

    ldrsh       r4, [r1, #2]          @ a1
    ldrsh       r5, [r2, #2]          @ b1
    montgomery  r4, r5, r5
    montgomery  r4, r3, r5 @ r4 = fqmul(a1,b1)*zeta

    ldrsh       r5, [r1]              @ a0
    ldrsh       r3, [r2]              @ b0
    montgomery  r5, r3, r3
    add         r4, r4, r5
    strh        r4, [r0]

    ldrsh       r4, [r1]              @ reuse r4 for r1 term
    ldrsh       r5, [r2, #2]          @ b1
    montgomery  r4, r5, r5

    ldrsh       r5, [r1, #2]          @ a1
    ldrsh       r3, [r2]              @ b0
    montgomery  r5, r3, r3
    add         r4, r4, r5
    strh        r4, [r0, #2]

    pop         {r4-r7, pc}
