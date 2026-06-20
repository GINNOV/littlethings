#ifndef _VBCCINLINE_AHI_SUB_H
#define _VBCCINLINE_AHI_SUB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

ULONG __AHIsub_AllocAudio(void *, struct TagItem * tagList, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define AHIsub_AllocAudio(tagList, AudioCtrl) __AHIsub_AllocAudio(AHIsubBase, (tagList), (AudioCtrl))

void __AHIsub_FreeAudio(void *, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AHIsub_FreeAudio(AudioCtrl) __AHIsub_FreeAudio(AHIsubBase, (AudioCtrl))

void __AHIsub_Disable(void *, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AHIsub_Disable(AudioCtrl) __AHIsub_Disable(AHIsubBase, (AudioCtrl))

void __AHIsub_Enable(void *, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AHIsub_Enable(AudioCtrl) __AHIsub_Enable(AHIsubBase, (AudioCtrl))

ULONG __AHIsub_Start(void *, ULONG Flags, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define AHIsub_Start(Flags, AudioCtrl) __AHIsub_Start(AHIsubBase, (Flags), (AudioCtrl))

ULONG __AHIsub_Update(void *, ULONG Flags, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AHIsub_Update(Flags, AudioCtrl) __AHIsub_Update(AHIsubBase, (Flags), (AudioCtrl))

ULONG __AHIsub_Stop(void *, ULONG Flags, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define AHIsub_Stop(Flags, AudioCtrl) __AHIsub_Stop(AHIsubBase, (Flags), (AudioCtrl))

ULONG __AHIsub_SetVol(void *, UWORD Channel, Fixed Volume, sposition Pan, struct AHIAudioCtrlDrv * AudioCtrl, ULONG Flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,40(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AHIsub_SetVol(Channel, Volume, Pan, AudioCtrl, Flags) __AHIsub_SetVol(AHIsubBase, (Channel), (Volume), (Pan), (AudioCtrl), (Flags))

ULONG __AHIsub_SetFreq(void *, UWORD Channel, ULONG Freq, struct AHIAudioCtrlDrv * AudioCtrl, ULONG Flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AHIsub_SetFreq(Channel, Freq, AudioCtrl, Flags) __AHIsub_SetFreq(AHIsubBase, (Channel), (Freq), (AudioCtrl), (Flags))

ULONG __AHIsub_SetSound(void *, UWORD Channel, UWORD Sound, ULONG Offset, LONG Length, struct AHIAudioCtrlDrv * AudioCtrl, ULONG Flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,16(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define AHIsub_SetSound(Channel, Sound, Offset, Length, AudioCtrl, Flags) __AHIsub_SetSound(AHIsubBase, (Channel), (Sound), (Offset), (Length), (AudioCtrl), (Flags))

ULONG __AHIsub_SetEffect(void *, APTR Effect, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define AHIsub_SetEffect(Effect, AudioCtrl) __AHIsub_SetEffect(AHIsubBase, (Effect), (AudioCtrl))

ULONG __AHIsub_LoadSound(void *, UWORD Sound, ULONG Type, APTR Info, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AHIsub_LoadSound(Sound, Type, Info, AudioCtrl) __AHIsub_LoadSound(AHIsubBase, (Sound), (Type), (Info), (AudioCtrl))

ULONG __AHIsub_UnloadSound(void *, UWORD Sound, struct AHIAudioCtrlDrv * Audioctrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define AHIsub_UnloadSound(Sound, Audioctrl) __AHIsub_UnloadSound(AHIsubBase, (Sound), (Audioctrl))

LONG __AHIsub_GetAttr(void *, ULONG Attribute, LONG Argument, LONG d2arg, struct TagItem * tagList, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AHIsub_GetAttr(Attribute, Argument, d2arg, tagList, AudioCtrl) __AHIsub_GetAttr(AHIsubBase, (Attribute), (Argument), (d2arg), (tagList), (AudioCtrl))

LONG __AHIsub_HardwareControl(void *, ULONG Attribute, LONG Argument, struct AHIAudioCtrlDrv * AudioCtrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define AHIsub_HardwareControl(Attribute, Argument, AudioCtrl) __AHIsub_HardwareControl(AHIsubBase, (Attribute), (Argument), (AudioCtrl))

#endif /*  _VBCCINLINE_AHI_SUB_H  */
