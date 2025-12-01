#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <limits.h>
#include "api.h"
#include "hal.h"
#include "randombytes.h"
#include "poly.h"
#include "polyvec.h"
#include "ntt.h"
#include "reduce.h" // 需要引用 reduce.h 來使用 montgomery_reduce 等

#include "testvectors.inc"

#define N_ITERATIONS 1000

// ==========================================
// 外部 ASM 函式宣告 (來自 .S 檔案)
// ==========================================

// NTT 相關 ASM
extern void ntt_s(int16_t r[256]);
extern void invntt_s(int16_t r[256]);
extern void basemul_s(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta);

// 模運算 ASM (注意：ASM 的 montgomery 通常對應 C 的 fqmul，即乘法+縮減)
extern int16_t montgomery(int16_t a, int16_t b);
extern int16_t barrett(int16_t a);

// 多項式運算 ASM
extern void poly_add_s(poly *r, const poly *a, const poly *b);
extern void poly_sub_s(poly *r, const poly *a, const poly *b);
extern void poly_compress_s(uint8_t *r, poly *a); // 假設 KYBER_K=3 (Kyber768)
extern void poly_decompress_s(poly *r, const uint8_t *a);

// C 語言的輔助函式 (通常是 static，為了測試可能需要在此重新定義或確保可見)
// 這裡我們直接使用 reduce.h 中的 fqmul (如果它是 static inline 則沒問題，如果是 static 則需要複製一份邏輯)
// 為了安全起見，我們手動定義一個 C 版 fqmul 用於比較
int16_t c_fqmul_wrapper(int16_t a, int16_t b)
{
    return montgomery_reduce((int32_t)a * b);
}

// ==========================================
// 原有的測試函式保持不變
// ==========================================

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

// ==========================================
// 新增：底層函數 Benchmark (C vs ASM)
// ==========================================

static void print_cycles(const char *label, uint64_t cycles)
{
    char str[100];
#ifdef MPS2_AN386
    (void)cycles;
    sprintf(str, "%-30s: [N/A qemu]\n", label);
#else
    sprintf(str, "%-30s: %llu cycles\n", label, cycles);
#endif
    hal_send_str(str);
}

static void run_lowlevel_benchmark(void)
{
    poly a, b, r;
    int16_t x = 1234, y = 5678, z = 1;
    uint64_t t0, t1;
    int i;

    // 初始化一些隨機數據
    for (i = 0; i < KYBER_N; i++)
    {
        a.coeffs[i] = (i * 123) % KYBER_Q;
        b.coeffs[i] = (i * 456) % KYBER_Q;
    }

    hal_send_str("\n=== Low-Level Benchmarks (Avg of 1000 iter) ===\n");
    hal_send_str("Function                        | Cycles\n");
    hal_send_str("--------------------------------|--------\n");

    // --- 1. NTT Benchmark ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        ntt(a.coeffs);
    t1 = hal_get_time();
    print_cycles("NTT (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        ntt_s(a.coeffs);
    t1 = hal_get_time();
    print_cycles("NTT (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- 2. Inverse NTT Benchmark ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        invntt(a.coeffs);
    t1 = hal_get_time();
    print_cycles("InvNTT (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        invntt_s(a.coeffs);
    t1 = hal_get_time();
    print_cycles("InvNTT (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- 3. Poly Add Benchmark ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        poly_add(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Add (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        poly_add_s(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Add (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- 4. Poly Sub Benchmark ---
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        poly_sub(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Sub (C)", (t1 - t0) / N_ITERATIONS);

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS; i++)
        poly_sub_s(&r, &a, &b);
    t1 = hal_get_time();
    print_cycles("Poly Sub (ASM)", (t1 - t0) / N_ITERATIONS);

    // --- 5. Base Multiplication Benchmark ---
    // basemul 只操作 2 個係數，迴圈次數加倍以獲得更穩定數據
    int16_t r_base[2];
    int16_t a_base[2] = {123, 456};
    int16_t b_base[2] = {789, 101};
    int16_t zeta = 222;

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        basemul(r_base, a_base, b_base, zeta);
    t1 = hal_get_time();
    print_cycles("Basemul (C)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        basemul_s(r_base, a_base, b_base, zeta);
    t1 = hal_get_time();
    print_cycles("Basemul (ASM)", (t1 - t0) / (N_ITERATIONS * 10));

    // --- 6. Modular Reduction Benchmark ---
    // 比較單次運算 (C: fqmul vs ASM: montgomery)
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = c_fqmul_wrapper(x, y);
    t1 = hal_get_time();
    print_cycles("Montgomery (C fqmul)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = montgomery(x, y);
    t1 = hal_get_time();
    print_cycles("Montgomery (ASM)", (t1 - t0) / (N_ITERATIONS * 10));

    // Barrett
    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = barrett_reduce(x);
    t1 = hal_get_time();
    print_cycles("Barrett (C)", (t1 - t0) / (N_ITERATIONS * 10));

    t0 = hal_get_time();
    for (i = 0; i < N_ITERATIONS * 10; i++)
        z = barrett(x);
    t1 = hal_get_time();
    print_cycles("Barrett (ASM)", (t1 - t0) / (N_ITERATIONS * 10));
}

// ==========================================
// High Level Benchmarks (原有的 run_speed)
// ==========================================
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

    // Poly NTT
    cycles = hal_get_time();
    poly_ntt(&a);
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "poly_ntt            : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    // Keypair
    cycles = hal_get_time();
    pqcrystals_kyber768_ref_keypair(pk, sk);
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "Keypair Generation  : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    // Encapsulation
    cycles = hal_get_time();
    pqcrystals_kyber768_ref_enc(ct, ss, pk);
    cycles = hal_get_time() - cycles;
    sprintf(cycles_str, "Encapsulation       : %llu cycles\n", cycles);
    hal_send_str(cycles_str);

    // Decapsulation
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
    run_speed();              // 原有的高層 API 測試
    run_lowlevel_benchmark(); // 新增的 C vs ASM 底層比較
    run_stack();

    hal_send_str("\n*** ALL GOOD ***\n");
    return 0;
}