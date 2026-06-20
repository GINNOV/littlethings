#ifndef _INLINE_MATHFFP_H
#define _INLINE_MATHFFP_H

#ifndef MATHFFP_BASE_NAME
#define MATHFFP_BASE_NAME MathBase
#endif

#define SPFix(parm) \
	((LONG (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 30))(parm, (struct Library *) MATHFFP_BASE_NAME)

#define SPFlt(integer) \
	((FLOAT (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 36))(integer, (struct Library *) MATHFFP_BASE_NAME)

#define SPCmp(leftParm, rightParm) \
	((LONG (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 42))(leftParm, rightParm, (struct Library *) MATHFFP_BASE_NAME)

#define SPTst(parm) \
	((LONG (*)(FLOAT __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 48))(parm, (struct Library *) MATHFFP_BASE_NAME)

#define SPAbs(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 54))(parm, (struct Library *) MATHFFP_BASE_NAME)

#define SPNeg(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 60))(parm, (struct Library *) MATHFFP_BASE_NAME)

#define SPAdd(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 66))(leftParm, rightParm, (struct Library *) MATHFFP_BASE_NAME)

#define SPSub(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 72))(leftParm, rightParm, (struct Library *) MATHFFP_BASE_NAME)

#define SPMul(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 78))(leftParm, rightParm, (struct Library *) MATHFFP_BASE_NAME)

#define SPDiv(leftParm, rightParm) \
	((FLOAT (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 84))(leftParm, rightParm, (struct Library *) MATHFFP_BASE_NAME)

#define SPFloor(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 90))(parm, (struct Library *) MATHFFP_BASE_NAME)

#define SPCeil(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHFFP_BASE_NAME) - 96))(parm, (struct Library *) MATHFFP_BASE_NAME)

#endif /*  _INLINE_MATHFFP_H  */
