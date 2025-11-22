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


def generate_ct_inverse_omegas_linear_128():
    omega = KYBER_ROOT_OF_UNITY

    omega_inv = pow(omega, KYBER_Q - 2, KYBER_Q)

    layers = []

    num_layers = 8

    for layer in range(num_layers):

        num_zetas = 1 << layer

        if num_zetas == 0:
            stride = 0
        else:
            stride = 128 // num_zetas

        cur = []

        for k in range(num_zetas):

            power = k * stride

            w = pow(omega_inv, power, KYBER_Q)

            w = (w * MONT) % KYBER_Q
            w = center_mod_q(w)
            cur.append(w)

        layers.append(cur)

    return layers


layers = generate_ct_inverse_omegas_linear_128()


print("static const int16_t inv_zetas[8][128] = {")

for i, L in enumerate(layers):

    stride_info = 128 // (1 << i)
    print(f"  // Layer {i}: {len(L)} elements (Stride {stride_info})")

    print("  {" + ", ".join(map(str, L)) + "},")

print("};")


def generate_linear_twist_table():
    # 1. 參數設定
    omega = KYBER_ROOT_OF_UNITY
    omega_inv = pow(omega, KYBER_Q - 2, KYBER_Q)  # 1175

    # Scaling: 乘 R^2 (為了 Montgomery 運算)
    scale = (R * R) % KYBER_Q

    twist_table = []

    # 2. 生成 128 個因子，對應 Pair 0 到 Pair 127
    curr = scale
    for i in range(128):

        # 存入數值 (Linear Order)
        # Twist[0] = Scale * w^-0
        # Twist[1] = Scale * w^-1
        # ...
        val = center_mod_q(curr)
        twist_table.append(val)

        # 下一個
        curr = (curr * omega_inv) % KYBER_Q

    return twist_table


twist = generate_linear_twist_table()

print("static const int16_t twist_table[128] = {")
for i in range(0, 128, 8):
    chunk = twist[i : i + 8]

    print("  " + ", ".join(f"{x:>5}" for x in chunk) + ",")
print("};")
