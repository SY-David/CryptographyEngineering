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

static inline void fe25519_mul_core(const unsigned char *a,
                                    const unsigned char *b,
                                    int64_t h[10])
{

  uint64_t ax0 = load4(a + 0);
  uint64_t ax1 = load4(a + 4);
  uint64_t ax2 = load4(a + 8);
  uint64_t ax3 = load4(a + 12);
  uint64_t ax4 = load4(a + 16);
  uint64_t ax5 = load4(a + 20);
  uint64_t ax6 = load4(a + 24);
  uint64_t ax7 = load4(a + 28);

  uint64_t bx0 = load4(b + 0);
  uint64_t bx1 = load4(b + 4);
  uint64_t bx2 = load4(b + 8);
  uint64_t bx3 = load4(b + 12);
  uint64_t bx4 = load4(b + 16);
  uint64_t bx5 = load4(b + 20);
  uint64_t bx6 = load4(b + 24);
  uint64_t bx7 = load4(b + 28);

  int64_t f0 = (int64_t)(ax0 & 0x3ffffff);
  int64_t f1 = (int64_t)((((ax1 << 32) | ax0) >> 26) & 0x1ffffff);
  int64_t f2 = (int64_t)((((ax2 << 32) | ax1) >> 19) & 0x3ffffff);
  int64_t f3 = (int64_t)((((ax3 << 32) | ax2) >> 13) & 0x1ffffff);
  int64_t f4 = (int64_t)((ax3 >> 6) & 0x3ffffff);
  int64_t f5 = (int64_t)(ax4 & 0x1ffffff);
  int64_t f6 = (int64_t)((((ax5 << 32) | ax4) >> 25) & 0x3ffffff);
  int64_t f7 = (int64_t)((((ax6 << 32) | ax5) >> 19) & 0x1ffffff);
  int64_t f8 = (int64_t)((((ax7 << 32) | ax6) >> 12) & 0x3ffffff);
  int64_t f9 = (int64_t)((ax7 >> 6) & 0x1ffffff);

  int64_t g0 = (int64_t)(bx0 & 0x3ffffff);
  int64_t g1 = (int64_t)((((bx1 << 32) | bx0) >> 26) & 0x1ffffff);
  int64_t g2 = (int64_t)((((bx2 << 32) | bx1) >> 19) & 0x3ffffff);
  int64_t g3 = (int64_t)((((bx3 << 32) | bx2) >> 13) & 0x1ffffff);
  int64_t g4 = (int64_t)((bx3 >> 6) & 0x3ffffff);
  int64_t g5 = (int64_t)(bx4 & 0x1ffffff);
  int64_t g6 = (int64_t)((((bx5 << 32) | bx4) >> 25) & 0x3ffffff);
  int64_t g7 = (int64_t)((((bx6 << 32) | bx5) >> 19) & 0x1ffffff);
  int64_t g8 = (int64_t)((((bx7 << 32) | bx6) >> 12) & 0x3ffffff);
  int64_t g9 = (int64_t)((bx7 >> 6) & 0x1ffffff);

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

  h[0] = h0;
  h[1] = h1;
  h[2] = h2;
  h[3] = h3;
  h[4] = h4;
  h[5] = h5;
  h[6] = h6;
  h[7] = h7;
  h[8] = h8;
  h[9] = h9;
}

void fe25519_mul(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  unsigned char a[32];
  unsigned char b[32];

  fe25519_pack(a, x);
  fe25519_pack(b, y);

  int64_t h[10];
  fe25519_mul_core(a, b, h);

  unsigned char s[32];
  contract_limbs(s, h);

  for (int i = 0; i < 32; ++i)
  {
    r->v[i] = s[i];
  }
}
extern void fe25519_square_core_s(const unsigned char *a,
                                  int64_t h[10]);
