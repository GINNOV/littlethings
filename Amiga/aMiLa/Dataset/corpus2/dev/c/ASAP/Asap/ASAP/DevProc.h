/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADevProc wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DevProc_H
#define ASAP_DevProc_H

#include <New.h>

extern "C"
{
 #include <Proto/DOS.h>
}

class ADevProc : public DevProc
{
 public:
 inline void FreeDeviceProc();
 inline void operator delete(void *);
 inline ADevProc * GetDeviceProc(STRPTR name);
 inline void * operator new(size_t, STRPTR name);
};
//----------------------------------------------------------------------------
void ADevProc::FreeDeviceProc ()
{
 ::FreeDeviceProc(this);
}
//----------------------------------------------------------------------------
void ADevProc::operator delete (void *devProc)
{
 ((ADevProc *) devProc)->FreeDeviceProc();
}
//----------------------------------------------------------------------------
ADevProc * ADevProc::GetDeviceProc (STRPTR name)
{
 return (ADevProc *) ::GetDeviceProc(name, this);
}
//----------------------------------------------------------------------------
void * ADevProc::operator new(size_t, STRPTR name)
{
 return (ADevProc *) ::GetDeviceProc(name, 0);
}

#endif
