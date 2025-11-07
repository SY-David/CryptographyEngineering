#include <stdint.h>
#include "params.h"
#include "ntt.h"
#include "reduce.h"

/* Code to generate zetas and zetas_inv used in the number-theoretic transform:

#define KYBER_ROOT_OF_UNITY 17

static const uint8_t tree[128] = {
  0, 64, 32, 96, 16, 80, 48, 112, 8, 72, 40, 104, 24, 88, 56, 120,
  4, 68, 36, 100, 20, 84, 52, 116, 12, 76, 44, 108, 28, 92, 60, 124,
  2, 66, 34, 98, 18, 82, 50, 114, 10, 74, 42, 106, 26, 90, 58, 122,
  6, 70, 38, 102, 22, 86, 54, 118, 14, 78, 46, 110, 30, 94, 62, 126,
  1, 65, 33, 97, 17, 81, 49, 113, 9, 73, 41, 105, 25, 89, 57, 121,
  5, 69, 37, 101, 21, 85, 53, 117, 13, 77, 45, 109, 29, 93, 61, 125,
  3, 67, 35, 99, 19, 83, 51, 115, 11, 75, 43, 107, 27, 91, 59, 123,
  7, 71, 39, 103, 23, 87, 55, 119, 15, 79, 47, 111, 31, 95, 63, 127
};

void init_ntt() {
  unsigned int i;
  int16_t tmp[128];

  tmp[0] = MONT;
  for(i=1;i<128;i++)
    tmp[i] = fqmul(tmp[i-1],MONT*KYBER_ROOT_OF_UNITY % KYBER_Q);

  for(i=0;i<128;i++) {
    zetas[i] = tmp[tree[i]];
    if(zetas[i] > KYBER_Q/2)
      zetas[i] -= KYBER_Q;
    if(zetas[i] < -KYBER_Q/2)
      zetas[i] += KYBER_Q;
  }
}
*/

