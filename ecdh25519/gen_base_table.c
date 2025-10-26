#include <stdio.h>
#include "smult_base_table.h"

static const group_ge ge_identity = {{{0}},
                                     {{1}},
                                     {{1}},
                                     {{0}}};

static void print_fe(const fe25519 *f)
{
    putchar('{');
    for (int i = 0; i < 32; ++i)
    {
        printf("%u", f->v[i]);
        if (i != 31)
        {
            printf(", ");
        }
    }
    putchar('}');
}

static void print_point(const group_ge *p)
{
    printf("{{");
    print_fe(&p->x);
    printf("}, {");
    print_fe(&p->y);
    printf("}, {");
    print_fe(&p->z);
    printf("}, {");
    print_fe(&p->t);
    printf("}}");
}

int main(void)
{
    group_ge table[BASE_WINDOW_COUNT][BASE_WINDOW_SIZE];
    group_ge window_base = group_ge_base;

    for (int i = 0; i < BASE_WINDOW_COUNT; ++i)
    {
        table[i][0] = ge_identity;
        table[i][1] = window_base;

        for (int j = 2; j < BASE_WINDOW_SIZE; ++j)
        {
            group_ge_add(&table[i][j], &table[i][j - 1], &window_base);
        }

        if (i + 1 < BASE_WINDOW_COUNT)
        {
            for (int d = 0; d < BASE_WINDOW_BITS; ++d)
            {
                group_ge_double(&window_base, &window_base);
            }
        }
    }

    printf("#include \"smult_base_table.h\"\n\n");
    printf("const group_ge crypto_scalarmult_base_table[%d][%d] = {\n", BASE_WINDOW_COUNT, BASE_WINDOW_SIZE);
    for (int i = 0; i < BASE_WINDOW_COUNT; ++i)
    {
        printf("    {\n");
        for (int j = 0; j < BASE_WINDOW_SIZE; ++j)
        {
            printf("        ");
            print_point(&table[i][j]);
            if (!(i == BASE_WINDOW_COUNT - 1 && j == BASE_WINDOW_SIZE - 1))
            {
                printf(",");
            }
            printf("\n");
        }
        printf("    }");
        if (i != BASE_WINDOW_COUNT - 1)
        {
            printf(",");
        }
        printf("\n");
    }
    printf("};\n");

    return 0;
}
