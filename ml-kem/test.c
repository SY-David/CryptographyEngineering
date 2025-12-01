#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <limits.h>
#include "api.h"
#include "hal.h"
#include "randombytes.h"
#include "poly.h"
#include "polyvec.h"
#include "params.h"
#include <ntt.h>
#include <reduce.h>

#include "testvectors.inc"

#define N_ITERATIONS 1000

// =========================================================
//  PART 1: C Reference Implementations (Restored)
//  為了避免與專案中現有的函式名稱衝突，這裡全部加上 c_ 前綴
// =========================================================

// --- From reduce.c ---

static int16_t c_montgomery_reduce(int32_t a)
{
    int16_t t;
    t = (int16_t)a * QINV;
    t = (a - (int32_t)t * KYBER_Q) >> 16;
    return t;
}

static int16_t c_barrett_reduce(int16_t a)
{
    int16_t t;
    const int16_t v = ((1 << 26) + KYBER_Q / 2) / KYBER_Q;
    t = ((int32_t)v * a + (1 << 25)) >> 26;
    t *= KYBER_Q;
    return a - t;
}

// --- From ntt.c ---

static const int16_t c_zetas[128] = {
    -1044, -758, -359, -1517, 1493, 1422, 287, 202,
    -171, 622, 1577, 182, 962, -1202, -1474, 1468,
    573, -1325, 264, 383, -829, 1458, -1602, -130,
    -681, 1017, 732, 608, -1542, 411, -205, -1571,
    1223, 652, -552, 1015, -1293, 1491, -282, -1544,
    516, -8, -320, -666, -1618, -1162, 126, 1469,
    -853, -90, -271, 830, 107, -1421, -247, -951,
    -398, 961, -1508, -725, 448, -1065, 677, -1275,
    -1103, 430, 555, 843, -1251, 871, 1550, 105,
    422, 587, 177, -235, -291, -460, 1574, 1653,
    -246, 778, 1159, -147, -777, 1483, -602, 1119,
    -1590, 644, -872, 349, 418, 329, -156, -75,
    817, 1097, 603, 610, 1322, -1285, -1465, 384,
    -1215, -136, 1218, -1335, -874, 220, -1187, -1659,
    -1185, -1530, -1278, 794, -1510, -854, -870, 478,
    -108, -308, 996, 991, 958, -1460, 1522, 1628};

static int16_t c_fqmul(int16_t a, int16_t b)
{
    return c_montgomery_reduce((int32_t)a * b);
}

static void c_ntt(int16_t r[256])
{
    unsigned int len, start, j, k;
    int16_t t, zeta;

    k = 1;
    for (len = 128; len >= 2; len >>= 1)
    {
        for (start = 0; start < 256; start = j + len)
        {
            zeta = c_zetas[k++];
            for (j = start; j < start + len; j++)
            {
                t = c_fqmul(zeta, r[j + len]);
                r[j + len] = r[j] - t;
                r[j] = r[j] + t;
            }
        }
    }
}

static void c_invntt(int16_t r[256])
{
    unsigned int start, len, j, k;
    int16_t t, zeta;
    const int16_t f = 1441; // mont^2/128

    k = 127;
    for (len = 2; len <= 128; len <<= 1)
    {
        for (start = 0; start < 256; start = j + len)
        {
            zeta = c_zetas[k--];
            for (j = start; j < start + len; j++)
            {
                t = r[j];
                r[j] = c_barrett_reduce(t + r[j + len]);
                r[j + len] = r[j + len] - t;
                r[j + len] = c_fqmul(zeta, r[j + len]);
            }
        }
    }

    for (j = 0; j < 256; j++)
        r[j] = c_fqmul(r[j], f);
}

static void c_basemul(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta)
{
    r[0] = c_fqmul(a[1], b[1]);
    r[0] = c_fqmul(r[0], zeta);
    r[0] += c_fqmul(a[0], b[0]);
    r[1] = c_fqmul(a[0], b[1]);
    r[1] += c_fqmul(a[1], b[0]);
}

