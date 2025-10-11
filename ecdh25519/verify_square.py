from random import randrange
P = (1 << 255) - 19

def int_to_bytes(x):
    return [(x >> (8 * i)) & 0xff for i in range(32)]

def load3(s, off):
    return s[off] | (s[off+1] << 8) | (s[off+2] << 16)

def load4(s, off):
    return s[off] | (s[off+1] << 8) | (s[off+2] << 16) | (s[off+3] << 24)

def to_limbs(s):
    f0 = load4(s, 0) & 0x3ffffff
    f1 = (load4(s, 3) >> 2) & 0x1ffffff
    f2 = (load3(s, 6) >> 3) & 0x3ffffff
    f3 = (load3(s, 9) >> 5) & 0x1ffffff
    f4 = (load3(s, 12) >> 6) & 0x3ffffff
    f5 = load4(s, 16) & 0x1ffffff
    f6 = (load4(s, 19) >> 1) & 0x3ffffff
    f7 = (load4(s, 22) >> 3) & 0x1ffffff
    f8 = (load4(s, 25) >> 4) & 0x3ffffff
    f9 = (load3(s, 28) >> 6) & 0x1ffffff
    return [f0,f1,f2,f3,f4,f5,f6,f7,f8,f9]

def square_limbs(f):
    f0,f1,f2,f3,f4,f5,f6,f7,f8,f9 = f
    f0_2 = 2*f0
    f1_2 = 2*f1
    f2_2 = 2*f2
    f3_2 = 2*f3
    f4_2 = 2*f4
    f5_2 = 2*f5
    f6_2 = 2*f6
    f7_2 = 2*f7
    f5_38 = 38*f5
    f6_19 = 19*f6
    f7_38 = 38*f7
    f8_19 = 19*f8
    f9_38 = 38*f9
    h0 = f0*f0 + f1_2*f9_38 + f2_2*f8_19 + f3_2*f7_38 + f4_2*f6_19 + f5*f5_38
    h1 = f0_2*f1 + f2*f9_38 + f3_2*f8_19 + f4*f7_38 + f5_2*f6_19
    h2 = f0_2*f2 + f1_2*f1 + f3_2*f9_38 + f4*f8_19 + f5_2*f7_38 + f6*f6_19
    h3 = f0_2*f3 + f1_2*f2 + f4*f9_38 + f5_2*f8_19 + f6*f7_38
    h4 = f0_2*f4 + f1_2*f3 + f2*f2 + f5_2*f9_38 + f6*f8_19 + f7*f7_38
    h5 = f0_2*f5 + f1_2*f4 + f2_2*f3 + f6*f9_38 + f7_2*f8_19
    h6 = f0_2*f6 + f1_2*f5 + f2_2*f4 + f3*f3 + f7_2*f9_38 + f8*f8_19
    h7 = f0_2*f7 + f1_2*f6 + f2_2*f5 + f3_2*f4 + f8*f9_38
    h8 = f0_2*f8 + f1_2*f7 + f2_2*f6 + f3_2*f5 + f4*f4 + f9*f9_38
    h9 = f0_2*f9 + f1_2*f8 + f2_2*f7 + f3_2*f6 + f4_2*f5
    return [h0,h1,h2,h3,h4,h5,h6,h7,h8,h9]

def contract(h):
    f = h[:]
    for _ in range(2):
        carry = (f[0] + (1<<25)) >> 26
        f[1] += carry; f[0] -= carry << 26
        carry = (f[1] + (1<<24)) >> 25
        f[2] += carry; f[1] -= carry << 25
        carry = (f[2] + (1<<25)) >> 26
        f[3] += carry; f[2] -= carry << 26
        carry = (f[3] + (1<<24)) >> 25
        f[4] += carry; f[3] -= carry << 25
        carry = (f[4] + (1<<25)) >> 26
        f[5] += carry; f[4] -= carry << 26
        carry = (f[5] + (1<<24)) >> 25
        f[6] += carry; f[5] -= carry << 25
        carry = (f[6] + (1<<25)) >> 26
        f[7] += carry; f[6] -= carry << 26
        carry = (f[7] + (1<<24)) >> 25
        f[8] += carry; f[7] -= carry << 25
        carry = (f[8] + (1<<25)) >> 26
        f[9] += carry; f[8] -= carry << 26
        carry = (f[9] + (1<<24)) >> 25
        f[0] += carry * 19
        f[9] -= carry << 25
    carry = (f[0] + (1<<25)) >> 26
    f[1] += carry; f[0] -= carry << 26
    carry = (f[1] + (1<<24)) >> 25
    f[2] += carry; f[1] -= carry << 25
    return f

def limbs_to_int(f):
    shifts = [0,26,51,77,102,128,153,179,204,230]
    return sum(limb << shift for limb, shift in zip(f, shifts)) % P

for _ in range(1000):
    a = randrange(P)
    limbs = to_limbs(int_to_bytes(a))
    f = contract(square_limbs(limbs))
    if limbs_to_int(f) != (a * a) % P:
        print('Mismatch')
        break
else:
    print('ok')
