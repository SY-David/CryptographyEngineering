#include <stdio.h>
#include "fe25519.h"
#include <string.h>
#include "hal.h"
const fe25519 fe25519_zero = {{0}};
const fe25519 fe25519_one = {{1}};
const fe25519 fe25519_two = {{2}};

const fe25519 fe25519_sqrtm1 = {{0xB0, 0xA0, 0x0E, 0x4A, 0x27, 0x1B, 0xEE, 0xC4, 0x78, 0xE4, 0x2F, 0xAD, 0x06, 0x18, 0x43, 0x2F,
                                 0xA7, 0xD7, 0xFB, 0x3D, 0x99, 0x00, 0x4D, 0x2B, 0x0B, 0xDF, 0xC1, 0x4F, 0x80, 0x24, 0x83, 0x2B}};

const fe25519 fe25519_msqrtm1 = {{0x3D, 0x5F, 0xF1, 0xB5, 0xD8, 0xE4, 0x11, 0x3B, 0x87, 0x1B, 0xD0, 0x52, 0xF9, 0xE7, 0xBC, 0xD0,
                                  0x58, 0x28, 0x4, 0xC2, 0x66, 0xFF, 0xB2, 0xD4, 0xF4, 0x20, 0x3E, 0xB0, 0x7F, 0xDB, 0x7C, 0x54}};

const fe25519 fe25519_m1 = {{236, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                             0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f}};
static inline void fe25519_pack_nofreeze(unsigned char r[32],
                                         const fe25519 *x)
{
  for (int i = 0; i < 32; i++)
    r[i] = (unsigned char)x->v[i];
}
static uint32_t equal(uint32_t a, uint32_t b)
{
  uint32_t x = a ^ b;
  x -= 1;
  x >>= 31;
  return x;
}

static uint32_t ge(uint32_t a, uint32_t b)
{
  uint32_t x = a;
  x -= (uint32_t)b;
  x >>= 31;
  x ^= 1;
  return x;
}

static uint32_t times19(uint32_t a)
{
  return (a << 4) + (a << 1) + a;
}

static uint32_t times38(uint32_t a)
{
  return (a << 5) + (a << 2) + (a << 1);
}

static void reduce_add_sub(fe25519 *r)
{
  uint32_t t;
  int i, rep;

  for (rep = 0; rep < 2; rep++)
  {
    t = r->v[31] >> 7;
    r->v[31] &= 127;
    t = times19(t);
    r->v[0] += t;
    for (i = 0; i < 31; i++)
    {
      t = r->v[i] >> 8;
      r->v[i + 1] += t;
      r->v[i] &= 255;
    }
  }
}

static void reduce_mul(fe25519 *r)
{
  uint32_t t;
  int i, rep;

  for (rep = 0; rep < 3; rep++)
  {
    t = r->v[31] >> 7;
    r->v[31] &= 127;
    t = times19(t);
    r->v[0] += t;
    for (i = 0; i < 31; i++)
    {
      t = r->v[i] >> 8;
      r->v[i + 1] += t;
      r->v[i] &= 255;
    }
  }
}

static inline uint32_t load4(const unsigned char *s)
{
  return ((uint32_t)s[0]) |
         ((uint32_t)s[1] << 8) |
         ((uint32_t)s[2] << 16) |
         ((uint32_t)s[3] << 24);
}

