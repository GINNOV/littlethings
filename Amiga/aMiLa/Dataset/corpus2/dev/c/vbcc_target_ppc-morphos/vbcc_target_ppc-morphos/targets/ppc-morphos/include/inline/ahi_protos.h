#ifndef _VBCCINLINE_AHI_H
#define _VBCCINLINE_AHI_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct AHIAudioCtrl * __AHI_AllocAudioA(void *, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AHI_AllocAudioA(tagList) __AHI_AllocAudioA(AHIBase, (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct AHIAudioCtrl * __linearvarargs __AHI_AllocAudio(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AHI_AllocAudio(...) __AHI_AllocAudio(AHIBase, __VA_ARGS__)
#endif

void __AHI_FreeAudio(void *, struct AHIAudioCtrl * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AHI_FreeAudio(AudioCtrl) __AHI_FreeAudio(AHIBase, (AudioCtrl))

void __AHI_KillAudio(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define AHI_KillAudio() __AHI_KillAudio(AHIBase)

ULONG __AHI_ControlAudioA(void *, struct AHIAudioCtrl * AudioCtrl, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AHI_ControlAudioA(AudioCtrl, tagList) __AHI_ControlAudioA(AHIBase, (AudioCtrl), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __AHI_ControlAudio(void *, struct AHIAudioCtrl * AudioCtrl, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AHI_ControlAudio(AudioCtrl, ...) __AHI_ControlAudio(AHIBase, (AudioCtrl), __VA_ARGS__)
#endif

void __AHI_SetVol(void *, UWORD Channel, Fixed Volume, sposition Pan, struct AHIAudioCtrl * AudioCtrl, ULONG Flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,40(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define AHI_SetVol(Channel, Volume, Pan, AudioCtrl, Flags) __AHI_SetVol(AHIBase, (Channel), (Volume), (Pan), (AudioCtrl), (Flags))

void __AHI_SetFreq(void *, UWORD Channel, ULONG Freq, struct AHIAudioCtrl * AudioCtrl, ULONG Flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AHI_SetFreq(Channel, Freq, AudioCtrl, Flags) __AHI_SetFreq(AHIBase, (Channel), (Freq), (AudioCtrl), (Flags))

void __AHI_SetSound(void *, UWORD Channel, UWORD Sound, ULONG Offset, LONG Length, struct AHIAudioCtrl * AudioCtrl, ULONG Flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,16(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AHI_SetSound(Channel, Sound, Offset, Length, AudioCtrl, Flags) __AHI_SetSound(AHIBase, (Channel), (Sound), (Offset), (Length), (AudioCtrl), (Flags))

ULONG __AHI_SetEffect(void *, APTR Effect, struct AHIAudioCtrl * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define AHI_SetEffect(Effect, AudioCtrl) __AHI_SetEffect(AHIBase, (Effect), (AudioCtrl))

ULONG __AHI_LoadSound(void *, UWORD Sound, ULONG Type, APTR Info, struct AHIAudioCtrl * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define AHI_LoadSound(Sound, Type, Info, AudioCtrl) __AHI_LoadSound(AHIBase, (Sound), (Type), (Info), (AudioCtrl))

void __AHI_UnloadSound(void *, UWORD Sound, struct AHIAudioCtrl * Audioctrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AHI_UnloadSound(Sound, Audioctrl) __AHI_UnloadSound(AHIBase, (Sound), (Audioctrl))

ULONG __AHI_NextAudioID(void *, ULONG Last_ID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define AHI_NextAudioID(Last_ID) __AHI_NextAudioID(AHIBase, (Last_ID))

BOOL __AHI_GetAudioAttrsA(void *, ULONG ID, struct AHIAudioCtrl * Audioctrl, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AHI_GetAudioAttrsA(ID, Audioctrl, tagList) __AHI_GetAudioAttrsA(AHIBase, (ID), (Audioctrl), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __AHI_GetAudioAttrs(void *, ULONG ID, struct AHIAudioCtrl * Audioctrl, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AHI_GetAudioAttrs(ID, Audioctrl, ...) __AHI_GetAudioAttrs(AHIBase, (ID), (Audioctrl), __VA_ARGS__)
#endif

ULONG __AHI_BestAudioIDA(void *, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define AHI_BestAudioIDA(tagList) __AHI_BestAudioIDA(AHIBase, (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __AHI_BestAudioID(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define AHI_BestAudioID(...) __AHI_BestAudioID(AHIBase, __VA_ARGS__)
#endif

struct AHIAudioModeRequester * __AHI_AllocAudioRequestA(void *, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define AHI_AllocAudioRequestA(tagList) __AHI_AllocAudioRequestA(AHIBase, (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct AHIAudioModeRequester * __linearvarargs __AHI_AllocAudioRequest(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define AHI_AllocAudioRequest(...) __AHI_AllocAudioRequest(AHIBase, __VA_ARGS__)
#endif

BOOL __AHI_AudioRequestA(void *, struct AHIAudioModeRequester * requester, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define AHI_AudioRequestA(requester, tagList) __AHI_AudioRequestA(AHIBase, (requester), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __AHI_AudioRequest(void *, struct AHIAudioModeRequester * requester, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define AHI_AudioRequest(requester, ...) __AHI_AudioRequest(AHIBase, (requester), __VA_ARGS__)
#endif

void __AHI_FreeAudioRequest(void *, struct AHIAudioModeRequester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define AHI_FreeAudioRequest(requester) __AHI_FreeAudioRequest(AHIBase, (requester))

void __AHI_PlayA(void *, struct AHIAudioCtrl * Audioctrl, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define AHI_PlayA(Audioctrl, tagList) __AHI_PlayA(AHIBase, (Audioctrl), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __AHI_Play(void *, struct AHIAudioCtrl * Audioctrl, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define AHI_Play(Audioctrl, ...) __AHI_Play(AHIBase, (Audioctrl), __VA_ARGS__)
#endif

ULONG __AHI_SampleFrameSize(void *, ULONG SampleType) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define AHI_SampleFrameSize(SampleType) __AHI_SampleFrameSize(AHIBase, (SampleType))

ULONG __AHI_AddAudioMode(void *, struct TagItem * a0arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define AHI_AddAudioMode(a0arg) __AHI_AddAudioMode(AHIBase, (a0arg))

ULONG __AHI_RemoveAudioMode(void *, ULONG d0arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define AHI_RemoveAudioMode(d0arg) __AHI_RemoveAudioMode(AHIBase, (d0arg))

ULONG __AHI_LoadModeFile(void *, STRPTR a0arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define AHI_LoadModeFile(a0arg) __AHI_LoadModeFile(AHIBase, (a0arg))

#endif /*  _VBCCINLINE_AHI_H  */
