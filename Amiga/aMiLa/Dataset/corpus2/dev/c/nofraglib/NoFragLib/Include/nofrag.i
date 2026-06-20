    IFND    LIBRARIES_NOFRAG_I
LIBRARIES_NOFRAG_I  SET 1

*-- AutoRev header do NOT edit!
*
*   Program         :   nofrag.i
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
*-- REV_END --*

    IFND EXEC_TYPES_I
        include 'exec/types.i'
    ENDC

    IFND EXEC_MEMORY_I
        include 'exec/memory.i'
    ENDC

    IFND EXEC_LISTS_I
        include 'exec/lists.i'
    ENDC

    IFND EXEC_LIBRARIES_I
        include 'exec/libraries.i'
    ENDC

    STRUCTURE   NoFragBase,LIB_SIZE
    LABEL       nfb_SIZEOF

NOFRAG_VERSION  equ     2
NOFRAG_REVISION equ     2

*
* ALL structures following are PRIVATE! DO NOT USE THEM!
*
    STRUCTURE   MemoryBlock,0
    APTR        mb_Next
    APTR        mb_Previous
    ULONG       mb_Requirements
    ULONG       mb_BytesUsed
    LABEL       mb_SIZEOF

    STRUCTURE   MemoryItem,0
    APTR        mit_Next
    APTR        mit_Previous
    APTR        mit_Block
    ULONG       mit_Size
    LABEL       mit_SIZEOF

    STRUCTURE   BlockList,0
    APTR        bl_First
    APTR        bl_End
    APTR        bl_Last
    LABEL       bl_SIZEOF

    STRUCTURE   ItemList,0
    APTR        il_First
    APTR        il_End
    APTR        il_Last
    LABEL       il_SIZEOF

*
* This structure may only be used to pass on to the library routines!
* It may ONLY be obtained by a call to "GetMemoryChain()"
*
    STRUCTURE   MemoryChain,0
    STRUCT      mc_Blocks,bl_SIZEOF
    STRUCT      mc_Items,il_SIZEOF
    ULONG       mc_BlockSize
    LABEL       mc_SIZEOF

MINALLOC        equ     mit_SIZEOF

 ENDC
