from dataclasses import dataclass
from typing import List

# --------- Field and curve parameters ----------
p = 2**255 - 19

def inv(a: int) -> int:
    return pow(a, p - 2, p)

# Edwards25519:  a = -1,  d = -121665/121666 mod p
d = (-121665 * inv(121666)) % p
two_d = (2 * d) % p

# sqrt(-1) (p ≡ 5 mod 8)
I = pow(2, (p - 1) // 4, p)

@dataclass
class Ext:
    X: int
    Y: int
    Z: int
    T: int

# Hisil et al. 2008 (extended coordinates) addition
def add(P: Ext, Q: Ext) -> Ext:
    X1, Y1, Z1, T1 = P.X, P.Y, P.Z, P.T
    X2, Y2, Z2, T2 = Q.X, Q.Y, Q.Z, Q.T
    A = ((Y1 - X1) % p) * ((Y2 - X2) % p) % p
    B = ((Y1 + X1) % p) * ((Y2 + X2) % p) % p
    C = (T1 * two_d % p) * T2 % p
    D = (2 * Z1 % p) * Z2 % p
    E = (B - A) % p
    F = (D - C) % p
    G = (D + C) % p
    H = (B + A) % p
    X3 = (E * F) % p
    Y3 = (G * H) % p
    Z3 = (F * G) % p
    T3 = (E * H) % p
    return Ext(X3, Y3, Z3, T3)

# Hisil et al. 2008 doubling
def dbl(P: Ext) -> Ext:
    X1, Y1, Z1, T1 = P.X, P.Y, P.Z, P.T
    A = (X1 * X1) % p
    B = (Y1 * Y1) % p
    C = (2 * (Z1 * Z1 % p)) % p
    D = (-A) % p
    E = ((X1 + Y1) % p) ** 2 % p
    E = (E - A - B) % p
    G = (D + B) % p
    F = (G - C) % p
    H = (D - B) % p
    X3 = (E * F) % p
    Y3 = (G * H) % p
    Z3 = (F * G) % p
    T3 = (E * H) % p
    return Ext(X3, Y3, Z3, T3)

# Recover x from y on curve: -x^2 + y^2 = 1 + d x^2 y^2
def recover_x_from_y(y: int) -> int:
    y2 = (y * y) % p
    u = (y2 - 1) % p
    v = (d * y2 + 1) % p
    x2 = (u * inv(v)) % p
    # Tonelli-ish for p ≡ 5 mod 8
    x = pow(x2, (p + 3) // 8, p)
    if (x * x - x2) % p != 0:
        x = (x * I) % p
    # Ed25519 basepoint uses even x
    if x & 1:
        x = (-x) % p
    return x

def basepoint() -> Ext:
    y = (4 * inv(5)) % p  # y = 4/5
    x = recover_x_from_y(y)
    z = 1
    t = (x * y) % p
    return Ext(x, y, z, t)

def to_le32_bytes(x: int) -> List[int]:
    return list(x.to_bytes(32, "little"))

def emit_fe25519(val: int) -> str:
    bs = to_le32_bytes(val)
    items = ", ".join(f"0x{b:02X}" for b in bs)
    return f"{{{{{items}}}}}"  # fe25519 是 { uint32_t v[32]; }，外層再包一層

def emit_point(P: Ext) -> str:
    return "{%s, %s, %s, %s}" % (
        emit_fe25519(P.X),
        emit_fe25519(P.Y),
        emit_fe25519(P.Z),
        emit_fe25519(P.T),
    )

# --------- Build the table: 64 rows × 9 entries ---------
rows = []
P = basepoint()
for i in range(64):
    twoP = dbl(P)
    # odd multiples: 1P,3P,...,15P
    row = [P]
    acc = P
    for _ in range(1, 8):
        acc = add(acc, twoP)  # +2P
        row.append(acc)
    # 8P
    fourP = dbl(twoP)
    eightP = dbl(fourP)
    row.append(eightP)
    rows.append(row)
    # advance P ← 16P
    for _ in range(4):
        P = dbl(P)

# --------- Emit C files ---------
header = """#ifndef PRECOMP_W4_H
#define PRECOMP_W4_H
#include "group.h"
#ifdef __cplusplus
extern "C" {
#endif
extern const group_ge precomp_w4[64][9];
#ifdef __cplusplus
}
#endif
#endif
"""

with open("precomp_w4.h", "w") as f:
    f.write(header)

body_intro = """#include "group.h"
#include "precomp_w4.h"

// Layout per row i (0..63):
//   [0..7] : {1,3,5,7,9,11,13,15} * (16^i * B)
//   [8]    : 8 * (16^i * B)
const group_ge precomp_w4[64][9] = {
"""

rows_str = []
for row in rows:
    pts = ",\n    ".join(emit_point(pt) for pt in row)
    rows_str.append(f"  {{\n    {pts}\n  }}")

with open("precomp_w4.c", "w") as f:
    f.write(body_intro + ",\n".join(rows_str) + "\n};\n")

print("Done. Generated precomp_w4.h and precomp_w4.c")