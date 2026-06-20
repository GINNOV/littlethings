#ifndef _AWINDDAZURE2_H
#define _AWINDDAZURE2_H

#include <exec/types.h>

#ifdef __GNUC__

void awddscalech68k8(
  UBYTE *src __asm("a2"),UBYTE *dst __asm("a0"),
  ULONG swidth __asm("d0"),ULONG sheight __asm("d1"),
  ULONG dwidth __asm("d2"),ULONG dheight __asm("d3"),
  ULONG dwidtha __asm("d4"),ULONG dppr __asm("d5"));

void awddremapscalech68k8(
  UBYTE *src __asm("a2"),UBYTE *dst __asm("a0"),
  UBYTE *remap __asm("a6"),
  ULONG swidth __asm("d0"),ULONG sheight __asm("d1"),
  ULONG dwidth __asm("d2"),ULONG dheight __asm("d3"),
  ULONG dwidtha __asm("d4"));

void awddscalech68k16(
  UBYTE *src __asm("a2"),UBYTE *dst __asm("a0"),
  ULONG swidth __asm("d0"),ULONG sheight __asm("d1"),
  ULONG dwidth __asm("d2"),ULONG dheight __asm("d3"),
  ULONG dwidtha __asm("d4"),ULONG dppr __asm("d5"));

void awddremapscalech68k16(
  UBYTE *src __asm("a2"),UBYTE *dst __asm("a0"),
  UBYTE *remap __asm("a6"),
  ULONG swidth __asm("d0"),ULONG sheight __asm("d1"),
  ULONG dwidth __asm("d2"),ULONG dheight __asm("d3"),
  ULONG dwidtha __asm("d4"));

void awddscalech68k16_565(
  UBYTE *src __asm("a2"),UBYTE *dst __asm("a0"),
  ULONG swidth __asm("d0"),ULONG sheight __asm("d1"),
  ULONG dwidth __asm("d2"),ULONG dheight __asm("d3"),
  ULONG dwidtha __asm("d4"),ULONG dppr __asm("d5"));

void awddscalech68k16_argb(
  UBYTE *src __asm("a2"),UBYTE *dst __asm("a0"),
  ULONG swidth __asm("d0"),ULONG sheight __asm("d1"),
  ULONG dwidth __asm("d2"),ULONG dheight __asm("d3"),
  ULONG dwidtha __asm("d4"),ULONG dppr __asm("d5"));

#endif /* __GNUC__ */


#ifdef __SASC

void __asm awddscalech68k8(
  register __a2 UBYTE *src,register __a0 UBYTE *dst,
  register __d0 ULONG swidth,register __d1 ULONG sheight,
  register __d2 ULONG dwidth,register __d3 ULONG dheight,
  register __d4 ULONG dwidtha,register __d5 ULONG dppr);

void __asm awddremapscalech68k8(
  register __a2 UBYTE *src,register __a0 UBYTE *dst,
  register __a6 UBYTE *remap,
  register __d0 ULONG swidth,register __d1 ULONG sheight,
  register __d2 ULONG dwidth,register __d3 ULONG dheight,
  register __d4 ULONG dwidtha);

void __asm awddscalech68k16(
  register __a2 UBYTE *src,register __a0 UBYTE *dst,
  register __d0 ULONG swidth,register __d1 ULONG sheight,
  register __d2 ULONG dwidth,register __d3 ULONG dheight,
  register __d4 ULONG dwidtha,register __d5 ULONG dppr);

void __asm awddremapscalech68k16(
  register __a2 UBYTE *src,register __a0 UBYTE *dst,
  register __a6 UBYTE *remap,
  register __d0 ULONG swidth,register __d1 ULONG sheight,
  register __d2 ULONG dwidth,register __d3 ULONG dheight,
  register __d4 ULONG dwidtha);

void __asm awddscalech68k16_565(
  register __a2 UBYTE *src,register __a0 UBYTE *dst,
  register __d0 ULONG swidth,register __d1 ULONG sheight,
  register __d2 ULONG dwidth,register __d3 ULONG dheight,
  register __d4 ULONG dwidtha,register __d5 ULONG dppr);

void __asm awddscalech68k16_argb(
  register __a2 UBYTE *src,register __a0 UBYTE *dst,
  register __d0 ULONG swidth,register __d1 ULONG sheight,
  register __d2 ULONG dwidth,register __d3 ULONG dheight,
  register __d4 ULONG dwidtha,register __d5 ULONG dppr);

#endif /* __SASC */


#endif /* _AWINDDAZURE2_H */
