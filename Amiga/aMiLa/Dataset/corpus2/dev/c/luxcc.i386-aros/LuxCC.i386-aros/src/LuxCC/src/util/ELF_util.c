#include "ELF_util.h"
#include <stdlib.h>
#include <string.h>
#include "util.h"

struct StrTab {
    int siz, max;
    char **str;
    int *offs;
};

StrTab *strtab_new(void)
{
    StrTab *n;

    n = malloc(sizeof(StrTab));
    n->max = 16;
    n->str = malloc(sizeof(char *)*n->max);
    n->offs = malloc(sizeof(int)*n->max);
    n->str[0] = "";
    n->offs[0] = 0;
    n->siz = 1;
    return n;
}

void strtab_destroy(StrTab *tab)
{
    free(tab->str);
    free(tab->offs);
    free(tab);
}

int strtab_append(StrTab *tab, char *str)
{
    if (tab->siz >= tab->max) {
        tab->max *= 2;
        tab->str = realloc(tab->str, sizeof(char *)*tab->max);
        tab->offs = realloc(tab->offs, sizeof(int)*tab->max);
    }
    tab->str[tab->siz] = str;
    tab->offs[tab->siz] = tab->offs[tab->siz-1]+strlen(tab->str[tab->siz-1])+1;
    return tab->offs[tab->siz++];
}

int strtab_write(StrTab *tab, FILE *fp)
{
    int i, total = 0;

    for (i = 0; i < tab->siz; i++) {
        int n;

        n = strlen(tab->str[i])+1;
        fwrite(tab->str[i], n, 1, fp);
        total += n;
    }
    return total;
}

unsigned strtab_get_size(StrTab *tab)
{
    int i;
    unsigned n;

    for (i=0, n=0; i < tab->siz; i++)
        n += strlen(tab->str[i])+1;
    return n;
}

int strtab_get_offset(StrTab *tab, char *str)
{
    int i;

    for (i = 0; i < tab->siz; i++)
        if (strcmp(tab->str[i], str) == 0)
            return tab->offs[i];
    return -1;
}

char *strtab_get_string(StrTab *tab, int offs)
{
    int i;

    for (i = 0; i < tab->siz; i++)
        if (tab->offs[i] == offs)
            return tab->str[i];
    return NULL;
}

void strtab_copy(StrTab *tab, char *dest)
{
    int i;
    unsigned n;

    for (i = 0; i < tab->siz; i++) {
        n = strlen(tab->str[i])+1;
        memcpy(dest, tab->str[i], n);
        dest += n;
    }
}

unsigned long elf_hash(const unsigned char *name)
{
	unsigned long h = 0, g;

	while (*name) {
		h = (h << 4) + *name++;
		if (g = h & 0xf0000000)
			h ^= g >> 24;
		h &= ~g;
	}
	return h;
}

unsigned elf_get_nbucket(unsigned nsym)
{
    /*
     * Number of buckets as defined by GNU ld.
     * If the symbol table has less than 3 elements,
     * the hash table will have 1 bucket, less than
     * 17 elements 3 buckets, etc.
     */
    static unsigned hash_buckets[] = {
        1, 3, 17, 37, 67, 97, 131, 197,
        263, 521, 1031,	2053, 4099, 8209,
        16411, 32771, 65537, 131101, 262147
    };
    unsigned i;

    for (i = 1; i < NELEMS(hash_buckets); i++)
        if (hash_buckets[i] > nsym)
            break;
    return hash_buckets[i-1];
}
