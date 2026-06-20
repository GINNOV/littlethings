/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AFileRequester wrapper class                                              *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AFileRequester_H
#define ASAP_AFileRequester_H

#include <New.h>

extern "C"
{
 #include <Proto/ASL.h>
}

class AFileRequester : public FileRequester
{
 public:
 inline static AFileRequester * AllocFileRequest();
 inline void * operator new(size_t);
 inline void FreeFileRequest();
 inline void * operator delete(void *fileReq); 
 inline BOOL RequestFile();
};
//----------------------------------------------------------------------------
AFileRequester * AFileRequester::AllocFileRequest ()
{
 return (AFileRequester *) ::AllocFileRequest();
}
//----------------------------------------------------------------------------
void * AFileRequester::operator new (size_t)
{
 return AFileRequester::AllocFileRequest();
}
//----------------------------------------------------------------------------
void AFileRequester::FreeFileRequest ()
{
 ::FreeFileRequest(this);
}
void AFileRequester::operator delete (void *fileReq)
{
 ((AFileRequest *) fileReq)->FreeFileRequest();
}
//----------------------------------------------------------------------------
BOOL AFileRequester::RequestFile ()
{
 return ::RequestFile(this);
}

#endif
