/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_DOS_H
#define _PPCPRAGMA_DOS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__DOS_H
#include <ppcinline/dos.h>
#endif
#else

#ifndef POWERUP_PPCLIB_INTERFACE_H
#include <powerup/ppclib/interface.h>
#endif

#ifndef POWERUP_GCCLIB_PROTOS_H
#include <powerup/gcclib/powerup_protos.h>
#endif

#ifndef NO_PPCINLINE_STDARG
#define NO_PPCINLINE_STDARG
#endif/* SAS C PPC inlines */

#ifndef DOS_BASE_NAME
#define DOS_BASE_NAME DOSBase
#endif /* !DOS_BASE_NAME */

#define	AbortPkt(port, pkt)	_AbortPkt(DOS_BASE_NAME, port, pkt)

static __inline void
_AbortPkt(void *DOSBase, struct MsgPort *port, struct DosPacket *pkt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) pkt;
	MyCaos.caos_Un.Offset	=	(-264);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	AddBuffers(name, number)	_AddBuffers(DOS_BASE_NAME, name, number)

static __inline LONG
_AddBuffers(void *DOSBase, STRPTR name, long number)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) number;
	MyCaos.caos_Un.Offset	=	(-732);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AddDosEntry(dlist)	_AddDosEntry(DOS_BASE_NAME, dlist)

static __inline LONG
_AddDosEntry(void *DOSBase, struct DosList *dlist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dlist;
	MyCaos.caos_Un.Offset	=	(-678);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AddPart(dirname, filename, size)	_AddPart(DOS_BASE_NAME, dirname, filename, size)

static __inline BOOL
_AddPart(void *DOSBase, STRPTR dirname, STRPTR filename, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dirname;
	MyCaos.d2		=(ULONG) filename;
	MyCaos.d3		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-882);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AddSegment(name, seg, system)	_AddSegment(DOS_BASE_NAME, name, seg, system)

static __inline LONG
_AddSegment(void *DOSBase, STRPTR name, BPTR seg, long system)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) seg;
	MyCaos.d3		=(ULONG) system;
	MyCaos.caos_Un.Offset	=	(-774);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AllocDosObject(type, tags)	_AllocDosObject(DOS_BASE_NAME, type, tags)

static __inline APTR
_AllocDosObject(void *DOSBase, unsigned long type, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) type;
	MyCaos.d2		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-228);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define AllocDosObjectTagList(a0, a1) AllocDosObject ((a0), (a1))

#ifndef NO_PPCINLINE_STDARG
#define AllocDosObjectTags(a0, tags...) \
	({ULONG _tags[] = { tags }; AllocDosObject((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AssignAdd(name, lock)	_AssignAdd(DOS_BASE_NAME, name, lock)

static __inline BOOL
_AssignAdd(void *DOSBase, STRPTR name, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-630);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AssignLate(name, path)	_AssignLate(DOS_BASE_NAME, name, path)

static __inline BOOL
_AssignLate(void *DOSBase, STRPTR name, STRPTR path)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) path;
	MyCaos.caos_Un.Offset	=	(-618);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AssignLock(name, lock)	_AssignLock(DOS_BASE_NAME, name, lock)

static __inline LONG
_AssignLock(void *DOSBase, STRPTR name, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-612);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AssignPath(name, path)	_AssignPath(DOS_BASE_NAME, name, path)

static __inline BOOL
_AssignPath(void *DOSBase, STRPTR name, STRPTR path)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) path;
	MyCaos.caos_Un.Offset	=	(-624);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AttemptLockDosList(flags)	_AttemptLockDosList(DOS_BASE_NAME, flags)

static __inline struct DosList *
_AttemptLockDosList(void *DOSBase, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-666);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DosList *)PPCCallOS(&MyCaos));
}

#define	ChangeMode(type, fh, newmode)	_ChangeMode(DOS_BASE_NAME, type, fh, newmode)

static __inline LONG
_ChangeMode(void *DOSBase, long type, BPTR fh, long newmode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) type;
	MyCaos.d2		=(ULONG) fh;
	MyCaos.d3		=(ULONG) newmode;
	MyCaos.caos_Un.Offset	=	(-450);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CheckSignal(mask)	_CheckSignal(DOS_BASE_NAME, mask)

static __inline LONG
_CheckSignal(void *DOSBase, long mask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) mask;
	MyCaos.caos_Un.Offset	=	(-792);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Cli()	_Cli(DOS_BASE_NAME)

static __inline struct CommandLineInterface *
_Cli(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-492);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct CommandLineInterface *)PPCCallOS(&MyCaos));
}

#define	CliInitNewcli(dp)	_CliInitNewcli(DOS_BASE_NAME, dp)

static __inline LONG
_CliInitNewcli(void *DOSBase, struct DosPacket *dp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dp;
	MyCaos.caos_Un.Offset	=	(-930);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CliInitRun(dp)	_CliInitRun(DOS_BASE_NAME, dp)

static __inline LONG
_CliInitRun(void *DOSBase, struct DosPacket *dp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dp;
	MyCaos.caos_Un.Offset	=	(-936);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Close(file)	_Close(DOS_BASE_NAME, file)

static __inline LONG
_Close(void *DOSBase, BPTR file)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CompareDates(date1, date2)	_CompareDates(DOS_BASE_NAME, date1, date2)

static __inline LONG
_CompareDates(void *DOSBase, struct DateStamp *date1, struct DateStamp *date2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) date1;
	MyCaos.d2		=(ULONG) date2;
	MyCaos.caos_Un.Offset	=	(-738);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CreateDir(name)	_CreateDir(DOS_BASE_NAME, name)

static __inline BPTR
_CreateDir(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	CreateNewProc(tags)	_CreateNewProc(DOS_BASE_NAME, tags)

static __inline struct Process *
_CreateNewProc(void *DOSBase, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-498);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct Process *)PPCCallOS(&MyCaos));
}

