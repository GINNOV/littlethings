/* ------------------------------------------------------------------ */
/* $VER: easyaudiobase.h 39.01 (12.12.1999)                           */
/*                                                                    */
/* definition of EasyaudioBase                                        */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#ifndef EASYAUDIO_EASYAUDIOBASE_H
#define EASYAUDIO_EASYAUDIOBASE_H

#ifndef  EXEC_LIBRARIES
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */


struct EasyaudioBase
{
 struct Library         eab_LibNode;
 SEGLISTPTR             eab_SegList;
 struct ExecBase       *eab_SysBase;
 struct IntuitionBase  *eab_IntuitionBase;
 struct DOSLibrary     *eab_DOSBase;
 struct GfxBase        *eab_GfxBase;
 struct Library        *eab_UtilityBase;
};

#endif /* EASYAUDIO_EASYAUDIOBASE_H */
