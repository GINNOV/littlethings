#ifndef CLIB_NOFRAG_PROTOS_H
#define CLIB_NOFRAG_PROTOS_H 1

/*-- AutoRev header do NOT edit!
*
*   Program         :   nofrag_protos.h
*   Copyright       :   © 1991 Jaba Development
*   Author          :   Jan van den Baard
*   Creation Date   :   06-Apr-91
*   Current version :   2.2
*   Translator      :   Several
*
*   REVISION HISTORY
*
*   Date          Version         Comment
*   ---------     -------         ------------------------------------------
*   13-Apr-92     2.2             Removed Mungwall hits.
*   19-May-91     2.1             Added 'Vec' routines.
*   06-Apr-91     1.1             Initial version!
*
*-- REV_END --*/

#ifndef LIBRARIES_NOFRAG_H
#include <libraries/nofrag.h>
#endif

/*--- version 1.1 names. ---*/
struct MemoryChain *GetMemoryChain(ULONG blocksize);
void *AllocItem(struct MemoryChain *chain, ULONG size, ULONG requirements);
void FreeItem(struct MemoryChain *chain, void *memptr, ULONG size);
void FreeMemoryChain(struct MemoryChain *chain, ULONG all);
/*--- version 2.1 names. ---*/
void *AllocVecItem(struct MemoryChain *chain, ULONG size, ULONG requirements);
void FreeVecItem(struct MemoryChain *chain, void *memptr);
#endif
