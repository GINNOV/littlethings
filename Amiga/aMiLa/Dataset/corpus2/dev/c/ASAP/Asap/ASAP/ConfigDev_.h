/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AConfigDev wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ConfigDev_H
#define ASAP_ConfigDev_H

#include <New.h>

extern "C"
{
 #include <Proto/Expansion.h>
}

class AConfigDev : public ConfigDev
{
 public:
 inline void AddConfigDev();
 inline static AConfigDev * AllocConfigDev();
 inline void * operator new();
 inline static AConfigDev * FindConfigDev(long manufacturer, long product);
 inline void FreeConfigDev();
 inline void operator delete(void *);
 inline void RemConfigDev();
};
//----------------------------------------------------------------------------
void AConfigDev::AddConfigDev ()
{
 ::AddConfigDev(this);
}
//----------------------------------------------------------------------------
AConfigDev * AConfigDev::AllocConfigDev ()
{
 return (AConfigDev *) ::AllocConfigDev();
}
//----------------------------------------------------------------------------
void * AConfigDev::operator new ()
{
 return AConfigDev::AllocConfigDev();
}
//----------------------------------------------------------------------------
AConfigDev * AConfigDev::FindConfigDev (long manufacturer, long product)
{
 return (AConfigDev *) ::FindConfigDev(this, manufacturer, product);
}
//----------------------------------------------------------------------------
void AConfigDev::FreeConfigDev ()
{
 ::FreeConfigDev(this);
}
//----------------------------------------------------------------------------
void AConfigDev::operator delete (void *configDev)
{
 ((AConfigDev *) configDev)->FreeConfigDev();
}
//----------------------------------------------------------------------------
void AConfigDev::RemConfigDev ()
{
 ::RemConfigDev(this);
}

#endif
