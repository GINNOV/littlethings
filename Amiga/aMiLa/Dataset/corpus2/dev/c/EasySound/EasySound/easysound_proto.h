#ifndef EASYSOUND_PROTO_H
#define EASYSOUND_PROTO_H

/* easysound.c          */

BOOL PlayIff(struct SoundInfo *info, UWORD vol, UBYTE chan, BYTE prio, WORD drate, UWORD repeat, ULONG start, ULONG time, BOOL wait);
void StopIff(UBYTE chan);
LONG GetClockSpeed(void);
BOOL PlayIff (struct SoundInfo *info, UWORD vol, UBYTE chan, BYTE prio, WORD drate, UWORD repeat, ULONG start, ULONG time, BOOL wait);
void StopIff (UBYTE chan);
LONG GetClockSpeed(void);
void RemoveIff(struct SoundInfo *info);
struct SoundInfo *LoadIff(STRPTR name);
void FindChunk(BPTR file, char *searchchunk);

#endif

