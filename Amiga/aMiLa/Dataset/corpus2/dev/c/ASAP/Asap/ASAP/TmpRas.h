/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ATmpRas wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ATmpRas_H
#define ASAP_ATmpRas_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class ATmpRas : public TmpRas
{
 public:
 inline ATmpRas * InitTmpRas(PLANEPTR buffer, long size);
};
//----------------------------------------------------------------------------
ATmpRas * ATmpRas::InitTmpRas (PLANEPTR buffer, long size)
{
 return (ATmpRas *) ::InitTmpRas(this, buffer, size);
}

#endif
