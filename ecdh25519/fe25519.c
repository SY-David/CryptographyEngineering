#include <stdio.h>
#include "fe25519.h"

const fe25519 fe25519_zero = {{0}};
const fe25519 fe25519_one = {{1}};
const fe25519 fe25519_two = {{2}};

const fe25519 fe25519_sqrtm1 = {{0xB0, 0xA0, 0x0E, 0x4A, 0x27, 0x1B, 0xEE, 0xC4, 0x78, 0xE4, 0x2F, 0xAD, 0x06, 0x18, 0x43, 0x2F,
                                 0xA7, 0xD7, 0xFB, 0x3D, 0x99, 0x00, 0x4D, 0x2B, 0x0B, 0xDF, 0xC1, 0x4F, 0x80, 0x24, 0x83, 0x2B}};

const fe25519 fe25519_msqrtm1 = {{0x3D, 0x5F, 0xF1, 0xB5, 0xD8, 0xE4, 0x11, 0x3B, 0x87, 0x1B, 0xD0, 0x52, 0xF9, 0xE7, 0xBC, 0xD0,
                                  0x58, 0x28, 0x4, 0xC2, 0x66, 0xFF, 0xB2, 0xD4, 0xF4, 0x20, 0x3E, 0xB0, 0x7F, 0xDB, 0x7C, 0x54}};

const fe25519 fe25519_m1 = {{236, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                             0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f}};

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

