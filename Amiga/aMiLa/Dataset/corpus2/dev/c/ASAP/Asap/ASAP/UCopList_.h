/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AUCopList wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AUCopList_H
#define ASAP_AUCopList_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class AUCopList : public UCopList
{
 public:
 inline void CBump();
 inline void CMove(APTR destination, long data);
 inline void CWait(long v, long h);
};
//----------------------------------------------------------------------------
void AUCopList::CBump ()
{
 ::CBump(this);
}
//----------------------------------------------------------------------------
void AUCopList::CMove (APTR destination, long data)
{
 ::CMove(this, destination, data);
}
//----------------------------------------------------------------------------
void AUCopList::CWait (long v, long h)
{
 ::CWait(this, v, h);
}

#endif
