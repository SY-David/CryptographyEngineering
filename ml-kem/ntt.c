#include <stdint.h>
#include "params.h"
#include "ntt.h"
#include "reduce.h"

extern void ntt_s(int16_t r[256]);
extern void invntt_s(int16_t r[256]);
void ntt(int16_t r[256])
{
  ntt_s(r);
}

void invntt_test(int16_t r[256])
{
  invntt_s(r);
}
