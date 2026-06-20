#ifndef	PROTO_ARP_H
#define	PROTO_ARP_H 1

#ifndef LIBRARIES_ARPBASE_H
#include <libraries/arpbase.h>
#endif	/* LIBRARIES_ARPBASE_H */

extern struct ArpBase *ArpBase;

#ifndef	AZTEC_C

/*
 ************************************************************************
 *	The arp copies of the dos.library calls...			*
 ************************************************************************
 */

/* Only include these if you can use ARP.library without dos.library... */

#ifdef	DO_ARP_COPIES
#pragma	libcall	ArpBase	Open			001E	2102
#pragma	libcall	ArpBase	Close			0024	101
#pragma	libcall	ArpBase	Read			002A	32103
#pragma	libcall	ArpBase	Write			0030	32103
#pragma	libcall	ArpBase	Input			0036	00
#pragma	libcall	ArpBase	Output			003C	00
#pragma	libcall	ArpBase	Seek			0042	32103
#pragma	libcall	ArpBase	DeleteFile		0048	101
#pragma	libcall	ArpBase	Rename			004E	2102
#pragma	libcall	ArpBase	Lock			0054	2102
#pragma	libcall	ArpBase	UnLock			005A	101
#pragma	libcall	ArpBase	DupLock			0060	101
#pragma	libcall	ArpBase	Examine			0066	2102
#pragma	libcall	ArpBase	ExNext			006C	2102
#pragma	libcall	ArpBase	Info			0072	2102
#pragma	libcall	ArpBase	CreateDir		0078	101
#pragma	libcall	ArpBase	CurrentDir		007E	101
#pragma	libcall	ArpBase	IoErr			0084	00
#pragma	libcall	ArpBase	CreateProc		008A	432104
#pragma	libcall	ArpBase	Exit			0090	101
#pragma	libcall	ArpBase	LoadSeg			0096	101
#pragma	libcall	ArpBase	UnLoadSeg		009C	101
#pragma	libcall	ArpBase	DeviceProc		00AE	101
#pragma	libcall	ArpBase	SetComment		00B4	2102
#pragma	libcall	ArpBase	SetProtection		00BA	2102
#pragma	libcall	ArpBase	DateStamp		00C0	101
#pragma	libcall	ArpBase	Delay			00C6	101
#pragma	libcall	ArpBase	WaitForChar		00CC	2102
#pragma	libcall	ArpBase	ParentDir		00D2	101
#pragma	libcall	ArpBase	IsInteractive		00D8	101
#pragma	libcall	ArpBase	Execute			00DE	32103
#endif /* DO_ARP_COPIES */

/*
 ************************************************************************
 *	Stuff only in arp.library					*
 ************************************************************************
 */
/*	libcall	ArpBase	Printf			00E4	9802	This does not work without glue */
/*	libcall	ArpBase	FPrintf			00EA	98003	This does not work without glue */
#pragma	libcall	ArpBase	Puts			00F0	901
#pragma	libcall	ArpBase	ReadLine		00F6	801
#pragma	libcall	ArpBase	GADS			00FC	BA90805
#pragma	libcall	ArpBase	Atol			0102	801
#pragma	libcall	ArpBase	EscapeString		0108	801
#pragma	libcall	ArpBase	CheckAbort		010E	901
#pragma	libcall	ArpBase	CheckBreak		0114	9102
#pragma	libcall	ArpBase	Getenv			011A	09803
#pragma	libcall	ArpBase	Setenv			0120	9802
#pragma	libcall	ArpBase	FileRequest		0126	801
#pragma	libcall	ArpBase	CloseWindowSafely	012C	9802
#pragma	libcall	ArpBase	CreatePort		0132	0802
#pragma	libcall	ArpBase	DeletePort		0138	901
#pragma	libcall	ArpBase	SendPacket		013E	98003
#pragma	libcall	ArpBase	InitStdPacket		0144	A98004
#pragma	libcall	ArpBase	PathName		014A	18003
#pragma	libcall	ArpBase	Assign			0150	9802
#pragma	libcall	ArpBase	DosAllocMem		0156	001
#pragma	libcall	ArpBase	DosFreeMem		015C	901
#pragma	libcall	ArpBase	BtoCStr			0162	10803
#pragma	libcall	ArpBase	CtoBStr			0168	10803
#pragma	libcall	ArpBase	GetDevInfo		016E	A01
#pragma	libcall	ArpBase	FreeTaskResList		0174	00
#pragma	libcall	ArpBase	ArpExit			017A	2002
#pragma	libcall	ArpBase	ArpAlloc		0180	001
/*	libcall	ArpBase	ArpAllocMem		0186	1002	Secondary result - IoErr() */
/*	libcall	ArpBase	ArpOpen			018C	2102	Secondary result - IoErr() */
/*	libcall	ArpBase	ArpDupLock		0192	101	Secondary result - IoErr() */
/*	libcall	ArpBase	ArpLock			0198	2102	Secondary result - IoErr() */
/*	libcall	ArpBase	RListAlloc		019E	0802	Secondary result - IoErr() */
#pragma	libcall	ArpBase	FindCLI			01A4	001
#pragma	libcall	ArpBase	QSort			01AA	910804

