/* ------------------------------------------------------------------ */
/* $VER: Func_Sound.h 39.01 (12.12.1999)                              */
/*                                                                    */
/* Yet more headers for easyaudio.library _sound functions_           */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#include <exec/types.h>

/* Sound channels: */
#define LEFT0         0
#define RIGHT0        1
#define RIGHT1        2
#define LEFT1         3

#define NONSTOP       0 /* Play the sound over and over... */
#define ONCE          1 /* Play the sound once. */ 
#define MAXVOLUME    64 /* Maximum volume. */
#define MINVOLUME     0 /* Minimum volume. */
#define NORMALRATE    0 /* Normal rate. */
#define DO_NOT_WAIT   0 /* Do not wait for the sound to be completed. */ 
#define WAIT          1 /* Wait for the sound to be completed. */

/* Sound priorities: */
#define SOUND_PRI_UNSTOPPABLE  (BYTE)127
#define SOUND_PRI_EMERGENCIES  (BYTE)95
#define SOUND_PRI_ATTENTION    (BYTE)85
#define SOUND_PRI_SPEECH       (BYTE)75
#define SOUND_PRI_INFORMATION  (BYTE)60
#define SOUND_PRI_MUSIC        (BYTE)0
#define SOUND_PRI_EFFECT       (BYTE)-35
#define SOUND_PRI_BACKGROUND   (BYTE)-90
#define SOUND_PRI_SILENCE      (BYTE)-128

/* SoundInfo structure: */
struct SoundInfo
{
  BYTE *SoundBuffer; /* WaveForm Buffers.           */
  UWORD RecordRate;  /* Record Rate.                */
  ULONG FileLength;  /* WaveForm Lengths.           */
  UBYTE channel_bit; /* Audio channel bit position. */
};