#define CreateNewProcTagList(a0) CreateNewProc ((a0))

#ifndef NO_PPCINLINE_STDARG
#define CreateNewProcTags(tags...) \
	({ULONG _tags[] = { tags }; CreateNewProc((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	CreateProc(name, pri, segList, stackSize)	_CreateProc(DOS_BASE_NAME, name, pri, segList, stackSize)

static __inline struct MsgPort *
_CreateProc(void *DOSBase, STRPTR name, long pri, BPTR segList, long stackSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) pri;
	MyCaos.d3		=(ULONG) segList;
	MyCaos.d4		=(ULONG) stackSize;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	CurrentDir(lock)	_CurrentDir(DOS_BASE_NAME, lock)

static __inline BPTR
_CurrentDir(void *DOSBase, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	DateStamp(date)	_DateStamp(DOS_BASE_NAME, date)

static __inline struct DateStamp *
_DateStamp(void *DOSBase, struct DateStamp *date)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) date;
	MyCaos.caos_Un.Offset	=	(-192);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DateStamp *)PPCCallOS(&MyCaos));
}

#define	DateToStr(datetime)	_DateToStr(DOS_BASE_NAME, datetime)

static __inline LONG
_DateToStr(void *DOSBase, struct DateTime *datetime)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) datetime;
	MyCaos.caos_Un.Offset	=	(-744);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Delay(timeout)	_Delay(DOS_BASE_NAME, timeout)

static __inline void
_Delay(void *DOSBase, long timeout)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) timeout;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	DeleteFile(name)	_DeleteFile(DOS_BASE_NAME, name)

static __inline LONG
_DeleteFile(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DeleteVar(name, flags)	_DeleteVar(DOS_BASE_NAME, name, flags)

static __inline LONG
_DeleteVar(void *DOSBase, STRPTR name, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-912);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DeviceProc(name)	_DeviceProc(DOS_BASE_NAME, name)

static __inline struct MsgPort *
_DeviceProc(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	DoPkt(port, action, arg1, arg2, arg3, arg4, arg5)	_DoPkt(DOS_BASE_NAME, port, action, arg1, arg2, arg3, arg4, arg5)

static __inline LONG
_DoPkt(void *DOSBase, struct MsgPort *port, long action, long arg1, long arg2, long arg3, long arg4, long arg5)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) action;
	MyCaos.d3		=(ULONG) arg1;
	MyCaos.d4		=(ULONG) arg2;
	MyCaos.d5		=(ULONG) arg3;
	MyCaos.d6		=(ULONG) arg4;
	MyCaos.d7		=(ULONG) arg5;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DoPkt0(port, action)	_DoPkt0(DOS_BASE_NAME, port, action)

static __inline LONG
_DoPkt0(void *DOSBase, struct MsgPort *port, long action)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) action;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DoPkt1(port, action, arg1)	_DoPkt1(DOS_BASE_NAME, port, action, arg1)

static __inline LONG
_DoPkt1(void *DOSBase, struct MsgPort *port, long action, long arg1)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) action;
	MyCaos.d3		=(ULONG) arg1;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DoPkt2(port, action, arg1, arg2)	_DoPkt2(DOS_BASE_NAME, port, action, arg1, arg2)

static __inline LONG
_DoPkt2(void *DOSBase, struct MsgPort *port, long action, long arg1, long arg2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) action;
	MyCaos.d3		=(ULONG) arg1;
	MyCaos.d4		=(ULONG) arg2;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DoPkt3(port, action, arg1, arg2, arg3)	_DoPkt3(DOS_BASE_NAME, port, action, arg1, arg2, arg3)

static __inline LONG
_DoPkt3(void *DOSBase, struct MsgPort *port, long action, long arg1, long arg2, long arg3)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) action;
	MyCaos.d3		=(ULONG) arg1;
	MyCaos.d4		=(ULONG) arg2;
	MyCaos.d5		=(ULONG) arg3;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DoPkt4(port, action, arg1, arg2, arg3, arg4)	_DoPkt4(DOS_BASE_NAME, port, action, arg1, arg2, arg3, arg4)

static __inline LONG
_DoPkt4(void *DOSBase, struct MsgPort *port, long action, long arg1, long arg2, long arg3, long arg4)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) action;
	MyCaos.d3		=(ULONG) arg1;
	MyCaos.d4		=(ULONG) arg2;
	MyCaos.d5		=(ULONG) arg3;
	MyCaos.d6		=(ULONG) arg4;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DupLock(lock)	_DupLock(DOS_BASE_NAME, lock)

static __inline BPTR
_DupLock(void *DOSBase, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	DupLockFromFH(fh)	_DupLockFromFH(DOS_BASE_NAME, fh)

static __inline BPTR
_DupLockFromFH(void *DOSBase, BPTR fh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.caos_Un.Offset	=	(-372);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	EndNotify(notify)	_EndNotify(DOS_BASE_NAME, notify)

static __inline void
_EndNotify(void *DOSBase, struct NotifyRequest *notify)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) notify;
	MyCaos.caos_Un.Offset	=	(-894);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	ErrorReport(code, type, arg1, device)	_ErrorReport(DOS_BASE_NAME, code, type, arg1, device)

static __inline LONG
_ErrorReport(void *DOSBase, long code, long type, unsigned long arg1, struct MsgPort *device)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) code;
	MyCaos.d2		=(ULONG) type;
	MyCaos.d3		=(ULONG) arg1;
	MyCaos.d4		=(ULONG) device;
	MyCaos.caos_Un.Offset	=	(-480);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ExAll(lock, buffer, size, data, control)	_ExAll(DOS_BASE_NAME, lock, buffer, size, data, control)