#pragma	libcall	ArpBase	PatternMatch		01B0	9802
#pragma	libcall	ArpBase	FindFirst		01B6	8002
#pragma	libcall	ArpBase	FindNext		01BC	801
#pragma	libcall	ArpBase	FreeAnchorChain		01C2	801

#pragma	libcall	ArpBase	CompareLock		01C8	1002

#pragma	libcall	ArpBase	FindTaskResList		01CE	00
#pragma	libcall	ArpBase	CreateTaskResList	01D4	00
#pragma	libcall	ArpBase	FreeResList		01DA	00
#pragma	libcall	ArpBase	FreeTrackedItem		01E0	901
/*	libcall	ArpBase	GetTracker		01E6	90	Stores the ID in the tracker */

#pragma	libcall	ArpBase	GetAccess		01EC	901
#pragma	libcall	ArpBase	FreeAccess		01F2	901

#pragma	libcall	ArpBase	FreeDAList		01F8	901
#pragma	libcall	ArpBase	AddDANode		01FE	109804
#pragma	libcall	ArpBase	AddDADevs		0204	0802

#pragma	libcall	ArpBase	Strcmp			020A	9802
#pragma	libcall	ArpBase	Strncmp			0210	09803
#pragma	libcall	ArpBase	Toupper			0216	001
#pragma	libcall	ArpBase	SyncRun			021C	109804

/*
 ************************************************************************
 *	Added V32 of arp.library					*
 *	Note that SpawnShell is ASyncRun but was added at V39 of arp...	*
 ************************************************************************
 */
#pragma	libcall	ArpBase	ASyncRun		0222	A9803
#pragma	libcall	ArpBase	SpawnShell		0222	A9803
#pragma	libcall	ArpBase	LoadPrg			0228	101
#pragma	libcall	ArpBase	PreParse		022E	9802

/*
 ************************************************************************
 *	Added V33 of arp.library					*
 ************************************************************************
 */
#pragma	libcall	ArpBase	StamptoStr		0234	801
#pragma	libcall	ArpBase	StrtoStamp		023A	801

#pragma	libcall	ArpBase	ObtainResidentPrg	0240	801
#pragma	libcall	ArpBase	AddResidentPrg		0246	8102
#pragma	libcall	ArpBase	RemResidentPrg		024C	801
#pragma	libcall	ArpBase	UnLoadPrg		0252	101
#pragma	libcall	ArpBase	LMult			0258	1002
#pragma	libcall	ArpBase	LDiv			025E	1002
#pragma	libcall	ArpBase	LMod			0264	1002

#pragma	libcall	ArpBase	CheckSumPrg		026A	101
#pragma	libcall	ArpBase	TackOn			0270	9802
#pragma	libcall	ArpBase	BaseName		0276	801
#pragma	libcall	ArpBase	ReleaseResidentPrg	027C	101

/*
 ************************************************************************
 *	Added V36 of arp.library					*
 ************************************************************************
 */