static inline uint64_t load4(const unsigned char *s)
{
  return ((uint64_t)s[0]) |
         ((uint64_t)s[1] << 8) |
         ((uint64_t)s[2] << 16) |
         ((uint64_t)s[3] << 24);
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

void fe25519_mul(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  unsigned char a[32];
  unsigned char b[32];

  for (int i = 0; i < 32; ++i)
  {
    a[i] = (unsigned char)(x->v[i] & 0xffu);
    b[i] = (unsigned char)(y->v[i] & 0xffu);
  }

  /* Convert to a temporary 10-limb radix-(2^25.5) form for Comba-style multiply. */
  int64_t f0 = (int64_t)(load4(a + 0) & 0x3ffffff);
  int64_t f1 = (int64_t)((load4(a + 3) >> 2) & 0x1ffffff);
  int64_t f2 = (int64_t)((load4(a + 6) >> 3) & 0x3ffffff);
  int64_t f3 = (int64_t)((load4(a + 9) >> 5) & 0x1ffffff);
  int64_t f4 = (int64_t)((load4(a + 12) >> 6) & 0x3ffffff);
  int64_t f5 = (int64_t)(load4(a + 16) & 0x1ffffff);
  int64_t f6 = (int64_t)((load4(a + 19) >> 1) & 0x3ffffff);
  int64_t f7 = (int64_t)((load4(a + 22) >> 3) & 0x1ffffff);
  int64_t f8 = (int64_t)((load4(a + 25) >> 4) & 0x3ffffff);
  int64_t f9 = (int64_t)((load4(a + 28) >> 6) & 0x1ffffff);

  int64_t g0 = (int64_t)(load4(b + 0) & 0x3ffffff);
  int64_t g1 = (int64_t)((load4(b + 3) >> 2) & 0x1ffffff);
  int64_t g2 = (int64_t)((load4(b + 6) >> 3) & 0x3ffffff);
  int64_t g3 = (int64_t)((load4(b + 9) >> 5) & 0x1ffffff);
  int64_t g4 = (int64_t)((load4(b + 12) >> 6) & 0x3ffffff);
  int64_t g5 = (int64_t)(load4(b + 16) & 0x1ffffff);
  int64_t g6 = (int64_t)((load4(b + 19) >> 1) & 0x3ffffff);
  int64_t g7 = (int64_t)((load4(b + 22) >> 3) & 0x1ffffff);
  int64_t g8 = (int64_t)((load4(b + 25) >> 4) & 0x3ffffff);
  int64_t g9 = (int64_t)((load4(b + 28) >> 6) & 0x1ffffff);

  int64_t g1_19 = 19 * g1;
  int64_t g2_19 = 19 * g2;
  int64_t g3_19 = 19 * g3;
  int64_t g4_19 = 19 * g4;
  int64_t g5_19 = 19 * g5;
  int64_t g6_19 = 19 * g6;
  int64_t g7_19 = 19 * g7;
  int64_t g8_19 = 19 * g8;
  int64_t g9_19 = 19 * g9;

  int64_t f1_2 = 2 * f1;
  int64_t f3_2 = 2 * f3;
  int64_t f5_2 = 2 * f5;
  int64_t f7_2 = 2 * f7;
  int64_t f9_2 = 2 * f9;

  int64_t h0 = f0 * g0 + f1_2 * g9_19 + f2 * g8_19 + f3_2 * g7_19 + f4 * g6_19 + f5_2 * g5_19 + f6 * g4_19 + f7_2 * g3_19 + f8 * g2_19 + f9_2 * g1_19;
  int64_t h1 = f0 * g1 + f1 * g0 + f2 * g9_19 + f3 * g8_19 + f4 * g7_19 + f5 * g6_19 + f6 * g5_19 + f7 * g4_19 + f8 * g3_19 + f9 * g2_19;
  int64_t h2 = f0 * g2 + f1_2 * g1 + f2 * g0 + f3_2 * g9_19 + f4 * g8_19 + f5_2 * g7_19 + f6 * g6_19 + f7_2 * g5_19 + f8 * g4_19 + f9_2 * g3_19;
  int64_t h3 = f0 * g3 + f1 * g2 + f2 * g1 + f3 * g0 + f4 * g9_19 + f5 * g8_19 + f6 * g7_19 + f7 * g6_19 + f8 * g5_19 + f9 * g4_19;
  int64_t h4 = f0 * g4 + f1_2 * g3 + f2 * g2 + f3_2 * g1 + f4 * g0 + f5_2 * g9_19 + f6 * g8_19 + f7_2 * g7_19 + f8 * g6_19 + f9_2 * g5_19;
  int64_t h5 = f0 * g5 + f1 * g4 + f2 * g3 + f3 * g2 + f4 * g1 + f5 * g0 + f6 * g9_19 + f7 * g8_19 + f8 * g7_19 + f9 * g6_19;
  int64_t h6 = f0 * g6 + f1_2 * g5 + f2 * g4 + f3_2 * g3 + f4 * g2 + f5_2 * g1 + f6 * g0 + f7_2 * g9_19 + f8 * g8_19 + f9_2 * g7_19;
  int64_t h7 = f0 * g7 + f1 * g6 + f2 * g5 + f3 * g4 + f4 * g3 + f5 * g2 + f6 * g1 + f7 * g0 + f8 * g9_19 + f9 * g8_19;
  int64_t h8 = f0 * g8 + f1_2 * g7 + f2 * g6 + f3_2 * g5 + f4 * g4 + f5_2 * g3 + f6 * g2 + f7_2 * g1 + f8 * g0 + f9_2 * g9_19;
  int64_t h9 = f0 * g9 + f1 * g8 + f2 * g7 + f3 * g6 + f4 * g5 + f5 * g4 + f6 * g3 + f7 * g2 + f8 * g1 + f9 * g0;

  int64_t carry0 = (h0 + ((int64_t)1 << 25)) >> 26;
  h1 += carry0;
  h0 -= carry0 << 26;
  int64_t carry1 = (h1 + ((int64_t)1 << 24)) >> 25;
  h2 += carry1;
  h1 -= carry1 << 25;
  int64_t carry2 = (h2 + ((int64_t)1 << 25)) >> 26;
  h3 += carry2;
  h2 -= carry2 << 26;
  int64_t carry3 = (h3 + ((int64_t)1 << 24)) >> 25;
  h4 += carry3;
  h3 -= carry3 << 25;
  int64_t carry4 = (h4 + ((int64_t)1 << 25)) >> 26;
  h5 += carry4;
  h4 -= carry4 << 26;
  int64_t carry5 = (h5 + ((int64_t)1 << 24)) >> 25;
  h6 += carry5;
  h5 -= carry5 << 25;
  int64_t carry6 = (h6 + ((int64_t)1 << 25)) >> 26;
  h7 += carry6;
  h6 -= carry6 << 26;
  int64_t carry7 = (h7 + ((int64_t)1 << 24)) >> 25;
  h8 += carry7;
  h7 -= carry7 << 25;
  int64_t carry8 = (h8 + ((int64_t)1 << 25)) >> 26;
  h9 += carry8;
  h8 -= carry8 << 26;
  int64_t carry9 = (h9 + ((int64_t)1 << 24)) >> 25;
  h0 += carry9 * 19;
  h9 -= carry9 << 25;

  carry0 = (h0 + ((int64_t)1 << 25)) >> 26;
  h1 += carry0;
  h0 -= carry0 << 26;
  carry1 = (h1 + ((int64_t)1 << 24)) >> 25;
  h2 += carry1;
  h1 -= carry1 << 25;

  unsigned char s[32];
  uint64_t hh0 = (uint64_t)h0;
  uint64_t hh1 = (uint64_t)h1;
  uint64_t hh2 = (uint64_t)h2;
  uint64_t hh3 = (uint64_t)h3;
  uint64_t hh4 = (uint64_t)h4;
  uint64_t hh5 = (uint64_t)h5;
  uint64_t hh6 = (uint64_t)h6;
  uint64_t hh7 = (uint64_t)h7;
  uint64_t hh8 = (uint64_t)h8;
  uint64_t hh9 = (uint64_t)h9;

  s[0] = (unsigned char)(hh0 & 0xffu);
  s[1] = (unsigned char)((hh0 >> 8) & 0xffu);
  s[2] = (unsigned char)((hh0 >> 16) & 0xffu);
  s[3] = (unsigned char)(((hh0 >> 24) | (hh1 << 2)) & 0xffu);
  s[4] = (unsigned char)((hh1 >> 6) & 0xffu);
  s[5] = (unsigned char)((hh1 >> 14) & 0xffu);
  s[6] = (unsigned char)(((hh1 >> 22) | (hh2 << 3)) & 0xffu);
  s[7] = (unsigned char)((hh2 >> 5) & 0xffu);
  s[8] = (unsigned char)((hh2 >> 13) & 0xffu);
  s[9] = (unsigned char)(((hh2 >> 21) | (hh3 << 5)) & 0xffu);
  s[10] = (unsigned char)((hh3 >> 3) & 0xffu);
  s[11] = (unsigned char)((hh3 >> 11) & 0xffu);
  s[12] = (unsigned char)(((hh3 >> 19) | (hh4 << 6)) & 0xffu);
  s[13] = (unsigned char)((hh4 >> 2) & 0xffu);
  s[14] = (unsigned char)((hh4 >> 10) & 0xffu);
  s[15] = (unsigned char)((hh4 >> 18) & 0xffu);
  s[16] = (unsigned char)(hh5 & 0xffu);
  s[17] = (unsigned char)((hh5 >> 8) & 0xffu);
  s[18] = (unsigned char)((hh5 >> 16) & 0xffu);
  s[19] = (unsigned char)(((hh5 >> 24) | (hh6 << 1)) & 0xffu);
  s[20] = (unsigned char)((hh6 >> 7) & 0xffu);
  s[21] = (unsigned char)((hh6 >> 15) & 0xffu);
  s[22] = (unsigned char)(((hh6 >> 23) | (hh7 << 3)) & 0xffu);
  s[23] = (unsigned char)((hh7 >> 5) & 0xffu);
  s[24] = (unsigned char)((hh7 >> 13) & 0xffu);
  s[25] = (unsigned char)(((hh7 >> 21) | (hh8 << 4)) & 0xffu);
  s[26] = (unsigned char)((hh8 >> 4) & 0xffu);
  s[27] = (unsigned char)((hh8 >> 12) & 0xffu);
  s[28] = (unsigned char)(((hh8 >> 20) | (hh9 << 6)) & 0xffu);
  s[29] = (unsigned char)((hh9 >> 2) & 0xffu);
  s[30] = (unsigned char)((hh9 >> 10) & 0xffu);
  s[31] = (unsigned char)((hh9 >> 18) & 0xffu);

  for (int i = 0; i < 32; ++i)
  {
    r->v[i] = s[i];
  }
}

void fe25519_square(fe25519 *r, const fe25519 *x)
{
  uint32_t t[63];

  for (int k = 0; k <= 30; k += 2)
  {
    int m = k >> 1;
    uint32_t acc = 0;
    for (int i = 0; i < m; ++i)
      acc += ((uint32_t)x->v[i] * (uint32_t)x->v[k - i]) << 1;
    uint32_t d = (uint32_t)x->v[m];
    acc += d * d;
    t[k] = acc;
  }

  for (int k = 32; k <= 62; k += 2)
  {
    int m = k >> 1;
    int i0 = k - 31;
    uint32_t acc = 0;
    for (int i = i0; i < m; ++i)
      acc += ((uint32_t)x->v[i] * (uint32_t)x->v[k - i]) << 1;
    uint32_t d = (uint32_t)x->v[m];
    acc += d * d;
    t[k] = acc;
  }

  for (int k = 1; k <= 31; k += 2)
  {
    int m = (k + 1) >> 1;
    uint32_t acc = 0;
    for (int i = 0; i < m; ++i)
      acc += ((uint32_t)x->v[i] * (uint32_t)x->v[k - i]) << 1;
    t[k] = acc;
  }

  for (int k = 33; k <= 61; k += 2)
  {
    int m = (k + 1) >> 1;
    int i0 = k - 31;
    uint32_t acc = 0;
    for (int i = i0; i < m; ++i)
      acc += ((uint32_t)x->v[i] * (uint32_t)x->v[k - i]) << 1;
    t[k] = acc;
  }

  for (int i = 32; i < 63; ++i)
    r->v[i - 32] = t[i - 32] + times38(t[i]);

  r->v[31] = t[31];

  reduce_mul(r);
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