static __inline LONG
_ExAll(void *DOSBase, BPTR lock, struct ExAllData *buffer, long size, long data, struct ExAllControl *control)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) size;
	MyCaos.d4		=(ULONG) data;
	MyCaos.d5		=(ULONG) control;
	MyCaos.caos_Un.Offset	=	(-432);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ExAllEnd(lock, buffer, size, data, control)	_ExAllEnd(DOS_BASE_NAME, lock, buffer, size, data, control)

static __inline void
_ExAllEnd(void *DOSBase, BPTR lock, struct ExAllData *buffer, long size, long data, struct ExAllControl *control)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) size;
	MyCaos.d4		=(ULONG) data;
	MyCaos.d5		=(ULONG) control;
	MyCaos.caos_Un.Offset	=	(-990);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	ExNext(lock, fileInfoBlock)	_ExNext(DOS_BASE_NAME, lock, fileInfoBlock)

static __inline LONG
_ExNext(void *DOSBase, BPTR lock, struct FileInfoBlock *fileInfoBlock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.d2		=(ULONG) fileInfoBlock;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Examine(lock, fileInfoBlock)	_Examine(DOS_BASE_NAME, lock, fileInfoBlock)

static __inline LONG
_Examine(void *DOSBase, BPTR lock, struct FileInfoBlock *fileInfoBlock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.d2		=(ULONG) fileInfoBlock;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ExamineFH(fh, fib)	_ExamineFH(DOS_BASE_NAME, fh, fib)

static __inline BOOL
_ExamineFH(void *DOSBase, BPTR fh, struct FileInfoBlock *fib)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) fib;
	MyCaos.caos_Un.Offset	=	(-390);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	Execute(string, file, file2)	_Execute(DOS_BASE_NAME, string, file, file2)

static __inline LONG
_Execute(void *DOSBase, STRPTR string, BPTR file, BPTR file2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) string;
	MyCaos.d2		=(ULONG) file;
	MyCaos.d3		=(ULONG) file2;
	MyCaos.caos_Un.Offset	=	(-222);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Exit(returnCode)	_Exit(DOS_BASE_NAME, returnCode)

static __inline void
_Exit(void *DOSBase, long returnCode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) returnCode;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	FGetC(fh)	_FGetC(DOS_BASE_NAME, fh)

static __inline LONG
_FGetC(void *DOSBase, BPTR fh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.caos_Un.Offset	=	(-306);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FGets(fh, buf, buflen)	_FGets(DOS_BASE_NAME, fh, buf, buflen)

static __inline STRPTR
_FGets(void *DOSBase, BPTR fh, STRPTR buf, unsigned long buflen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) buf;
	MyCaos.d3		=(ULONG) buflen;
	MyCaos.caos_Un.Offset	=	(-336);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	FPutC(fh, ch)	_FPutC(DOS_BASE_NAME, fh, ch)

static __inline LONG
_FPutC(void *DOSBase, BPTR fh, long ch)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) ch;
	MyCaos.caos_Un.Offset	=	(-312);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FPuts(fh, str)	_FPuts(DOS_BASE_NAME, fh, str)

static __inline LONG
_FPuts(void *DOSBase, BPTR fh, STRPTR str)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) str;
	MyCaos.caos_Un.Offset	=	(-342);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FRead(fh, block, blocklen, number)	_FRead(DOS_BASE_NAME, fh, block, blocklen, number)

static __inline LONG
_FRead(void *DOSBase, BPTR fh, APTR block, unsigned long blocklen, unsigned long number)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) block;
	MyCaos.d3		=(ULONG) blocklen;
	MyCaos.d4		=(ULONG) number;
	MyCaos.caos_Un.Offset	=	(-324);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FWrite(fh, block, blocklen, number)	_FWrite(DOS_BASE_NAME, fh, block, blocklen, number)

static __inline LONG
_FWrite(void *DOSBase, BPTR fh, APTR block, unsigned long blocklen, unsigned long number)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) block;
	MyCaos.d3		=(ULONG) blocklen;
	MyCaos.d4		=(ULONG) number;
	MyCaos.caos_Un.Offset	=	(-330);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Fault(code, header, buffer, len)	_Fault(DOS_BASE_NAME, code, header, buffer, len)

static __inline BOOL
_Fault(void *DOSBase, long code, STRPTR header, STRPTR buffer, long len)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) code;
	MyCaos.d2		=(ULONG) header;
	MyCaos.d3		=(ULONG) buffer;
	MyCaos.d4		=(ULONG) len;
	MyCaos.caos_Un.Offset	=	(-468);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FilePart(path)	_FilePart(DOS_BASE_NAME, path)

static __inline STRPTR
_FilePart(void *DOSBase, STRPTR path)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) path;
	MyCaos.caos_Un.Offset	=	(-870);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	FindArg(keyword, arg_template)	_FindArg(DOS_BASE_NAME, keyword, arg_template)

static __inline LONG
_FindArg(void *DOSBase, STRPTR keyword, STRPTR arg_template)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) keyword;
	MyCaos.d2		=(ULONG) arg_template;
	MyCaos.caos_Un.Offset	=	(-804);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FindCliProc(num)	_FindCliProc(DOS_BASE_NAME, num)

static __inline struct Process *
_FindCliProc(void *DOSBase, unsigned long num)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) num;
	MyCaos.caos_Un.Offset	=	(-546);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct Process *)PPCCallOS(&MyCaos));
}

#define	FindDosEntry(dlist, name, flags)	_FindDosEntry(DOS_BASE_NAME, dlist, name, flags)

static __inline struct DosList *
_FindDosEntry(void *DOSBase, struct DosList *dlist, STRPTR name, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dlist;
	MyCaos.d2		=(ULONG) name;
	MyCaos.d3		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-684);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DosList *)PPCCallOS(&MyCaos));
}

