/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_POWERSDL_MIXER_H
#define _VBCCINLINE_POWERSDL_MIXER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

int  __Mix_PlayMusic(Mix_Music *, int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_PlayMusic(__p0, __p1) __Mix_PlayMusic((__p0), (__p1))

int  __Mix_Volume(int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_Volume(__p0, __p1) __Mix_Volume((__p0), (__p1))

void  __Mix_HookMusicFinished(void (*)(void)) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_HookMusicFinished(__p0) __Mix_HookMusicFinished((__p0))

Mix_Music * __Mix_LoadMUS_RW(SDL_RWops *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_LoadMUS_RW(__p0) __Mix_LoadMUS_RW((__p0))

void  __Mix_SetPostMix(void (*)                              (void *udata, Uint8 *stream, int len), void *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetPostMix(__p0, __p1) __Mix_SetPostMix((__p0), (__p1))

int  __Mix_QuerySpec(int *, Uint16 *, int *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_QuerySpec(__p0, __p1, __p2) __Mix_QuerySpec((__p0), (__p1), (__p2))

int  __Mix_PlayChannelTimed(int , Mix_Chunk *, int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_PlayChannelTimed(__p0, __p1, __p2, __p3) __Mix_PlayChannelTimed((__p0), (__p1), (__p2), (__p3))

int  __Mix_HaltChannel(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_HaltChannel(__p0) __Mix_HaltChannel((__p0))

Mix_Fading  __Mix_FadingChannel(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadingChannel(__p0) __Mix_FadingChannel((__p0))

int  __Mix_Paused(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_Paused(__p0) __Mix_Paused((__p0))

int  __Mix_SetMusicPosition(double ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetMusicPosition(__p0) __Mix_SetMusicPosition((__p0))

void  __Mix_ChannelFinished(void (*)(int channel)) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_ChannelFinished(__p0) __Mix_ChannelFinished((__p0))

int  __Mix_GroupChannel(int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GroupChannel(__p0, __p1) __Mix_GroupChannel((__p0), (__p1))

int  __Mix_ExpireChannel(int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_ExpireChannel(__p0, __p1) __Mix_ExpireChannel((__p0), (__p1))

int  __Mix_ReserveChannels(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_ReserveChannels(__p0) __Mix_ReserveChannels((__p0))

int  __Mix_VolumeChunk(Mix_Chunk *, int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_VolumeChunk(__p0, __p1) __Mix_VolumeChunk((__p0), (__p1))

void  __Mix_Resume(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_Resume(__p0) __Mix_Resume((__p0))

void  __Mix_ResumeMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_ResumeMusic() __Mix_ResumeMusic()

int  __Mix_PlayingMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_PlayingMusic() __Mix_PlayingMusic()

int  __Mix_SetDistance(int , Uint8 ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetDistance(__p0, __p1) __Mix_SetDistance((__p0), (__p1))

int  __Mix_SetPanning(int , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetPanning(__p0, __p1, __p2) __Mix_SetPanning((__p0), (__p1), (__p2))

Mix_Chunk * __Mix_GetChunk(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GetChunk(__p0) __Mix_GetChunk((__p0))

const SDL_version * __Mix_Linked_Version() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_Linked_Version() __Mix_Linked_Version()

int  __Mix_SetPosition(int , Sint16 , Uint8 ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetPosition(__p0, __p1, __p2) __Mix_SetPosition((__p0), (__p1), (__p2))

int  __Mix_UnregisterAllEffects(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_UnregisterAllEffects(__p0) __Mix_UnregisterAllEffects((__p0))

void  __Mix_FreeMusic(Mix_Music *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FreeMusic(__p0) __Mix_FreeMusic((__p0))

int  __Mix_PausedMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_PausedMusic() __Mix_PausedMusic()

Mix_Chunk * __Mix_QuickLoad_RAW(Uint8 *, Uint32 ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_QuickLoad_RAW(__p0, __p1) __Mix_QuickLoad_RAW((__p0), (__p1))

void  __Mix_CloseAudio() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_CloseAudio() __Mix_CloseAudio()

void  __Mix_RewindMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_RewindMusic() __Mix_RewindMusic()

int  __Mix_GroupAvailable(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GroupAvailable(__p0) __Mix_GroupAvailable((__p0))

int  __Mix_Playing(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_Playing(__p0) __Mix_Playing((__p0))

Mix_Music * __Mix_LoadMUS(const char *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_LoadMUS(__p0) __Mix_LoadMUS((__p0))

int  __Mix_SetReverseStereo(int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetReverseStereo(__p0, __p1) __Mix_SetReverseStereo((__p0), (__p1))

void  __Mix_Pause(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_Pause(__p0) __Mix_Pause((__p0))

int  __Mix_FadeOutChannel(int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadeOutChannel(__p0, __p1) __Mix_FadeOutChannel((__p0), (__p1))

Mix_MusicType  __Mix_GetMusicType(const Mix_Music *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GetMusicType(__p0) __Mix_GetMusicType((__p0))

int  __Mix_OpenAudio(int , Uint16 , int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_OpenAudio(__p0, __p1, __p2, __p3) __Mix_OpenAudio((__p0), (__p1), (__p2), (__p3))

void * __Mix_GetMusicHookData() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GetMusicHookData() __Mix_GetMusicHookData()

void  __Mix_HookMusic(void (*)                           (void *udata, Uint8 *stream, int len), void *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_HookMusic(__p0, __p1) __Mix_HookMusic((__p0), (__p1))

int  __Mix_RegisterEffect(int , Mix_EffectFunc_t , Mix_EffectDone_t , void *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_RegisterEffect(__p0, __p1, __p2, __p3) __Mix_RegisterEffect((__p0), (__p1), (__p2), (__p3))

int  __Mix_FadeInChannelTimed(int , Mix_Chunk *, int , int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadeInChannelTimed(__p0, __p1, __p2, __p3, __p4) __Mix_FadeInChannelTimed((__p0), (__p1), (__p2), (__p3), (__p4))

int  __Mix_UnregisterEffect(int , Mix_EffectFunc_t ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_UnregisterEffect(__p0, __p1) __Mix_UnregisterEffect((__p0), (__p1))

int  __Mix_FadeOutGroup(int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadeOutGroup(__p0, __p1) __Mix_FadeOutGroup((__p0), (__p1))

int  __Mix_HaltGroup(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_HaltGroup(__p0) __Mix_HaltGroup((__p0))

Mix_Chunk * __Mix_LoadWAV_RW(SDL_RWops *, int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_LoadWAV_RW(__p0, __p1) __Mix_LoadWAV_RW((__p0), (__p1))

int  __Mix_GroupCount(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GroupCount(__p0) __Mix_GroupCount((__p0))

int  __Mix_GroupOldest(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GroupOldest(__p0) __Mix_GroupOldest((__p0))

int  __Mix_VolumeMusic(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_VolumeMusic(__p0) __Mix_VolumeMusic((__p0))

int  __Mix_GroupChannels(int , int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GroupChannels(__p0, __p1, __p2) __Mix_GroupChannels((__p0), (__p1), (__p2))

int  __Mix_FadeInMusicPos(Mix_Music *, int , int , double ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadeInMusicPos(__p0, __p1, __p2, __p3) __Mix_FadeInMusicPos((__p0), (__p1), (__p2), (__p3))

void  __Mix_FreeChunk(Mix_Chunk *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FreeChunk(__p0) __Mix_FreeChunk((__p0))

void  __Mix_PauseMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_PauseMusic() __Mix_PauseMusic()

int  __Mix_SetMusicCMD(const char *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetMusicCMD(__p0) __Mix_SetMusicCMD((__p0))

int  __Mix_GetSynchroValue() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GetSynchroValue() __Mix_GetSynchroValue()

int  __Mix_FadeInMusic(Mix_Music *, int , int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadeInMusic(__p0, __p1, __p2) __Mix_FadeInMusic((__p0), (__p1), (__p2))

int  __Mix_FadeOutMusic(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadeOutMusic(__p0) __Mix_FadeOutMusic((__p0))

Mix_Fading  __Mix_FadingMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_FadingMusic() __Mix_FadingMusic()

int  __Mix_HaltMusic() =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_HaltMusic() __Mix_HaltMusic()

Mix_Chunk * __Mix_QuickLoad_WAV(Uint8 *) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_QuickLoad_WAV(__p0) __Mix_QuickLoad_WAV((__p0))

int  __Mix_GroupNewer(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_GroupNewer(__p0) __Mix_GroupNewer((__p0))

int  __Mix_SetSynchroValue(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_SetSynchroValue(__p0) __Mix_SetSynchroValue((__p0))

int  __Mix_AllocateChannels(int ) =
	"\tlis\t11,PowerSDLMixerBase@ha\n"
	"\tlwz\t12,PowerSDLMixerBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Mix_AllocateChannels(__p0) __Mix_AllocateChannels((__p0))

#endif /* !_VBCCINLINE_POWERSDL_MIXER_H */
