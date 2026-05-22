#ifndef _INLINE_EASYAUDIO_H
#define _INLINE_EASYAUDIO_H

#ifndef __INLINE_STUB_H
#include <inline/stubs.h>
#endif

#ifndef BASE_EXT_DECL
#define BASE_EXT_DECL
#define BASE_EXT_DECL0 struct Library *EasyaudioBase;
#endif
#ifndef BASE_PAR_DECL
#define BASE_PAR_DECL
#define BASE_PAR_DECL0 void
#endif
#ifndef BASE_NAME
#define BASE_NAME EasyaudioBase
#endif

BASE_EXT_DECL0

__inline ULONG
EA_Request(BASE_PAR_DECL UBYTE * title, UBYTE * body, UBYTE * gadgets)
{
   BASE_EXT_DECL
   register ULONG res __asm("d0");
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register UBYTE * d1 __asm("d1") = title;
   register UBYTE * d2 __asm("d2") = body;
   register UBYTE * d3 __asm("d3") = gadgets;
   __asm volatile ("jsr a6@(-0x1E:W)"
   : "=r" (res)
   : "r" (a6), "r" (d1), "r" (d2), "r" (d3)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
   return res;
}

__inline ULONG
EA_Speech(BASE_PAR_DECL char * text)
{
   BASE_EXT_DECL
   register ULONG res __asm("d0");
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register char * d1 __asm("d1") = text;
   __asm volatile ("jsr a6@(-0x24:W)"
   : "=r" (res)
   : "r" (a6), "r" (d1)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
   return res;
}

__inline ULONG
EA_Beep(BASE_PAR_DECL ULONG frequency, ULONG duration)
{
   BASE_EXT_DECL
   register ULONG res __asm("d0");
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register ULONG d1 __asm("d1") = frequency;
   register ULONG d2 __asm("d2") = duration;
   __asm volatile ("jsr a6@(-0x2A:W)"
   : "=r" (res)
   : "r" (a6), "r" (d1), "r" (d2)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
   return res;
}

__inline struct SoundInfo *
EA_PrepareSound(BASE_PAR_DECL STRPTR file)
{
   BASE_EXT_DECL
   register struct SoundInfo * res __asm("d0");
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register STRPTR d1 __asm("d1") = file;
   __asm volatile ("jsr a6@(-0x30:W)"
   : "=r" (res)
   : "r" (a6), "r" (d1)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
   return res;
}

__inline BOOL
EA_PlaySound(BASE_PAR_DECL struct SoundInfo * info, UWORD volume, UBYTE channel, BYTE priority, WORD delta_rate, UWORD times, ULONG start, ULONG time, BOOL wait)
{
   BASE_EXT_DECL
   register BOOL res __asm("d0");
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register struct SoundInfo * d1 __asm("d1") = info;
   register UWORD d2 __asm("d2") = volume;
   register UBYTE d3 __asm("d3") = channel;
   register BYTE d4 __asm("d4") = priority;
   register WORD d5 __asm("d5") = delta_rate;
   register UWORD d6 __asm("d6") = times;
   register ULONG a2 __asm("a2") = start;
   register ULONG a3 __asm("a3") = time;
   register BOOL d7 __asm("d7") = wait;
   __asm volatile ("exg d7,a4\n\tjsr a6@(-0x36:W)\n\texg d7,a4"
   : "=r" (res)
   : "r" (a6), "r" (d1), "r" (d2), "r" (d3), "r" (d4), "r" (d5), "r" (d6), "r" (a2), "r" (a3), "r" (d7)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
   return res;
}

__inline void
EA_StopSound(BASE_PAR_DECL UBYTE channel)
{
   BASE_EXT_DECL
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register UBYTE d1 __asm("d1") = channel;
   __asm volatile ("jsr a6@(-0x3C:W)"
   : /* No Output */
   : "r" (a6), "r" (d1)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
}

__inline void
EA_RemoveSound(BASE_PAR_DECL struct SoundInfo * info)
{
   BASE_EXT_DECL
   register struct Library *a6 __asm("a6") = BASE_NAME;
   register struct SoundInfo * d1 __asm("d1") = info;
   __asm volatile ("jsr a6@(-0x42:W)"
   : /* No Output */
   : "r" (a6), "r" (d1)
   : "d0", "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
}

#undef BASE_EXT_DECL
#undef BASE_EXT_DECL0
#undef BASE_PAR_DECL
#undef BASE_PAR_DECL0
#undef BASE_NAME

#endif /*  _INLINE_EASYAUDIO_H  */