#define	FindSegment(name, seg, system)	_FindSegment(DOS_BASE_NAME, name, seg, system)

static __inline struct Segment *
_FindSegment(void *DOSBase, STRPTR name, struct Segment *seg, long system)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) seg;
	MyCaos.d3		=(ULONG) system;
	MyCaos.caos_Un.Offset	=	(-780);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct Segment *)PPCCallOS(&MyCaos));
}

#define	FindVar(name, type)	_FindVar(DOS_BASE_NAME, name, type)

static __inline struct LocalVar *
_FindVar(void *DOSBase, STRPTR name, unsigned long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-918);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct LocalVar *)PPCCallOS(&MyCaos));
}

#define	Flush(fh)	_Flush(DOS_BASE_NAME, fh)

static __inline LONG
_Flush(void *DOSBase, BPTR fh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.caos_Un.Offset	=	(-360);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Format(filesystem, volumename, dostype)	_Format(DOS_BASE_NAME, filesystem, volumename, dostype)

static __inline BOOL
_Format(void *DOSBase, STRPTR filesystem, STRPTR volumename, unsigned long dostype)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) filesystem;
	MyCaos.d2		=(ULONG) volumename;
	MyCaos.d3		=(ULONG) dostype;
	MyCaos.caos_Un.Offset	=	(-714);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FreeArgs(args)	_FreeArgs(DOS_BASE_NAME, args)

static __inline void
_FreeArgs(void *DOSBase, struct RDArgs *args)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) args;
	MyCaos.caos_Un.Offset	=	(-858);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeDeviceProc(dp)	_FreeDeviceProc(DOS_BASE_NAME, dp)

static __inline void
_FreeDeviceProc(void *DOSBase, struct DevProc *dp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dp;
	MyCaos.caos_Un.Offset	=	(-648);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeDosEntry(dlist)	_FreeDosEntry(DOS_BASE_NAME, dlist)

static __inline void
_FreeDosEntry(void *DOSBase, struct DosList *dlist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dlist;
	MyCaos.caos_Un.Offset	=	(-702);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeDosObject(type, ptr)	_FreeDosObject(DOS_BASE_NAME, type, ptr)

static __inline void
_FreeDosObject(void *DOSBase, unsigned long type, APTR ptr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) type;
	MyCaos.d2		=(ULONG) ptr;
	MyCaos.caos_Un.Offset	=	(-234);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	GetArgStr()	_GetArgStr(DOS_BASE_NAME)

static __inline STRPTR
_GetArgStr(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-534);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	GetConsoleTask()	_GetConsoleTask(DOS_BASE_NAME)

static __inline struct MsgPort *
_GetConsoleTask(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-510);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	GetCurrentDirName(buf, len)	_GetCurrentDirName(DOS_BASE_NAME, buf, len)

static __inline BOOL
_GetCurrentDirName(void *DOSBase, STRPTR buf, long len)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) buf;
	MyCaos.d2		=(ULONG) len;
	MyCaos.caos_Un.Offset	=	(-564);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	GetDeviceProc(name, dp)	_GetDeviceProc(DOS_BASE_NAME, name, dp)

static __inline struct DevProc *
_GetDeviceProc(void *DOSBase, STRPTR name, struct DevProc *dp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) dp;
	MyCaos.caos_Un.Offset	=	(-642);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DevProc *)PPCCallOS(&MyCaos));
}

#define	GetFileSysTask()	_GetFileSysTask(DOS_BASE_NAME)

static __inline struct MsgPort *
_GetFileSysTask(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-522);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	GetProgramDir()	_GetProgramDir(DOS_BASE_NAME)

static __inline BPTR
_GetProgramDir(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-600);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	GetProgramName(buf, len)	_GetProgramName(DOS_BASE_NAME, buf, len)

static __inline BOOL
_GetProgramName(void *DOSBase, STRPTR buf, long len)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) buf;
	MyCaos.d2		=(ULONG) len;
	MyCaos.caos_Un.Offset	=	(-576);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	GetPrompt(buf, len)	_GetPrompt(DOS_BASE_NAME, buf, len)

static __inline BOOL
_GetPrompt(void *DOSBase, STRPTR buf, long len)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) buf;
	MyCaos.d2		=(ULONG) len;
	MyCaos.caos_Un.Offset	=	(-588);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	GetVar(name, buffer, size, flags)	_GetVar(DOS_BASE_NAME, name, buffer, size, flags)

static __inline LONG
_GetVar(void *DOSBase, STRPTR name, STRPTR buffer, long size, long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) size;
	MyCaos.d4		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-906);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Info(lock, parameterBlock)	_Info(DOS_BASE_NAME, lock, parameterBlock)

static __inline LONG
_Info(void *DOSBase, BPTR lock, struct InfoData *parameterBlock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.d2		=(ULONG) parameterBlock;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Inhibit(name, onoff)	_Inhibit(DOS_BASE_NAME, name, onoff)

static __inline LONG
_Inhibit(void *DOSBase, STRPTR name, long onoff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) onoff;
	MyCaos.caos_Un.Offset	=	(-726);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Input()	_Input(DOS_BASE_NAME)

static __inline BPTR
_Input(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	InternalLoadSeg(fh, table, funcarray, stack)	_InternalLoadSeg(DOS_BASE_NAME, fh, table, funcarray, stack)

static __inline BPTR
_InternalLoadSeg(void *DOSBase, BPTR fh, BPTR table, LONG *funcarray, LONG *stack)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) fh;
	MyCaos.a0		=(ULONG) table;
	MyCaos.a1		=(ULONG) funcarray;
	MyCaos.a2		=(ULONG) stack;
	MyCaos.caos_Un.Offset	=	(-756);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	InternalUnLoadSeg(seglist, freefunc)	_InternalUnLoadSeg(DOS_BASE_NAME, seglist, freefunc)

static __inline BOOL
_InternalUnLoadSeg(void *DOSBase, BPTR seglist, void (*freefunc)())
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) seglist;
	MyCaos.a1		=(ULONG) freefunc;
	MyCaos.caos_Un.Offset	=	(-762);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IoErr()	_IoErr(DOS_BASE_NAME)

