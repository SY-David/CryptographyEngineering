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

static inline uint32_t fe_get_bits(const fe25519 *a, int start_bit, int width)
{
  // 讀進最多 6 個位元組（足夠覆蓋 any 25/26-bit 視窗）
  uint64_t acc = 0;
  int byte0 = start_bit >> 3;
  int shift = start_bit & 7;
  int need = (shift + width + 7) >> 3; // 需要多少 byte（最多 5）
  for (int k = 0; k < need; ++k)
  {
    int idx = byte0 + k;
    uint64_t b = (idx < 32) ? (uint64_t)(a->v[idx] & 0xffu) : 0;
    acc |= (b << (8 * k));
  }
  uint64_t mask = (width == 32) ? 0xffffffffULL : ((1ULL << width) - 1ULL);
  return (uint32_t)((acc >> shift) & mask);
}

// 把 value 的低 width 位寫回到 r 的 bit 區間 [start_bit, start_bit+width-1]（OR 累加）
static inline void fe_put_bits(fe25519 *r, int start_bit, int width, uint32_t value)
{
  int bit = start_bit;
  for (int i = 0; i < width; ++i, ++bit)
  {
    int byte_idx = bit >> 3;
    int bit_idx = bit & 7;
    if (byte_idx < 32)
    {
      r->v[byte_idx] += ((value >> i) & 1u) << bit_idx; // 先累加；carry 交給 reduce_mul
    }
  }
}

// 主要：10×25.5 內部乘法，輸出仍為 32 個 8-bit digits，最後交給 reduce_mul
void fe25519_mul(fe25519 *restrict r, const fe25519 *restrict x, const fe25519 *restrict y)
{
  // 1) 32 bytes → 10×(26/25) limbs（little-endian bit-slicing）
  //    bit 起點：0,26,51,77,102,128,153,179,204,230
  const int start[10] = {0, 26, 51, 77, 102, 128, 153, 179, 204, 230};
  const int w[10] = {26, 25, 26, 25, 26, 25, 26, 25, 26, 25};

  uint32_t X[10], Y[10];
  for (int i = 0; i < 10; ++i)
  {
    X[i] = fe_get_bits(x, start[i], w[i]);
    Y[i] = fe_get_bits(y, start[i], w[i]);
  }

  // 2) 10×10 欄位卷積（64-bit 累加即可）
  uint64_t T[19] = {0};
  for (int i = 0; i < 10; ++i)
  {
    for (int j = 0; j < 10; ++j)
    {
      T[i + j] += (uint64_t)X[i] * (uint64_t)Y[j];
    }
  }

  // 3) 高半部折返（2^255 ≡ 19）：把 T[10..18] 以 ×19 回灌到 T[0..8]
  for (int k = 10; k <= 18; ++k)
  {
    T[k - 10] += 19u * T[k];
  }
  // 現在僅需關心 H[0..9]
  uint64_t H[10];
  for (int i = 0; i < 10; ++i)
    H[i] = T[i];

  // 4) 兩趟 carry 傳播（26/25 交錯；最後處理 h9 回灌 ×19，再做前半一次）
  const uint64_t M26 = (1ULL << 26) - 1ULL;
  const uint64_t M25 = (1ULL << 25) - 1ULL;

  // 第 1 趟：h0..h8 往右傳
  uint64_t c;

  c = H[0] >> 26;
  H[0] &= M26;
  H[1] += c;
  c = H[1] >> 25;
  H[1] &= M25;
  H[2] += c;
  c = H[2] >> 26;
  H[2] &= M26;
  H[3] += c;
  c = H[3] >> 25;
  H[3] &= M25;
  H[4] += c;
  c = H[4] >> 26;
  H[4] &= M26;
  H[5] += c;
  c = H[5] >> 25;
  H[5] &= M25;
  H[6] += c;
  c = H[6] >> 26;
  H[6] &= M26;
  H[7] += c;
  c = H[7] >> 25;
  H[7] &= M25;
  H[8] += c;
  c = H[8] >> 26;
  H[8] &= M26;
  H[9] += c;

  // h9 的 25-bit 溢位回灌到 h0（×19），再做前半 carry 一次
  c = H[9] >> 25;
  H[9] &= M25;
  H[0] += c * 19u;

  c = H[0] >> 26;
  H[0] &= M26;
  H[1] += c;
  c = H[1] >> 25;
  H[1] &= M25;
  H[2] += c;

  // 這時 H[0..9] 均落在指定位寬（弱化約簡）

  // 5) 清空輸出位元組槽；把 H[0..9] 以「bit 方式」寫回 32×8（外觀不變）
  for (int i = 0; i < 32; ++i)
    r->v[i] = 0;

  for (int i = 0; i < 10; ++i)
  {
    fe_put_bits(r, start[i], w[i], (uint32_t)H[i]);
  }

  // 6) 交給你現有的 reduce_mul(r) 做 base-256 傳播與 2^255×19 的保守收尾
  reduce_mul(r);
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
