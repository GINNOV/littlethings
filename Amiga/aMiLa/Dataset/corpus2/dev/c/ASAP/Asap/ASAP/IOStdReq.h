/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIOStdReq wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_IOStdReq_H
#define ASAP_IOStdReq_H

#include <New.h>

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
 #include <EXEC/IO.h>
}

class AIOStdReq : public IOStdReq
{
 public:
 inline static AIOStdReq * CreateStdIO(MsgPort * port);
 inline void * operator new(size_t, MsgPort * port);
 inline void DeleteStdIO();
 inline void operator delete(void *);
};
//----------------------------------------------------------------------------
AIOStdReq * AIOStdReq::CreateStdIO (struct MsgPort * port)
{
 return (AIOStdReq *) ::CreateStdIO(port);
}
//----------------------------------------------------------------------------
void * operator new (size_t, MsgPort * port)
{
 return AIOStdReq::CreateStdIO(port);
}
//----------------------------------------------------------------------------
void AIOStdReq::DeleteStdIO ()
{
 ::DeleteStdIO(this);
}
//----------------------------------------------------------------------------
void AIOStdReq::operator delete(void *ioReq)
{
 ((AIOStdReq *) ioReq)->DeleteStdIO();
}

#endif
