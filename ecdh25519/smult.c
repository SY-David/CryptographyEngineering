#include <stdint.h>
#include "group.h"
#include "smult.h"
#include <string.h>
#include "smult_base_table.h"

static inline unsigned char ct_is_nonzero(uint32_t x)
{
    x |= (uint32_t)(-x);
    return (unsigned char)(x >> 31);
}

static inline unsigned char ct_eq_uint32(uint32_t a, uint32_t b)
{
    return (unsigned char)(1u ^ ct_is_nonzero(a ^ b));
}

static void base_select_window(group_ge *r, int window_idx, unsigned char nibble)
{
    *r = crypto_scalarmult_base_table[window_idx][0];

    for (unsigned int j = 1; j < BASE_WINDOW_SIZE; ++j)
    {
        unsigned char mask = ct_eq_uint32(nibble, j);
        group_ge_cmov(r, &crypto_scalarmult_base_table[window_idx][j], mask);
    }
}

int crypto_scalarmult(unsigned char *ss, const unsigned char *sk, const unsigned char *pk)
{
    group_ge p, k, D, A;
    unsigned char t[32];
    int i, j = 5;

    memcpy(t, sk, 32);

    t[0] &= 248;
    t[31] &= 127;
    t[31] |= 64;

    if (group_ge_unpack(&p, pk))
    {
        return -1;
    }

    k = p;
    for (i = 31; i >= 0; i--)
    {
        for (; j >= 0; j--)
        {
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
    group_ge acc, selected, sum;

    memcpy(e, sk, GROUP_GE_PACKEDBYTES);
    e[0] &= 248;
    e[31] &= 127;
    e[31] |= 64;

    acc = group_ge_neutral;

    for (int w = BASE_WINDOW_COUNT - 1; w >= 0; --w)
    {
        int bit = w * BASE_WINDOW_BITS;
        int byte_idx = bit >> 3;
        int shift = bit & 7;
        unsigned char nibble =
            (unsigned char)((e[byte_idx] >> shift) & (BASE_WINDOW_SIZE - 1));

        base_select_window(&selected, w, nibble);
        group_ge_add(&sum, &acc, &selected);
        group_ge_cmov(&acc, &sum, ct_is_nonzero((uint32_t)nibble));
    }

    group_ge_pack(pk, &acc);
    return 0;
}