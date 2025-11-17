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


def generate_ct_inverse_omegas():
    omega = KYBER_ROOT_OF_UNITY
    omega_inv = pow(omega, KYBER_Q - 2, KYBER_Q)

    layers = []
    n = 256

    for layer in range(int(log2(n))):
        m = 1 << (layer + 1)
        stride = n // m
        cur = []

        for k in range(m // 2):
            w = pow(omega_inv, k * stride, KYBER_Q)
            w = (w * MONT) % KYBER_Q
            w = center_mod_q(w)
            cur.append(w)

        layers.append(cur)

    return layers


layers = generate_ct_inverse_omegas()
for L in layers:
    print(L)
