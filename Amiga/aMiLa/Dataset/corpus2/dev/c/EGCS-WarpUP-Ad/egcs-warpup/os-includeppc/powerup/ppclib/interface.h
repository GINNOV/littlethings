#ifndef POWERUP_PPCLIB_INTERFACE_H
#define POWERUP_PPCLIB_INTERFACE_H

#include <exec/types.h>

/*
 * Structure which is used on the PPC side to call
 * AmigaOS library functions or sub routines.
 *
 */

/*****************************/
/* About the CacheMode field */
/*****************************/

/*
 * For calling functions from the PPC under M68k AmigaOS or for
 * calling functions on the PPC Supervisor mode you have to care
 * for the cache issues. Please read the Cache chapter in the
 * docs/powerup.guide about the cache problems involved.
 * If you do something wrong here you can expect that you loose
 * data, get wrong data or simply crash the machine.
 *
 * IF_CACHEFLUSHNO:
 * You use this mode for the cpu if your function
 * touches no memory both cpus use.
 *
 * Example: Close(File)
 *          If you call this function by the PPC there`s no need
 *          to flush the cache because the PPC isn`t allowed to
 *          touch any memory which has to do with the File BPTR.
 * ATTENTION:
 *          The PPC MUST NOT be used to poke into AmigaOS system
 *          structures.
 *
 * IF_CACHEFLUSHALL:
 * You use this mode for the cpu if your function
 * touches memory both cpus use and it`s no simple memory area
 * which may be flushed individually. This should be used by default.
 *
 * Example: OpenWindowTagList(NewWindow,TagList)
 *          Here you pass a complex data structure which may use
 *          memory areas at several different areas.
 *
 * IF_CACHEFLUSHAREA:
 * You use this mode for the cpu if your function
 * touches memory both cpus use and it`s a memory area which isn`t
 * very big. It depends on the size and how many lines are dirty
 * if this is faster than IF_CACHEFLUSHALL.
 * With the Start and Length fields of each cpu you can define
 * the area.
 *
 * Example: Write(File,Address,Length)
 *          When the PPC runs this function the PPC must make sure
 *          that all data in the to be written memory area is in
 *          in the memory and not only in the cache.
 *
 * IF_CACHEINVALIDAREA: (V45)
 * You use this mode for the cpu if your function
 * touches memory both cpus use and it`s a memory area where you
 * don`t care for valid data anymore.
 * With the Start and Length fields of each cpu you can define
 * the area.
 *
 * Example: Read(File,Address,Length)
 *          When the PPC runs this function the PPC has no need
 *          anymore for anything which is in its cache for the
 *          area the Address and Length define, so you could
 *          invalidate this instead of doing a cacheflush which
 *          may write back dirty lines.
 *          Be VERY careful about this.
 *
 * ATTENTION! The Address must be 32Byte aligned, so you should always
 * use PPCAllocMem for data which is used on the M68k and PPC
 * You are NOT allowed to use normal pools for exchanging data between
 * the M68k and PPC.
 *
 * IF_ASYNC: (V45)
 * If you use this flag, the function is called asynchronous and
 * the PPC doesn`t have to wait for a result.
 * This flag is only checked in the M68kCacheMode field.
 * This also means that the result of the PPCCall#? function
 * is meaningless.
 * Normally this flag doesn`t really fit into a CacheMode flag, but
 * well..too bad i haven`t declared another flag field there.
 */

struct Caos
{
	union
	{
		int	Offset;
		APTR	Function;
	} caos_Un;
	ULONG	M68kCacheMode;
	APTR	M68kStart;
	ULONG	M68kLength;
	ULONG	PPCCacheMode;
	APTR	PPCStart;
	ULONG	PPCLength;
	ULONG	d0;
	ULONG	d1;
	ULONG	d2;
	ULONG	d3;
	ULONG	d4;
	ULONG	d5;
	ULONG	d6;
	ULONG	d7;
	ULONG	a0;
	ULONG	a1;
	ULONG	a2;
	ULONG	a3;
	ULONG	a4;
	ULONG	a5;
/*
 * here you have to put the LibBasePtr if you want
 * to call a Library.
 */
	ULONG	a6;
};

#define	IF_CACHEFLUSHNO		0
#define	IF_CACHEFLUSHALL	1
#define	IF_CACHEFLUSHAREA	2
#define	IF_CACHEINVALIDAREA	4
#define	IF_ASYNC		0x10000



/*
 * Structure which is used on the M68k side to run
 * a Kernal Supervisor ElfObject. During this time
 * the multitasking on the PPC stops
 * PPCRunKernalModule() ONLY !!!!!!!!!!!!!!!!!!!!!
 *
 */

struct ModuleArgs
{
	ULONG	M68kCacheMode;
	APTR	M68kStart;
	ULONG	M68kLength;
	ULONG	PPCCacheMode;
	APTR	PPCStart;
	ULONG	PPCLength;

	ULONG	Arg1;	/* GPR3=C Integer Arg1  */
	ULONG	Arg2;	/* GPR4=C Integer Arg2  */
	ULONG	Arg3;	/* GPR5=C Integer Arg3  */
	ULONG	Arg4;	/* GPR6=C Integer Arg4  */
	ULONG	Arg5;	/* GPR7=C Integer Arg5  */
	ULONG	Arg6;	/* GPR8=C Integer Arg6  */
	ULONG	Arg7;	/* GPR9=C Integer Arg7  */
	ULONG	Arg8;	/* GPR10=C Integer Arg8 */
	DOUBLE	FArg1;	/* FPR1=C FPU Arg1 */
	DOUBLE	FArg2;	/* FPR2=C FPU Arg2 */
	DOUBLE	FArg3;	/* FPR3=C FPU Arg3 */
	DOUBLE	FArg4;	/* FPR4=C FPU Arg4 */
	DOUBLE	FArg5;	/* FPR5=C FPU Arg5 */
	DOUBLE	FArg6;	/* FPR6=C FPU Arg6 */
	DOUBLE	FArg7;	/* FPR7=C FPU Arg7 */
	DOUBLE	FArg8;	/* FPR8=C FPU Arg8 */
};

#endif
