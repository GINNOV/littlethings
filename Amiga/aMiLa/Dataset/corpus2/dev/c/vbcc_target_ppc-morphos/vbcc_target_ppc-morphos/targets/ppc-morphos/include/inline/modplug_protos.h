/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_MODPLUG_H
#define _VBCCINLINE_MODPLUG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

int  __ModPlug_GetPlayingChannels(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetPlayingChannels(__p0) __ModPlug_GetPlayingChannels((__p0))

void  __ModPlug_Seek(ModPlugFile *, int ) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_Seek(__p0, __p1) __ModPlug_Seek((__p0), (__p1))

unsigned int  __ModPlug_GetMasterVolume(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetMasterVolume(__p0) __ModPlug_GetMasterVolume((__p0))

void  __ModPlug_GetSettings(ModPlug_Settings *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetSettings(__p0) __ModPlug_GetSettings((__p0))

int  __ModPlug_GetCurrentOrder(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetCurrentOrder(__p0) __ModPlug_GetCurrentOrder((__p0))

int  __ModPlug_GetCurrentSpeed(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetCurrentSpeed(__p0) __ModPlug_GetCurrentSpeed((__p0))

int  __ModPlug_GetLength(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetLength(__p0) __ModPlug_GetLength((__p0))

void  __ModPlug_SetSettings(const ModPlug_Settings *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_SetSettings(__p0) __ModPlug_SetSettings((__p0))

void  __ModPlug_SeekOrder(ModPlugFile *, int ) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_SeekOrder(__p0, __p1) __ModPlug_SeekOrder((__p0), (__p1))

unsigned int  __ModPlug_NumPatterns(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_NumPatterns(__p0) __ModPlug_NumPatterns((__p0))

unsigned int  __ModPlug_SampleName(ModPlugFile *, unsigned int , char *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_SampleName(__p0, __p1, __p2) __ModPlug_SampleName((__p0), (__p1), (__p2))

const char * __ModPlug_GetName(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetName(__p0) __ModPlug_GetName((__p0))

void  __ModPlug_InitMixerCallback(ModPlugFile *, ModPlugMixerProc ) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_InitMixerCallback(__p0, __p1) __ModPlug_InitMixerCallback((__p0), (__p1))

ModPlugNote * __ModPlug_GetPattern(ModPlugFile *, int , unsigned * numrows) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetPattern(__p0, __p1, __p2) __ModPlug_GetPattern((__p0), (__p1), (__p2))

unsigned int  __ModPlug_NumSamples(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_NumSamples(__p0) __ModPlug_NumSamples((__p0))

int  __ModPlug_GetModuleType(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetModuleType(__p0) __ModPlug_GetModuleType((__p0))

void  __ModPlug_Unload(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_Unload(__p0) __ModPlug_Unload((__p0))

int  __ModPlug_GetCurrentPattern(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetCurrentPattern(__p0) __ModPlug_GetCurrentPattern((__p0))

int  __ModPlug_Read(ModPlugFile *, void *, int ) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_Read(__p0, __p1, __p2) __ModPlug_Read((__p0), (__p1), (__p2))

ModPlugFile * __ModPlug_Load(const void *, int ) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_Load(__p0, __p1) __ModPlug_Load((__p0), (__p1))

int  __ModPlug_GetCurrentTempo(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetCurrentTempo(__p0) __ModPlug_GetCurrentTempo((__p0))

void  __ModPlug_SetMasterVolume(ModPlugFile *, unsigned int ) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_SetMasterVolume(__p0, __p1) __ModPlug_SetMasterVolume((__p0), (__p1))

unsigned int  __ModPlug_NumChannels(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_NumChannels(__p0) __ModPlug_NumChannels((__p0))

void  __ModPlug_UnloadMixerCallback(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_UnloadMixerCallback(__p0) __ModPlug_UnloadMixerCallback((__p0))

int  __ModPlug_GetCurrentRow(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetCurrentRow(__p0) __ModPlug_GetCurrentRow((__p0))

char * __ModPlug_GetMessage(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_GetMessage(__p0) __ModPlug_GetMessage((__p0))

unsigned int  __ModPlug_NumInstruments(ModPlugFile *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_NumInstruments(__p0) __ModPlug_NumInstruments((__p0))

unsigned int  __ModPlug_InstrumentName(ModPlugFile *, unsigned int , char *) =
	"\tlis\t11,ModPlugBase@ha\n"
	"\tlwz\t12,ModPlugBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ModPlug_InstrumentName(__p0, __p1, __p2) __ModPlug_InstrumentName((__p0), (__p1), (__p2))

#endif /* !_VBCCINLINE_MODPLUG_H */
