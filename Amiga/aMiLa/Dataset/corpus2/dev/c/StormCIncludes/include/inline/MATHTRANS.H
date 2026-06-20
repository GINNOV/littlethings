#ifndef _INLINE_MATHTRANS_H
#define _INLINE_MATHTRANS_H

#ifndef MATHTRANS_BASE_NAME
#define MATHTRANS_BASE_NAME MathTransBase
#endif

#define SPAtan(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 30))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPSin(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 36))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPCos(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 42))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPTan(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 48))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPSincos(cosResult, parm) \
	((FLOAT (*)(FLOAT * __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 54))(cosResult, parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPSinh(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 60))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPCosh(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 66))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPTanh(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 72))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPExp(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 78))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPLog(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 84))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPPow(power, arg) \
	((FLOAT (*)(FLOAT __asm("d1"), FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 90))(power, arg, (struct Library *) MATHTRANS_BASE_NAME)

#define SPSqrt(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 96))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPTieee(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 102))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPFieee(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 108))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPAsin(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 114))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPAcos(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 120))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#define SPLog10(parm) \
	((FLOAT (*)(FLOAT __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MATHTRANS_BASE_NAME) - 126))(parm, (struct Library *) MATHTRANS_BASE_NAME)

#endif /*  _INLINE_MATHTRANS_H  */
