/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)hash.c	1.1 86/10/09";

#include <string.h>

char *hashSearch(char *key, char *base, int nel, int width, int (*h1)(char *), int (*h2)(char *), int (*compar)(char *,char *), long *probes);

/*
	Look for `key' in the hash table starting at address `base'.
	`base' is a table containing `nel' elements of size `width'.
	The hashing strategy we use is open addressing.  Apply the
	primary hash function `h1' and the secondary hash function
	`h2' when searching for `key' or an empty slot.  `compar'
	is the comparison function that should be used to compare
	the key with an element of the table.  It is called with two
	arguments.  The first argument is the address of the key, and
	the second argument is the address of the hash table element
	in question.  `compar' should return 0 if the key matches the
	element or the empty slot, and non-zero otherwise.

	If a pointer to a long is provided for `probes' we will keep
	a running total of open addressing hash probes.
*/
char *
hashSearch(key, base, nel, width, h1, h2, compar, probes)
	char		*key;		/* key to locate */
	char		*base;		/* base of hash table */
	register int	nel;		/* number of elements in table */
	int		width;		/* width of each element */
	int		(*h1)(char *);	/* primary hash function */
	int		(*h2)(char *);	/* secondary hash function */
	int		(*compar)(char *,char *);	/* key comparison function */
	long		*probes;
{
	register int	hash1;
	register int	hash2;
	register char	*slot;

	hash1 = (*h1)(key) % nel;
	slot = &base[hash1 * width];

	if (probes)
		(*probes)++;
	if ((*compar)(key, slot) == 0)
		return slot;

	hash2 = (*h2)(key);
	for (;;) {
		hash1 = (hash1 + hash2) % nel;
		slot = &base[hash1 * width];

		if (probes)
			(*probes)++;
		if ((*compar)(key, slot) == 0)
			return slot;
	}
}

#define	ABS(n)		((n) < 0 ? -(n) : (n))

/*
	A Primary hash function for string keys.
*/
int
h1str(register char *key)
{
	register int	sum;
	register int	s;

	for (sum = s = 0; *key; s++)
		sum += ((*key++) << s);

	return ABS(sum);
}

/*
	A Secondary hash function for string keys.
*/
int
h2str(register char *key)
{
	register int	sum;
	register int	s;
	char		*keysav;

	keysav = key;
	key = &key[strlen(key)];

	for (sum = s = 0; key > keysav; s++)
		sum += ((*--key) << s);

	return ABS(sum) | 1;
}
