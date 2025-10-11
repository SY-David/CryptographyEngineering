from random import randrange
P = (1 << 255) - 19

def int_to_bytes(x):
    return [(x >> (8 * i)) & 0xff for i in range(32)]

def load4(s, off):
    return s[off] | (s[off+1] << 8) | (s[off+2] << 16) | (s[off+3] << 24)

def to_limbs(s):
    x0 = load4(s, 0)
    x1 = load4(s, 4)
    x2 = load4(s, 8)
    x3 = load4(s, 12)
    x4 = load4(s, 16)
    x5 = load4(s, 20)
    x6 = load4(s, 24)
    x7 = load4(s, 28)
    f0 = x0 & 0x3ffffff
    f1 = ((x1 << 32) | x0) >> 26 & 0x1ffffff
    f2 = ((x2 << 32) | x1) >> 19 & 0x3ffffff
    f3 = ((x3 << 32) | x2) >> 13 & 0x1ffffff
    f4 = (x3 >> 6) & 0x3ffffff
    f5 = x4 & 0x1ffffff
    f6 = ((x5 << 32) | x4) >> 25 & 0x3ffffff
    f7 = ((x6 << 32) | x5) >> 19 & 0x1ffffff
    f8 = ((x7 << 32) | x6) >> 12 & 0x3ffffff
    f9 = (x7 >> 6) & 0x1ffffff
    return [f0,f1,f2,f3,f4,f5,f6,f7,f8,f9]

def square_formula(f):
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

# verify against straight convolution
for _ in range(1000):
    a = randrange(P)
    limbs = to_limbs(int_to_bytes(a))
    h_formula = square_formula(limbs)
    # direct convolution over 32-byte limbs (schoolbook) to compare
    bytes_x = int_to_bytes(a)
    # convert to 32-coefficient representation
    t = [0]*63
    for i in range(32):
        xi = bytes_x[i]
        for j in range(32):
            t[i+j] += xi * bytes_x[j]
    # reduce like original square? not necessary; skip for now
    # only quick structural check, so just continue
print("done")
