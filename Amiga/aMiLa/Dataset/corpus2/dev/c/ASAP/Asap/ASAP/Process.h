/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AProcess wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AProcedure_H
#define ASAP_AProcedure_H

extern "C"
{
 #include <Proto/DOS.h>
}

class AMsgPort;

class AProcess : public Process
{
 public:
 inline static AProcess * CreateNewProc(TagItem * tags);
 inline static AProcess * CreateNewProcTagList(TagItem * tags);
 inline static AProcess * CreateNewProcTags(unsigned long tag1type,  ...);
 inline static AMsgPort * CreateProc(STRPTR name, long pri, BPTR segList, long stackSize);
};
//----------------------------------------------------------------------------
AProcess * AProcess::CreateNewProc (TagItem * tags)
{
 return (AProcess *) ::CreateNewProc(tags);
}
//----------------------------------------------------------------------------
AProcess * AProcess::CreateNewProcTagList (TagItem * tags)
{
 return (AProcess *) ::CreateNewProcTagList(tags);
}
//----------------------------------------------------------------------------
AProcess * AProcess::CreateNewProcTags (unsigned long tag1type,  ...)
{
 return (AProcess *) ::CreateNewProcTagList((TagItem *) &tag1type);
}
//----------------------------------------------------------------------------
AMsgPort * AProcess::CreateProc (STRPTR name, long pri, BPTR segList, long stackSize)
{
 return (AMsgPort *) ::CreateProc(name, pri, segList, stackSize);
}

#endif
