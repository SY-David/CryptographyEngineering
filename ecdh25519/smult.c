#include "group.h"
#include "smult.h"

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
  unsigned char t[GROUP_GE_PACKEDBYTES];
  group_ge_pack(t, &group_ge_base);
  return crypto_scalarmult(pk, sk, t);
}