static __inline LONG
_IoErr(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	IsFileSystem(name)	_IsFileSystem(DOS_BASE_NAME, name)

static __inline BOOL
_IsFileSystem(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-708);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsInteractive(file)	_IsInteractive(DOS_BASE_NAME, file)

static __inline LONG
_IsInteractive(void *DOSBase, BPTR file)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	LoadSeg(name)	_LoadSeg(DOS_BASE_NAME, name)

static __inline BPTR
_LoadSeg(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	Lock(name, type)	_Lock(DOS_BASE_NAME, name, type)

static __inline BPTR
_Lock(void *DOSBase, STRPTR name, long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	LockDosList(flags)	_LockDosList(DOS_BASE_NAME, flags)

static __inline struct DosList *
_LockDosList(void *DOSBase, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-654);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DosList *)PPCCallOS(&MyCaos));
}

#define	LockRecord(fh, offset, length, mode, timeout)	_LockRecord(DOS_BASE_NAME, fh, offset, length, mode, timeout)

static __inline BOOL
_LockRecord(void *DOSBase, BPTR fh, unsigned long offset, unsigned long length, unsigned long mode, unsigned long timeout)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) offset;
	MyCaos.d3		=(ULONG) length;
	MyCaos.d4		=(ULONG) mode;
	MyCaos.d5		=(ULONG) timeout;
	MyCaos.caos_Un.Offset	=	(-270);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	LockRecords(recArray, timeout)	_LockRecords(DOS_BASE_NAME, recArray, timeout)

static __inline BOOL
_LockRecords(void *DOSBase, struct RecordLock *recArray, unsigned long timeout)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) recArray;
	MyCaos.d2		=(ULONG) timeout;
	MyCaos.caos_Un.Offset	=	(-276);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	MakeDosEntry(name, type)	_MakeDosEntry(DOS_BASE_NAME, name, type)

static __inline struct DosList *
_MakeDosEntry(void *DOSBase, STRPTR name, long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-696);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DosList *)PPCCallOS(&MyCaos));
}

#define	MakeLink(name, dest, soft)	_MakeLink(DOS_BASE_NAME, name, dest, soft)

static __inline LONG
_MakeLink(void *DOSBase, STRPTR name, long dest, long soft)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) dest;
	MyCaos.d3		=(ULONG) soft;
	MyCaos.caos_Un.Offset	=	(-444);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MatchEnd(anchor)	_MatchEnd(DOS_BASE_NAME, anchor)

static __inline void
_MatchEnd(void *DOSBase, struct AnchorPath *anchor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) anchor;
	MyCaos.caos_Un.Offset	=	(-834);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	MatchFirst(pat, anchor)	_MatchFirst(DOS_BASE_NAME, pat, anchor)

static __inline LONG
_MatchFirst(void *DOSBase, STRPTR pat, struct AnchorPath *anchor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) pat;
	MyCaos.d2		=(ULONG) anchor;
	MyCaos.caos_Un.Offset	=	(-822);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MatchNext(anchor)	_MatchNext(DOS_BASE_NAME, anchor)

static __inline LONG
_MatchNext(void *DOSBase, struct AnchorPath *anchor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) anchor;
	MyCaos.caos_Un.Offset	=	(-828);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MatchPattern(pat, str)	_MatchPattern(DOS_BASE_NAME, pat, str)

static __inline BOOL
_MatchPattern(void *DOSBase, STRPTR pat, STRPTR str)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) pat;
	MyCaos.d2		=(ULONG) str;
	MyCaos.caos_Un.Offset	=	(-846);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	MatchPatternNoCase(pat, str)	_MatchPatternNoCase(DOS_BASE_NAME, pat, str)

static __inline BOOL
_MatchPatternNoCase(void *DOSBase, STRPTR pat, STRPTR str)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) pat;
	MyCaos.d2		=(ULONG) str;
	MyCaos.caos_Un.Offset	=	(-972);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	MaxCli()	_MaxCli(DOS_BASE_NAME)

static __inline ULONG
_MaxCli(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-552);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	NameFromFH(fh, buffer, len)	_NameFromFH(DOS_BASE_NAME, fh, buffer, len)

static __inline LONG
_NameFromFH(void *DOSBase, BPTR fh, STRPTR buffer, long len)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) len;
	MyCaos.caos_Un.Offset	=	(-408);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	NameFromLock(lock, buffer, len)	_NameFromLock(DOS_BASE_NAME, lock, buffer, len)

static __inline LONG
_NameFromLock(void *DOSBase, BPTR lock, STRPTR buffer, long len)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) len;
	MyCaos.caos_Un.Offset	=	(-402);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	NewLoadSeg(file, tags)	_NewLoadSeg(DOS_BASE_NAME, file, tags)

static __inline BPTR
_NewLoadSeg(void *DOSBase, STRPTR file, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.d2		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-768);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define NewLoadSegTagList(a0, a1) NewLoadSeg ((a0), (a1))

