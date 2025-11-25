#include <stdint.h>
#include "params.h"
#include "poly.h"
#include "ntt.h"
#include "reduce.h"
#include "cbd.h"
#include "symmetric.h"
#include "verify.h"

extern void poly_add_s(int16_t *r, const int16_t *a, const int16_t *b);
extern void poly_sub_s(int16_t *r, const int16_t *a, const int16_t *b);
#if (KYBER_POLYCOMPRESSEDBYTES == 128)
extern void poly_compress_s(uint8_t *r, const int16_t *a);
extern void poly_decompress_s(int16_t *r, const uint8_t *a);
#elif (KYBER_POLYCOMPRESSEDBYTES == 160)
extern void poly_compress160_s(uint8_t *r, const int16_t *a);
extern void poly_decompress160_s(int16_t *r, const uint8_t *a);
#endif

/*************************************************
 * Name:        poly_compress
 *
 * Description: Compression and subsequent serialization of a polynomial
 *
 * Arguments:   - uint8_t *r: pointer to output byte array
 *                            (of length KYBER_POLYCOMPRESSEDBYTES)
 *              - const poly *a: pointer to input polynomial
 **************************************************/
void poly_compress(uint8_t r[KYBER_POLYCOMPRESSEDBYTES], const poly *a)
{
#if (KYBER_POLYCOMPRESSEDBYTES == 128)
  poly_compress_s(r, a->coeffs);
#elif (KYBER_POLYCOMPRESSEDBYTES == 160)
  poly_compress160_s(r, a->coeffs);
#else
#error "KYBER_POLYCOMPRESSEDBYTES needs to be in {128, 160}"
#endif
}

/*************************************************
 * Name:        poly_decompress
 *
 * Description: De-serialization and subsequent decompression of a polynomial;
 *              approximate inverse of poly_compress
 *
 * Arguments:   - poly *r: pointer to output polynomial
 *              - const uint8_t *a: pointer to input byte array
 *                                  (of length KYBER_POLYCOMPRESSEDBYTES bytes)
 **************************************************/
void poly_decompress(poly *r, const uint8_t a[KYBER_POLYCOMPRESSEDBYTES])
{
#if (KYBER_POLYCOMPRESSEDBYTES == 128)
  poly_decompress_s(r->coeffs, a);
#elif (KYBER_POLYCOMPRESSEDBYTES == 160)
  poly_decompress160_s(r->coeffs, a);
#else
#error "KYBER_POLYCOMPRESSEDBYTES needs to be in {128, 160}"
#endif
}

/*************************************************
 * Name:        poly_tobytes
 *
 * Description: Serialization of a polynomial
 *
 * Arguments:   - uint8_t *r: pointer to output byte array
 *                            (needs space for KYBER_POLYBYTES bytes)
 *              - const poly *a: pointer to input polynomial
 **************************************************/
void poly_tobytes(uint8_t r[KYBER_POLYBYTES], const poly *a)
{
  unsigned int i;
  uint16_t t0, t1;

  for (i = 0; i < KYBER_N / 2; i++)
  {
    // map to positive standard representatives
    t0 = a->coeffs[2 * i];
    t0 += ((int16_t)t0 >> 15) & KYBER_Q;
    t1 = a->coeffs[2 * i + 1];
    t1 += ((int16_t)t1 >> 15) & KYBER_Q;
    r[3 * i + 0] = (t0 >> 0);
    r[3 * i + 1] = (t0 >> 8) | (t1 << 4);
    r[3 * i + 2] = (t1 >> 4);
  }
}

/*************************************************
 * Name:        poly_frombytes
 *
 * Description: De-serialization of a polynomial;
 *              inverse of poly_tobytes
 *
 * Arguments:   - poly *r: pointer to output polynomial
 *              - const uint8_t *a: pointer to input byte array
 *                                  (of KYBER_POLYBYTES bytes)
 **************************************************/
