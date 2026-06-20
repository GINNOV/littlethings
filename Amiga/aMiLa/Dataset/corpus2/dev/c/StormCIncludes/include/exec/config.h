#ifndef EXEC_CONFIG_H
#define EXEC_CONFIG_H
/*
**  $VER: config.h 50.1 (26.06.2000)
**  Includes Release 50.1
**
**  To be compatible to the old 68k-AmigaOS calling convention for
**  libraries.
**
*/

#ifdef __STORM__
    #define __ASM
    #define __STDARGS
#elif defined(__GNUC__)
    #define __ASM
    #define __STDARGS __stdargs
#else
    #define __ASM __asm
    #define __STDARGS __stdargs
#endif
#define __SAVEDS __saveds



#ifdef __STORM__
#ifndef __PPC__

#define __LIBBASE(arg) register __a6 arg

#define __REGD0(arg) register __d0 arg
#define __REGD1(arg) register __d1 arg
#define __REGD2(arg) register __d2 arg
#define __REGD3(arg) register __d3 arg
#define __REGD4(arg) register __d4 arg
#define __REGD5(arg) register __d5 arg
#define __REGD6(arg) register __d6 arg
#define __REGD7(arg) register __d7 arg

#define __REGA0(arg) register __a0 arg
#define __REGA1(arg) register __a1 arg
#define __REGA2(arg) register __a2 arg
#define __REGA3(arg) register __a3 arg
#define __REGA4(arg) register __a4 arg
#define __REGA5(arg) register __a5 arg
#define __REGA6(arg) register __a6 arg
#define __REGA7(arg) register __a7 arg

#else
#define __LIBBASE(arg) arg

#define __REGD0(arg) arg
#define __REGD1(arg) arg
#define __REGD2(arg) arg
#define __REGD3(arg) arg
#define __REGD4(arg) arg
#define __REGD5(arg) arg
#define __REGD6(arg) arg
#define __REGD7(arg) arg

#define __REGA0(arg) arg
#define __REGA1(arg) arg
#define __REGA2(arg) arg
#define __REGA3(arg) arg
#define __REGA4(arg) arg
#define __REGA5(arg) arg
#define __REGA6(arg) arg
#define __REGA7(arg) arg

#endif
#endif  /* __STORM__ */


#ifdef  __GNUC__
#ifdef mc68000

#define __LIBBASE(arg) arg __asm("a6")

#define __REGD0(arg) arg __asm("d0")
#define __REGD1(arg) arg __asm("d1")
#define __REGD2(arg) arg __asm("d2")
#define __REGD3(arg) arg __asm("d3")
#define __REGD4(arg) arg __asm("d4")
#define __REGD5(arg) arg __asm("d5")
#define __REGD6(arg) arg __asm("d6")
#define __REGD7(arg) arg __asm("d7")

#define __REGA0(arg) arg __asm("a0")
#define __REGA1(arg) arg __asm("a1")
#define __REGA2(arg) arg __asm("a2")
#define __REGA3(arg) arg __asm("a3")
#define __REGA4(arg) arg __asm("a4")
#define __REGA5(arg) arg __asm("a5")
#define __REGA6(arg) arg __asm("a6")
#define __REGA7(arg) arg __asm("a7")

#else

#define __LIBBASE(arg) arg

#define __REGD0(arg) arg
#define __REGD1(arg) arg
#define __REGD2(arg) arg
#define __REGD3(arg) arg
#define __REGD4(arg) arg
#define __REGD5(arg) arg
#define __REGD6(arg) arg
#define __REGD7(arg) arg

#define __REGA0(arg) arg
#define __REGA1(arg) arg
#define __REGA2(arg) arg
#define __REGA3(arg) arg
#define __REGA4(arg) arg
#define __REGA5(arg) arg
#define __REGA6(arg) arg
#define __REGA7(arg) arg

#endif
#endif  /* __GNUC__ */

#endif  /* EXEC_CONFIG_H */

