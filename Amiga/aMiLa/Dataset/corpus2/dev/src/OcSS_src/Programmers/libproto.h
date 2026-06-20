#ifndef NO_PRAGMAS
/* prototypes for medplayer.library V2.0 - V7.0*/
#pragma libcall MEDPlayerBase GetPlayer 1e 001
#pragma libcall MEDPlayerBase FreePlayer 24 0
#pragma libcall MEDPlayerBase PlayModule 2a 801
#pragma libcall MEDPlayerBase ContModule 30 801
#pragma libcall MEDPlayerBase StopPlayer 36 0
/*#pragma libcall MEDPlayerBase DimOffPlayer 3c 001*/
#pragma libcall MEDPlayerBase SetTempo 42 001
#pragma libcall MEDPlayerBase LoadModule 48 801
#pragma libcall MEDPlayerBase UnLoadModule 4e 801
#pragma libcall MEDPlayerBase GetCurrentModule 54 0
#pragma libcall MEDPlayerBase ResetMIDI 5a 0
/* functions below in V2.00 or later*/
#pragma libcall MEDPlayerBase SetModnum 60 001
#pragma libcall MEDPlayerBase RelocModule 66 801
/* functions below in V7.00 or later*/
#pragma libcall MEDPlayerBase RequiredPlayRoutine 6c 801
#pragma libcall MEDPlayerBase FastMemPlayRecommended 72 801
#pragma libcall MEDPlayerBase LoadModule_Fast 78 801
#pragma libcall MEDPlayerBase SetFastMemPlay 7e 1002

/* prototypes for OctaPlayer.library */
#pragma libcall OctaPlayerBase GetPlayer8 1E 0
#pragma libcall OctaPlayerBase FreePlayer8 24 0
#pragma libcall OctaPlayerBase PlayModule8 2A 801
#pragma libcall OctaPlayerBase ContModule8 30 801
#pragma libcall OctaPlayerBase StopPlayer8 36 0
#pragma libcall OctaPlayerBase LoadModule8 3C 801
#pragma libcall OctaPlayerBase UnLoadModule8 42 801
#pragma libcall OctaPlayerBase SetModnum8 48 001
#pragma libcall OctaPlayerBase RelocModule8 4E 801
#pragma libcall OctaPlayerBase SetHQ 54 1
/* functions below in V7.00 or later*/
#pragma libcall OctaPlayerBase RequiredPlayRoutine8 5a 801
#pragma libcall OctaPlayerBase FastMemPlayRecommended8 60 801
#pragma libcall OctaPlayerBase LoadModule_Fast8 66 801
#pragma libcall OctaPlayerBase SetFastMemPlay8 6c 1002

/* prototypes for octamixplayer.library V7*/
#pragma libcall OctaMixPlayerBase GetPlayerM 1e 0
#pragma libcall OctaMixPlayerBase FreePlayerM 24 0
#pragma libcall OctaMixPlayerBase PlayModuleM 2a 801
#pragma libcall OctaMixPlayerBase ContModuleM 30 801
#pragma libcall OctaMixPlayerBase StopPlayerM 36 0
#pragma libcall OctaMixPlayerBase LoadModule_FastM 3c 801
#pragma libcall OctaMixPlayerBase UnLoadModuleM 42 801
#pragma libcall OctaMixPlayerBase SetModnumM 48 001
#pragma libcall OctaMixPlayerBase RelocModuleM 4e 801
#pragma libcall OctaMixPlayerBase RequiredPlayRoutineM 54 801
#pragma libcall OctaMixPlayerBase Set14BitMode 5a 001
#pragma libcall OctaMixPlayerBase SetMixingFrequency 60 001
#pragma libcall OctaMixPlayerBase SetMixBufferSize 66 001

#endif
/* prototypes */
LONG GetPlayer(UWORD midi);
void FreePlayer(void);
void PlayModule(struct MMD0 *module);
void ContModule(struct MMD0 *module);
void StopPlayer(void);
/* void DimOffPlayer(UWORD length); */
void SetTempo(UWORD tempo);
struct MMD0 *LoadModule(char *name);
void UnLoadModule(struct MMD0 *module);
struct MMD0 *GetCurrentModule(void);
void ResetMIDI(void);
void SetModnum(UWORD modnum);
void RelocModule(struct MMD0 *module);
ULONG RequiredPlayRoutine(struct MMD0 *module);
ULONG FastMemPlayRecommended(struct MMD0 *module);
struct MMD0 *LoadModule_Fast(char *name);
void SetFastMemPlay(ULONG newstate,ULONG buffsize);

/* for octaplayer.library */
LONG GetPlayer8(void);
void FreePlayer8(void);
void PlayModule8(struct MMD0 *module);
void ContModule8(struct MMD0 *module);
void StopPlayer8(void);
struct MMD0 *LoadModule8(char *name);
void UnLoadModule8(struct MMD0 *module);
void SetModnum8(UWORD modnum);
void RelocModule8(struct MMD0 *module);
void SetHQ(LONG hq);
ULONG RequiredPlayRoutine8(struct MMD0 *module);
ULONG FastMemPlayRecommended8(struct MMD0 *module);
struct MMD0 *LoadModule_Fast8(char *name);
void SetFastMemPlay8(ULONG newstate,ULONG buffsize);

/* for octamixplayer.library */
LONG GetPlayerM(void);
void FreePlayerM(void);
ULONG PlayModuleM(struct MMD0 *module);
void ContModuleM(struct MMD0 *module);
void StopPlayerM(void);
struct MMD0 *LoadModule_FastM(char *name);
void UnLoadModuleM(struct MMD0 *module);
void SetModnumM(UWORD modnum);
void RelocModuleM(struct MMD0 *module);
ULONG RequiredPlayRoutineM(struct MMD0 *module);
void Set14BitMode(ULONG newmode);
void SetMixingFrequency(ULONG newfreq);
void SetMixBufferSize(ULONG newbuffsize);

#define OCTAPLR_LIB_PROTOS 1
