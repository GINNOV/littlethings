/* ------------------------------------------------------------------ */
/* $VER: easyaudio_protos.h 39.01 (12.12.1999)                        */
/*                                                                    */
/* prototypes for easyaudio.library                                   */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#ifndef CLIB_EASYAUDIO_PROTOS_H
#define CLIB_EASYAUDIO_PROTOS_H

#ifndef EASYAUDIO_EASYAUDIO_H
#include <easyaudio/easyaudio.h>
#endif /* EASYAUDIO_EASYAUDIO_H */

ULONG EA_Request( UBYTE *title, UBYTE *body, UBYTE *gadgets);

ULONG EA_Speech(char *text);

ULONG EA_Beep(ULONG frequency, ULONG duration);

struct SoundInfo *EA_PrepareSound( STRPTR file);

BOOL EA_PlaySound( struct SoundInfo *info, UWORD volume, UBYTE channel,
                   BYTE priority, WORD delta_rate, UWORD times, ULONG start,
                   ULONG time, BOOL wait);

void EA_StopSound(UBYTE channel);

void EA_RemoveSound(struct SoundInfo *info);

#endif /* CLIB_EASYAUDIO_PROTOS_H */
