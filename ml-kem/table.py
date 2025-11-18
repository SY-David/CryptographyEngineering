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
    # 計算 omega 的反元素 (256th root)
    omega_inv = pow(omega, KYBER_Q - 2, KYBER_Q)

    layers = []

    # 您的需求是從 stride 64, 32... 到 1
    # 這意味著我們只需要生成 8 層 (Layer 0 到 Layer 7)
    # Layer 7 的數量是 128，stride 是 1

    num_layers = 8  # 0~7

    for layer in range(num_layers):

        num_zetas = 1 << layer

        # 核心修改：您的序列顯示 Stride 是以 128 為基準除的
        # Layer 0: 128 // 1 = 128 (雖然只有一個元素0，但邏輯一致)
        # Layer 1: 128 // 2 = 64  (0, 64)
        # Layer 2: 128 // 4 = 32  (0, 32, 64, 96)
        if num_zetas == 0:
            stride = 0
        else:
            stride = 128 // num_zetas

        cur = []

        for k in range(num_zetas):

            # 線性增長
            power = k * stride

            w = pow(omega_inv, power, KYBER_Q)

            w = (w * MONT) % KYBER_Q
            w = center_mod_q(w)
            cur.append(w)

        layers.append(cur)

    return layers


layers = generate_ct_inverse_omegas_linear_128()

# 因為實際上只生成了 8 層 (對應到 128 個元素)，所以宣告改為 [8][128] 比較安全
# 但如果您程式碼其他地方 hardcode 了 9，這裡也可以保留 9，最後一層會是空的
print("static const int16_t inv_zetas[8][128] = {")

for i, L in enumerate(layers):
    # 顯示 Stride 方便驗證
    stride_info = 128 // (1 << i)
    print(f"  // Layer {i}: {len(L)} elements (Stride {stride_info})")

    print("  {" + ", ".join(map(str, L)) + "},")

print("};")
