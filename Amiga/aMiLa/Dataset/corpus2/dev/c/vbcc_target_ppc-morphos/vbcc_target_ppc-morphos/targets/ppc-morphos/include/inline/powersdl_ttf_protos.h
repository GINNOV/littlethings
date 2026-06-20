/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_POWERSDL_TTF_H
#define _VBCCINLINE_POWERSDL_TTF_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

int  __TTF_FontAscent(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontAscent(__p0) __TTF_FontAscent((__p0))

int  __TTF_FontLineSkip(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontLineSkip(__p0) __TTF_FontLineSkip((__p0))

char * __TTF_FontFaceStyleName(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontFaceStyleName(__p0) __TTF_FontFaceStyleName((__p0))

long  __TTF_FontFaces(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontFaces(__p0) __TTF_FontFaces((__p0))

const SDL_version * __TTF_Linked_Version() =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_Linked_Version() __TTF_Linked_Version()

int  __TTF_WasInit() =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_WasInit() __TTF_WasInit()

SDL_Surface * __TTF_RenderUNICODE_Solid(TTF_Font *, const Uint16 *, SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderUNICODE_Solid(__p0, __p1, __p2) __TTF_RenderUNICODE_Solid((__p0), (__p1), (__p2))

SDL_Surface * __TTF_RenderUTF8_Solid(TTF_Font *, const char *, SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderUTF8_Solid(__p0, __p1, __p2) __TTF_RenderUTF8_Solid((__p0), (__p1), (__p2))

TTF_Font * __TTF_OpenFontIndex(const char *, int , long ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_OpenFontIndex(__p0, __p1, __p2) __TTF_OpenFontIndex((__p0), (__p1), (__p2))

int  __TTF_SizeUTF8(TTF_Font *, const char *, int *, int *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_SizeUTF8(__p0, __p1, __p2, __p3) __TTF_SizeUTF8((__p0), (__p1), (__p2), (__p3))

int  __TTF_GetFontStyle(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_GetFontStyle(__p0) __TTF_GetFontStyle((__p0))

char * __TTF_FontFaceFamilyName(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontFaceFamilyName(__p0) __TTF_FontFaceFamilyName((__p0))

SDL_Surface * __TTF_RenderGlyph_Shaded(TTF_Font *, Uint16 , SDL_Color , SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderGlyph_Shaded(__p0, __p1, __p2, __p3) __TTF_RenderGlyph_Shaded((__p0), (__p1), (__p2), (__p3))

void  __TTF_CloseFont(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_CloseFont(__p0) __TTF_CloseFont((__p0))

SDL_Surface * __TTF_RenderUNICODE_Shaded(TTF_Font *, const Uint16 *, SDL_Color , SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderUNICODE_Shaded(__p0, __p1, __p2, __p3) __TTF_RenderUNICODE_Shaded((__p0), (__p1), (__p2), (__p3))

SDL_Surface * __TTF_RenderUTF8_Shaded(TTF_Font *, const char *, SDL_Color , SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderUTF8_Shaded(__p0, __p1, __p2, __p3) __TTF_RenderUTF8_Shaded((__p0), (__p1), (__p2), (__p3))

void  __TTF_ByteSwappedUNICODE(int ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_ByteSwappedUNICODE(__p0) __TTF_ByteSwappedUNICODE((__p0))

int  __TTF_FontHeight(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontHeight(__p0) __TTF_FontHeight((__p0))

int  __TTF_FontFaceIsFixedWidth(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontFaceIsFixedWidth(__p0) __TTF_FontFaceIsFixedWidth((__p0))

TTF_Font * __TTF_OpenFontRW(SDL_RWops *, int , int ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_OpenFontRW(__p0, __p1, __p2) __TTF_OpenFontRW((__p0), (__p1), (__p2))

int  __TTF_Init() =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_Init() __TTF_Init()

void  __TTF_SetFontStyle(TTF_Font *, int ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_SetFontStyle(__p0, __p1) __TTF_SetFontStyle((__p0), (__p1))

SDL_Surface * __TTF_RenderUTF8_Blended(TTF_Font *, const char *, SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderUTF8_Blended(__p0, __p1, __p2) __TTF_RenderUTF8_Blended((__p0), (__p1), (__p2))

SDL_Surface * __TTF_RenderUNICODE_Blended(TTF_Font *, const Uint16 *, SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderUNICODE_Blended(__p0, __p1, __p2) __TTF_RenderUNICODE_Blended((__p0), (__p1), (__p2))

int  __TTF_GlyphMetrics(TTF_Font *, Uint16 , int *, int *, int *, int *, int *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_GlyphMetrics(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __TTF_GlyphMetrics((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

int  __TTF_FontDescent(TTF_Font *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_FontDescent(__p0) __TTF_FontDescent((__p0))

SDL_Surface * __TTF_RenderGlyph_Solid(TTF_Font *, Uint16 , SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderGlyph_Solid(__p0, __p1, __p2) __TTF_RenderGlyph_Solid((__p0), (__p1), (__p2))

SDL_Surface * __TTF_RenderText_Solid(TTF_Font *, const char *, SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderText_Solid(__p0, __p1, __p2) __TTF_RenderText_Solid((__p0), (__p1), (__p2))

int  __TTF_SizeText(TTF_Font *, const char *, int *, int *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_SizeText(__p0, __p1, __p2, __p3) __TTF_SizeText((__p0), (__p1), (__p2), (__p3))

int  __TTF_SizeUNICODE(TTF_Font *, const Uint16 *, int *, int *) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_SizeUNICODE(__p0, __p1, __p2, __p3) __TTF_SizeUNICODE((__p0), (__p1), (__p2), (__p3))

void  __TTF_Quit() =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_Quit() __TTF_Quit()

TTF_Font * __TTF_OpenFont(const char *, int ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_OpenFont(__p0, __p1) __TTF_OpenFont((__p0), (__p1))

TTF_Font * __TTF_OpenFontIndexRW(SDL_RWops *, int , int , long ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_OpenFontIndexRW(__p0, __p1, __p2, __p3) __TTF_OpenFontIndexRW((__p0), (__p1), (__p2), (__p3))

SDL_Surface * __TTF_RenderText_Shaded(TTF_Font *, const char *, SDL_Color , SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderText_Shaded(__p0, __p1, __p2, __p3) __TTF_RenderText_Shaded((__p0), (__p1), (__p2), (__p3))

SDL_Surface * __TTF_RenderGlyph_Blended(TTF_Font *, Uint16 , SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderGlyph_Blended(__p0, __p1, __p2) __TTF_RenderGlyph_Blended((__p0), (__p1), (__p2))

SDL_Surface * __TTF_RenderText_Blended(TTF_Font *, const char *, SDL_Color ) =
	"\tlis\t11,PowerSDLTTFBase@ha\n"
	"\tlwz\t12,PowerSDLTTFBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define TTF_RenderText_Blended(__p0, __p1, __p2) __TTF_RenderText_Blended((__p0), (__p1), (__p2))

#endif /* !_VBCCINLINE_POWERSDL_TTF_H */
