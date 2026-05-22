#ifndef _INLINE_MATHIEEEDOUBBAS_H
#define _INLINE_MATHIEEEDOUBBAS_H

#ifndef MATHIEEEDOUBBAS_BASE_NAME
#define MATHIEEEDOUBBAS_BASE_NAME MathIeeeDoubBasBase
#endif

#define IEEEDPFlt(integer) \
	((DOUBLE (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEEDOUBBAS_BASE_NAME) - 36))(integer, (struct Library *) MATHIEEEDOUBBAS_BASE_NAME)

#endif /*  _INLINE_MATHIEEEDOUBBAS_H  */