#ifndef NO_PPCINLINE_STDARG
#define NewLoadSegTags(a0, tags...) \
	({ULONG _tags[] = { tags }; NewLoadSeg((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	NextDosEntry(dlist, flags)	_NextDosEntry(DOS_BASE_NAME, dlist, flags)

static __inline struct DosList *
_NextDosEntry(void *DOSBase, struct DosList *dlist, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dlist;
	MyCaos.d2		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-690);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DosList *)PPCCallOS(&MyCaos));
}

#define	Open(name, accessMode)	_Open(DOS_BASE_NAME, name, accessMode)

static __inline BPTR
_Open(void *DOSBase, STRPTR name, long accessMode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) accessMode;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	OpenFromLock(lock)	_OpenFromLock(DOS_BASE_NAME, lock)

static __inline BPTR
_OpenFromLock(void *DOSBase, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-378);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	Output()	_Output(DOS_BASE_NAME)

static __inline BPTR
_Output(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	ParentDir(lock)	_ParentDir(DOS_BASE_NAME, lock)

static __inline BPTR
_ParentDir(void *DOSBase, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	ParentOfFH(fh)	_ParentOfFH(DOS_BASE_NAME, fh)

static __inline BPTR
_ParentOfFH(void *DOSBase, BPTR fh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.caos_Un.Offset	=	(-384);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	ParsePattern(pat, buf, buflen)	_ParsePattern(DOS_BASE_NAME, pat, buf, buflen)

static __inline LONG
_ParsePattern(void *DOSBase, STRPTR pat, STRPTR buf, long buflen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) pat;
	MyCaos.d2		=(ULONG) buf;
	MyCaos.d3		=(ULONG) buflen;
	MyCaos.caos_Un.Offset	=	(-840);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ParsePatternNoCase(pat, buf, buflen)	_ParsePatternNoCase(DOS_BASE_NAME, pat, buf, buflen)

static __inline LONG
_ParsePatternNoCase(void *DOSBase, STRPTR pat, STRPTR buf, long buflen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) pat;
	MyCaos.d2		=(ULONG) buf;
	MyCaos.d3		=(ULONG) buflen;
	MyCaos.caos_Un.Offset	=	(-966);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	PathPart(path)	_PathPart(DOS_BASE_NAME, path)

static __inline STRPTR
_PathPart(void *DOSBase, STRPTR path)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) path;
	MyCaos.caos_Un.Offset	=	(-876);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	PrintFault(code, header)	_PrintFault(DOS_BASE_NAME, code, header)

static __inline BOOL
_PrintFault(void *DOSBase, long code, STRPTR header)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) code;
	MyCaos.d2		=(ULONG) header;
	MyCaos.caos_Un.Offset	=	(-474);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	PutStr(str)	_PutStr(DOS_BASE_NAME, str)

static __inline LONG
_PutStr(void *DOSBase, STRPTR str)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) str;
	MyCaos.caos_Un.Offset	=	(-948);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Read(file, buffer, length)	_Read(DOS_BASE_NAME, file, buffer, length)

static __inline LONG
_Read(void *DOSBase, BPTR file, APTR buffer, long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadArgs(arg_template, array, args)	_ReadArgs(DOS_BASE_NAME, arg_template, array, args)

static __inline struct RDArgs *
_ReadArgs(void *DOSBase, STRPTR arg_template, LONG *array, struct RDArgs *args)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) arg_template;
	MyCaos.d2		=(ULONG) array;
	MyCaos.d3		=(ULONG) args;
	MyCaos.caos_Un.Offset	=	(-798);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct RDArgs *)PPCCallOS(&MyCaos));
}

#define	ReadItem(name, maxchars, cSource)	_ReadItem(DOS_BASE_NAME, name, maxchars, cSource)

static __inline LONG
_ReadItem(void *DOSBase, STRPTR name, long maxchars, struct CSource *cSource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) maxchars;
	MyCaos.d3		=(ULONG) cSource;
	MyCaos.caos_Un.Offset	=	(-810);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadLink(port, lock, path, buffer, size)	_ReadLink(DOS_BASE_NAME, port, lock, path, buffer, size)

static __inline LONG
_ReadLink(void *DOSBase, struct MsgPort *port, BPTR lock, STRPTR path, STRPTR buffer, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) port;
	MyCaos.d2		=(ULONG) lock;
	MyCaos.d3		=(ULONG) path;
	MyCaos.d4		=(ULONG) buffer;
	MyCaos.d5		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-438);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Relabel(drive, newname)	_Relabel(DOS_BASE_NAME, drive, newname)

static __inline LONG
_Relabel(void *DOSBase, STRPTR drive, STRPTR newname)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) drive;
	MyCaos.d2		=(ULONG) newname;
	MyCaos.caos_Un.Offset	=	(-720);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	RemAssignList(name, lock)	_RemAssignList(DOS_BASE_NAME, name, lock)

static __inline LONG
_RemAssignList(void *DOSBase, STRPTR name, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-636);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	RemDosEntry(dlist)	_RemDosEntry(DOS_BASE_NAME, dlist)

static __inline BOOL
_RemDosEntry(void *DOSBase, struct DosList *dlist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dlist;
	MyCaos.caos_Un.Offset	=	(-672);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	RemSegment(seg)	_RemSegment(DOS_BASE_NAME, seg)

static __inline LONG
_RemSegment(void *DOSBase, struct Segment *seg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) seg;
	MyCaos.caos_Un.Offset	=	(-786);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Rename(oldName, newName)	_Rename(DOS_BASE_NAME, oldName, newName)

static __inline LONG
_Rename(void *DOSBase, STRPTR oldName, STRPTR newName)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) oldName;
	MyCaos.d2		=(ULONG) newName;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReplyPkt(dp, res1, res2)	_ReplyPkt(DOS_BASE_NAME, dp, res1, res2)

