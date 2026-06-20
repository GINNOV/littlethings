/*
** This C prototypes file was generated automatically
** from a document file
** using doc2protos written by Claus Bönnhoff.
*/

#include <exec/types.h>

void T_IoErr(void);
BOOL T_RawPlayback(struct TagItem *);
BOOL T_SaveSettings(ULONG);
BOOL T_LoadSettings(ULONG);
WORD T_Expand(UBYTE, ULONG);
BOOL T_StartLevel(struct TagItem *);
BOOL T_Capture(struct TagItem *);
BOOL T_Playback(struct TagItem *);
void T_Pause(ULONG);
void T_Stop(ULONG);
void T_StopLevel(void);
ULONG T_FindFrequency(ULONG);
ULONG T_NextFrequency(ULONG);
void T_SetPart(struct TagItem *);
void T_GetPart(struct TagItem *);
