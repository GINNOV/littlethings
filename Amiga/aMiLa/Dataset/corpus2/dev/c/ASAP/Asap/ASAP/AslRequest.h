/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAslRequest wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AAslRequest_H
#define ASAP_AAslRequest_H

#include <New.h>

extern "C"
{
 #include <Proto/Asl.h>
}

// template <int reqType>
class AAslRequest
{
 public:
 inline static AAslRequest * AllocAslRequest(unsigned long reqType, TagItem * tagList);
 inline void * operator new(size_t, unsigned long reqType, TagItem * tagList);
 inline static AAslRequest * AllocAslRequestTags(unsigned long reqType, Tag Tag1,  ...);
 inline void * operator new(size_t, unsigned long reqType, Tag Tag1,  ...);
 inline BOOL AslRequest(TagItem * tagList);
 inline BOOL AslRequestTags(Tag Tag1,  ...);
 inline void FreeAslRequest();
 inline void operator delete(void *requester);
};
//----------------------------------------------------------------------------
AAslRequest * AAslRequest::AllocAslRequest (unsigned long reqType, TagItem * tagList)
{
 return (AAslRequest *) ::AllocAslRequest(reqType, tagList);
}
//----------------------------------------------------------------------------
void * operator new(size_t, unsigned long reqType, TagItem * tagList);
{
 return AAslRequest::AllocAslRequest(reqType, tagList);
}
//----------------------------------------------------------------------------
AAslRequest * AAslRequest::AllocAslRequestTags (unsigned long reqType, Tag Tag1,  ...)
{
 return AAslRequest::AllocAslRequest(reqType, (TagItem *) &Tag1);
}
//----------------------------------------------------------------------------
void * AAslRequest::operator new (size_t, unsigned long reqType, Tag Tag1,  ...)
{
 return AAslRequest::AllocAslRequest(reqType, (TagItem *) &Tag1);
}
//----------------------------------------------------------------------------
BOOL AAslRequest::AslRequest (TagItem * tagList)
{
 return ::AslRequest(this, tagList);
}
//----------------------------------------------------------------------------
BOOL AAslRequest::AslRequestTags (Tag Tag1,  ...)
{
 return AAslRequest::AslRequest(this, (TagItem *) &Tag1);
}
//----------------------------------------------------------------------------
void AAslRequest::FreeAslRequest (APTR requester)
{
 ::FreeAslRequest(requester);
}
//----------------------------------------------------------------------------
void AAslRequest::operator delete(void *requester)
{
 ((AAslRequest *) requester)->FreeAslRequest(requester);
}
