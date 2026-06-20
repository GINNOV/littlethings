/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AResident wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AResident_H
#define ASAP_AResident_H

extern "C"
{
 #include <EXEC/Resident.h>
 #include <Proto/EXEC.h>
}

class AResident : public Resident
{
 public:
 inline static AResident * FindResident(UBYTE * name);
 inline APTR InitResident(unsigned long segList);
};
//----------------------------------------------------------------------------
AResident * AResident::FindResident (UBYTE * name)
{
 return (AResident *) ::FindResident(name);
}
//----------------------------------------------------------------------------
APTR AResident::InitResident (unsigned long segList)
{
 return ::InitResident(this, segList);
}

#endif
