/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_POWERSDL_GFX_H
#define _VBCCINLINE_POWERSDL_GFX_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

int  __bezierColor(SDL_Surface *, const Sint16 *, const Sint16 *, int , int , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define bezierColor(__p0, __p1, __p2, __p3, __p4, __p5) __bezierColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

SDL_Surface * __rotozoomSurfaceXY(SDL_Surface *, double , double , double , int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define rotozoomSurfaceXY(__p0, __p1, __p2, __p3, __p4) __rotozoomSurfaceXY((__p0), (__p1), (__p2), (__p3), (__p4))

int  __lineRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define lineRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __lineRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

int  __boxRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define boxRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __boxRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

void  __SDL_framerateDelay(FPSmanager *) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_framerateDelay(__p0) __SDL_framerateDelay((__p0))

int  __characterColor(SDL_Surface *, Sint16 , Sint16 , char , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define characterColor(__p0, __p1, __p2, __p3, __p4) __characterColor((__p0), (__p1), (__p2), (__p3), (__p4))

void  __rotozoomSurfaceSize(int , int , double , double , int *, int *) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define rotozoomSurfaceSize(__p0, __p1, __p2, __p3, __p4, __p5) __rotozoomSurfaceSize((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

void  __SDL_initFramerate(FPSmanager *) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_initFramerate(__p0) __SDL_initFramerate((__p0))

int  __SDL_imageFilterDiv(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterDiv(__p0, __p1, __p2, __p3) __SDL_imageFilterDiv((__p0), (__p1), (__p2), (__p3))

SDL_Surface * __zoomSurface(SDL_Surface *, double , double , int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define zoomSurface(__p0, __p1, __p2, __p3) __zoomSurface((__p0), (__p1), (__p2), (__p3))

int  __hlineColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define hlineColor(__p0, __p1, __p2, __p3, __p4) __hlineColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __aaellipseColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aaellipseColor(__p0, __p1, __p2, __p3, __p4, __p5) __aaellipseColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __aacircleRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aacircleRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __aacircleRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __circleColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define circleColor(__p0, __p1, __p2, __p3, __p4) __circleColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __SDL_imageFilterBinarizeUsingThreshold(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterBinarizeUsingThreshold(__p0, __p1, __p2, __p3) __SDL_imageFilterBinarizeUsingThreshold((__p0), (__p1), (__p2), (__p3))

int  __stringRGBA(SDL_Surface *, Sint16 , Sint16 , const char *, Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define stringRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __stringRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __SDL_imageFilterShiftLeftUint(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterShiftLeftUint(__p0, __p1, __p2, __p3) __SDL_imageFilterShiftLeftUint((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterAddUint(unsigned char *, unsigned char *, int , unsigned int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterAddUint(__p0, __p1, __p2, __p3) __SDL_imageFilterAddUint((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterShiftLeft(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterShiftLeft(__p0, __p1, __p2, __p3) __SDL_imageFilterShiftLeft((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterAdd(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterAdd(__p0, __p1, __p2, __p3) __SDL_imageFilterAdd((__p0), (__p1), (__p2), (__p3))

int  __aatrigonColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aatrigonColor(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __aatrigonColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __stringColor(SDL_Surface *, Sint16 , Sint16 , const char *, Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define stringColor(__p0, __p1, __p2, __p3, __p4) __stringColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __filledPolygonColor(SDL_Surface *, const Sint16 *, const Sint16 *, int , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledPolygonColor(__p0, __p1, __p2, __p3, __p4) __filledPolygonColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __SDL_imageFilterSobelX(unsigned char *, unsigned char *, int , int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterSobelX(__p0, __p1, __p2, __p3) __SDL_imageFilterSobelX((__p0), (__p1), (__p2), (__p3))

void  __SDL_imageFilterMMXon() =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMMXon() __SDL_imageFilterMMXon()

int  __pieColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define pieColor(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __pieColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

int  __filledTrigonRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledTrigonRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9, __p10) __filledTrigonRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9), (__p10))

int  __filledTrigonColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledTrigonColor(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __filledTrigonColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __SDL_imageFilterAddByteToHalf(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterAddByteToHalf(__p0, __p1, __p2, __p3) __SDL_imageFilterAddByteToHalf((__p0), (__p1), (__p2), (__p3))

int  __lineColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define lineColor(__p0, __p1, __p2, __p3, __p4, __p5) __lineColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterShiftLeftByte(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterShiftLeftByte(__p0, __p1, __p2, __p3) __SDL_imageFilterShiftLeftByte((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterAddByte(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterAddByte(__p0, __p1, __p2, __p3) __SDL_imageFilterAddByte((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterBitOr(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterBitOr(__p0, __p1, __p2, __p3) __SDL_imageFilterBitOr((__p0), (__p1), (__p2), (__p3))

int  __ellipseColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ellipseColor(__p0, __p1, __p2, __p3, __p4, __p5) __ellipseColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __circleRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define circleRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __circleRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __rectangleRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define rectangleRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __rectangleRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

int  __aacircleColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aacircleColor(__p0, __p1, __p2, __p3, __p4) __aacircleColor((__p0), (__p1), (__p2), (__p3), (__p4))

void  __gfxPrimitivesSetFont(const void *, int , int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define gfxPrimitivesSetFont(__p0, __p1, __p2) __gfxPrimitivesSetFont((__p0), (__p1), (__p2))

void  __SDL_imageFilterMMXoff() =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMMXoff() __SDL_imageFilterMMXoff()

int  __SDL_getFramerate(FPSmanager *) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_getFramerate(__p0) __SDL_getFramerate((__p0))

int  __pieRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define pieRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9) __pieRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9))

int  __SDL_imageFilterMultByByte(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMultByByte(__p0, __p1, __p2, __p3) __SDL_imageFilterMultByByte((__p0), (__p1), (__p2), (__p3))

int  __bezierRGBA(SDL_Surface *, const Sint16 *, const Sint16 *, int , int , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define bezierRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __bezierRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

int  __SDL_imageFilterMultDivby2(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMultDivby2(__p0, __p1, __p2, __p3) __SDL_imageFilterMultDivby2((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterMultDivby4(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMultDivby4(__p0, __p1, __p2, __p3) __SDL_imageFilterMultDivby4((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterBitNegation(unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterBitNegation(__p0, __p1, __p2) __SDL_imageFilterBitNegation((__p0), (__p1), (__p2))

int  __filledCircleColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledCircleColor(__p0, __p1, __p2, __p3, __p4) __filledCircleColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __polygonRGBA(SDL_Surface *, const Sint16 *, const Sint16 *, int , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define polygonRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __polygonRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

void  __SDL_imageFilterRestoreStack() =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterRestoreStack() __SDL_imageFilterRestoreStack()

int  __SDL_setFramerate(FPSmanager *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_setFramerate(__p0, __p1) __SDL_setFramerate((__p0), (__p1))

int  __SDL_imageFilterShiftRightUint(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterShiftRightUint(__p0, __p1, __p2, __p3) __SDL_imageFilterShiftRightUint((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterShiftRight(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterShiftRight(__p0, __p1, __p2, __p3) __SDL_imageFilterShiftRight((__p0), (__p1), (__p2), (__p3))

int  __boxColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define boxColor(__p0, __p1, __p2, __p3, __p4, __p5) __boxColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

void  __zoomSurfaceSize(int , int , double , double , int *, int *) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define zoomSurfaceSize(__p0, __p1, __p2, __p3, __p4, __p5) __zoomSurfaceSize((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __aalineColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aalineColor(__p0, __p1, __p2, __p3, __p4, __p5) __aalineColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __aapolygonColor(SDL_Surface *, const Sint16 *, const Sint16 *, int , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aapolygonColor(__p0, __p1, __p2, __p3, __p4) __aapolygonColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __characterRGBA(SDL_Surface *, Sint16 , Sint16 , char , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define characterRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __characterRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __ellipseRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ellipseRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __ellipseRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

int  __SDL_imageFilterConvolveKernel3x3Divide(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel3x3Divide(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel3x3Divide((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterShiftRightAndMultByByte(unsigned char *, unsigned char *, int , unsigned char , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterShiftRightAndMultByByte(__p0, __p1, __p2, __p3, __p4) __SDL_imageFilterShiftRightAndMultByByte((__p0), (__p1), (__p2), (__p3), (__p4))

int  __filledPieColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledPieColor(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __filledPieColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

int  __SDL_imageFilterConvolveKernel5x5Divide(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel5x5Divide(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel5x5Divide((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __aatrigonRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aatrigonRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9, __p10) __aatrigonRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9), (__p10))

SDL_Surface * __rotozoomSurface(SDL_Surface *, double , double , int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define rotozoomSurface(__p0, __p1, __p2, __p3) __rotozoomSurface((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterConvolveKernel3x3ShiftRight(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel3x3ShiftRight(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel3x3ShiftRight((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterConvolveKernel7x7Divide(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel7x7Divide(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel7x7Divide((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterSub(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterSub(__p0, __p1, __p2, __p3) __SDL_imageFilterSub((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterSubUint(unsigned char *, unsigned char *, int , unsigned int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterSubUint(__p0, __p1, __p2, __p3) __SDL_imageFilterSubUint((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterConvolveKernel5x5ShiftRight(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel5x5ShiftRight(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel5x5ShiftRight((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterConvolveKernel9x9Divide(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel9x9Divide(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel9x9Divide((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterAbsDiff(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterAbsDiff(__p0, __p1, __p2, __p3) __SDL_imageFilterAbsDiff((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterConvolveKernel7x7ShiftRight(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel7x7ShiftRight(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel7x7ShiftRight((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterMultNor(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMultNor(__p0, __p1, __p2, __p3) __SDL_imageFilterMultNor((__p0), (__p1), (__p2), (__p3))

int  __filledEllipseColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledEllipseColor(__p0, __p1, __p2, __p3, __p4, __p5) __filledEllipseColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __vlineColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define vlineColor(__p0, __p1, __p2, __p3, __p4) __vlineColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __SDL_imageFilterBitAnd(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterBitAnd(__p0, __p1, __p2, __p3) __SDL_imageFilterBitAnd((__p0), (__p1), (__p2), (__p3))

int  __filledCircleRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledCircleRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __filledCircleRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __SDL_imageFilterConvolveKernel9x9ShiftRight(unsigned char *, unsigned char *, int , int , signed short *, unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterConvolveKernel9x9ShiftRight(__p0, __p1, __p2, __p3, __p4, __p5) __SDL_imageFilterConvolveKernel9x9ShiftRight((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __pixelColor(SDL_Surface *, Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define pixelColor(__p0, __p1, __p2, __p3) __pixelColor((__p0), (__p1), (__p2), (__p3))

int  __SDL_imageFilterClipToRange(unsigned char *, unsigned char *, int , unsigned char , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterClipToRange(__p0, __p1, __p2, __p3, __p4) __SDL_imageFilterClipToRange((__p0), (__p1), (__p2), (__p3), (__p4))

int  __aapolygonRGBA(SDL_Surface *, const Sint16 *, const Sint16 *, int , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aapolygonRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __aapolygonRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __aalineRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aalineRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __aalineRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

int  __polygonColor(SDL_Surface *, const Sint16 *, const Sint16 *, int , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define polygonColor(__p0, __p1, __p2, __p3, __p4) __polygonColor((__p0), (__p1), (__p2), (__p3), (__p4))

int  __SDL_imageFilterSubByte(unsigned char *, unsigned char *, int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterSubByte(__p0, __p1, __p2, __p3) __SDL_imageFilterSubByte((__p0), (__p1), (__p2), (__p3))

int  __filledPieRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledPieRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9) __filledPieRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9))

int  __SDL_imageFilterMean(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMean(__p0, __p1, __p2, __p3) __SDL_imageFilterMean((__p0), (__p1), (__p2), (__p3))

int  __hlineRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define hlineRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __hlineRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __aaellipseRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define aaellipseRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __aaellipseRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

void  __SDL_imageFilterAlignStack() =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterAlignStack() __SDL_imageFilterAlignStack()

int  __SDL_imageFilterMult(unsigned char *, unsigned char *, unsigned char *, int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMult(__p0, __p1, __p2, __p3) __SDL_imageFilterMult((__p0), (__p1), (__p2), (__p3))

int  __trigonRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define trigonRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9, __p10) __trigonRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9), (__p10))

int  __trigonColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define trigonColor(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __trigonColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __filledPolygonRGBA(SDL_Surface *, const Sint16 *, const Sint16 *, int , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledPolygonRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __filledPolygonRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __rectangleColor(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint32 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define rectangleColor(__p0, __p1, __p2, __p3, __p4, __p5) __rectangleColor((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

int  __SDL_imageFilterSobelXShiftRight(unsigned char *, unsigned char *, int , int , unsigned char ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterSobelXShiftRight(__p0, __p1, __p2, __p3, __p4) __SDL_imageFilterSobelXShiftRight((__p0), (__p1), (__p2), (__p3), (__p4))

int  __SDL_imageFilterMMXdetect() =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterMMXdetect() __SDL_imageFilterMMXdetect()

int  __SDL_imageFilterNormalizeLinear(unsigned char *, unsigned char *, int , int , int , int , int ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_imageFilterNormalizeLinear(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __SDL_imageFilterNormalizeLinear((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

int  __vlineRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define vlineRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __vlineRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

int  __filledEllipseRGBA(SDL_Surface *, Sint16 , Sint16 , Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define filledEllipseRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8) __filledEllipseRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8))

int  __pixelRGBA(SDL_Surface *, Sint16 , Sint16 , Uint8 , Uint8 , Uint8 , Uint8 ) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define pixelRGBA(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __pixelRGBA((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __rotozoomSurfaceSizeXY(int , int , double , double , double , int *, int *) =
	"\tlis\t11,PowerSDLGfxBase@ha\n"
	"\tlwz\t12,PowerSDLGfxBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define rotozoomSurfaceSizeXY(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __rotozoomSurfaceSizeXY((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

#endif /* !_VBCCINLINE_POWERSDL_GFX_H */