/*	libcall	ArpBase	SPrintf			0282	98003	This does not work without glue */
#pragma	libcall	ArpBase	GetKeywordIndex		0288	9802
/*	libcall	ArpBase	ArpOpenLibrary		028E	0902	Secondary result - IoErr() */
#pragma	libcall	ArpBase	ArpAllocFreq		0294	00

	/* Added ArpVPrintf, ArpVFPrintf and ArpVSPrintf. -olsen */

#pragma	libcall	ArpBase	ArpVPrintf		00E4	9802   
#pragma	libcall	ArpBase	ArpVFPrintf		00EA	98003 
#pragma	libcall	ArpBase	ArpVSPrintf		0282	98003

#else /* AZTEC_C */
#ifdef	DO_ARP_COPIES
#pragma amicall(ArpBase, 0x1e, Open(d1,d2))
#pragma amicall(ArpBase, 0x24, Close(d1))
#pragma amicall(ArpBase, 0x2a, Read(d1,d2,d3))
#pragma amicall(ArpBase, 0x30, Write(d1,d2,d3))
#pragma amicall(ArpBase, 0x36, Input())
#pragma amicall(ArpBase, 0x3c, Output())
#pragma amicall(ArpBase, 0x42, Seek(d1,d2,d3))
#pragma amicall(ArpBase, 0x48, DeleteFile(d1))
#pragma amicall(ArpBase, 0x4e, Rename(d1,d2))
#pragma amicall(ArpBase, 0x54, Lock(d1,d2))
#pragma amicall(ArpBase, 0x5a, UnLock(d1))
#pragma amicall(ArpBase, 0x60, DupLock(d1))
#pragma amicall(ArpBase, 0x66, Examine(d1,d2))
#pragma amicall(ArpBase, 0x6c, ExNext(d1,d2))
#pragma amicall(ArpBase, 0x72, Info(d1,d2))
#pragma amicall(ArpBase, 0x78, CreateDir(d1))
#pragma amicall(ArpBase, 0x7e, CurrentDir(d1))
#pragma amicall(ArpBase, 0x84, IoErr())
#pragma amicall(ArpBase, 0x8a, CreateProc(d1,d2,d3,d4))
#pragma amicall(ArpBase, 0x90, Exit(d1))
#pragma amicall(ArpBase, 0x96, LoadSeg(d1))
#pragma amicall(ArpBase, 0x9c, UnLoadSeg(d1))
#pragma amicall(ArpBase, 0xae, DeviceProc(d1))
#pragma amicall(ArpBase, 0xb4, SetComment(d1,d2))
#pragma amicall(ArpBase, 0xba, SetProtection(d1,d2))
#pragma amicall(ArpBase, 0xc0, DateStamp(d1))
#pragma amicall(ArpBase, 0xc6, Delay(d1))
#pragma amicall(ArpBase, 0xcc, WaitForChar(d1,d2))
#pragma amicall(ArpBase, 0xd2, ParentDir(d1))
#pragma amicall(ArpBase, 0xd8, IsInteractive(d1))
#pragma amicall(ArpBase, 0xde, Execute(d1,d2,d3))
#endif /* DO_ARP_COPIES */
#pragma amicall(ArpBase, 0xf0, Puts(a1))
#pragma amicall(ArpBase, 0xf6, ReadLine(a0))
#pragma amicall(ArpBase, 0xfc, GADS(a0,d0,a1,a2,a3))
#pragma amicall(ArpBase, 0x102, Atol(a0))
#pragma amicall(ArpBase, 0x108, EscapeString(a0))
#pragma amicall(ArpBase, 0x10e, CheckAbort(a1))
#pragma amicall(ArpBase, 0x114, CheckBreak(d1,a1))
#pragma amicall(ArpBase, 0x11a, Getenv(a0,a1,d0))
#pragma amicall(ArpBase, 0x120, Setenv(a0,a1))
#pragma amicall(ArpBase, 0x126, FileRequest(a0))
#pragma amicall(ArpBase, 0x12c, CloseWindowSafely(a0,a1))
#pragma amicall(ArpBase, 0x132, CreatePort(a0,d0))
#pragma amicall(ArpBase, 0x138, DeletePort(a1))
#pragma amicall(ArpBase, 0x13e, SendPacket(d0,a0,a1))
#pragma amicall(ArpBase, 0x144, InitStdPacket(d0,a0,a1,a2))
#pragma amicall(ArpBase, 0x14a, PathName(d0,a0,d1))
#pragma amicall(ArpBase, 0x150, Assign(a0,a1))
#pragma amicall(ArpBase, 0x156, DosAllocMem(d0))
#pragma amicall(ArpBase, 0x15c, DosFreeMem(a1))
#pragma amicall(ArpBase, 0x162, BtoCStr(a0,d0,d1))
#pragma amicall(ArpBase, 0x168, CtoBStr(a0,d0,d1))
#pragma amicall(ArpBase, 0x16e, GetDevInfo(a2))
#pragma amicall(ArpBase, 0x174, FreeTaskResList())
#pragma amicall(ArpBase, 0x17a, ArpExit(d0,d2))
#pragma amicall(ArpBase, 0x1a4, FindCLI(d0))
#pragma amicall(ArpBase, 0x1aa, QSort(a0,d0,d1,a1))
#pragma amicall(ArpBase, 0x1b0, PatternMatch(a0,a1))
#pragma amicall(ArpBase, 0x1b6, FindFirst(d0,a0))
#pragma amicall(ArpBase, 0x1bc, FindNext(a0))
#pragma amicall(ArpBase, 0x1c2, FreeAnchorChain(a0))
#pragma amicall(ArpBase, 0x1c8, CompareLock(d0,d1))
#pragma amicall(ArpBase, 0x1ce, FindTaskResList())
#pragma amicall(ArpBase, 0x1d4, CreateTaskResList())
#pragma amicall(ArpBase, 0x1da, FreeResList(a1))
#pragma amicall(ArpBase, 0x1e0, FreeTrackedItem(a1))
#pragma amicall(ArpBase, 0x1ec, GetAccess(a1))
#pragma amicall(ArpBase, 0x1f2, FreeAccess(a1))
#pragma amicall(ArpBase, 0x1f8, FreeDAList(a1))
#pragma amicall(ArpBase, 0x1fe, AddDANode(a0,a1,d0,d1))
#pragma amicall(ArpBase, 0x204, AddDADevs(a0,d0))
#pragma amicall(ArpBase, 0x20a, Strcmp(a0,a1))
#pragma amicall(ArpBase, 0x210, Strncmp(a0,a1,d0))
#pragma amicall(ArpBase, 0x21c, SyncRun(a0,a1,d0,d1))
#pragma amicall(ArpBase, 0x222, ASyncRun(a0,a1,a2))
#pragma amicall(ArpBase, 0x222, SpawnShell(a0,a1,a2))
#pragma amicall(ArpBase, 0x228, LoadPrg(d1))
#pragma amicall(ArpBase, 0x22e, PreParse(a0,a1))
#pragma amicall(ArpBase, 0x234, StamptoStr(a0))
#pragma amicall(ArpBase, 0x23a, StrtoStamp(a0))
#pragma amicall(ArpBase, 0x240, ObtainResidentPrg(a0))
#pragma amicall(ArpBase, 0x246, AddResidentPrg(d1,a0))
#pragma amicall(ArpBase, 0x24c, RemResidentPrg(a0))
#pragma amicall(ArpBase, 0x252, UnLoadPrg(d1))
#pragma amicall(ArpBase, 0x258, LMult(d0,d1))
#pragma amicall(ArpBase, 0x25e, LDiv(d0,d1))
#pragma amicall(ArpBase, 0x264, LMod(d0,d1))
#pragma amicall(ArpBase, 0x26a, CheckSumPrg(d0))
#pragma amicall(ArpBase, 0x270, TackOn(a0,a1))
#pragma amicall(ArpBase, 0x276, BaseName(a0))
#pragma amicall(ArpBase, 0x27c, ReleaseResidentPrg(d1))
#pragma amicall(ArpBase, 0xe4, ArpVPrintf(a0,a1))
#pragma amicall(ArpBase, 0xea, ArpVFPrintf(d0,a0,a1))
#pragma amicall(ArpBase, 0x282, ArpVSPrintf(d0,a0,a1))
#endif /* AZTEC_C */

#endif /* PROTO_ARP_H */
