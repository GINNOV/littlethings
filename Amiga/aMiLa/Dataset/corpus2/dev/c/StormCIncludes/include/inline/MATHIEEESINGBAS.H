#ifndef _INLINE_MATHIEEESINGBAS_H
#define _INLINE_MATHIEEESINGBAS_H

#ifndef MATHIEEESINGBAS_BASE_NAME
#define MATHIEEESINGBAS_BASE_NAME MathIeeeSingBasBase
#endif

#define IEEESPFix(parm) \
	((LONG (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 30))(parm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPFlt(integer) \
	((FLOAT (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 36))(integer, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPCmp(leftParm, rightParm) \
	((LONG (*)(FLOAT __asm("d0"), FLOAT __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 42))(leftParm, rightParm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPTst(parm) \
	((LONG (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 48))(parm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPAbs(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 54))(parm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPNeg(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 60))(parm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPAdd(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d0"), FLOAT __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 66))(leftParm, rightParm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPSub(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d0"), FLOAT __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 72))(leftParm, rightParm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPMul(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d0"), FLOAT __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 78))(leftParm, rightParm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPDiv(dividend, divisor) \
	((FLOAT (*)(FLOAT __asm("d0"), FLOAT __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 84))(dividend, divisor, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPFloor(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 90))(parm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#define IEEESPCeil(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHIEEESINGBAS_BASE_NAME) - 96))(parm, (struct Library *) MATHIEEESINGBAS_BASE_NAME)

#endif /*  _INLINE_MATHIEEESINGBAS_H  */
