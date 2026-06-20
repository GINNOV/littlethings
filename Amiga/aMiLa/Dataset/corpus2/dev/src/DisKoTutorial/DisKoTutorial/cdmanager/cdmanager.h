
#ifndef __CDMANAGER_H__

#define __CDMANAGER_H__

extern int CDM_Initialize(STRPTR device, int unit);
extern void CDM_DeInitialize(void);
extern int CDM_GetNumTracks(void);
extern void CDM_PlayTrack(int num);
extern void CDM_StopTrack(void);

#endif