static void contract_limbs(unsigned char out[32], const int64_t in[10])
{
  int64_t f[10];
  for (int i = 0; i < 10; ++i)
  {
    f[i] = in[i];
  }

#define REDUCE_MASK_26 ((int64_t)((1 << 26) - 1))
#define REDUCE_MASK_25 ((int64_t)((1 << 25) - 1))

#define CARRY_PASS()        \
  do                        \
  {                         \
    f[1] += f[0] >> 26;     \
    f[0] &= REDUCE_MASK_26; \
    f[2] += f[1] >> 25;     \
    f[1] &= REDUCE_MASK_25; \
    f[3] += f[2] >> 26;     \
    f[2] &= REDUCE_MASK_26; \
    f[4] += f[3] >> 25;     \
    f[3] &= REDUCE_MASK_25; \
    f[5] += f[4] >> 26;     \
    f[4] &= REDUCE_MASK_26; \
    f[6] += f[5] >> 25;     \
    f[5] &= REDUCE_MASK_25; \
    f[7] += f[6] >> 26;     \
    f[6] &= REDUCE_MASK_26; \
    f[8] += f[7] >> 25;     \
    f[7] &= REDUCE_MASK_25; \
    f[9] += f[8] >> 26;     \
    f[8] &= REDUCE_MASK_26; \
  } while (0)

#define CARRY_PASS_FULL()      \
  do                           \
  {                            \
    CARRY_PASS();              \
    f[0] += 19 * (f[9] >> 25); \
    f[9] &= REDUCE_MASK_25;    \
  } while (0)

#define CARRY_PASS_FINAL()  \
  do                        \
  {                         \
    CARRY_PASS();           \
    f[9] &= REDUCE_MASK_25; \
  } while (0)

  CARRY_PASS_FULL();
  CARRY_PASS_FULL();

  f[0] += 19;
  CARRY_PASS_FULL();

  f[0] += ((int64_t)1 << 26) - 19;
  f[1] += ((int64_t)1 << 25) - 1;
  f[2] += ((int64_t)1 << 26) - 1;
  f[3] += ((int64_t)1 << 25) - 1;
  f[4] += ((int64_t)1 << 26) - 1;
  f[5] += ((int64_t)1 << 25) - 1;
  f[6] += ((int64_t)1 << 26) - 1;
  f[7] += ((int64_t)1 << 25) - 1;
  f[8] += ((int64_t)1 << 26) - 1;
  f[9] += ((int64_t)1 << 25) - 1;

  CARRY_PASS_FINAL();

#undef CARRY_PASS
#undef CARRY_PASS_FULL
#undef CARRY_PASS_FINAL
#undef REDUCE_MASK_26
#undef REDUCE_MASK_25

  f[1] <<= 2;
  f[2] <<= 3;
  f[3] <<= 5;
  f[4] <<= 6;
  f[6] <<= 1;
  f[7] <<= 3;
  f[8] <<= 4;
  f[9] <<= 6;

  for (int i = 0; i < 32; ++i)
  {
    out[i] = 0;
  }

#define STORE_LIMB(i, offset)                               \
  do                                                        \
  {                                                         \
    out[offset + 0] |= (unsigned char)(f[i] & 0xff);        \
    out[offset + 1] = (unsigned char)((f[i] >> 8) & 0xff);  \
    out[offset + 2] = (unsigned char)((f[i] >> 16) & 0xff); \
    out[offset + 3] = (unsigned char)((f[i] >> 24) & 0xff); \
  } while (0)

  STORE_LIMB(0, 0);
  STORE_LIMB(1, 3);
  STORE_LIMB(2, 6);
  STORE_LIMB(3, 9);
  STORE_LIMB(4, 12);
  STORE_LIMB(5, 16);
  STORE_LIMB(6, 19);
  STORE_LIMB(7, 22);
  STORE_LIMB(8, 25);
  STORE_LIMB(9, 28);

#undef STORE_LIMB
}

void fe25519_freeze(fe25519 *r)
{
  int i;
  uint32_t m = equal(r->v[31], 127);
  for (i = 30; i > 0; i--)
    m &= equal(r->v[i], 255);
  m &= ge(r->v[0], 237);

  m = -m;

  r->v[31] -= m & 127;
  for (i = 30; i > 0; i--)
    r->v[i] -= m & 255;
  r->v[0] -= m & 237;
}

void fe25519_unpack(fe25519 *r, const unsigned char x[32])
{
  int i;
  for (i = 0; i < 32; i++)
    r->v[i] = x[i];
  r->v[31] &= 127;
}

void fe25519_pack(unsigned char r[32], const fe25519 *x)
{
  int i;
  fe25519 y = *x;
  fe25519_freeze(&y);
  for (i = 0; i < 32; i++)
    r[i] = y.v[i];
}

int fe25519_iszero(const fe25519 *x)
{
  return fe25519_iseq(x, &fe25519_zero);
}

int fe25519_isone(const fe25519 *x)
{
  return fe25519_iseq(x, &fe25519_one);
}

int fe25519_isnegative(const fe25519 *x)
{
  fe25519 t = *x;

  fe25519_freeze(&t);

  return t.v[0] & 1;
}

int fe25519_iseq(const fe25519 *x, const fe25519 *y)
{
  fe25519 t1, t2;
  int i, r = 0;

  t1 = *x;
  t2 = *y;
  fe25519_freeze(&t1);
  fe25519_freeze(&t2);
  for (i = 0; i < 32; i++)
    r |= (1 - equal(t1.v[i], t2.v[i]));
  return 1 - r;
}

void fe25519_cmov(fe25519 *r, const fe25519 *x, unsigned char b)
{

  uint32_t mask = 0u - (uint32_t)(b & 1u);
  for (int i = 0; i < 32; ++i)
  {
    uint32_t ri = r->v[i];
    uint32_t xi = x->v[i];
    r->v[i] = ri ^ (mask & (ri ^ xi));
  }
}

