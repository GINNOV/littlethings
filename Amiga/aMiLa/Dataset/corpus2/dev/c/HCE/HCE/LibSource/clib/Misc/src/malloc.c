/*
 * malloc.c: Amiga version is quite a bit simpler than gem version.
 * 	     15May89 - Created by Jeff Lydiatt
 */

#include <exec/types.h>
#include <stddef.h>
#include <exec/memory.h>

typedef struct memchunk {
	struct memchunk	*next;
	struct memchunk	*prev;
	long		 size;
} MEMCHUNK;

extern char *AllocMem();
extern void FreeMem();
extern void  (*_freeall)();
void freeall(); /* forward reference */

static MEMCHUNK sentinel;

char *
lalloc( size )
unsigned long size;
{
	register MEMCHUNK *mp;
	register unsigned long chunksize;	

	if (sentinel.prev == NULL) { /* 'Sozobon-C won't allow static def*/
		sentinel.prev = &sentinel;
		sentinel.next = &sentinel;
	}

	chunksize = size + sizeof(MEMCHUNK);
	mp = (MEMCHUNK *)AllocMem( chunksize, MEMF_CLEAR);
	if ( mp == NULL )
		return NULL;

	/*
	 * Keep the forward and backward links.
	 */

	sentinel.prev->next = mp;
	mp->prev = sentinel.prev;
	sentinel.prev = mp;

	mp->next = &sentinel;
	mp->size = chunksize;
	_freeall = freeall;
	return ++mp;
}

char *malloc(size)
unsigned int size;
{
	return(lalloc((long)size));
}


void
free( p )
char *p;
{
	register MEMCHUNK *mp, *prevmp, *nextmp;
	long Output();

	mp = (MEMCHUNK *)(p - sizeof(MEMCHUNK));

	/*
	 * Sanity check: the prev link should point to us. Do nothing if bad.
	 */

	prevmp = mp->prev;
	nextmp = mp->next;
	if ( prevmp->next != mp ) {
		return;
	}

	FreeMem( mp, mp->size );
	prevmp->next = nextmp;
	nextmp->prev = prevmp;

	return;
}

char *calloc(n, size)
unsigned int n;
size_t size;
{
	register long total;
	register char *p, *q;

	total = (((long) n) * ((long) size));
	if(p = lalloc(total))
		for(q=p; total--; *q++ = 0)
			;
	return(p);
}

/*
 * Called by exit() to free any allocated memory.
 */

static void
freeall()
{
	register MEMCHUNK	*mp, *mp1;

	for ( mp = sentinel.prev; mp != &sentinel; ) {
		mp1 = mp->prev;
		FreeMem( mp, mp->size );
		mp = mp1;
	}
}
