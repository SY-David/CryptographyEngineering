#include <stdint.h>
#include "group.h"
#include "smult.h"
#include "smult_base_table.h"
static const group_ge group_ge_neutral = {{{0}},
                                          {{1}},
                                          {{1}},
                                          {{0}}};
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
    *r = group_ge_neutral;
    for (unsigned int j = 0; j < BASE_WINDOW_SIZE; ++j)
    {
        unsigned char mask = ct_eq_uint32(nibble, j);
        group_ge_cmov(r, &crypto_scalarmult_base_table[window_idx][j], mask);
    }
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

    for (int i = 0; i < BASE_WINDOW_COUNT; ++i)
    {
        int bit = i * BASE_WINDOW_BITS;
        int byte_idx = bit >> 3;
        int shift = bit & 7;
        windows[i] = (unsigned char)((e[byte_idx] >> shift) & (BASE_WINDOW_SIZE - 1));
    }

    acc = group_ge_neutral;

    for (int i = BASE_WINDOW_COUNT - 1; i >= 0; --i)
    {
        base_select_window(&selected, i, windows[i]);
        group_ge_add(&sum, &acc, &selected);
        group_ge_cmov(&acc, &sum, ct_is_nonzero(windows[i]));
    }

    group_ge_pack(pk, &acc);
    return 0;
}