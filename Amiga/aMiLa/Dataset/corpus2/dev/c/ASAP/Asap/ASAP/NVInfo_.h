/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ANVInfo wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ANVInfo_H
#define ASAP_ANVInfo_H

#include <New.h>

extern "C"
{
 #include <Proto/Nonvolatile.h>
}

class ANVInfo : public NVInfo
{
 public:
 inline void FreeNVData();
 inline void operator delete(void *);
 inline static ANVInfo * GetNVInfo(long killRequesters = 1);
 inline void * operator new(size_t, BOOL killRequesters = 1);
};
//----------------------------------------------------------------------------
void ANVInfo::FreeNVData ()
{
 ::FreeNVData((APTR) this);
}
//----------------------------------------------------------------------------
void ANVInfo::operator delete(void *data)
{
 ((ANVInfo *) data)->FreeNVData();
}
//----------------------------------------------------------------------------
ANVInfo * ANVInfo::GetNVInfo (long killRequesters)
{
 return (ANVInfo *) ::GetNVInfo(killRequesters);
}
//----------------------------------------------------------------------------
void * ANVInfo::operator new (size_t, BOOL killRequesters)
{
 return ANVInfo::GetNVInfo(killRequesters);
}

#endif