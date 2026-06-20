#ifndef LIBRARIES_NOFRAG_H
#define LIBRARIES_NOFRAG_H 1

/*-- AutoRev header do NOT edit!
*
*   Program         :   nofrag.h
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
*   13-Apr-92     2.2             Removed mungwall hits.
*   19-May-91     2.1             Added 'Vec' routines.
*   06-Apr-91     1.1             Initial version!
*
*-- REV_END --*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_MEMORY_H
#include <exec/memory.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

struct NoFragBase
{
    struct  Library     LibNode;
};

#define NOFRAG_VERSION  2
#define NOFRAG_REVISION 2

/*
 * ALL structures following are PRIVATE! DO NOT USE THEM!
 */
struct MemoryBlock
{
    struct MemoryBlock *Next;
    struct MemoryBlock *Previous;
    ULONG               Requirements;
    ULONG               BytesUsed;
};

struct MemoryItem
{
    struct MemoryItem  *Next;
    struct MemoryItem  *Previous;
    struct MemoryBlock *Block;
    ULONG               Size;
};

struct BlockList
{
    struct MemoryBlock *First;
    struct MemoryBlock *End;
    struct MemoryBlock *Last;
};

struct ItemList
{
    struct MemoryItem  *First;
    struct MemoryItem  *End;
    struct MemoryItem  *Last;
};

/*
 * This structure may only be used to pass on to the library routines!
 * It may ONLY be obtained by a call to "GetMemoryChain()"
 */
struct MemoryChain
{
    struct BlockList    Blocks;
    struct ItemList     Items;
    ULONG               BlockSize;
};

#define MINALLOC        sizeof(struct MemoryItem)

#endif
