#ifndef _SGESOUND_H
#define _SGESOUND_H

#include <sge.h>

typedef struct {
	Mix_Chunk *data;
	int playing;
	int channel;
	char *internalID;
} SGESOUND;

void sgeSetDefaultSampleRate(int rate);
int sgeGetDefaultSampleRate(void);
void sgeSetVolume(int volume);
int sgeGetVolume(void);
SGESOUND *sgeSoundNew(SGEFILE *f, const char *name);
void sgeSoundDestroy(SGESOUND *m);

void sgeSoundPlay(SGESOUND *m, int loop, int fadeinms);
void sgeSoundStop(SGESOUND *m, int fadeoutms);
int sgeSoundIsPlaying(SGESOUND *m);

#endif
