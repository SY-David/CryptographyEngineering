#ifndef SMULT_BASE_TABLE_H
#define SMULT_BASE_TABLE_H

#include "group.h"

#define BASE_WINDOW_BITS 4
#define BASE_WINDOW_COUNT (256 / BASE_WINDOW_BITS)
#define BASE_WINDOW_SIZE (1 << BASE_WINDOW_BITS)

extern const group_ge crypto_scalarmult_base_table[BASE_WINDOW_COUNT][BASE_WINDOW_SIZE];

#endif
