/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 * AMIGAGUIDEHOST wrapper class                                              *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMIGAGUIDEHOST_H
#define ASAP_AMIGAGUIDEHOST_H

#include <CLIB/AMIGAGUIDE_PROTOS.H>

class CAmigaGuideHost : public AmigaGuideHost
{
static
AmigaGuideHost */*APTR*/ AddAmigaGuideHost( Hook *h, STRPTR name, Tag tag1, ... );
static
AmigaGuideHost */*APTR*/ AddAmigaGuideHostA( Hook *h, STRPTR name, TagItem *attrs );
LONG RemoveAmigaGuideHost(/* APTR hh, */Tag tag1, ... );
LONG RemoveAmigaGuideHostA(/* APTR hh, */TagItem *attrs );
};
#endif