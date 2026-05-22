#ifndef _INLINE_AHI_SUB_H
#define _INLINE_AHI_SUB_H

#ifndef AHI_SUB_BASE_NAME
#define AHI_SUB_BASE_NAME AHIsubBase
#endif

#define AHIsub_AllocAudio(tagList, AudioCtrl) \
	((ULONG (*)(struct TagItem * __asm("a1"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 30))(tagList, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_FreeAudio(AudioCtrl) \
	((void (*)(struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 36))(AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_Disable(AudioCtrl) \
	((void (*)(struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 42))(AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_Enable(AudioCtrl) \
	((void (*)(struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 48))(AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_Start(Flags, AudioCtrl) \
	((ULONG (*)(ULONG __asm("d0"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 54))(Flags, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_Update(Flags, AudioCtrl) \
	((ULONG (*)(ULONG __asm("d0"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 60))(Flags, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_Stop(Flags, AudioCtrl) \
	((ULONG (*)(ULONG __asm("d0"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 66))(Flags, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_SetVol(Channel, Volume, Pan, AudioCtrl, Flags) \
	((ULONG (*)(UWORD __asm("d0"), Fixed __asm("d1"), sposition __asm("d2"), struct AHIAudioCtrlDrv * __asm("a2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 72))(Channel, Volume, Pan, AudioCtrl, Flags, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_SetFreq(Channel, Freq, AudioCtrl, Flags) \
	((ULONG (*)(UWORD __asm("d0"), ULONG __asm("d1"), struct AHIAudioCtrlDrv * __asm("a2"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 78))(Channel, Freq, AudioCtrl, Flags, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_SetSound(Channel, Sound, Offset, Length, AudioCtrl, Flags) \
	((ULONG (*)(UWORD __asm("d0"), UWORD __asm("d1"), ULONG __asm("d2"), LONG __asm("d3"), struct AHIAudioCtrlDrv * __asm("a2"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 84))(Channel, Sound, Offset, Length, AudioCtrl, Flags, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_SetEffect(Effect, AudioCtrl) \
	((ULONG (*)(APTR __asm("a0"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 90))(Effect, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_LoadSound(Sound, Type, Info, AudioCtrl) \
	((ULONG (*)(UWORD __asm("d0"), ULONG __asm("d1"), APTR __asm("a0"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 96))(Sound, Type, Info, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_UnloadSound(Sound, Audioctrl) \
	((ULONG (*)(UWORD __asm("d0"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 102))(Sound, Audioctrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_GetAttr(Attribute, Argument, Default, tagList, AudioCtrl) \
	((LONG (*)(ULONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct TagItem * __asm("a1"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 108))(Attribute, Argument, Default, tagList, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#define AHIsub_HardwareControl(Attribute, Argument, AudioCtrl) \
	((LONG (*)(ULONG __asm("d0"), LONG __asm("d1"), struct AHIAudioCtrlDrv * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_SUB_BASE_NAME) - 114))(Attribute, Argument, AudioCtrl, (struct Library *) AHI_SUB_BASE_NAME)

#endif /*  _INLINE_AHI_SUB_H  */
