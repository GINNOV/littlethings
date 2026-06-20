#ifndef _INLINE_CIA_H
#define _INLINE_CIA_H

#ifndef CIA_BASE_NAME
#define CIA_BASE_NAME CIABase
#endif

#define AddICRVector(iCRBit, interrupt) \
	((struct Interrupt * (*)(LONG __asm("d0"), struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CIA_BASE_NAME) - 6))(iCRBit, interrupt, (struct Library *) CIA_BASE_NAME)

#define RemICRVector(iCRBit, interrupt) \
	((VOID (*)(LONG __asm("d0"), struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CIA_BASE_NAME) - 12))(iCRBit, interrupt, (struct Library *) CIA_BASE_NAME)

#define AbleICR(mask) \
	((WORD (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CIA_BASE_NAME) - 18))(mask, (struct Library *) CIA_BASE_NAME)

#define SetICR(mask) \
	((WORD (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CIA_BASE_NAME) - 24))(mask, (struct Library *) CIA_BASE_NAME)

#endif /*  _INLINE_CIA_H  */
