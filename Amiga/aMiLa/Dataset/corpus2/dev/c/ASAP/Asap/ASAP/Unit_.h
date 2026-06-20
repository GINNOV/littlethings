/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AUnit wrapper class                                                       *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AUnit_H
#define ASAP_AUnit_H

extern "C"
{
 #include <Proto/Disk.h>
}

class AUnit
{
 public:
 inline static BOOL AllocUnit(long unitNum);
 inline static void FreeUnit(long unitNum);
 inline static LONG GetUnitID(long unitNum);
 inline static void GiveUnit();
 inline static LONG ReadUnitID(long unitNum);
};
//----------------------------------------------------------------------------
BOOL AUnit::AllocUnit (long unitNum)
{
 return ::AllocUnit(unitNum);
}
//----------------------------------------------------------------------------
void AUnit::FreeUnit (long unitNum)
{
 ::FreeUnit(unitNum);
}
//----------------------------------------------------------------------------
LONG AUnit::GetUnitID (long unitNum)
{
 return ::GetUnitID(unitNum);
}
//----------------------------------------------------------------------------
void AUnit::GiveUnit ()
{
 ::GiveUnit();
}
//----------------------------------------------------------------------------
LONG AUnit::ReadUnitID (long unitNum)
{
 return ::ReadUnitID(unitNum);
}

#endif