static __inline void
_ReplyPkt(void *DOSBase, struct DosPacket *dp, long res1, long res2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dp;
	MyCaos.d2		=(ULONG) res1;
	MyCaos.d3		=(ULONG) res2;
	MyCaos.caos_Un.Offset	=	(-258);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	RunCommand(seg, stack, paramptr, paramlen)	_RunCommand(DOS_BASE_NAME, seg, stack, paramptr, paramlen)

static __inline LONG
_RunCommand(void *DOSBase, BPTR seg, long stack, STRPTR paramptr, long paramlen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) seg;
	MyCaos.d2		=(ULONG) stack;
	MyCaos.d3		=(ULONG) paramptr;
	MyCaos.d4		=(ULONG) paramlen;
	MyCaos.caos_Un.Offset	=	(-504);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SameDevice(lock1, lock2)	_SameDevice(DOS_BASE_NAME, lock1, lock2)

static __inline BOOL
_SameDevice(void *DOSBase, BPTR lock1, BPTR lock2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock1;
	MyCaos.d2		=(ULONG) lock2;
	MyCaos.caos_Un.Offset	=	(-984);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SameLock(lock1, lock2)	_SameLock(DOS_BASE_NAME, lock1, lock2)

static __inline LONG
_SameLock(void *DOSBase, BPTR lock1, BPTR lock2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock1;
	MyCaos.d2		=(ULONG) lock2;
	MyCaos.caos_Un.Offset	=	(-420);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Seek(file, position, offset)	_Seek(DOS_BASE_NAME, file, position, offset)

static __inline LONG
_Seek(void *DOSBase, BPTR file, long position, long offset)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.d2		=(ULONG) position;
	MyCaos.d3		=(ULONG) offset;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SelectInput(fh)	_SelectInput(DOS_BASE_NAME, fh)

static __inline BPTR
_SelectInput(void *DOSBase, BPTR fh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.caos_Un.Offset	=	(-294);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	SelectOutput(fh)	_SelectOutput(DOS_BASE_NAME, fh)

static __inline BPTR
_SelectOutput(void *DOSBase, BPTR fh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.caos_Un.Offset	=	(-300);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	SendPkt(dp, port, replyport)	_SendPkt(DOS_BASE_NAME, dp, port, replyport)

static __inline void
_SendPkt(void *DOSBase, struct DosPacket *dp, struct MsgPort *port, struct MsgPort *replyport)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) dp;
	MyCaos.d2		=(ULONG) port;
	MyCaos.d3		=(ULONG) replyport;
	MyCaos.caos_Un.Offset	=	(-246);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	SetArgStr(string)	_SetArgStr(DOS_BASE_NAME, string)

static __inline BOOL
_SetArgStr(void *DOSBase, STRPTR string)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) string;
	MyCaos.caos_Un.Offset	=	(-540);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetComment(name, comment)	_SetComment(DOS_BASE_NAME, name, comment)

static __inline LONG
_SetComment(void *DOSBase, STRPTR name, STRPTR comment)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) comment;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetConsoleTask(task)	_SetConsoleTask(DOS_BASE_NAME, task)

static __inline struct MsgPort *
_SetConsoleTask(void *DOSBase, struct MsgPort *task)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) task;
	MyCaos.caos_Un.Offset	=	(-516);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	SetCurrentDirName(name)	_SetCurrentDirName(DOS_BASE_NAME, name)

static __inline BOOL
_SetCurrentDirName(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-558);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetFileDate(name, date)	_SetFileDate(DOS_BASE_NAME, name, date)

static __inline LONG
_SetFileDate(void *DOSBase, STRPTR name, struct DateStamp *date)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) date;
	MyCaos.caos_Un.Offset	=	(-396);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetFileSize(fh, pos, mode)	_SetFileSize(DOS_BASE_NAME, fh, pos, mode)

static __inline LONG
_SetFileSize(void *DOSBase, BPTR fh, long pos, long mode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) pos;
	MyCaos.d3		=(ULONG) mode;
	MyCaos.caos_Un.Offset	=	(-456);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetFileSysTask(task)	_SetFileSysTask(DOS_BASE_NAME, task)

static __inline struct MsgPort *
_SetFileSysTask(void *DOSBase, struct MsgPort *task)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) task;
	MyCaos.caos_Un.Offset	=	(-528);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	SetIoErr(result)	_SetIoErr(DOS_BASE_NAME, result)

static __inline LONG
_SetIoErr(void *DOSBase, long result)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) result;
	MyCaos.caos_Un.Offset	=	(-462);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetMode(fh, mode)	_SetMode(DOS_BASE_NAME, fh, mode)

static __inline LONG
_SetMode(void *DOSBase, BPTR fh, long mode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) mode;
	MyCaos.caos_Un.Offset	=	(-426);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetOwner(name, owner_info)	_SetOwner(DOS_BASE_NAME, name, owner_info)

static __inline BOOL
_SetOwner(void *DOSBase, STRPTR name, long owner_info)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) owner_info;
	MyCaos.caos_Un.Offset	=	(-996);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetProgramDir(lock)	_SetProgramDir(DOS_BASE_NAME, lock)

static __inline BPTR
_SetProgramDir(void *DOSBase, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-594);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BPTR)PPCCallOS(&MyCaos));
}

#define	SetProgramName(name)	_SetProgramName(DOS_BASE_NAME, name)

static __inline BOOL
_SetProgramName(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-570);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetPrompt(name)	_SetPrompt(DOS_BASE_NAME, name)

static __inline BOOL
_SetPrompt(void *DOSBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-582);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetProtection(name, protect)	_SetProtection(DOS_BASE_NAME, name, protect)

static __inline LONG
_SetProtection(void *DOSBase, STRPTR name, long protect)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) protect;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetVBuf(fh, buff, type, size)	_SetVBuf(DOS_BASE_NAME, fh, buff, type, size)

static __inline LONG
_SetVBuf(void *DOSBase, BPTR fh, STRPTR buff, long type, long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) buff;
	MyCaos.d3		=(ULONG) type;
	MyCaos.d4		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-366);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetVar(name, buffer, size, flags)	_SetVar(DOS_BASE_NAME, name, buffer, size, flags)

