.syntax unified
.thumb
.text

.macro montgomery input1, input2, temp2, const1, const2
    smulbb      input1, input1, input2
    smulbb      temp2, input1, const1
    smlabb      input1, temp2, const2, input1
    asr         input1, input1, #16
.endm

.global basemul_s
.type basemul_s, %function
basemul_s:
    push        {r4-r9, lr}
    movw        r8, #3327
    movw        r9, #3329
    ldrsh       r4, [r1, #2]        @ a1
    ldrsh       r5, [r2, #2]        @ b1
    montgomery  r4, r5, r7, r8, r9
    montgomery  r4, r3, r7, r8, r9 @ r4 = fqmul(a1,b1)*zeta

    ldrsh       r5, [r1]            @ a0
    ldrsh       r6, [r2]            @ b0
    montgomery  r5, r6, r7, r8, r9
    add         r4, r4, r5
    strh        r4, [r0]

    ldrsh       r4, [r1]            @ a0
    ldrsh       r5, [r2, #2]        @ b1
    montgomery  r4, r5, r7, r8, r9

    ldrsh       r5, [r1, #2]        @ a1
    ldrsh       r6, [r2]            @ b0
    montgomery  r5, r6, r7, r8, r9
    add         r4, r4, r5
    strh        r4, [r0, #2]

    pop         {r4-r9, pc}
