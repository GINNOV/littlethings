#ifndef _INLINE_AHI_H
#define _INLINE_AHI_H

#ifndef AHI_BASE_NAME
#define AHI_BASE_NAME AHIBase
#endif

#define AHI_AllocAudioA(tagList) \
	((struct AHIAudioCtrl * (*)(struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 42))(tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_AllocAudio(tags...) \
	({ULONG _tags[] = {tags}; AHI_AllocAudioA((Tag) _tags);})
#endif

#define AHI_FreeAudio(AudioCtrl) \
	((void (*)(struct AHIAudioCtrl * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 48))(AudioCtrl, (struct Library *) AHI_BASE_NAME)

#define AHI_KillAudio() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 54))((struct Library *) AHI_BASE_NAME)

#define AHI_ControlAudioA(AudioCtrl, tagList) \
	((ULONG (*)(struct AHIAudioCtrl * __asm("a2"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 60))(AudioCtrl, tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_ControlAudio(AudioCtrl, tags...) \
	({ULONG _tags[] = {tags}; AHI_ControlAudioA((AudioCtrl), (Tag) _tags);})
#endif

#define AHI_SetVol(Channel, Volume, Pan, AudioCtrl, Flags) \
	((void (*)(UWORD __asm("d0"), Fixed __asm("d1"), sposition __asm("d2"), struct AHIAudioCtrl * __asm("a2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 66))(Channel, Volume, Pan, AudioCtrl, Flags, (struct Library *) AHI_BASE_NAME)

#define AHI_SetFreq(Channel, Freq, AudioCtrl, Flags) \
	((void (*)(UWORD __asm("d0"), ULONG __asm("d1"), struct AHIAudioCtrl * __asm("a2"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 72))(Channel, Freq, AudioCtrl, Flags, (struct Library *) AHI_BASE_NAME)

#define AHI_SetSound(Channel, Sound, Offset, Length, AudioCtrl, Flags) \
	((void (*)(UWORD __asm("d0"), UWORD __asm("d1"), ULONG __asm("d2"), LONG __asm("d3"), struct AHIAudioCtrl * __asm("a2"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 78))(Channel, Sound, Offset, Length, AudioCtrl, Flags, (struct Library *) AHI_BASE_NAME)

#define AHI_SetEffect(Effect, AudioCtrl) \
	((ULONG (*)(APTR __asm("a0"), struct AHIAudioCtrl * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 84))(Effect, AudioCtrl, (struct Library *) AHI_BASE_NAME)

#define AHI_LoadSound(Sound, Type, Info, AudioCtrl) \
	((ULONG (*)(UWORD __asm("d0"), ULONG __asm("d1"), APTR __asm("a0"), struct AHIAudioCtrl * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 90))(Sound, Type, Info, AudioCtrl, (struct Library *) AHI_BASE_NAME)

#define AHI_UnloadSound(Sound, Audioctrl) \
	((void (*)(UWORD __asm("d0"), struct AHIAudioCtrl * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 96))(Sound, Audioctrl, (struct Library *) AHI_BASE_NAME)

#define AHI_NextAudioID(Last_ID) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 102))(Last_ID, (struct Library *) AHI_BASE_NAME)

#define AHI_GetAudioAttrsA(ID, Audioctrl, tagList) \
	((BOOL (*)(ULONG __asm("d0"), struct AHIAudioCtrl * __asm("a2"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 108))(ID, Audioctrl, tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_GetAudioAttrs(ID, Audioctrl, tags...) \
	({ULONG _tags[] = {tags}; AHI_GetAudioAttrsA((ID), (Audioctrl), (Tag) _tags);})
#endif

#define AHI_BestAudioIDA(tagList) \
	((ULONG (*)(struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 114))(tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_BestAudioID(tags...) \
	({ULONG _tags[] = {tags}; AHI_BestAudioIDA((Tag) _tags);})
#endif

#define AHI_AllocAudioRequestA(tagList) \
	((struct AHIAudioModeRequester * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 120))(tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_AllocAudioRequest(tags...) \
	({ULONG _tags[] = {tags}; AHI_AllocAudioRequestA((Tag) _tags);})
#endif

#define AHI_AudioRequestA(Requester, tagList) \
	((BOOL (*)(struct AHIAudioModeRequester * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 126))(Requester, tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_AudioRequest(Requester, tags...) \
	({ULONG _tags[] = {tags}; AHI_AudioRequestA((Requester), (Tag) _tags);})
#endif

#define AHI_FreeAudioRequest(Requester) \
	((void (*)(struct AHIAudioModeRequester * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 132))(Requester, (struct Library *) AHI_BASE_NAME)

#define AHI_PlayA(Audioctrl, tagList) \
	((void (*)(struct AHIAudioCtrl * __asm("a2"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 138))(Audioctrl, tagList, (struct Library *) AHI_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AHI_Play(Audioctrl, tags...) \
	({ULONG _tags[] = {tags}; AHI_PlayA((Audioctrl), (Tag) _tags);})
#endif

#define AHI_SampleFrameSize(SampleType) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 144))(SampleType, (struct Library *) AHI_BASE_NAME)

#define AHI_AddAudioMode(Private) \
	((ULONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 150))(Private, (struct Library *) AHI_BASE_NAME)

#define AHI_RemoveAudioMode(Private) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 156))(Private, (struct Library *) AHI_BASE_NAME)

#define AHI_LoadModeFile(Private) \
	((ULONG (*)(STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AHI_BASE_NAME) - 162))(Private, (struct Library *) AHI_BASE_NAME)

#endif /*  _INLINE_AHI_H  */
