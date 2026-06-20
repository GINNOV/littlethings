#include "arena.h"
#include <stdio.h>
#include <stdlib.h>
#include "util.h"

#define MULTIPLE    4
#define DEFAULT_NAS 10*1024

typedef struct Block Block;
struct Block {
    char *limit;
    char *avail;
    Block *next;
};

struct Arena {
    Block *first;
    Block *last;
    unsigned nas; /* nominal arena size */
    int zero;
};

static void *allocate(Arena *a, unsigned n);

/* create a new `size' bytes sized arena */
Arena *arena_new(unsigned size, int zero)
{
    Arena *a;
    unsigned n;

    a = malloc(sizeof(Arena));
    n = round_up(sizeof(Block)+size, MULTIPLE);
    if (zero) {
        a->first = calloc(1, n);
    } else {
        a->first = malloc(n);
        a->first->next = NULL;
    }
    a->first->limit = (char *)a->first+n;
    a->first->avail = (char *)a->first+sizeof(Block);
    a->last = a->first;
    a->nas = DEFAULT_NAS;
    a->zero = zero;

    return a;
}

/* return `n' bytes of storage */
void *arena_alloc(Arena *a, unsigned n)
{
    void *p;

    p = a->last->avail;
    if ((a->last->avail+=n) > a->last->limit)
        p = allocate(a, n);

    return p;
}

/* allocate `n' bytes from `a'; create a new block if necessary */
void *allocate(Arena *a, unsigned n)
{
    Block *ap;

    for (ap = a->last; ap->avail+n > ap->limit; a->last = ap) {
        if (ap->next != NULL) { /* move to next block */
            ap = ap->next;
            ap->avail = (char *)ap+sizeof(Block); /* reset */
        } else { /* allocate a new block */
            unsigned m;

            m = round_up(n, MULTIPLE)+a->nas+sizeof(Block);
            /*m = (ap->limit-(char *)ap-sizeof(Block))*2 + round_up(n, MULTIPLE) + sizeof(Block);*/
            if (a->zero)
                ap->next = calloc(1, m);
            else
                ap->next = malloc(m);
            if ((ap=ap->next) == NULL)
                return NULL;
            ap->limit = (char *)ap+m;
            ap->avail = (char *)ap+sizeof(Block);
            ap->next = NULL;
        }
    }
    ap->avail += n;
    return ap->avail-n;
}

void arena_reset(Arena *a)
{
    a->last = a->first;
    a->last->avail = (char *)a->last+sizeof(Block);
}

void arena_destroy(Arena *a)
{
    Block *p, *q;

    p = a->first;
    while (p != NULL) {
        q = p;
        p = p->next;
        free(q);
    }
    free(a);
}

void arena_set_nom_siz(Arena *a, unsigned size)
{
    a->nas = size;
}
