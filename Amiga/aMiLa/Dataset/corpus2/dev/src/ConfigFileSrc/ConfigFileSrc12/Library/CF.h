/*
**		$PROJECT: ConfigFile.library
**		$FILE: CF.h
**		$DESCRIPTION: Main header file of the library.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef CF_H
#define CF_H

//#define CF_FUNC_DEBUG	TRUE
//#define CF_STEP_DEBUG	TRUE
//#define CF_MEMA_DEBUG	TRUE

#define CF_MAX_STRLEN	220

#define CF_IDENT_LEN		4
#define CF_IDENT_EXTLEN	5
#define CF_IDENT			0x43464654L

/********* Memory Pools functions of the AmigaLib or Kick3.0+ *************/

//#define POOLS_V39 1

#ifdef CF_MEMA_DEBUG

#define MyAllocPooled(a,b)		DEBAllocPooled (a, b)
#define MyCreatePool(a,b,c)	DEBCreatePool (a, b, c)
#define MyDeletePool(a)			DEBDeletePool (a)
#define MyFreePooled(a,b,c)	DEBFreePooled (a, b, c)

#else

#ifndef POOLS_V39

#define MyAllocPooled(a,b)		AsmAllocPooled (a, b, SysBase)
#define MyCreatePool(a,b,c)	AsmCreatePool (a, b, c, SysBase)
#define MyDeletePool(a)			AsmDeletePool (a, SysBase)
#define MyFreePooled(a,b,c)	AsmFreePooled (a, b, c, SysBase)

#else

#define MyAllocPooled(a,b)		AllocPooled (a, b)
#define MyCreatePool(a,b,c)	CreatePool (a, b, c)
#define MyDeletePool(a)			DeletePool (a)
#define MyFreePooled(a,b,c)	FreePooled (a, b, c)

#endif

#endif

/************************ Intern CF definitions ***************************/

typedef struct iCFHeader 
{
	ULONG				 OpenMode;
	ULONG				 Length;
	ULONG				 WBufLength;
	ULONG				 Flags;
	BPTR				 FileHandle;
	struct MinList	 GroupList;
	ULONG				 PuddleSize;
	APTR				 MemPool;			/* Private memory pool */
	UBYTE				 ArryNum;
	UBYTE				 ExtFlags;			/* CF intern flags */
} iCFHeader;

/* Extra flags of the iCFHeader */
#define CF_EFLG_ALREADY_READ	0x01

/* Extra flags for iCFGroup, iCFArgument, and iCFItem */
#define CF_EFLG_EXTERN_STRING	0x01	/* The pointer in #?Node->Name must
													be extra freeing */
#define CF_EFLG_REMOVED			0x02	/* The Node is removed */

typedef struct iCFGroup
{
	struct iCFGroup  *NextGrp;
	struct iCFGroup  *LastGrp;
	STRPTR			   Name;
	struct MinList	   ArgList;
	struct iCFHeader *Header;
	UBYTE					StructSize;		/* Size of the structure and the
													including string */
	UBYTE					ExtFlags;
	UBYTE					UnUsed;
} iCFGroup;

typedef struct iCFArgument
{
	struct iCFArgument *NextArg;
	struct iCFArgument *LastArg;
	STRPTR				  Name;
	struct MinList		  ItemList;
	struct iCFGroup	 *GrpNode;
	UBYTE					  StructSize;
	UBYTE					  ExtFlags;
	UBYTE					  UnUsed;
} iCFArgument;

typedef struct iCFItem
{
	struct iCFItem		 *NextItem;
	struct iCFItem		 *LastItem;
	UBYTE					  SpecialType;
	UBYTE					  Type;
	union	{
		STRPTR			  String;
		LONG				  Number;
		ULONG				  Bool;
		ULONG				  All;
	} Contents;
	struct iCFArgument *ArgNode;
	UBYTE					  StructSize;
	UBYTE					  ExtFlags;
	UBYTE					  UnUsed;
} iCFItem;

#endif /* CF_H */