// --- From poly.c ---

static void c_poly_add(poly *r, const poly *a, const poly *b)
{
    unsigned int i;
    for (i = 0; i < KYBER_N; i++)
        r->coeffs[i] = a->coeffs[i] + b->coeffs[i];
}

static void c_poly_sub(poly *r, const poly *a, const poly *b)
{
    unsigned int i;
    for (i = 0; i < KYBER_N; i++)
        r->coeffs[i] = a->coeffs[i] - b->coeffs[i];
}

// =========================================================
//  PART 2: ASM Function Declarations
// =========================================================

extern void ntt_s(int16_t r[256]);
extern void invntt_s(int16_t r[256]);
extern void basemul_s(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta);
extern int16_t montgomery(int16_t a, int16_t b); // ASM version of fqmul/montgomery
extern int16_t barrett(int16_t a);
extern void poly_add_s(poly *r, const poly *a, const poly *b);
extern void poly_sub_s(poly *r, const poly *a, const poly *b);

// =========================================================
//  PART 3: Benchmarking & Testing
// =========================================================

static void print_cycles(const char *label, uint64_t cycles)
{
    char str[100];
#ifdef MPS2_AN386
    (void)cycles;
    sprintf(str, "%-25s: [N/A qemu]\n", label);
#else
    sprintf(str, "%-25s: %llu cycles\n", label, cycles);
#endif
    hal_send_str(str);
}