void poly_frombytes(poly *r, const uint8_t a[KYBER_POLYBYTES])
{
  unsigned int i;
  for (i = 0; i < KYBER_N / 2; i++)
  {
    r->coeffs[2 * i] = ((a[3 * i + 0] >> 0) | ((uint16_t)a[3 * i + 1] << 8)) & 0xFFF;
    r->coeffs[2 * i + 1] = ((a[3 * i + 1] >> 4) | ((uint16_t)a[3 * i + 2] << 4)) & 0xFFF;
  }
}

/*************************************************
 * Name:        poly_frommsg
 *
 * Description: Convert 32-byte message to polynomial
 *
 * Arguments:   - poly *r: pointer to output polynomial
 *              - const uint8_t *msg: pointer to input message
 **************************************************/
void poly_frommsg(poly *r, const uint8_t msg[KYBER_INDCPA_MSGBYTES])
{
  unsigned int i, j;

#if (KYBER_INDCPA_MSGBYTES != KYBER_N / 8)
#error "KYBER_INDCPA_MSGBYTES must be equal to KYBER_N/8 bytes!"
#endif

  for (i = 0; i < KYBER_N / 8; i++)
  {
    for (j = 0; j < 8; j++)
    {
      r->coeffs[8 * i + j] = 0;
      cmov_int16(r->coeffs + 8 * i + j, ((KYBER_Q + 1) / 2), (msg[i] >> j) & 1);
    }
  }
}

/*************************************************
 * Name:        poly_tomsg
 *
 * Description: Convert polynomial to 32-byte message
 *
 * Arguments:   - uint8_t *msg: pointer to output message
 *              - const poly *a: pointer to input polynomial
 **************************************************/
void poly_tomsg(uint8_t msg[KYBER_INDCPA_MSGBYTES], const poly *a)
{
  unsigned int i, j;
  uint32_t t;

  for (i = 0; i < KYBER_N / 8; i++)
  {
    msg[i] = 0;
    for (j = 0; j < 8; j++)
    {
      t = a->coeffs[8 * i + j];
      t += ((int16_t)t >> 15) & KYBER_Q;
      t <<= 1;
      t += KYBER_Q / 2;
      t *= 80635;
      t >>= 28;
      t &= 1;
      msg[i] |= t << j;
    }
  }
}

/*************************************************
 * Name:        poly_getnoise_eta1
 *
 * Description: Sample a polynomial deterministically from a seed and a nonce,
 *              with output polynomial close to centered binomial distribution
 *              with parameter KYBER_ETA1
 *
 * Arguments:   - poly *r: pointer to output polynomial
 *              - const uint8_t *seed: pointer to input seed
 *                                     (of length KYBER_SYMBYTES bytes)
 *              - uint8_t nonce: one-byte input nonce
 **************************************************/
void poly_getnoise_eta1(poly *r, const uint8_t seed[KYBER_SYMBYTES], uint8_t nonce)
{
  uint8_t buf[KYBER_ETA1 * KYBER_N / 4];
  prf(buf, sizeof(buf), seed, nonce);
  poly_cbd_eta1(r, buf);
}

/*************************************************
 * Name:        poly_getnoise_eta2
 *
 * Description: Sample a polynomial deterministically from a seed and a nonce,
 *              with output polynomial close to centered binomial distribution
 *              with parameter KYBER_ETA2
 *
 * Arguments:   - poly *r: pointer to output polynomial
 *              - const uint8_t *seed: pointer to input seed
 *                                     (of length KYBER_SYMBYTES bytes)
 *              - uint8_t nonce: one-byte input nonce
 **************************************************/
void poly_getnoise_eta2(poly *r, const uint8_t seed[KYBER_SYMBYTES], uint8_t nonce)
{
  uint8_t buf[KYBER_ETA2 * KYBER_N / 4];
  prf(buf, sizeof(buf), seed, nonce);
  poly_cbd_eta2(r, buf);
}

/*************************************************
 * Name:        poly_ntt
 *
 * Description: Computes negacyclic number-theoretic transform (NTT) of
 *              a polynomial in place;
 *              inputs assumed to be in normal order, output in bitreversed order
 *
 * Arguments:   - uint16_t *r: pointer to in/output polynomial
 **************************************************/
