/*
**  simpleguide.h - header file for the SimpleGuide code
**
**	Copyright (C) 1994 Petter Nilsen of Ultima Thule Software,
**						All Rights Reserved.
**
*/
#ifndef SIMPLEGUIDE_H_INCLUDED
#define SIMPLEGUIDE_H_INCLUDED

#ifndef GUIDECONTEXT
#define GUIDECONTEXT
typedef void *GuideContext;
#endif

/* Prototypes */

extern __asm GuideContext AmigaGuideOpen(register __a0 struct NewAmigaGuide *nag);
extern __asm void AmigaGuideClose(register __a0 GuideContext guide);
extern __asm void HandleAmigaGuide(register __a0 GuideContext guide);
extern __asm ULONG GetAmigaGuideSignal(register __a0 GuideContext guide);
extern __asm struct Library *GetAmigaGuideBase(register __a0 GuideContext guide);
extern __asm BOOL SetGuideContext(register __a0 GuideContext guide, register __d0 ULONG index);
extern __asm BOOL SendGuideContext(register __a0 GuideContext guide);

#endif /* SIMPLEGUIDE_H_INCLUDED */