static void run_lowlevel_benchmark(void)
{
    poly a, b, r;
    int16_t x = 1234, y = 5678, z = 1;
    uint64_t t0, t1;
    int i;

    // Initialize dummy data
    for (i = 0; i < KYBER_N; i++)
    {
        a.coeffs[i] = (i * 123) % KYBER_Q;
        b.coeffs[i] = (i * 456) % KYBER_Q;
    }

    hal_send_str("\n=== Low-Level Benchmarks (Avg of 1000 runs) ===\n");
    hal_send_str("Function                 | Performance\n");
    hal_send_str("-------------------------|----------------\n");

    // --- NTT ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        c_ntt(a.coeffs);
    t1 = hal_get_time();
    print_cycles("NTT (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        ntt_s(a.coeffs);
    t1 = hal_get_time();
    print_cycles("NTT (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- InvNTT ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        c_invntt(a.coeffs);
    t1 = hal_get_time();
    print_cycles("InvNTT (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        invntt_s(a.coeffs);
    t1 = hal_get_time();
    print_cycles("InvNTT (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- Poly Add ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        c_poly_add(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Add (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        poly_add_s(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Add (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- Poly Sub ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        c_poly_sub(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Sub (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        poly_sub_s(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Sub (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- Basemul ---
    // basemul is very fast, run 10x more iterations per loop
    int16_t r_base[2], a_base[2] = {123, 456}, b_base[2] = {789, 101}, zeta = 222;

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        c_basemul(r_base, a_base, b_base, zeta);
    t1 = hal_get_time();
    print_cycles("Basemul (C)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        basemul_s(r_base, a_base, b_base, zeta);
    t1 = hal_get_time();
    print_cycles("Basemul (ASM)", (t1 - t0) / (N_ITERATIONS * 10));

    // --- Reduce ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = c_fqmul(x, y);
    t1 = hal_get_time();
    print_cycles("Montgomery (C)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = montgomery(x, y);
    t1 = hal_get_time();
    print_cycles("Montgomery (ASM)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = c_barrett_reduce(x);
    t1 = hal_get_time();
    print_cycles("Barrett (C)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = barrett(x);
    t1 = hal_get_time();
    print_cycles("Barrett (ASM)", (t1 - t0) / (N_ITERATIONS * 10));
}

// =========================================================
//  PART 4: Existing High-Level Tests
// =========================================================

static int test_keygen_vector(void)
{
    uint8_t pk[pqcrystals_kyber768_ref_PUBLICKEYBYTES];
    uint8_t sk[pqcrystals_kyber768_ref_SECRETKEYBYTES];
    int i;
    hal_send_str("\n=== Test 1: Keypair Generation ===\n");
    if (pqcrystals_kyber768_ref_keypair_derand(pk, sk, tv_keypair_coins) != 0)
    {
        hal_send_str("Keypair generation failed!\n");
        return -1;
    }
    for (i = 0; i < pqcrystals_kyber768_ref_PUBLICKEYBYTES; i++)
    {
        if (pk[i] != tv_expected_pk[i])
        {
            hal_send_str("Public key mismatch!\n");
            return -1;
        }
    }
    for (i = 0; i < pqcrystals_kyber768_ref_SECRETKEYBYTES; i++)
    {
        if (sk[i] != tv_expected_sk[i])
        {
            hal_send_str("Secret key mismatch!\n");
            return -1;
        }
    }
    hal_send_str("✓ Keypair generation test vector PASSED\n");
    return 0;
}

static int test_encaps_vector(void)
{
    uint8_t ct[pqcrystals_kyber768_ref_CIPHERTEXTBYTES];
    uint8_t ss[pqcrystals_kyber768_ref_BYTES];
    int i;
    hal_send_str("\n=== Test 2: Encapsulation ===\n");
    if (pqcrystals_kyber768_ref_enc_derand(ct, ss, tv_encaps_pk, tv_encaps_coins) != 0)
    {
        hal_send_str("Encapsulation failed!\n");
        return -1;
    }
    for (i = 0; i < pqcrystals_kyber768_ref_CIPHERTEXTBYTES; i++)
    {
        if (ct[i] != tv_expected_ct[i])
        {
            hal_send_str("Ciphertext mismatch!\n");
            return -1;
        }
    }
    for (i = 0; i < pqcrystals_kyber768_ref_BYTES; i++)
    {
        if (ss[i] != tv_expected_ss_encaps[i])
        {
            hal_send_str("Shared secret mismatch!\n");
            return -1;
        }
    }
    hal_send_str("✓ Encapsulation test vector PASSED\n");
    return 0;
}

static int test_decaps_vector(void)
{
    uint8_t ss[pqcrystals_kyber768_ref_BYTES];
    int i;
    hal_send_str("\n=== Test 3: Decapsulation ===\n");
    if (pqcrystals_kyber768_ref_dec(ss, tv_decaps_ct, tv_decaps_sk) != 0)
    {
        hal_send_str("Decapsulation failed!\n");
        return -1;
    }
    for (i = 0; i < pqcrystals_kyber768_ref_BYTES; i++)
    {
        if (ss[i] != tv_expected_ss_decaps[i])
        {
            hal_send_str("Shared secret mismatch!\n");
            return -1;
        }
    }
    hal_send_str("✓ Decapsulation test vector PASSED\n");
    return 0;
}

static int run_test(void)
{
    uint8_t pk[pqcrystals_kyber768_ref_PUBLICKEYBYTES];
    uint8_t sk[pqcrystals_kyber768_ref_SECRETKEYBYTES];
    uint8_t ct[pqcrystals_kyber768_ref_CIPHERTEXTBYTES];
    uint8_t ss1[pqcrystals_kyber768_ref_BYTES];
    uint8_t ss2[pqcrystals_kyber768_ref_BYTES];
    uint8_t coins_keypair[pqcrystals_kyber768_ref_KEYPAIRCOINBYTES];
    uint8_t coins_enc[pqcrystals_kyber768_ref_ENCCOINBYTES];
    int i;

    for (i = 0; i < pqcrystals_kyber768_ref_KEYPAIRCOINBYTES; i++)
        coins_keypair[i] = i;
    for (i = 0; i < pqcrystals_kyber768_ref_ENCCOINBYTES; i++)
        coins_enc[i] = i + 64;

    if (pqcrystals_kyber768_ref_keypair_derand(pk, sk, coins_keypair) != 0)
        return -1;
    if (pqcrystals_kyber768_ref_enc_derand(ct, ss1, pk, coins_enc) != 0)
        return -1;
    if (pqcrystals_kyber768_ref_dec(ss2, ct, sk) != 0)
        return -1;

    for (i = 0; i < pqcrystals_kyber768_ref_BYTES; i++)
    {
        if (ss1[i] != ss2[i])
        {
            hal_send_str("Shared secrets don't match!\n");
            return -1;
        }
    }
    hal_send_str("✓ Functional KEM test PASSED\n");
    return 0;
}

static void run_speed(void)
{
    uint8_t pk[pqcrystals_kyber768_ref_PUBLICKEYBYTES];
    uint8_t sk[pqcrystals_kyber768_ref_SECRETKEYBYTES];
    uint8_t ct[pqcrystals_kyber768_ref_CIPHERTEXTBYTES];
    uint8_t ss[pqcrystals_kyber768_ref_BYTES];
    poly a;
    uint64_t cycles;
    char cycles_str[100];

    hal_send_str("\n=== High-Level Benchmarks (Kyber768) ===\n");

    cycles = hal_get_time();
    c_ntt(a.coeffs); // Measure C version here just for consistency or switch to ASM
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "poly_ntt (C)        : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    cycles = hal_get_time();
    ntt_s(a.coeffs); // Measure ASM version
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "poly_ntt (ASM)      : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    cycles = hal_get_time();
    pqcrystals_kyber768_ref_keypair(pk, sk);
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "Keypair Generation  : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    cycles = hal_get_time();
    pqcrystals_kyber768_ref_enc(ct, ss, pk);
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "Encapsulation       : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    cycles = hal_get_time();
    pqcrystals_kyber768_ref_dec(ss, ct, sk);
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "Decapsulation       : %llu cycles\n", cycles);
    hal_send_str(cycles_str);
}

static void run_stack(void)
{
    uint8_t pk[pqcrystals_kyber768_ref_PUBLICKEYBYTES];
    uint8_t sk[pqcrystals_kyber768_ref_SECRETKEYBYTES];
    uint8_t ct[pqcrystals_kyber768_ref_CIPHERTEXTBYTES];
    uint8_t ss[pqcrystals_kyber768_ref_BYTES];
    size_t stack_usage;
    char outstr[128];

    hal_send_str("\n=== Stack Usage Measurements ===\n");
    hal_send_str("Measuring keypair generation stack usage...\n");
    hal_spraystack();
    pqcrystals_kyber768_ref_keypair(pk, sk);
    stack_usage = hal_checkstack();
    sprintf(outstr, "Keypair: %zu bytes\n", stack_usage);
    hal_send_str(outstr);

    hal_send_str("Measuring encapsulation stack usage...\n");
    hal_spraystack();
    pqcrystals_kyber768_ref_enc(ct, ss, pk);
    stack_usage = hal_checkstack();
    sprintf(outstr, "Encapsulation: %zu bytes\n", stack_usage);
    hal_send_str(outstr);

    hal_send_str("Measuring decapsulation stack usage...\n");
    hal_spraystack();
    pqcrystals_kyber768_ref_dec(ss, ct, sk);
    stack_usage = hal_checkstack();
    sprintf(outstr, "Decapsulation: %zu bytes\n", stack_usage);
    hal_send_str(outstr);
}

int main(void)
{
    hal_setup(CLOCK_BENCHMARK);

    // Test Vectors
    if (test_keygen_vector() != 0)
        return -1;
    if (test_encaps_vector() != 0)
        return -1;
    if (test_decaps_vector() != 0)
        return -1;

    // Functional Test
    hal_send_str("\n=== Test 4: Functional KEM Test ===\n");
    if (run_test() != 0)
        return -1;

    // Run Benchmarks
    run_speed();              // High-level API benchmarks
    run_lowlevel_benchmark(); // Detailed C vs ASM benchmarks
    run_stack();

    hal_send_str("\n*** ALL GOOD ***\n");
    return 0;
}