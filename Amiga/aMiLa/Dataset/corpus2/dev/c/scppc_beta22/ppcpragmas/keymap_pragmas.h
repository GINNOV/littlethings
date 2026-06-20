/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_KEYMAP_H
#define _PPCPRAGMA_KEYMAP_H
#ifdef __GNUC__
#ifndef _PPCINLINE__KEYMAP_H
#include <ppcinline/keymap.h>
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

#ifndef KEYMAP_BASE_NAME
#define KEYMAP_BASE_NAME KeymapBase
#endif /* !KEYMAP_BASE_NAME */

#define	AskKeyMapDefault()	_AskKeyMapDefault(KEYMAP_BASE_NAME)

static __inline struct KeyMap *
_AskKeyMapDefault(void *KeymapBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) KeymapBase;	
	return((struct KeyMap *)PPCCallOS(&MyCaos));
}

#define	MapANSI(string, count, buffer, length, keyMap)	_MapANSI(KEYMAP_BASE_NAME, string, count, buffer, length, keyMap)

static __inline LONG
_MapANSI(void *KeymapBase, STRPTR string, long count, STRPTR buffer, long length, struct KeyMap *keyMap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d0		=(ULONG) count;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d1		=(ULONG) length;
	MyCaos.a2		=(ULONG) keyMap;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) KeymapBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MapRawKey(event, buffer, length, keyMap)	_MapRawKey(KEYMAP_BASE_NAME, event, buffer, length, keyMap)

static __inline WORD
_MapRawKey(void *KeymapBase, struct InputEvent *event, STRPTR buffer, long length, struct KeyMap *keyMap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) event;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d1		=(ULONG) length;
	MyCaos.a2		=(ULONG) keyMap;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) KeymapBase;	
	return((WORD)PPCCallOS(&MyCaos));
}

#define	SetKeyMapDefault(keyMap)	_SetKeyMapDefault(KEYMAP_BASE_NAME, keyMap)

static __inline void
_SetKeyMapDefault(void *KeymapBase, struct KeyMap *keyMap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) keyMap;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) KeymapBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_KEYMAP_H */
