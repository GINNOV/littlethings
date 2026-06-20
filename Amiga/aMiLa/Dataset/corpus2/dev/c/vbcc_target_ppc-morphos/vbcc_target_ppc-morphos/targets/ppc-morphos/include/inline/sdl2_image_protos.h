#ifndef _VBCCINLINE_SDL2_IMAGE_H
#define _VBCCINLINE_SDL2_IMAGE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

SDL_Surface * __IMG_LoadTyped_RW(SDL_RWops * src, int freesrc, char * type) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadTyped_RW(src, freesrc, type) __IMG_LoadTyped_RW((src), (freesrc), (type))

SDL_Surface * __IMG_Load(const char * file) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_Load(file) __IMG_Load((file))

SDL_Surface * __IMG_Load_RW(SDL_RWops * src, int freesrc) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_Load_RW(src, freesrc) __IMG_Load_RW((src), (freesrc))

int __IMG_SavePNG(SDL_Surface * surface, const char * file) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_SavePNG(surface, file) __IMG_SavePNG((surface), (file))

int __IMG_SavePNG_RW(SDL_Surface * surface, SDL_RWops * dst, int freedst) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_SavePNG_RW(surface, dst, freedst) __IMG_SavePNG_RW((surface), (dst), (freedst))

SDL_Texture * __IMG_LoadTexture(SDL_Renderer * renderer, const char * file) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadTexture(renderer, file) __IMG_LoadTexture((renderer), (file))

SDL_Texture * __IMG_LoadTexture_RW(SDL_Renderer * renderer, SDL_RWops * src, int freesrc) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadTexture_RW(renderer, src, freesrc) __IMG_LoadTexture_RW((renderer), (src), (freesrc))

SDL_Texture * __IMG_LoadTextureTyped_RW(SDL_Renderer * renderer, SDL_RWops * src, int freesrc, const char * type) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadTextureTyped_RW(renderer, src, freesrc, type) __IMG_LoadTextureTyped_RW((renderer), (src), (freesrc), (type))

int __IMG_isBMP(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isBMP(src) __IMG_isBMP((src))

int __IMG_isPNM(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isPNM(src) __IMG_isPNM((src))

int __IMG_isXPM(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isXPM(src) __IMG_isXPM((src))

int __IMG_isXCF(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isXCF(src) __IMG_isXCF((src))

int __IMG_isPCX(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isPCX(src) __IMG_isPCX((src))

int __IMG_isGIF(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isGIF(src) __IMG_isGIF((src))

int __IMG_isJPG(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isJPG(src) __IMG_isJPG((src))

int __IMG_isTIF(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isTIF(src) __IMG_isTIF((src))

int __IMG_isPNG(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isPNG(src) __IMG_isPNG((src))

int __IMG_isLBM(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isLBM(src) __IMG_isLBM((src))

int __IMG_isXV(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isXV(src) __IMG_isXV((src))

int __IMG_isWEBP(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_isWEBP(src) __IMG_isWEBP((src))

SDL_Surface * __IMG_LoadBMP_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadBMP_RW(src) __IMG_LoadBMP_RW((src))

SDL_Surface * __IMG_LoadPNM_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadPNM_RW(src) __IMG_LoadPNM_RW((src))

SDL_Surface * __IMG_LoadXPM_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadXPM_RW(src) __IMG_LoadXPM_RW((src))

SDL_Surface * __IMG_LoadXCF_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadXCF_RW(src) __IMG_LoadXCF_RW((src))

SDL_Surface * __IMG_LoadPCX_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadPCX_RW(src) __IMG_LoadPCX_RW((src))

SDL_Surface * __IMG_LoadGIF_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadGIF_RW(src) __IMG_LoadGIF_RW((src))

SDL_Surface * __IMG_LoadJPG_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadJPG_RW(src) __IMG_LoadJPG_RW((src))

SDL_Surface * __IMG_LoadTIF_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadTIF_RW(src) __IMG_LoadTIF_RW((src))

SDL_Surface * __IMG_LoadPNG_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadPNG_RW(src) __IMG_LoadPNG_RW((src))

SDL_Surface * __IMG_LoadTGA_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadTGA_RW(src) __IMG_LoadTGA_RW((src))

SDL_Surface * __IMG_LoadLBM_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadLBM_RW(src) __IMG_LoadLBM_RW((src))

SDL_Surface * __IMG_LoadXV_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadXV_RW(src) __IMG_LoadXV_RW((src))

SDL_Surface * __IMG_LoadWEBP_RW(SDL_RWops * src) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_LoadWEBP_RW(src) __IMG_LoadWEBP_RW((src))

SDL_Surface * __IMG_ReadXPMFromArray(char ** xpm) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_ReadXPMFromArray(xpm) __IMG_ReadXPMFromArray((xpm))

const SDL_version * __IMG_Linked_Version() =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_Linked_Version() __IMG_Linked_Version()

int __IMG_Init(int flags) =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_Init(flags) __IMG_Init((flags))

void __IMG_Quit() =
	"\tlis\t11,SDL2ImageBase@ha\n"
	"\tlwz\t12,SDL2ImageBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IMG_Quit() __IMG_Quit()

#endif /*  _VBCCINLINE_SDL2_IMAGE_H  */
