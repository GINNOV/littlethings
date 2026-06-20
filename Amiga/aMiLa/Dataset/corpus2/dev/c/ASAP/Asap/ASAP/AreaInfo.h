/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAreaInfo wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AreaInfo_H
#define ASAP_AreaInfo_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class AAreaInfo : public AreaInfo
{
 public:
 inline void InitArea(APTR vectorBuffer, long maxVectors);
};
//----------------------------------------------------------------------------
void AAreaInfo::InitArea (APTR vectorBuffer, long maxVectors)
{
 ::InitArea(this, vectorBuffer, maxVectors);
}

#endif
