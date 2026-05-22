/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_POWERSDLSOUND_H
#define _VBCCINLINE_POWERSDLSOUND_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

int  __Sound_Seek(Sound_Sample *, Uint32 ) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_Seek(__p0, __p1) __Sound_Seek((__p0), (__p1))

int  __Sound_Rewind(Sound_Sample *) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_Rewind(__p0) __Sound_Rewind((__p0))

const Sound_DecoderInfo ** __Sound_AvailableDecoders() =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_AvailableDecoders() __Sound_AvailableDecoders()

const char * __Sound_GetError() =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_GetError() __Sound_GetError()

Sound_Sample * __Sound_NewSample(SDL_RWops *, const char *, Sound_AudioInfo *, Uint32 ) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_NewSample(__p0, __p1, __p2, __p3) __Sound_NewSample((__p0), (__p1), (__p2), (__p3))

void  __Sound_GetLinkedVersion(Sound_Version *) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_GetLinkedVersion(__p0) __Sound_GetLinkedVersion((__p0))

Uint32  __Sound_DecodeAll(Sound_Sample *) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_DecodeAll(__p0) __Sound_DecodeAll((__p0))

Sound_Sample * __Sound_NewSampleFromFile(const char *, Sound_AudioInfo *, Uint32 ) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_NewSampleFromFile(__p0, __p1, __p2) __Sound_NewSampleFromFile((__p0), (__p1), (__p2))

int  __Sound_SetBufferSize(Sound_Sample *, Uint32 ) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_SetBufferSize(__p0, __p1) __Sound_SetBufferSize((__p0), (__p1))

void  __Sound_ClearError() =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_ClearError() __Sound_ClearError()

int  __Sound_Quit() =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_Quit() __Sound_Quit()

int  __Sound_Init() =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_Init() __Sound_Init()

void  __Sound_FreeSample(Sound_Sample *) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_FreeSample(__p0) __Sound_FreeSample((__p0))

Uint32  __Sound_Decode(Sound_Sample *) =
	"\tlis\t11,PowerSDLSoundBase@ha\n"
	"\tlwz\t12,PowerSDLSoundBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define Sound_Decode(__p0) __Sound_Decode((__p0))

#endif /* !_VBCCINLINE_POWERSDLSOUND_H */
