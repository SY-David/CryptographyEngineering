#include <stdint.h>
#include "group.h"
#include "smult.h"

#define BASE_WINDOW_BITS 4
#define BASE_WINDOW_COUNT (256 / BASE_WINDOW_BITS)
#define BASE_WINDOW_SIZE (1 << BASE_WINDOW_BITS)

static const group_ge ge_identity = {{{0}},
                                     {{1}},
                                     {{1}},
                                     {{0}}};

static group_ge base_window_table[BASE_WINDOW_COUNT][BASE_WINDOW_SIZE];
static int base_window_initialized;

static unsigned char ct_is_nonzero(uint32_t x)
{
    x |= (uint32_t)(-x);
    return (unsigned char)(x >> 31);
}

static unsigned char ct_eq_uint32(uint32_t a, uint32_t b)
{
    return (unsigned char)(1u ^ ct_is_nonzero(a ^ b));
}

static void base_select_window(group_ge *r, int window_idx, unsigned char nibble)
{
    *r = ge_identity;
    for (unsigned int j = 0; j < BASE_WINDOW_SIZE; ++j)
    {
        unsigned char mask = ct_eq_uint32(nibble, j);
        group_ge_cmov(r, &base_window_table[window_idx][j], mask);
    }
}

static void base_precompute(void)
{
    if (base_window_initialized)
    {
        return;
    }

    group_ge window_base = group_ge_base;

    for (int i = 0; i < BASE_WINDOW_COUNT; ++i)
    {
        base_window_table[i][0] = ge_identity;
        base_window_table[i][1] = window_base;

        for (int j = 2; j < BASE_WINDOW_SIZE; ++j)
        {
            group_ge_add(&base_window_table[i][j], &base_window_table[i][j - 1], &window_base);
        }

        if (i + 1 < BASE_WINDOW_COUNT)
        {
            for (int d = 0; d < BASE_WINDOW_BITS; ++d)
            {
                group_ge_double(&window_base, &window_base);
            }
        }
    }

    base_window_initialized = 1;
}

int crypto_scalarmult(unsigned char *ss, const unsigned char *sk, const unsigned char *pk)
{
    group_ge p, k;
    unsigned char t[32];
    int i, j = 5;

    for (i = 0; i < 32; i++)
    {
        t[i] = sk[i];
    }

    t[0] &= 248;
    t[31] &= 127;
    t[31] |= 64;

    if (group_ge_unpack(&p, pk))
    {
        return -1; /*No need to change*/
    }

    k = p;
    for (i = 31; i >= 0; i--)
    {
        for (; j >= 0; j--)
        {
            group_ge D, A;
            group_ge_double(&D, &k);
            group_ge_add(&A, &D, &p);
            unsigned char b = (t[i] >> j) & 1u;

            group_ge_cmov(&k, &D, (unsigned char)(1u ^ b));
            group_ge_cmov(&k, &A, b);
        }
        j = 7;
    }

    group_ge_pack(ss, &k);
    return 0;
}

int crypto_scalarmult_base(unsigned char *pk, const unsigned char *sk)
{
    unsigned char e[GROUP_GE_PACKEDBYTES];
    unsigned char windows[BASE_WINDOW_COUNT];
    group_ge acc, selected, sum;

    for (int i = 0; i < GROUP_GE_PACKEDBYTES; ++i)
    {
        e[i] = sk[i];
    }

    e[0] &= 248;
    e[31] &= 127;
    e[31] |= 64;

    base_precompute();

    for (int i = 0; i < BASE_WINDOW_COUNT; ++i)
    {
        int bit = i * BASE_WINDOW_BITS;
        int byte_idx = bit >> 3;
        int shift = bit & 7;
        windows[i] = (unsigned char)((e[byte_idx] >> shift) & (BASE_WINDOW_SIZE - 1));
    }

    acc = ge_identity;

    for (int i = BASE_WINDOW_COUNT - 1; i >= 0; --i)
    {
        base_select_window(&selected, i, windows[i]);
        group_ge_add(&sum, &acc, &selected);
        group_ge_cmov(&acc, &sum, ct_is_nonzero(windows[i]));
    }

    group_ge_pack(pk, &acc);
    return 0;
}
