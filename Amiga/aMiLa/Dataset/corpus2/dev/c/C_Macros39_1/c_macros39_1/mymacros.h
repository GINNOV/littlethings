#ifndef MYMACROS_H
#define MYMACROS_H

/*
**	$VER: mymacros.h 39.3 (26.7.95)
**	Includes Release 40.13
**
**	Function macros. For use with 32 bit integers only.
**
**	(C) Copyright 1995 Bruce M. Simpson
**	    All Rights Reserved
*/


/* function macros */

/* test if a string is empty */
#define isnull(string_p) ((BOOL)((*string_p == NULL) ? TRUE : FALSE))

/* Hook related macros */
#define INITHOOKSTK(hook,function,userdata) {(hook)->h_Entry = HookEntry; (hook)->h_SubEntry = function; (hook)->h_Data = userdata;}
#define INITHOOKREG(hook,function,userdata) {(hook)->h_Entry = function; (hook)->h_Data = userdata;}

/* Pointer related macros */
#define MEMORY_FOLLOWING(ptr) ((void *)((ptr)+1))
#define MEMORY_N_FOLLOWING(ptr,n) ((void *)( ((ULONG)ptr) + n ))

/* Dos BPTR stuff */

/* change a BPTR to an APTR */
#ifndef BPTR2A
#define BPTR2A(bptr,type) ((type *)((long)(bptr) << 2))
#endif

/* change an APTR to a BPTR */
#ifndef APTR2B
#define APTR2B(cptr) ((BPTR)((unsigned long)(cptr) >> 2))
#endif

/* SAS/C shorthand */

#define SAVEDS __saveds
#define ASM __asm
#define REG(x) register __ ## x
#define INLINE __inline


/* absolute address macros, no lame linking! ;) */

#ifdef USE_ABS_SYSBASE
#define SysBase (*((struct ExecBase **)4L))
#endif

#define custom (*((struct Custom *)0xDFF000L))
#define ciaa (*((struct CIA *)0xBFE001L))
#define ciab (*((struct CIA *)0xBFD000L))


/* audio filter macros */

#define LOPASS_FILTER_TOGGLE (ciaa.ciapra ^= CIAF_LED)
#define LOPASS_FILTER_OFF (ciaa.ciapra |= CIAF_LED)
#define LOPASS_FILTER_ON (ciaa.ciapra &= ~CIAF_LED)

#ifdef IGNORE_MATH_ERRS
double __except(int foo,const char *bar,double x,double y,double z){return(1.0);}
#endif

#ifdef NO_ONEXIT
const void *_ONEXIT = NULL;
#endif

#ifndef MakeID
#define MakeID(a,b,c,d)  ( (LONG)(a)<<24L | (LONG)(b)<<16L | (c)<<8 | (d) )
#endif

#ifdef INLINE_SPRINTF
static __inline __stdargs void
InlineSPrintf( struct ExecBase *SysBase, STRPTR outstr, STRPTR fmtstr, ...)
{
	RawDoFmt(fmtstr, &fmtstr+1, (void (*))"\x16\xc0\x4e\x75", outstr);
}
#endif

#endif /* MYMACROS_H */
