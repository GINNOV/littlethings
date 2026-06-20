#ifndef _INLINE_MATHIEEESINGTRANS_H
#define _INLINE_MATHIEEESINGTRANS_H

#ifndef MATHIEEESINGTRANS_BASE_NAME
#define MATHIEEESINGTRANS_BASE_NAME MathIeeeSingTransBase
#endif

#define IEEESPAtan(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 30))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPSin(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 36))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPCos(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 42))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPTan(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 48))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPSincos(cosptr, parm) \
	((FLOAT (*)(FLOAT * __asm("a0"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 54))(cosptr, parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPSinh(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 60))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPCosh(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 66))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPTanh(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 72))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPExp(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 78))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPLog(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 84))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPPow(exp, arg) \
	((FLOAT (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 90))(exp, arg, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPSqrt(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 96))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPTieee(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 102))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPFieee(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 108))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPAsin(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 114))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPAcos(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 120))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#define IEEESPLog10(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGTRANS_BASE_NAME) - 126))(parm, (struct Library *) MATHIEEESINGTRANS_BASE_NAME)

#endif /*  _INLINE_MATHIEEESINGTRANS_H  */
