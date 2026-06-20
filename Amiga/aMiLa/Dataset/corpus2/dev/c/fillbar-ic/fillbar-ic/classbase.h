#ifndef	CLASSBASE_H
#define	CLASSBASE_H

/*****************************************************************************/

#include <exec/types.h>
#include <exec/libraries.h>
#include <intuition/classes.h>
#include <dos.h>

/*****************************************************************************/

#define ASM           __asm
#define REG(x)	      register __ ## x

/*****************************************************************************/

struct ClassLib
{
    struct ClassLibrary	 cb_Library;
    UWORD		 cb_Pad;
    APTR		 cb_SysBase;
    APTR		 cb_UtilityBase;
    APTR		 cb_IntuitionBase;
    APTR		 cb_GfxBase;
    BPTR		 cb_SegList;

};

/*****************************************************************************/

#define SysBase		cb->cb_SysBase
#define GfxBase		cb->cb_GfxBase
#define IntuitionBase	cb->cb_IntuitionBase
#define UtilityBase	cb->cb_UtilityBase

/*****************************************************************************/

LONG __stdargs DoMethod(Object *, ULONG, ...);
LONG __stdargs DoMethodA(Object *, VOID *);
LONG __stdargs DoSuperMethod(Class *, Object *, ULONG, ...);
LONG __stdargs DoSuperMethodA(Class *, Object *, VOID *msg);

/*****************************************************************************/

kprintf(STRPTR,...);
sprintf(STRPTR,...);

/*****************************************************************************/

#endif /* CLASSBASE_H */
