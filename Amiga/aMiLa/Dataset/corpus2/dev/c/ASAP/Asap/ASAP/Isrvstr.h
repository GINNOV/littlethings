/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIsrvstr wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AIsrvstr_H
#define ASAP_AIsrvstr_H

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
}

class AIsrvstr : public Isrvstr
{
 public:
 inline void AddTOF(long (* p)(), long a);
 inline void RemTOF();
};
//----------------------------------------------------------------------------
void AIsrvstr::AddTOF (long (* p)(), long a)
{
 ::AddTOF(this, p, a);
}
//----------------------------------------------------------------------------
void AIsrvstr::RemTOF ()
{
 ::RemTOF(this);
}

#endif
