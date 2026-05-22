/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AContextNode wrapper class                                                *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ContextNode_H
#define ASAP_ContextNode_H

extern "C"
{
 #include <Proto/IFFParse.h>
}

class AContextNode : public ContextNode
{
 public:
 inline static AContextNode * CurrentChunk(struct IFFHandle * iff);
 inline static AContextNode * FindPropContext(struct IFFHandle * iff);
 inline AContextNode * ParentChunk();
};
//----------------------------------------------------------------------------
AContextNode * AContextNode::CurrentChunk (struct IFFHandle * iff)
{
 return (AContextNode *) ::CurrentChunk(iff);
}
//----------------------------------------------------------------------------
AContextNode * AContextNode::FindPropContext (struct IFFHandle * iff)
{
 return (AContextNode *) ::FindPropContext(iff);
}
//----------------------------------------------------------------------------
AContextNode * AContextNode::ParentChunk ()
{
 return (AContextNode *) ::ParentChunk(this);
}

#endif