const int16_t zetas[128] = {
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

/*************************************************
 * Name:        fqmul
 *
 * Description: Multiplication followed by Montgomery reduction
 *
 * Arguments:   - int16_t a: first factor
 *              - int16_t b: second factor
 *
 * Returns 16-bit integer congruent to a*b*R^{-1} mod q
 **************************************************/

static int16_t fqmul(int16_t a, int16_t b)
{
  // return montgomery_reduce((int32_t)a * b);
  return montgomery(a, b);
}

/*************************************************
 * Name:        ntt
 *
 * Description: Inplace number-theoretic transform (NTT) in Rq.
 *              input is in standard order, output is in bitreversed order
 *
 * Arguments:   - int16_t r[256]: pointer to input/output vector of elements of Zq
 **************************************************/
void ntt(int16_t r[256])
{
  /* Fuse the layers as 2+2+2+1 radix-4 style blocks to cut redundant loads. */
  unsigned int base, block, offset;
  int16_t t0, t1;

  const int16_t *zetap = zetas + 1;
  const int16_t zeta128 = *zetap++;
  const int16_t *zeta64 = zetap;
  zetap += 2;
  const int16_t *zeta32 = zetap;
  zetap += 4;
  const int16_t *zeta16 = zetap;
  zetap += 8;
  const int16_t *zeta8 = zetap;
  zetap += 16;
  const int16_t *zeta4 = zetap;
  zetap += 32;
  const int16_t *zeta2 = zetap;

  /* Layers len=128 and len=64 */
  const int16_t zeta64_top = zeta64[0];
  const int16_t zeta64_bottom = zeta64[1];

  for (base = 0; base < 64; base += 2)
  {
    int16_t a0 = r[base];
    int16_t a1 = r[base + 1];
    int16_t b0 = r[base + 128];
    int16_t b1 = r[base + 129];

    int16_t t128_0 = fqmul(zeta128, b0);
    int16_t t128_1 = fqmul(zeta128, b1);

    int16_t top0 = a0 + t128_0;
    int16_t top1 = a1 + t128_1;
    int16_t bot0 = a0 - t128_0;
    int16_t bot1 = a1 - t128_1;

    int16_t a2 = r[base + 64];
    int16_t a3 = r[base + 65];
    int16_t b2 = r[base + 192];
    int16_t b3 = r[base + 193];

    int16_t t128_2 = fqmul(zeta128, b2);
    int16_t t128_3 = fqmul(zeta128, b3);

    int16_t top2 = a2 + t128_2;
    int16_t top3 = a3 + t128_3;
    int16_t bot2 = a2 - t128_2;
    int16_t bot3 = a3 - t128_3;

    int16_t t64_0 = fqmul(zeta64_top, top2);
    int16_t t64_1 = fqmul(zeta64_top, top3);

    r[base] = top0 + t64_0;
    r[base + 64] = top0 - t64_0;
    r[base + 1] = top1 + t64_1;
    r[base + 65] = top1 - t64_1;

    int16_t t64_2 = fqmul(zeta64_bottom, bot2);
    int16_t t64_3 = fqmul(zeta64_bottom, bot3);

    r[base + 128] = bot0 + t64_2;
    r[base + 192] = bot0 - t64_2;
    r[base + 129] = bot1 + t64_3;
    r[base + 193] = bot1 - t64_3;
  }

  /* Layers len=32 and len=16 */
  for (block = 0; block < 256; block += 64)
  {
    unsigned int blk = block >> 6;
    const int16_t zeta32_cur = zeta32[blk];
    const int16_t zeta16_top = zeta16[2 * blk];
    const int16_t zeta16_bottom = zeta16[2 * blk + 1];

    for (offset = 0; offset < 16; offset += 2)
    {
      unsigned int idx0 = block + offset;
      unsigned int idx1 = idx0 + 1;
      unsigned int idx2 = idx0 + 16;
      unsigned int idx3 = idx1 + 16;
      unsigned int idx4 = idx0 + 32;
      unsigned int idx5 = idx1 + 32;
      unsigned int idx6 = idx0 + 48;
      unsigned int idx7 = idx1 + 48;

      int16_t x0 = r[idx0];
      int16_t x1 = r[idx1];
      int16_t y0 = r[idx4];
      int16_t y1 = r[idx5];
      int16_t t32_0 = fqmul(zeta32_cur, y0);
      int16_t t32_1 = fqmul(zeta32_cur, y1);
      r[idx0] = x0 + t32_0;
      r[idx1] = x1 + t32_1;
      r[idx4] = x0 - t32_0;
      r[idx5] = x1 - t32_1;

      int16_t x2 = r[idx2];
      int16_t x3 = r[idx3];
      int16_t y2 = r[idx6];
      int16_t y3 = r[idx7];
      int16_t t32_2 = fqmul(zeta32_cur, y2);
      int16_t t32_3 = fqmul(zeta32_cur, y3);
      r[idx2] = x2 + t32_2;
      r[idx3] = x3 + t32_3;
      r[idx6] = x2 - t32_2;
      r[idx7] = x3 - t32_3;

      int16_t u0 = r[idx0];
      int16_t u1 = r[idx1];
      int16_t v0 = r[idx2];
      int16_t v1 = r[idx3];
      t0 = fqmul(zeta16_top, v0);
      t1 = fqmul(zeta16_top, v1);
      r[idx0] = u0 + t0;
      r[idx2] = u0 - t0;
      r[idx1] = u1 + t1;
      r[idx3] = u1 - t1;

      int16_t u2 = r[idx4];
      int16_t u3 = r[idx5];
      int16_t v2 = r[idx6];
      int16_t v3 = r[idx7];
      t0 = fqmul(zeta16_bottom, v2);
      t1 = fqmul(zeta16_bottom, v3);
      r[idx4] = u2 + t0;
      r[idx6] = u2 - t0;
      r[idx5] = u3 + t1;
      r[idx7] = u3 - t1;
    }
  }

  /* Layers len=8 and len=4 */
  for (block = 0; block < 256; block += 16)
  {
    unsigned int blk = block >> 4;
    const int16_t zeta8_cur = zeta8[blk];
    const int16_t zeta4_top = zeta4[2 * blk];
    const int16_t zeta4_bottom = zeta4[2 * blk + 1];

    for (offset = 0; offset < 4; offset += 2)
    {
      unsigned int idx0 = block + offset;
      unsigned int idx1 = idx0 + 1;
      unsigned int idx4 = idx0 + 4;
      unsigned int idx5 = idx1 + 4;
      unsigned int idx8 = idx0 + 8;
      unsigned int idx9 = idx1 + 8;
      unsigned int idx12 = idx4 + 8;
      unsigned int idx13 = idx5 + 8;

      int16_t a0 = r[idx0];
      int16_t a1 = r[idx1];
      int16_t b0 = r[idx8];
      int16_t b1 = r[idx9];
      int16_t t8_0 = fqmul(zeta8_cur, b0);
      int16_t t8_1 = fqmul(zeta8_cur, b1);
      r[idx0] = a0 + t8_0;
      r[idx1] = a1 + t8_1;
      r[idx8] = a0 - t8_0;
      r[idx9] = a1 - t8_1;

      int16_t a2 = r[idx4];
      int16_t a3 = r[idx5];
      int16_t b2 = r[idx12];
      int16_t b3 = r[idx13];
      int16_t t8_2 = fqmul(zeta8_cur, b2);
      int16_t t8_3 = fqmul(zeta8_cur, b3);
      r[idx4] = a2 + t8_2;
      r[idx5] = a3 + t8_3;
      r[idx12] = a2 - t8_2;
      r[idx13] = a3 - t8_3;

      int16_t s0 = r[idx0];
      int16_t s1 = r[idx1];
      int16_t s2 = r[idx4];
      int16_t s3 = r[idx5];
      t0 = fqmul(zeta4_top, s2);
      t1 = fqmul(zeta4_top, s3);
      r[idx0] = s0 + t0;
      r[idx4] = s0 - t0;
      r[idx1] = s1 + t1;
      r[idx5] = s1 - t1;

      int16_t s4 = r[idx8];
      int16_t s5 = r[idx9];
      int16_t s6 = r[idx12];
      int16_t s7 = r[idx13];
      t0 = fqmul(zeta4_bottom, s6);
      t1 = fqmul(zeta4_bottom, s7);
      r[idx8] = s4 + t0;
      r[idx12] = s4 - t0;
      r[idx9] = s5 + t1;
      r[idx13] = s5 - t1;
    }
  }

  /* Final len=2 layer */
  for (block = 0; block < 256; block += 4)
  {
    const int16_t zeta2_cur = zeta2[block >> 2];
    unsigned int idx0 = block;
    unsigned int idx1 = block + 1;
    unsigned int idx2 = block + 2;
    unsigned int idx3 = block + 3;

    int16_t p0 = r[idx0];
    int16_t p1 = r[idx1];
    int16_t q0 = r[idx2];
    int16_t q1 = r[idx3];

    t0 = fqmul(zeta2_cur, q0);
    t1 = fqmul(zeta2_cur, q1);
    r[idx0] = p0 + t0;
    r[idx2] = p0 - t0;
    r[idx1] = p1 + t1;
    r[idx3] = p1 - t1;
  }
}

/*************************************************
 * Name:        invntt_tomont
 *
 * Description: Inplace inverse number-theoretic transform in Rq and
 *              multiplication by Montgomery factor 2^16.
 *              Input is in bitreversed order, output is in standard order
 *
 * Arguments:   - int16_t r[256]: pointer to input/output vector of elements of Zq
 **************************************************/
void invntt(int16_t r[256])
{
  unsigned int start, len, j, k;
  int16_t t, zeta;
  const int16_t f = 1441; // mont^2/128

  k = 127;
  for (len = 2; len <= 128; len <<= 1)
  {
    for (start = 0; start < 256; start = j + len)
    {
      zeta = zetas[k--];
      for (j = start; j < start + len; j++)
      {
        t = r[j];
        r[j] = barrett(t + r[j + len]);
        r[j + len] = r[j + len] - t;
        r[j + len] = fqmul(zeta, r[j + len]);
      }
    }
  }

  for (j = 0; j < 256; j++)
    r[j] = fqmul(r[j], f);
}

/*************************************************
 * Name:        basemul
 *
 * Description: Multiplication of polynomials in Zq[X]/(X^2-zeta)
 *              used for multiplication of elements in Rq in NTT domain
 *
 * Arguments:   - int16_t r[2]: pointer to the output polynomial
 *              - const int16_t a[2]: pointer to the first factor
 *              - const int16_t b[2]: pointer to the second factor
 *              - int16_t zeta: integer defining the reduction polynomial
 **************************************************/
extern void basemul_s(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta);
void basemul(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta)
{
  basemul_s(r, a, b, zeta);
  /*r[0] = fqmul(a[1], b[1]);
  r[0] = fqmul(r[0], zeta);
  r[0] += fqmul(a[0], b[0]);
  r[1] = fqmul(a[0], b[1]);
  r[1] += fqmul(a[1], b[0]);
  */
}
