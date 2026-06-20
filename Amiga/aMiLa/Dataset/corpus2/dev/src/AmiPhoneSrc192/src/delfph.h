
#include <string.h>
#include <stdlib.h>
#include <exec/types.h>

/* function headers for delfph.c */


BOOL InitDelfina(void);
void CleanupDelfina(void);
BOOL StartDelfina(int samplerate, int bufsize, int compr, int ch);
void StopDelfina(void);
int DelfPacket(void *buf, int size, ULONG * setJoinCode);
int GetClosestDelfRate(int nIdealRate, int * pnOptSetFreq, int * pnOptSetDiv);
