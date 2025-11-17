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


def generate_omega_inv_table_mont(omega_inv_base, n, q):

    layers = int(log2(n))
    omega_table_by_layer = []

    for layer in range(layers):
        m = 1 << (layer + 1)
        stride = n // m

        layer_omegas = []
        for k in range(m // 2):

            w_plain = pow(omega_inv_base, k * stride, q)

            w_mont = (MONT * w_plain) % q
            w_mont = center_mod_q(w_mont, q)

            layer_omegas.append(w_mont)

        omega_table_by_layer.append(layer_omegas)

    return omega_table_by_layer


omega = KYBER_ROOT_OF_UNITY
omega_inv = pow(omega, KYBER_Q - 2, KYBER_Q)

OMEGA_INV_LAYERS = generate_omega_inv_table_mont(omega_inv, 256, KYBER_Q)


def print_omega_inv_layers_c(omega_layers):
    for layer, arr in enumerate(omega_layers):
        name = f"zetas_inv_layer{layer}"
        print(f"static const int16_t {name}[{len(arr)}] = {{")

        # 每行印最多 8 個，排版比較好看
        line = "  "
        for i, val in enumerate(arr):
            line += f"{val:6d}"
            if i != len(arr) - 1:
                line += ","
            if (i + 1) % 8 == 0 and i + 1 != len(arr):
                print(line)
                line = "  "
            else:
                line += " "
        print(line)
        print("};\n")

    # 再印出 pointer table
    print("static const int16_t * const zetas_inv_layers[8] = {")
    for layer in range(len(omega_layers)):
        comma = "," if layer != len(omega_layers) - 1 else ""
        print(f"  zetas_inv_layer{layer}{comma}")
    print("};")


print_omega_inv_layers_c(OMEGA_INV_LAYERS)
