/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_ASL_H
#define _PPCPRAGMA_ASL_H
#ifdef __GNUC__
#ifndef _PPCINLINE__ASL_H
#include <ppcinline/asl.h>
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

#ifndef ASL_BASE_NAME
#define ASL_BASE_NAME AslBase
#endif /* !ASL_BASE_NAME */

#define	AllocAslRequest(reqType, tagList)	_AllocAslRequest(ASL_BASE_NAME, reqType, tagList)

static __inline APTR
_AllocAslRequest(void *AslBase, unsigned long reqType, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) reqType;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) AslBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AllocAslRequestTags(a0, tags...) \
	({ULONG _tags[] = { tags }; AllocAslRequest((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AllocFileRequest()	_AllocFileRequest(ASL_BASE_NAME)

static __inline struct FileRequester *
_AllocFileRequest(void *AslBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) AslBase;	
	return((struct FileRequester *)PPCCallOS(&MyCaos));
}

#define	AslRequest(requester, tagList)	_AslRequest(ASL_BASE_NAME, requester, tagList)

static __inline BOOL
_AslRequest(void *AslBase, APTR requester, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) requester;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) AslBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AslRequestTags(a0, tags...) \
	({ULONG _tags[] = { tags }; AslRequest((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	FreeAslRequest(requester)	_FreeAslRequest(ASL_BASE_NAME, requester)

static __inline void
_FreeAslRequest(void *AslBase, APTR requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) AslBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeFileRequest(fileReq)	_FreeFileRequest(ASL_BASE_NAME, fileReq)

static __inline void
_FreeFileRequest(void *AslBase, struct FileRequester *fileReq)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) fileReq;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) AslBase;	
	PPCCallOS(&MyCaos);
}

#define	RequestFile(fileReq)	_RequestFile(ASL_BASE_NAME, fileReq)

static __inline BOOL
_RequestFile(void *AslBase, struct FileRequester *fileReq)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) fileReq;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) AslBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_ASL_H */
