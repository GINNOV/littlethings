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

#ifdef AZTEC_C
#pragma amicall(NoFragBase, 0x1e, GetMemoryChain(d0))
#pragma amicall(NoFragBase, 0x24, AllocItem(a0,d0,d1))
#pragma amicall(NoFragBase, 0x2a, FreeItem(a0,a1,d0))
#pragma amicall(NoFragBase, 0x30, FreeMemoryChain(a0,d0))
#pragma amicall(NoFragBase, 0x36, AllocVecItem(a0,d0,d1))
#pragma amicall(NoFragBase, 0x3c, FreeVecItem(a0,a1))
#else
#pragma libcall NoFragBase GetMemoryChain 1e 1
#pragma libcall NoFragBase AllocItem 24 10803
#pragma libcall NoFragBase FreeItem 2a 9803
#pragma libcall NoFragBase FreeMemoryChain 30 802
#pragma libcall NoFragBase AllocVecItem 36 10803
#pragma libcall NoFragBase FreeVecItem 3c 9802
#endif

#endif
