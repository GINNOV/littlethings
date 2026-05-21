/************************************************************
 * Sound Track Driver for Scheduler			    *
 ************************************************************
 * Finally written by _-=BN=-_ in late June 1988            *
 ***********************************************************/
 
#ifndef SOUND_H
#define SOUND_H


struct Music_Instrument {
   char *Name;			/* Name */
   char *Sample[5];		/* 5 samples */
};

typedef struct {
   SEvent *Track;		/* Address of first note */
   int Length;			/* Length of track in bytes */
   SEvent *CurPos;		/* Cursor Address in track */
   int SndPC;			/* Current Instrument Number */
   int Channel;			/* Amiga Channel number */
   UWORD *SamplePtr;
   UWORD SampleLength;
   UWORD *OctavePtr;
   UWORD Volume;
} TrackDesc;


typedef struct Music_Instrument MUS_Instr;
typedef struct Music_Instrument *MUS_PInstr;

extern TrackDesc Track[4];	/* Up to four tracks */
extern MUS_Instr Instrument[10];/* Up to ten instruments */

#endif
