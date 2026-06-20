#include "bset.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define BPI (sizeof(unsigned)*8)

struct BSet {
    unsigned siz;
    unsigned *v; /* v[siz] */
};

BSet *bset_new(int nmemb)
{
    BSet *s;

    s = malloc(sizeof(BSet));
    s->siz = (nmemb+BPI-1)/BPI;
    s->v = calloc(s->siz, sizeof(unsigned));
    return s;
}

void bset_free(BSet *s)
{
    free(s->v);
    free(s);
}

void bset_cpy(BSet *s1, BSet *s2)
{
    assert(s1->siz == s2->siz);
    memcpy(s1->v, s2->v, s1->siz*sizeof(unsigned));
}

void bset_clear(BSet *s)
{
    memset(s->v, 0, s->siz*sizeof(unsigned));
}

int bset_eq(BSet *s1, BSet *s2)
{
    assert(s1->siz == s2->siz);
    return (memcmp(s1->v, s2->v, s1->siz*sizeof(unsigned)) == 0);
}

void bset_union(BSet *s1, BSet *s2)
{
    int i;

    assert(s1->siz == s2->siz);
    for (i = 0; i < s1->siz; i++)
        s1->v[i] |= s2->v[i];
}

void bset_inters(BSet *s1, BSet *s2)
{
    int i;

    assert(s1->siz == s2->siz);
    for (i = 0; i < s1->siz; i++)
        s1->v[i] &= s2->v[i];
}

void bset_diff(BSet *s1, BSet *s2)
{
    int i;

    assert(s1->siz == s2->siz);
    for (i = 0; i < s1->siz; i++)
        s1->v[i] &= ~s2->v[i];
}

int bset_member(BSet *s, int e)
{
    assert(e < s->siz*BPI);
    return ((s->v[e/BPI] & (1U << (e%BPI))) != 0);
}

void bset_insert(BSet *s, int e)
{
    assert(e < s->siz*BPI);
    s->v[e/BPI] |= (1U << (e%BPI));
}

void bset_delete(BSet *s, int e)
{
    assert(e < s->siz*BPI);
    s->v[e/BPI] &= ~(1U << (e%BPI));
}

int bset_card(BSet *s)
{
    int i, c, n;

    c = 0;
    for (i = 0; i < s->siz; i++)
        for (n = s->v[i]; n; c++)
            n = n & n-1;
    return c;
}

int bset_iterate(BSet *s)
{
    static int i, c;
    static BSet *curr;

    if (s != NULL) {
        i = 0;
        curr = s;
        c = bset_card(curr);
    }

    for (; c; i++) {
        if ((curr->v[i/BPI] & (1U << (i%BPI))) != 0) {
            --c;
            return i++;
        }
    }
    return -1;
}

void bset_fill(BSet *s, int n)
{
    int i;

    for (i = 0; i<s->siz && n; i++) {
        int j;

        for (j = 0; j<BPI && n; j++, n--)
            s->v[i] |= (1U << j);
    }
}
