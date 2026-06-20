/* ------------------------------------------------------------------ */
/* $VER: esayaudio_lib.h 39.01 (12.12.1999)                           */
/*                                                                    */
/* pragmas for easyaudio.library and gcc 2.91                         */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#ifndef _INCLUDE_PRAGMA_EASYAUDIO_LIB_H
#define _INCLUDE_PRAGMA_EASYAUDIO_LIB_H

#ifndef CLIB_EXAMPLE_PROTOS_H
#include <clib/easyaudio_protos.h>
#endif

#pragma amicall(EasyaudioBase,0x01E,EA_Request(d1,d2,d3))
#pragma amicall(EasyaudioBase,0x024,EA_Speech(d1))
#pragma amicall(EasyaudioBase,0x02A,EA_Beep(d1,d2))
#pragma amicall(EasyaudioBase,0x030,EA_PrepareSound(d1))
#pragma amicall(EasyaudioBase,0x036,EA_PlaySound(d1,d2,d3,d4,d5,d6,a2,a3,a4))
#pragma amicall(EasyaudioBase,0x03C,EA_StopSound(d1))
#pragma amicall(EasyaudioBase,0x042,EA_RemoveSound(d1))

#endif  /*  _INCLUDE_PRAGMA_EASYAUDIO_LIB_H  */