void fe25519_cswap(fe25519 *a, fe25519 *b, unsigned char bit)
{
  uint32_t mask = 0u - (uint32_t)(bit & 1u);
  for (int i = 0; i < 32; ++i)
  {
    uint32_t t = mask & (a->v[i] ^ b->v[i]);
    a->v[i] ^= t;
    b->v[i] ^= t;
  }
}

void fe25519_neg(fe25519 *r, const fe25519 *x)
{
  fe25519 t = fe25519_zero;
  fe25519_sub(r, &t, x);
}

void fe25519_add(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  int i;
  for (i = 0; i < 32; i++)
    r->v[i] = x->v[i] + y->v[i];
  reduce_add_sub(r);
}

void fe25519_double(fe25519 *r, const fe25519 *x)
{
  int i;
  for (i = 0; i < 32; i++)
    r->v[i] = 2 * x->v[i];
  reduce_add_sub(r);
}

void fe25519_sub(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  int i;
  uint32_t t[32];
  t[0] = x->v[0] + 0x1da;
  t[31] = x->v[31] + 0xfe;
  for (i = 1; i < 31; i++)
    t[i] = x->v[i] + 0x1fe;
  for (i = 0; i < 32; i++)
    r->v[i] = t[i] - y->v[i];
  reduce_add_sub(r);
}
extern void fe25519_mul_core_s(const unsigned char *a, const unsigned char *b, int64_t *h);

void fe25519_mul(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  unsigned char a[32];
  unsigned char b[32];

  fe25519_pack_nofreeze(a, x);
  fe25519_pack_nofreeze(b, y);

  int64_t h[10];
  fe25519_mul_core_s(a, b, h);

  unsigned char s[32];
  contract_limbs(s, h);

  for (int i = 0; i < 32; ++i)
  {
    r->v[i] = s[i];
  }
}
extern void fe25519_square_core_s(const unsigned char *a,
                                  int64_t h[10]);

void fe25519_square(fe25519 *r, const fe25519 *x)
{
  unsigned char a[32];

  fe25519_pack_nofreeze(a, x);

  int64_t h_asm[10];

  fe25519_square_core_s(a, h_asm); // 彙編版

  unsigned char s[32];
  contract_limbs(s, h_asm);

  for (int i = 0; i < 32; ++i)
  {
    r->v[i] = s[i];
  }
}

void fe25519_pow2523(fe25519 *r, const fe25519 *x)
{
  fe25519 z2;
  fe25519 z9;
  fe25519 z11;
  fe25519 z2_5_0;
  fe25519 z2_10_0;
  fe25519 z2_20_0;
  fe25519 z2_50_0;
  fe25519 z2_100_0;
  fe25519 t;
  int i;

  fe25519_square(&z2, x);
  fe25519_square(&t, &z2);
  fe25519_square(&t, &t);
  fe25519_mul(&z9, &t, x);
  fe25519_mul(&z11, &z9, &z2);
  fe25519_square(&t, &z11);
  fe25519_mul(&z2_5_0, &t, &z9);

  fe25519_square(&t, &z2_5_0);
  for (i = 1; i < 5; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&z2_10_0, &t, &z2_5_0);

  fe25519_square(&t, &z2_10_0);
  for (i = 1; i < 10; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&z2_20_0, &t, &z2_10_0);

  fe25519_square(&t, &z2_20_0);
  for (i = 1; i < 20; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&t, &t, &z2_20_0);

  fe25519_square(&t, &t);
  for (i = 1; i < 10; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&z2_50_0, &t, &z2_10_0);

  fe25519_square(&t, &z2_50_0);
  for (i = 1; i < 50; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&z2_100_0, &t, &z2_50_0);

  fe25519_square(&t, &z2_100_0);
  for (i = 1; i < 100; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&t, &t, &z2_100_0);

  fe25519_square(&t, &t);
  for (i = 1; i < 50; i++)
  {
    fe25519_square(&t, &t);
  }
  fe25519_mul(&t, &t, &z2_50_0);

  fe25519_square(&t, &t);
  fe25519_square(&t, &t);
  fe25519_mul(r, &t, x);
}

void fe25519_invsqrt(fe25519 *r, const fe25519 *x)
{
  fe25519 den2, den3, den4, den6, chk, t, t2;
  int b;

  fe25519_square(&den2, x);
  fe25519_mul(&den3, &den2, x);

  fe25519_square(&den4, &den2);
  fe25519_mul(&den6, &den2, &den4);
  fe25519_mul(&t, &den6, x);

  fe25519_pow2523(&t, &t);
  fe25519_mul(&t, &t, &den3);

  fe25519_square(&chk, &t);
  fe25519_mul(&chk, &chk, x);

  fe25519_mul(&t2, &t, &fe25519_sqrtm1);
  b = 1 - fe25519_isone(&chk);

  fe25519_cmov(&t, &t2, b);

  *r = t;
}