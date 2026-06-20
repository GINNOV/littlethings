#ifndef _AWINCPU5AZURE2_H
#define _AWINCPU5AZURE2_H

#ifdef __GNUC__

void awinitchunky2planar(UBYTE *chunky __asm("a0"),
  ULONG width __asm("d0"),ULONG height __asm("d1"),
  ULONG depth __asm("d2"));

void awchunky2planar(UBYTE *planar __asm("a1"));

#endif /* __GNUC__ */


#ifdef __SASC

void __asm awinitchunky2planar(register __a0 UBYTE *chunky,
  register __d0 ULONG width, register __d1 ULONG height,
  register __d2 ULONG depth);

void __asm awchunky2planar(register __a1 UBYTE *planar);

#endif /* __SASC */


#endif /* _AWINCPU5AZURE2_H */
