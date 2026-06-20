/* ------------------------------------------------------------------ */
/* $VER: easyaudio_pragmas.h 39.01 (12.12.1999)                       */
/*                                                                    */
/* pragmas for easyaudio.library on non gcc compilers                 */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#ifndef PRAGMAS_EASYAUDIO_H
#define PRAGMAS_EASYAUDIO_H

#pragma  libcall EasyaudioBase EA_Request           01E 32103
#pragma  libcall EasyaudioBase EA_Speech            024 101
#pragma  libcall EasyaudioBase EA_Beep              02A 2102
#pragma  libcall EasyaudioBase EA_PrepareSound      030 101
#pragma  libcall EasyaudioBase EA_PlaySound         036 CBA65432109
#pragma  libcall EasyaudioBase EA_StopSound         03C 101
#pragma  libcall EasyaudioBase EA_RemoveSound       042 101

#endif /* PRAGMAS_EXAMPLE_H */