void poly_ntt(poly *r)
{
  ntt(r->coeffs);
  poly_reduce(r);
}

/*************************************************
 * Name:        poly_invntt_tomont
 *
 * Description: Computes inverse of negacyclic number-theoretic transform (NTT)
 *              of a polynomial in place;
 *              inputs assumed to be in bitreversed order, output in normal order
 *
 * Arguments:   - uint16_t *a: pointer to in/output polynomial
 **************************************************/
void poly_invntt_tomont(poly *r)
{

  poly test_poly;          // 1. 宣告實體
  poly *test = &test_poly; // 2. 讓指標指向它
  for (int i = 0; i < KYBER_N; ++i)
  {
    test->coeffs[i] = r->coeffs[i];
  }

  invntt(r->coeffs);

  invntt_test(test->coeffs);
  for (int i = 0; i < 10; ++i)
  {
    if (r->coeffs[i] != test->coeffs[i])
    {
      char cycles_str[100];
      sprintf(cycles_str, "%d, %d, %d\n", i, r->coeffs[i], test->coeffs[i]);
      hal_send_str(cycles_str);
    }
  }
}

/*************************************************
 * Name:        poly_basemul_montgomery
 *
 * Description: Multiplication of two polynomials in NTT domain
 *
 * Arguments:   - poly *r: pointer to output polynomial
 *              - const poly *a: pointer to first input polynomial
 *              - const poly *b: pointer to second input polynomial
 **************************************************/
extern void basemul_s(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta);
void poly_basemul_montgomery(poly *r, const poly *a, const poly *b)
{
  unsigned int i;
  for (i = 0; i < KYBER_N / 4; i++)
  {
    basemul_s(&r->coeffs[4 * i], &a->coeffs[4 * i], &b->coeffs[4 * i], zetas[64 + i]);
    basemul_s(&r->coeffs[4 * i + 2], &a->coeffs[4 * i + 2], &b->coeffs[4 * i + 2], -zetas[64 + i]);
  }
}

/*************************************************
 * Name:        poly_tomont
 *
 * Description: Inplace conversion of all coefficients of a polynomial
 *              from normal domain to Montgomery domain
 *
 * Arguments:   - poly *r: pointer to input/output polynomial
 **************************************************/
void poly_tomont(poly *r)
{
  unsigned int i;
  const int16_t f = (1ULL << 32) % KYBER_Q;
  for (i = 0; i < KYBER_N; i++)
    r->coeffs[i] = montgomery_reduce((int32_t)r->coeffs[i] * f);
}

/*************************************************
 * Name:        poly_reduce
 *
 * Description: Applies Barrett reduction to all coefficients of a polynomial
 *              for details of the Barrett reduction see comments in reduce.c
 *
 * Arguments:   - poly *r: pointer to input/output polynomial
 **************************************************/
void poly_reduce(poly *r)
{
  unsigned int i;
  for (i = 0; i < KYBER_N; i++)
    r->coeffs[i] = barrett_reduce(r->coeffs[i]);
}

/*************************************************
 * Name:        poly_add
 *
 * Description: Add two polynomials; no modular reduction is performed
 *
 * Arguments: - poly *r: pointer to output polynomial
 *            - const poly *a: pointer to first input polynomial
 *            - const poly *b: pointer to second input polynomial
 **************************************************/
void poly_add(poly *r, const poly *a, const poly *b)
{
  poly_add_s(r->coeffs, a->coeffs, b->coeffs);
}

/*************************************************
 * Name:        poly_sub
 *
 * Description: Subtract two polynomials; no modular reduction is performed
 *
 * Arguments: - poly *r:       pointer to output polynomial
 *            - const poly *a: pointer to first input polynomial
 *            - const poly *b: pointer to second input polynomial
 **************************************************/
void poly_sub(poly *r, const poly *a, const poly *b)
{
  poly_sub_s(r->coeffs, a->coeffs, b->coeffs);
}
