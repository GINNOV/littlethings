/********************************************************************

				 MemMan.h
			    Low-memory manager
		       Copyright (C) 1991 Bryan	Ford

********************************************************************/

/* To use memman.library, #define MM_RUNLIB before including this file.	*/

#ifndef	BRY_MEMMAN_H
#define	BRY_MEMMAN_H

#ifndef	EXEC_NODES_H
#include <exec/nodes.h>
#endif

/* Some	special	provisions to support both link	and runtime libraries */
#ifdef __SASC
#  define MM_REGARGS __regargs
#  ifndef MM_RUNLIB
#    define MM_ASM __asm
#    define MM_REG(r) register __ ## r
#  endif
#else
#  define MM_REGARGS
#endif
#ifndef	MM_ASM
#  define MM_ASM
#  define MM_REG(r)
#endif

struct MMNode
  {
    struct Node	Node;			/* Link	into systemwide	MMList */
    long MM_REGARGS (*GetRidFunc)(long size,long memtype,void *data);
    void *GetRidData;			/* Data	to send	to GetRidFunc */
  };
#define	MMNT_LINKED NT_USER		/* Special ln_Type means this node is active */

/* Prototypes */
#ifndef	MM_RUNLIB /* Init and Finish are automatic in the library version */
int MM_ASM MMInit(void);
void MM_ASM MMFinish(void);
#endif
void MM_ASM MMAddNode(MM_REG(a1) struct	MMNode *mmnode);
void MM_ASM MMRemNode(MM_REG(a1) struct	MMNode *mmnode);

/* Manx	register assignments for the linked version */
#ifdef AZTEC_C
#  ifndef MM_RUNLIB
#    pragma regcall(MMAddNode(a1))
#    pragma regcall(MMRemNode(a1))
#  endif
#endif

/* This	part defines the the function calls for	use with the runtime library. */
/* These pragmas (SAS style) will work for both	AZTEC C	and SAS/C */
#ifdef AMIGA
#  ifdef MM_RUNLIB
#    pragma libcall MMBase MMAddNode 1E	901
#    pragma libcall MMBase MMRemNode 24	901
#  endif
#endif

#undef MM_REGARGS
#undef MM_ASM
#undef MM_REG

#endif
