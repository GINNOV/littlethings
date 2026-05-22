/* memory.h - exec library function prototypes */
#ifndef EXEC_MEMORY_H
#define EXEC_MEMORY_H
/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/
#ifndef EXEC_NODES_H
#include "exec/nodes.h"
#endif !EXEC_NODES_H


/****** MemChunk ****************************************************/

struct  MemChunk {
    MemChunk *mc_Next;	/* pointer to next chunk */
    ULONG   mc_Bytes;		/* chunk byte size	*/

    MemChunk *next() { return mc_Next; }
};


/****** MemHeader ***************************************************/

struct	MemHeader : public Node {
    UWORD   mh_Attributes;	/* characteristics of this region */
    MemChunk *mh_First;		/* first free region		*/
    APTR    mh_Lower;		/* lower memory bound		*/
    APTR    mh_Upper;		/* upper memory bound+1		*/
    ULONG   mh_Free;		/* total number of free bytes	*/ 
};


/****** MemEntry ****************************************************/

struct	MemEntry {
union {
    ULONG   meu_Reqs;		/* the AllocMem requirements */
    APTR    meu_Addr;		/* the address of this memory region */
    } me_Un;
    ULONG   me_Length;		/* the length of this memory region */
};

#define me_un	    me_Un	/* compatability */
#define me_Reqs	    me_Un.meu_Reqs
#define me_Addr	    me_Un.meu_Addr


/****** MemList *****************************************************/

struct	MemList : public Node {
    UWORD   ml_NumEntries;	/* number of entries in this struct */
    MemEntry ml_ME[1];		/* the first entry	*/

	friend MemList * AllocEntry(const struct MemList *ml);
	friend void FreeEntry(struct MemList *ml);
};

#define ml_me	ml_ME		/* compatability */


/*----- Memory Requirement Types ---------------------------*/

const int MEMF_PUBLIC = (1<<0);
const int MEMF_CHIP =   (1<<1);
const int MEMF_FAST =   (1<<2);

const int MEMF_CLEAR = (1<<16);
const int MEMF_LARGEST = (1<<17);

const int MEM_BLOCKSIZE = 8;
const int MEM_BLOCKMASK = 7;

int AddMemList(const int size, const int attribs,
	 const int priority, const APTR base, const TEXT *name);

APTR AllocAbs(const int bytesize, const APTR loc);
APTR Allocate(const struct FreeList *fl, int bytesize);
void Deallocate(struct FreeList *fl, struct MemoryBlock *mb,
	const int bytes);

APTR AllocMem(const int numbytes, const int memtype);

int AvailMem(const int memtype);
void CopyMem(const APTR src, const APTR dest, const int size);
void CopyMemQuick(const LONG *src, const LONG *dst, const int size);

void FreeMem(const APTR mem, const int size);
int TypeOfMem(APTR mem);

#endif
