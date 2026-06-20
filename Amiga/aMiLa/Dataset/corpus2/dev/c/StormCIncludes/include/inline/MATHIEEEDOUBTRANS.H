#ifndef _INLINE_MATHIEEEDOUBTRANS_H
#define _INLINE_MATHIEEEDOUBTRANS_H

#ifndef MATHIEEEDOUBTRANS_BASE_NAME
#define MATHIEEEDOUBTRANS_BASE_NAME MathIeeeDoubTransBase
#endif

#define IEEEDPFieee(single) \
	((DOUBLE (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEEDOUBTRANS_BASE_NAME) - 108))(single, (struct Library *) MATHIEEEDOUBTRANS_BASE_NAME)

#endif /*  _INLINE_MATHIEEEDOUBTRANS_H  */
