from math import log2

KYBER_Q = 3329
KYBER_ROOT_OF_UNITY = 17
R = 1 << 16
MONT = R % KYBER_Q


def center_mod_q(x, q=KYBER_Q):
    if x > q // 2:
        x -= q
    if x < -q // 2:
        x += q
    return x


def generate_ct_inverse_omegas_linear_full():
    omega = KYBER_ROOT_OF_UNITY

    omega_inv = pow(omega, KYBER_Q - 2, KYBER_Q)

    layers = []
    n = 256

    for layer in range(int(log2(n)) + 1):

        num_zetas = 1 << layer
        stride = n // num_zetas

        cur = []

        for k in range(num_zetas):

            power = k * stride

            w = pow(omega_inv, power, KYBER_Q)

            w = (w * MONT) % KYBER_Q
            w = center_mod_q(w)
            cur.append(w)

        layers.append(cur)

    return layers


layers = generate_ct_inverse_omegas_linear_full()


print("static const int16_t inv_zetas[9][256] = {")

for i, L in enumerate(layers):
    print(f"  // Layer {i}: {len(L)} elements (Stride {256 // (1<<i)})")

    print("  {" + ", ".join(map(str, L)) + "},")

print("};")