static inline void fe25519_square_core(const unsigned char *a,
                                       int64_t h[10])
{

  uint64_t ax0 = load4(a + 0);
  uint64_t ax1 = load4(a + 4);
  uint64_t ax2 = load4(a + 8);
  uint64_t ax3 = load4(a + 12);
  uint64_t ax4 = load4(a + 16);
  uint64_t ax5 = load4(a + 20);
  uint64_t ax6 = load4(a + 24);
  uint64_t ax7 = load4(a + 28);

  int64_t f0 = (int64_t)(ax0 & 0x3ffffff);
  int64_t f1 = (int64_t)((((ax1 << 32) | ax0) >> 26) & 0x1ffffff);
  int64_t f2 = (int64_t)((((ax2 << 32) | ax1) >> 19) & 0x3ffffff);
  int64_t f3 = (int64_t)((((ax3 << 32) | ax2) >> 13) & 0x1ffffff);
  int64_t f4 = (int64_t)((ax3 >> 6) & 0x3ffffff);
  int64_t f5 = (int64_t)(ax4 & 0x1ffffff);
  int64_t f6 = (int64_t)((((ax5 << 32) | ax4) >> 25) & 0x3ffffff);
  int64_t f7 = (int64_t)((((ax6 << 32) | ax5) >> 19) & 0x1ffffff);
  int64_t f8 = (int64_t)((((ax7 << 32) | ax6) >> 12) & 0x3ffffff);
  int64_t f9 = (int64_t)((ax7 >> 6) & 0x1ffffff);

  int64_t f1_19 = 19 * f1;
  int64_t f2_19 = 19 * f2;
  int64_t f3_19 = 19 * f3;
  int64_t f4_19 = 19 * f4;
  int64_t f5_19 = 19 * f5;
  int64_t f6_19 = 19 * f6;
  int64_t f7_19 = 19 * f7;
  int64_t f8_19 = 19 * f8;
  int64_t f9_19 = 19 * f9;

  int64_t f0_2 = 2 * f0;
  int64_t f1_2 = 2 * f1;
  int64_t f2_2 = 2 * f2;
  int64_t f3_2 = 2 * f3;
  int64_t f4_2 = 2 * f4;
  int64_t f5_2 = 2 * f5;
  int64_t f6_2 = 2 * f6;
  int64_t f7_2 = 2 * f7;
  int64_t f8_2 = 2 * f8;
  int64_t f9_2 = 2 * f9;

  int64_t f1_38 = 38 * f1;
  int64_t f2_38 = 38 * f2;
  int64_t f3_38 = 38 * f3;
  int64_t f4_38 = 38 * f4;
  int64_t f5_38 = 38 * f5;
  int64_t f6_38 = 38 * f6;
  int64_t f7_38 = 38 * f7;
  int64_t f8_38 = 38 * f8;
  int64_t f9_38 = 38 * f9;

  int64_t h0 = f0 * f0 + f1_38 * f9 + f2_38 * f8 + f3_38 * f7 + f4_19 * f6 + f5_2 * f5_19;
  int64_t h1 = f0_2 * f1 + f2_38 * f9 + f3_38 * f8 + f4_19 * f7 + f5_2 * f6_19;
  int64_t h2 = f0_2 * f2 + f1_2 * f1 + f3_38 * f9 + f4_38 * f8 + f5_38 * f7 + f6_19 * f6;
  int64_t h3 = f0_2 * f3 + f1_2 * f2 + f4_38 * f9 + f5_38 * f8 + f6_19 * f7;
  int64_t h4 = f0_2 * f4 + f1_38 * f3 + f2 * f2 + f5_38 * f9 + f6_38 * f8 + f7_19 * f7;
  int64_t h5 = f0_2 * f5 + f1_2 * f4 + f2_2 * f3 + f6_38 * f9 + f7_38 * f8;
  int64_t h6 = f0_2 * f6 + f1_38 * f5 + f2_2 * f4 + f3_38 * f3 + f7_38 * f9 + f8_19 * f8;
  int64_t h7 = f0_2 * f7 + f1_2 * f6 + f2_2 * f5 + f3_2 * f4 + f8_38 * f9;
  int64_t h8 = f0_2 * f8 + f1_38 * f7 + f2_38 * f6 + f3_38 * f5 + f4_19 * f4 + f9_19 * f9;
  int64_t h9 = f0_2 * f9 + f1_2 * f8 + f2_2 * f7 + f3_2 * f6 + f4_2 * f5;

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

  h[0] = h0;
  h[1] = h1;
  h[2] = h2;
  h[3] = h3;
  h[4] = h4;
  h[5] = h5;
  h[6] = h6;
  h[7] = h7;
  h[8] = h8;
  h[9] = h9;
}

void fe25519_square(fe25519 *r, const fe25519 *x)
{
  unsigned char a[32];

  fe25519_pack(a, x);

  int64_t h_ref[10], h_asm[10];
  fe25519_square_core(a, h_ref);   // C 版
  fe25519_square_core_s(a, h_asm); // 彙編版

  char outstr[128];

  unsigned char s[32];
  contract_limbs(s, h_ref);

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