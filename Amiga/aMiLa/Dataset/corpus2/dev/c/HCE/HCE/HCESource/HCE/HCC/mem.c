/* mem.c - Added by Jason Petty - 1993. */

/* This code is based on 'malloc.c' by Jeff Lydiatt.
 *
 * REASONS FOR THIS CODE:
 *
 *       I needed a way of freeing all malloc`ed memory between
 *       compilations without affecting the malloc`ed memory used 
 *       by the device table(etc).
 *       Normally you would not be able to get memory back until 'exit()'.
 */

/* PLACES USED:
 *
 *    pre.c:
 *       'malloc_V2()' is used by 'newfile()' instead of 'malloc()'.
 *       This memory is always freed after each compilation with a call
 *       to 'freeall_V2()' in 'Do_Compile()'.
 *
 *    nodes.c:
 *       'hcc_calloc()' is used by 'allocnode()' instead of 'calloc()'.
 *       This memory is freed with 'free_hcc()' and is freed either if the
 *       user requests it or if memory is low.(see param.h, main.c)
 *
 *    tok.c:
 *       'SetMemFailed()' is called by 'xgetc()' if low memory is detected.
 *       This causes 'Do_Compile()' to call 'FreeForExit()' which then calls
 *       'free_hcc()' and all 'hcc_calloc()' memory is freed.
 */

/* malloc.c: Amiga version is quite a bit simpler than gem version.
 * 	     15May89 - Created by Jeff Lydiatt
 */

#include <exec/types.h>
#include <clib/stddef.h>
#include <exec/memory.h>

typedef struct m_chunkv2 
   {
    struct m_chunkv2 *next;
    struct m_chunkv2 *prev;
    long size;
    } MEM_CHUNKV2;

static MEM_CHUNKV2 sentinalv2;   /* Memlist used for anything. */
static MEM_CHUNKV2 hcc_sentinal; /* Memlist used for compile only. */
unsigned long mem_mon;           /* Monitor memory used. */
static int mem_keep;

char *AllocMem();
void FreeMem();

char *lalloc_V2( size )
unsigned long size;
{
	register MEM_CHUNKV2 *mp;
	register unsigned long chunksize;	

    if (sentinalv2.prev == NULL) { /* 'Sozobon-C won't allow static def*/
		sentinalv2.prev = &sentinalv2;
		sentinalv2.next = &sentinalv2;
	}

	chunksize = size + sizeof(MEM_CHUNKV2);
	mp = (MEM_CHUNKV2 *)AllocMem( chunksize, MEMF_CLEAR);
	if ( mp == NULL )
		return NULL;

     /* Keep the forward and backward links. */

	sentinalv2.prev->next = mp;
	mp->prev = sentinalv2.prev;
	sentinalv2.prev = mp;
	mp->next = &sentinalv2;
	mp->size = chunksize;

return ++mp;
}

char *malloc_V2(size)
unsigned int size;
{
	return(lalloc_V2((long)size));
}

void free_V2( p )
char *p;
{
	register MEM_CHUNKV2 *mp, *prevmp, *nextmp;
	long Output();

    if(sentinalv2.prev == NULL)
        return;

 	mp = (MEM_CHUNKV2 *)(p - sizeof(MEM_CHUNKV2));

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

char *calloc_V2(n, size)
unsigned int n;
size_t size;
{
	register long total;
	register char *p, *q;

	total = (((long) n) * ((long) size));
	if(p = lalloc_V2(total))
		for(q=p; total--; *q++ = 0)
			;
	return(p);
}

/*
 * Free all malloc_V2 memory.
 */

void freeall_V2()
{
  register MEM_CHUNKV2	*mp, *mp1;

 if(sentinalv2.prev == NULL)
    return;

	for ( mp = sentinalv2.prev; mp != &sentinalv2; ) {
		mp1 = mp->prev;
		FreeMem( mp, mp->size );
		mp = mp1;
	}
 sentinalv2.prev = NULL;
 sentinalv2.next = NULL;
}


/****************  FOR COMPILE PURPOSES ONLY ***************/

char *hcc_lalloc( size )
unsigned long size;
{
  register MEM_CHUNKV2 *mp;
  register unsigned long chunksize;	

     if (hcc_sentinal.prev == NULL) {
           hcc_sentinal.prev = &hcc_sentinal;
           hcc_sentinal.next = &hcc_sentinal;
	   }
           chunksize = size + sizeof(MEM_CHUNKV2);
     if (!(mp = (MEM_CHUNKV2 *)AllocMem(chunksize, MEMF_CLEAR)))
           return(NULL);

   /* Keep the forward and backward links.*/

           hcc_sentinal.prev->next = mp;
           mp->prev = hcc_sentinal.prev;
           hcc_sentinal.prev = mp;
           mp->next = &hcc_sentinal;
	   mp->size = chunksize;

 return ++mp;
}

/* Used in 'main.c' by 'doincl()' */

char *hcc_malloc(size)
unsigned int size;
{
	return(hcc_lalloc((long)size));
}

/* Used in 'nodes.c' by 'allocnode()' */

char *hcc_calloc(n, size)
unsigned int n;
size_t size;
{
  register long total;
  register char *p, *q;

  total = (((long) n) * ((long) size));

  if(p = hcc_lalloc(total))
     for(q=p; total--; *q++ = 0)
         ;

return(p);
}

/* Frees all 'hcc_calloc/malloc' memory. */
/* Usually called (if required) after a file has been compiled. */

void free_hcc()
{
  register MEM_CHUNKV2	*mp, *mp1;

 if(hcc_sentinal.prev == NULL)
    return;

	for ( mp = hcc_sentinal.prev; mp != &hcc_sentinal; ) {
		mp1 = mp->prev;
		FreeMem( mp, mp->size );
		mp = mp1;
	}
 hcc_sentinal.prev = NULL;
 hcc_sentinal.next = NULL;
}

void Reset_MMon()       /* Reset the memory monitoring variable. */
{
 mem_mon = (unsigned long)TotalMemB(); /* Get total free memory in Bytes.*/
 mem_keep = 1;
}

void SetMemFailed()     /* Set when memory gets low. */
{                       /* Used by xgetc() in tok.c. */
 mem_keep = 0L;
}

CheckMemFail()          /* Check if SetMemFailed was called. */
{
 return(mem_keep);
}
