#ifndef _INCLUDE_PROTO_BULLET_LOC_H
#define _INCLUDE_PROTO_BULLET_LOC_H

#include <exec/types.h>

#ifdef __cplusplus
extern "C" {
#endif

struct GlyphEngine * LOC_OpenEngine(struct Library * libbase);
#define OpenEngine(a) LOC_OpenEngine((struct Library *) a)

VOID LOC_CloseEngine(struct Library * libbase, struct GlyphEngine * glyphEngine);
#define CloseEngine(a) LOC_CloseEngine((struct Library *) BulletBase, a)

ULONG LOC_SetInfoA(struct Library * libbase, struct GlyphEngine * glyphEngine, struct TagItem * tagList);
#define SetInfoA(a, b) LOC_SetInfoA((struct Library *) BulletBase, a, b)

ULONG LOC_SetInfo(struct Library * libbase, struct GlyphEngine * glyphEngine, ...);
ULONG LOC_ObtainInfoA(struct Library * libbase, struct GlyphEngine * glyphEngine, struct TagItem * tagList);
#define ObtainInfoA(a, b) LOC_ObtainInfoA((struct Library *) BulletBase, a, b)

ULONG LOC_ObtainInfo(struct Library * libbase, struct GlyphEngine * glyphEngine, ...);
ULONG LOC_ReleaseInfoA(struct Library * libbase, struct GlyphEngine * glyphEngine, struct TagItem * tagList);
#define ReleaseInfoA(a, b) LOC_ReleaseInfoA((struct Library *) BulletBase, a, b)

ULONG LOC_ReleaseInfo(struct Library * libbase, struct GlyphEngine * glyphEngine, ...);
#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PROTO_BULLET_LOC_H  */