static __inline BOOL
_SetVar(void *DOSBase, STRPTR name, STRPTR buffer, long size, long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) size;
	MyCaos.d4		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-900);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SplitName(name, seperator, buf, oldpos, size)	_SplitName(DOS_BASE_NAME, name, seperator, buf, oldpos, size)

static __inline WORD
_SplitName(void *DOSBase, STRPTR name, unsigned long seperator, STRPTR buf, long oldpos, long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) name;
	MyCaos.d2		=(ULONG) seperator;
	MyCaos.d3		=(ULONG) buf;
	MyCaos.d4		=(ULONG) oldpos;
	MyCaos.d5		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-414);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((WORD)PPCCallOS(&MyCaos));
}

#define	StartNotify(notify)	_StartNotify(DOS_BASE_NAME, notify)

static __inline BOOL
_StartNotify(void *DOSBase, struct NotifyRequest *notify)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) notify;
	MyCaos.caos_Un.Offset	=	(-888);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	StrToDate(datetime)	_StrToDate(DOS_BASE_NAME, datetime)

static __inline LONG
_StrToDate(void *DOSBase, struct DateTime *datetime)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) datetime;
	MyCaos.caos_Un.Offset	=	(-750);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	StrToLong(string, value)	_StrToLong(DOS_BASE_NAME, string, value)

static __inline LONG
_StrToLong(void *DOSBase, STRPTR string, LONG *value)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) string;
	MyCaos.d2		=(ULONG) value;
	MyCaos.caos_Un.Offset	=	(-816);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SystemTagList(command, tags)	_SystemTagList(DOS_BASE_NAME, command, tags)

static __inline LONG
_SystemTagList(void *DOSBase, STRPTR command, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) command;
	MyCaos.d2		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-606);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define System(a0, a1) SystemTagList ((a0), (a1))

#ifndef NO_PPCINLINE_STDARG
#define SystemTags(a0, tags...) \
	({ULONG _tags[] = { tags }; SystemTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	UnGetC(fh, character)	_UnGetC(DOS_BASE_NAME, fh, character)

static __inline LONG
_UnGetC(void *DOSBase, BPTR fh, long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-318);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	UnLoadSeg(seglist)	_UnLoadSeg(DOS_BASE_NAME, seglist)

static __inline void
_UnLoadSeg(void *DOSBase, BPTR seglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) seglist;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	UnLock(lock)	_UnLock(DOS_BASE_NAME, lock)

static __inline void
_UnLock(void *DOSBase, BPTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	UnLockDosList(flags)	_UnLockDosList(DOS_BASE_NAME, flags)

static __inline void
_UnLockDosList(void *DOSBase, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-660);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#define	UnLockRecord(fh, offset, length)	_UnLockRecord(DOS_BASE_NAME, fh, offset, length)

static __inline BOOL
_UnLockRecord(void *DOSBase, BPTR fh, unsigned long offset, unsigned long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) offset;
	MyCaos.d3		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-282);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	UnLockRecords(recArray)	_UnLockRecords(DOS_BASE_NAME, recArray)

static __inline BOOL
_UnLockRecords(void *DOSBase, struct RecordLock *recArray)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) recArray;
	MyCaos.caos_Un.Offset	=	(-288);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	VFPrintf(fh, format, argarray)	_VFPrintf(DOS_BASE_NAME, fh, format, argarray)

static __inline LONG
_VFPrintf(void *DOSBase, BPTR fh, STRPTR format, APTR argarray)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) format;
	MyCaos.d3		=(ULONG) argarray;
	MyCaos.caos_Un.Offset	=	(-354);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define FPrintf(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; VFPrintf((a0), (a1), (APTR)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	VFWritef(fh, format, argarray)	_VFWritef(DOS_BASE_NAME, fh, format, argarray)

static __inline void
_VFWritef(void *DOSBase, BPTR fh, STRPTR format, LONG *argarray)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) fh;
	MyCaos.d2		=(ULONG) format;
	MyCaos.d3		=(ULONG) argarray;
	MyCaos.caos_Un.Offset	=	(-348);
	MyCaos.a6		=(ULONG) DOSBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define FWritef(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; VFWritef((a0), (a1), (LONG *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	VPrintf(format, argarray)	_VPrintf(DOS_BASE_NAME, format, argarray)

static __inline LONG
_VPrintf(void *DOSBase, STRPTR format, APTR argarray)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) format;
	MyCaos.d2		=(ULONG) argarray;
	MyCaos.caos_Un.Offset	=	(-954);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define Printf(a0, tags...) \
	({ULONG _tags[] = { tags }; VPrintf((a0), (APTR)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	WaitForChar(file, timeout)	_WaitForChar(DOS_BASE_NAME, file, timeout)

static __inline LONG
_WaitForChar(void *DOSBase, BPTR file, long timeout)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.d2		=(ULONG) timeout;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WaitPkt()	_WaitPkt(DOS_BASE_NAME)

static __inline struct DosPacket *
_WaitPkt(void *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-252);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((struct DosPacket *)PPCCallOS(&MyCaos));
}

#define	Write(file, buffer, length)	_Write(DOS_BASE_NAME, file, buffer, length)

static __inline LONG
_Write(void *DOSBase, BPTR file, APTR buffer, long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) file;
	MyCaos.d2		=(ULONG) buffer;
	MyCaos.d3		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WriteChars(buf, buflen)	_WriteChars(DOS_BASE_NAME, buf, buflen)

static __inline LONG
_WriteChars(void *DOSBase, STRPTR buf, unsigned long buflen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) buf;
	MyCaos.d2		=(ULONG) buflen;
	MyCaos.caos_Un.Offset	=	(-942);
	MyCaos.a6		=(ULONG) DOSBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_DOS_H */
