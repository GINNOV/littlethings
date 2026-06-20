/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ACopList wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_CopList_H
#define ASAP_CopList_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
}

class ACopList : public CopList
{
 public:
 inline void FreeCopList();
 inline void operator delete(void *);
 inline static ACopList * UCopperListInit(UCopList *, long n);
 inline void * operator new(size_t, UCopList *, long n);
};
//----------------------------------------------------------------------------
void ACopList::FreeCopList ()
{
 ::FreeCopList(this);
}
//----------------------------------------------------------------------------
void ACopList::operator delete (void *copList)
{
 ((ACopList *) copList)->FreeCopList();
}
//----------------------------------------------------------------------------
ACopList * ACopList::UCopperListInit (UCopList *ucopList, long n)
{
 return (ACopList *) ::UCopperListInit(ucopList, n);
}
//----------------------------------------------------------------------------
void * operator new (size_t, UCopList *ucopList, long n)
{
 return ACopList::UCopperListInit(ucopList, n);
}

#endif
