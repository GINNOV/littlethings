/*
 * $Id: init.c,v 1.4 2001/12/25 00:55:26 tfrieden Exp $
 *
 * $Date: 2001/12/25 00:55:26 $
 * $Revision: 1.4 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#include "sysinc.h"
#include <stdio.h>


static char rcsid[] UNUSED = "$Id: init.c,v 1.4 2001/12/25 00:55:26 tfrieden Exp $";

//surgeon: added 11-04-02 - initializes glDrawArrays to glDrawElements wrapper for clipping with compiled arrays

extern void Init_ArrayToElements_Warpper(void);


struct Library *UtilityBase;
struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;

#ifndef __PPC__
	extern struct DosLibrary *DOSBase;
	extern struct ExecBase *SysBase;
#endif

void MGL_SINCOS_Init(void);

#ifdef __PPC__
struct Library *Warp3DPPCBase = NULL;
#else
struct Library *Warp3DBase = NULL;
#endif
struct Library *CyberGfxBase = NULL;


GLboolean MGLInit(void)
{
	IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 0L);
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0L);
	UtilityBase = OpenLibrary("utility.library", 0L);
#ifdef __PPC__
	Warp3DPPCBase = OpenLibrary("Warp3DPPC.library", 2L);
#else
	Warp3DBase = OpenLibrary("Warp3D.library", 2L);
#endif
	CyberGfxBase = OpenLibrary("cybergraphics.library", 0L);

	if (!IntuitionBase || !GfxBase || !UtilityBase || !CyberGfxBase ||
#ifdef __PPC__
	    !Warp3DPPCBase)
#else
	    !Warp3DBase)
#endif
	{
	    printf("Library initialization failed:\n");

	    if (!IntuitionBase) printf("- intuition.library (How are you doing this ?)\n");
	    if (!GfxBase)       printf("- graphics.library (Strange!)\n");
#ifdef __PPC__
	    if (!Warp3DPPCBase) printf("- Warp3DPPC.library\n");
#else
	    if (!Warp3DBase)    printf("- Warp3D.library\n");
#endif
	    if (!CyberGfxBase)  printf("- cybergraphics.library\n");
	    
	    MGLTerm();
	    return GL_FALSE;
	}

#ifdef TRIGTABLES
	MGL_SINCOS_Init();
#endif


	Init_ArrayToElements_Warpper(); //11-04-02

	return GL_TRUE;

}

void MGLTerm(void)
{
	if (CyberGfxBase)       CloseLibrary(CyberGfxBase);
	CyberGfxBase = NULL;

	#ifdef __PPC__
	if (Warp3DPPCBase)      CloseLibrary(Warp3DPPCBase);
	Warp3DPPCBase = NULL;

	#else
	if (Warp3DBase)         CloseLibrary(Warp3DBase);
	Warp3DBase = NULL;
	#endif

	if (IntuitionBase)      CloseLibrary((struct Library *)IntuitionBase);
	IntuitionBase = NULL;

	if (GfxBase)            CloseLibrary((struct Library *)GfxBase);
	GfxBase = NULL;

	if (UtilityBase)        CloseLibrary(UtilityBase);
	UtilityBase = NULL;
}
