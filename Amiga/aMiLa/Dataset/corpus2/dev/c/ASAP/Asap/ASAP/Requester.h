/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ARequester wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ARequester_H
#define ASAP_ARequester_H

extern "C"
{
 #include <Proto/Intuition.h>
}

class ARequester : public Requester
{
 public:
 inline void EndRequest(Window * window);
 inline void InitRequester();
 inline BOOL Request(Window * window);
};
//----------------------------------------------------------------------------
void ARequester::EndRequest (Window * window)
{
 ::EndRequest(this, window);
}
//----------------------------------------------------------------------------
void ARequester::InitRequester ()
{
 ::InitRequester(this);
}
//----------------------------------------------------------------------------
BOOL ARequester::Request (Window * window)
{
 return ::Request(this, window);
}

#endif
