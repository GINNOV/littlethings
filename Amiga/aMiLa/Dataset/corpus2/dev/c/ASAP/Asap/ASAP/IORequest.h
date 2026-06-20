/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIORequest wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_IORequest_H
#define ASAP_IORequest_H

#include <New.h>

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
 #include <Proto/EXEC.h>
}

class AIORequest : public IORequest
{
 public:
 inline void AbortIO();
 inline void BeginIO();
 inline AIORequest * CheckIO();
 inline void CloseDevice();
 inline static AIORequest * CreateExtIO(MsgPort * port, long ioSize);
 inline void * operator new(size_t, MsgPort * port, long ioSize);
 inline void DeleteExtIO();
 inline void operator delete(void *);
 inline BYTE DoIO();
 inline void SendIO();
 inline BYTE WaitIO();
};
//----------------------------------------------------------------------------
void AIORequest::AbortIO ()
{
 ::AbortIO(this);
}
//----------------------------------------------------------------------------
void AIORequest::BeginIO ()
{
 ::BeginIO(this);
}
//----------------------------------------------------------------------------
AIORequest * AIORequest::CheckIO ()
{
 return (AIORequest *) ::CheckIO(this);
}
//----------------------------------------------------------------------------
void AIORequest::CloseDevice ()
{
 ::CloseDevice(this);
}
//----------------------------------------------------------------------------
AIORequest * AIORequest::CreateExtIO (struct MsgPort * port, long ioSize)
{
 return (AIORequest *) ::CreateExtIO(port, ioSize);
}
//----------------------------------------------------------------------------
void * operator new (size_t, MsgPort * port, long ioSize)
{
 return AIORequest::CreateExtIO(port, ioSize);
}
//----------------------------------------------------------------------------
void AIORequest::DeleteExtIO ()
{
 ::DeleteExtIO(this);
}
//----------------------------------------------------------------------------
void AIORequest::operator delete (void *extIO)
{
 ((AIORequest *) extIO)->DeleteExtIO();
}
//----------------------------------------------------------------------------
BYTE AIORequest::DoIO ()
{
 return ::DoIO(this);
}
//----------------------------------------------------------------------------
void AIORequest::SendIO ()
{
 ::SendIO(this);
}
//----------------------------------------------------------------------------
BYTE AIORequest::WaitIO ()
{
 return ::WaitIO(this);
}

#endif
