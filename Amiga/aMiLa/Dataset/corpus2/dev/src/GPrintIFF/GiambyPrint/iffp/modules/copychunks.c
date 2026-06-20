/* copychunks
 *
 * For Read/Modify/Write programs and other programs that need
 *   to close the IFF file but still reference gathered chunks.
 * Copies your gathered property and collection chunks
 *   from an iff context so that IFF handle may be
 *   closed right after parsing (allowing file or clipboard to
 *   to be reopened for read or write by self or other programs)
 *
 * The created list of chunks can be modified and written
 *   back out to a new handle with writechunklist().
 *
 * If you have used copychunks(), remember to free the copied
 *   chunks with freechunklist(), when ready, to deallocate them.
 * 
 * Note that this implementation is flat and is suitable only
 *   for simple FORMs.
 */

#include "iffp/iff.h"

/* copychunks()
 *
 * Copies chunks specified in propchks and collectchks
 *   FROM an already-parsed IFFHandle
 *   TO a singly linked list of Chunk structures,
 * and returns a pointer to the start of the list.
 *
 * Generally you would store this pointer in parseInfo.copiedchunks.
 *
 * You must later free the list of copied chunks by calling
 *   FreeChunkList().
 *
 * Reorders collection chunks so they appear in SAME ORDER
 * in chunk list as they did in the file.
 *
 * Returns 0 for failure
 */  
struct Chunk *copychunks(struct IFFHandle *iff,
			LONG *propchks, LONG *collectchks,
			ULONG memtype)
    {
    struct Chunk *chunk, *first=NULL, *prevchunk = NULL;
    struct StoredProperty *sp;
    struct CollectionItem *ci, *cii;
    long error;
    int k, kk, bk;

    if(!iff)	return(NULL);

    /* Copy gathered property chunks */
    error = 0;
    for(k=0; (!error) && (propchks) && (propchks[k] != TAG_DONE); k+=2)
	{
	if(sp=FindProp(iff,propchks[k],propchks[k+1]))
	    {
	    D(bug("copying %.4s.%.4s chunk\n",&propchks[k],&propchks[k+1]));
 
	    if(chunk=(struct Chunk *)
			AllocMem(sizeof(struct Chunk),memtype|MEMF_CLEAR))
		{
		chunk->ch_Type = propchks[k];
		chunk->ch_ID   = propchks[k+1];
		if(chunk->ch_Data = AllocMem(sp->sp_Size,memtype))
		    {
		    chunk->ch_Size = sp->sp_Size;
		    CopyMem(sp->sp_Data,chunk->ch_Data,sp->sp_Size);
		    if(prevchunk)	prevchunk->ch_Next = chunk;
		    else 		first = chunk;
		    prevchunk = chunk;
		    }
		else
		    {
		    FreeMem(chunk,sizeof(struct Chunk));
		    chunk=NULL;
		    error = 1;
		    }
		}
	    else error = 1;
	    }
	}

    /* Copy gathered collection chunks in reverse order */
    for(k=0; (!error) && (collectchks) && (collectchks[k] != TAG_DONE); k+=2)
	{
	if(ci=FindCollection(iff,collectchks[k],collectchks[k+1]))
	    {
	    D(bug("copying %.4s.%.4s collection\n",&collectchks[k],&collectchks[k+1]));
	    for(cii=ci, bk=0; cii; cii=cii->ci_Next)	bk++;

	    D(bug(" There are %ld of these, first is at $%lx\n",bk,ci));

	    for( bk; bk; bk--)
		{
 		for(kk=1, cii=ci; kk<bk; kk++) cii=cii->ci_Next;

		D(bug("  copying number %ld\n",kk));

	    	if(chunk=(struct Chunk *)
		    AllocMem(sizeof(struct Chunk),memtype|MEMF_CLEAR))
		    {
		    chunk->ch_Type = collectchks[k];
		    chunk->ch_ID   = collectchks[k+1];
		    if(chunk->ch_Data = AllocMem(cii->ci_Size,memtype))
		    	{
		    	chunk->ch_Size = cii->ci_Size;
		    	CopyMem(cii->ci_Data,chunk->ch_Data,cii->ci_Size);
		    	if(prevchunk)	prevchunk->ch_Next = chunk;
		    	else 		first = chunk;
		    	prevchunk = chunk;
		    	}
		    else
		    	{
		    	FreeMem(chunk,sizeof(struct Chunk));
		    	chunk=NULL;
		    	error = 1;
		    	}
		    }
	    	else error = 1;
		}
	    }
	}

    if(error)
	{
	if(first) freechunklist(first);
	first = NULL;
	}

    return(first);
    }


/* freechunklist - Free a dynamically allocated Chunk list and
 *   all of its ch_Data.
 *
 * Note - if a chunk's ch_Size is IFFSIZE_UNKNOWN, its ch_Data
 *   will not be deallocated.
 */
void freechunklist(struct Chunk *first)
    {
    struct Chunk *chunk, *next;

    chunk = first;
    while(chunk)
	{
	next = chunk->ch_Next;
	if((chunk->ch_Data)&&(chunk->ch_Size != IFFSIZE_UNKNOWN))
		FreeMem(chunk->ch_Data,chunk->ch_Size);
	FreeMem(chunk, sizeof(struct Chunk));	
	chunk = next;
	}
    }


/* findchunk - find first matching chunk in list of struct Chunks
 *    example  finchunk(pi->copiedchunks,ID_ILBM,ID_CRNG);
 *
 * returns struct Chunk *, or NULL if none found
 */
struct Chunk *findchunk(struct Chunk *first, long type, long id)
    {
    struct Chunk *chunk;

    for(chunk=first; chunk; chunk=chunk->ch_Next)
	{
	if((chunk->ch_Type == type)&&(chunk->ch_ID == id)) return(chunk); 
	}
    return(NULL);
    }


/* writechunklist - write out list of struct Chunk's
 * If data is a null terminated string, you may use
 * IFFSIZE_UNKNOWN as the ch_Szie and strlen(chunk->ch_Data)
 * will be used here as size.
 *
 * Returns 0 for success or an IFFERR
 */
long writechunklist(struct IFFHandle *iff, struct Chunk *first)
    {
    struct Chunk *chunk;
    long size, error = 0;

    D(bug("writechunklist: first chunk pointer = $%lx\n",first));

    for(chunk=first; chunk && (!error); chunk=chunk->ch_Next)
	{
	size  = (chunk->ch_Size == IFFSIZE_UNKNOWN) ?
			strlen(chunk->ch_Data) :  chunk->ch_Size;
	error = PutCk(iff, chunk->ch_ID, size, chunk->ch_Data);
	D(bug("writechunklist: put %.4s size=%ld, error=%ld\n",
				&chunk->ch_ID,size, error));
	}
    return(error);
    }

