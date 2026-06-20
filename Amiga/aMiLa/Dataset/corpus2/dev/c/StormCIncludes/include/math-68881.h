/******************************************************************\
*								   *
*  <math-68881.h>		last modified: 18 May 1989.	   *
*								   *
*  Copyright (C) 1989 by Matthew Self.				   *
*  You may freely distribute verbatim copies of this software	   *
*  provided that this copyright notice is retained in all copies.  *
*  You may distribute modifications to this software under the     *
*  conditions above if you also clearly note such modifications    *
*  with their author and date.			   	     	   *
*								   *
*  Note:  errno is not set to EDOM when domain errors occur for    *
*  most of these functions.  Rather, it is assumed that the	   *
*  68881's OPERR exception will be enabled and handled		   *
*  appropriately by the	operating system.  Similarly, overflow	   *
*  and underflow do not set errno to ERANGE.			   *
*								   *
*  Send bugs to Matthew Self (self@bayes.arc.nasa.gov).		   *
*								   *
\******************************************************************/

/* Dec 1991  - mw - added support for -traditional mode */

#include <errno.h>

#if defined(__STDC__) || defined(__cplusplus)
#define _DEFUN(name, args1, args2) name ( args2 )
#define _AND ,
#define _CONST const
#else
#define _DEFUN(name, args1, args2) name args1 args2;
#define _AND ;
#define _CONST
#endif

#ifndef HUGE_VAL
#define HUGE_VAL							\
({									\
  double huge_val;							\
									\
  __asm ("fmove%.d #0x7ff0000000000000,%0"	/* Infinity */		\
	 : "=f" (huge_val)						\
	 : /* no inputs */);						\
  huge_val;								\
})
#endif

__inline static _CONST double 
_DEFUN(sin, (x),
    double x)
{
  double value;

  __asm ("fsin%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(cos, (x),
    double x)
{
  double value;

  __asm ("fcos%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(tan, (x),
    double x)
{
  double value;

  __asm ("ftan%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(asin, (x),
    double x)
{
  double value;

  __asm ("fasin%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(acos, (x),
    double x)
{
  double value;

  __asm ("facos%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(atan, (x),
    double x)
{
  double value;

  __asm ("fatan%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(atan2, (y, x),
    double y _AND
    double x)
{
  double pi, pi_over_2;

  __asm ("fmovecr%.x %#0,%0"		/* extended precision pi */
	 : "=f" (pi)
	 : /* no inputs */ );
  __asm ("fscale%.b %#-1,%0"		/* no loss of accuracy */
	 : "=f" (pi_over_2)
	 : "0" (pi));
  if (x > 0)
    {
      if (y > 0)
	{
	  if (x > y)
	    return atan (y / x);
	  else
	    return pi_over_2 - atan (x / y);
	}
      else
	{
	  if (x > -y)
	    return atan (y / x);
	  else
	    return - pi_over_2 - atan (x / y);
	}
    }
  else
    {
      if (y > 0)
	{
	  if (-x > y)
	    return pi + atan (y / x);
	  else
	    return pi_over_2 - atan (x / y);
	}
      else
	{
	  if (-x > -y)
	    return - pi + atan (y / x);
	  else if (y < 0)
	    return - pi_over_2 - atan (x / y);
	  else
	    {
	      double value;
#ifdef _KERNEL
	      usetup;
#endif

	      errno = EDOM;
	      __asm ("fmove%.d %#0rnan,%0" 	/* quiet NaN */
		     : "=f" (value)
		     : /* no inputs */);
	      return value;
	    }
	}
    }
}

__inline static _CONST double 
_DEFUN(sinh, (x),
    double x)
{
  double value;

  __asm ("fsinh%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(cosh, (x),
    double x)
{
  double value;

  __asm ("fcosh%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(tanh, (x),
    double x)
{
  double value;

  __asm ("ftanh%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(atanh, (x),
    double x)
{
  double value;

  __asm ("fatanh%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(exp, (x),
    double x)
{
  double value;

  __asm ("fetox%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(expm1, (x),
    double x)
{
  double value;

  __asm ("fetoxm1%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(log, (x),
    double x)
{
  double value;

  __asm ("flogn%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(log1p, (x),
    double x)
{
  double value;

  __asm ("flognp1%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(log10, (x),
    double x)
{
  double value;

  __asm ("flog10%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(sqrt, (x),
    double x)
{
  double value;

  __asm ("fsqrt%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double
hypot (_CONST double x, _CONST double y)
{
  return sqrt (x*x + y*y);
}

__inline static _CONST double 
_DEFUN(pow, (x, y),
    _CONST double x _AND
    _CONST double y)
{
  if (x > 0)
    return exp (y * log (x));
  else if (x == 0)
    {
      if (y > 0)
	return 0.0;
      else
	{
	  double value;
#ifdef _KERNEL
	  usetup;
#endif

	  errno = EDOM;
	  __asm ("fmove%.d %#0rnan,%0"		/* quiet NaN */
		 : "=f" (value)
		 : /* no inputs */);
	  return value;
	}
    }
  else	/* x < 0 */
    {
      double temp;

      __asm ("fintrz%.x %1,%0"
	     : "=f" (temp)			/* integer-valued float */
	     : "f" (y));
      if (y == temp)
        {
	  int i = (int) y;
	  
	  if ((i & 1) == 0)			/* even */
	    return exp (y * log (-x));
	  else
	    return - exp (y * log (-x));
        }
      else
        {
	  double value;
#ifdef _KERNEL
	  usetup;
#endif

	  errno = EDOM;
	  __asm ("fmove%.d %#0rnan,%0"		/* quiet NaN */
		 : "=f" (value)
		 : /* no inputs */);
	  return value;
        }
    }
}

__inline static _CONST double 
_DEFUN(fabs, (x),
    double x)
{
  double value;

  __asm ("fabs%.x %1,%0"
	 : "=f" (value)
	 : "f" (x));
  return value;
}

__inline static _CONST double 
_DEFUN(ceil, (x),
    double x)
{
  int rounding_mode, round_up;
  double value;

  __asm __volatile ("fmove%.l fpcr,%0"
		  : "=dm" (rounding_mode)
		  : /* no inputs */ );
  round_up = rounding_mode | 0x30;
  __asm __volatile ("fmove%.l %0,fpcr"
		  : /* no outputs */
		  : "dmi" (round_up));
  __asm __volatile ("fint%.x %1,%0"
		  : "=f" (value)
		  : "f" (x));
  __asm __volatile ("fmove%.l %0,fpcr"
		  : /* no outputs */
		  : "dmi" (rounding_mode));
  return value;
}

__inline static _CONST double 
_DEFUN(floor, (x),
    double x)
{
  int rounding_mode, round_down;
  double value;

  __asm __volatile ("fmove%.l fpcr,%0"
		  : "=dm" (rounding_mode)
		  : /* no inputs */ );
  round_down = (rounding_mode & ~0x10)
		| 0x20;
  __asm __volatile ("fmove%.l %0,fpcr"
		  : /* no outputs */
		  : "dmi" (round_down));
  __asm __volatile ("fint%.x %1,%0"
		  : "=f" (value)
		  : "f" (x));
  __asm __volatile ("fmove%.l %0,fpcr"
		  : /* no outputs */
		  : "dmi" (rounding_mode));
  return value;
}

__inline static _CONST double 
_DEFUN(rint, (x),
    double x)
{
  int rounding_mode, round_nearest;
  double value;

  __asm __volatile ("fmove%.l fpcr,%0"
		  : "=dm" (rounding_mode)
		  : /* no inputs */ );
  round_nearest = rounding_mode & ~0x30;
  __asm __volatile ("fmove%.l %0,fpcr"
		  : /* no outputs */
		  : "dmi" (round_nearest));
  __asm __volatile ("fint%.x %1,%0"
		  : "=f" (value)
		  : "f" (x));
  __asm __volatile ("fmove%.l %0,fpcr"
		  : /* no outputs */
		  : "dmi" (rounding_mode));
  return value;
}

__inline static _CONST double 
_DEFUN(fmod, (x, y),
    double x _AND
    double y)
{
  double value;

  __asm ("fmod%.x %2,%0"
	 : "=f" (value)
	 : "0" (x),
	   "f" (y));
  return value;
}

__inline static _CONST double 
_DEFUN(drem, (x, y),
    double x _AND
    double y)
{
  double value;

  __asm ("frem%.x %2,%0"
	 : "=f" (value)
	 : "0" (x),
	   "f" (y));
  return value;
}

__inline static _CONST double 
_DEFUN(scalb, (x, n),
    double x _AND
    int n)
{
  double value;

  __asm ("fscale%.l %2,%0"
	 : "=f" (value)
	 : "0" (x),
	   "dmi" (n));
  return value;
}

__inline static double 
_DEFUN(logb, (x),
    double x)
{
  double exponent;

  __asm ("fgetexp%.x %1,%0"
	 : "=f" (exponent)
	 : "f" (x));
  return exponent;
}

__inline static _CONST double 
_DEFUN(ldexp, (x, n),
    double x _AND
    int n)
{
  double value;

  __asm ("fscale%.l %2,%0"
	 : "=f" (value)
	 : "0" (x),
	   "dmi" (n));
  return value;
}

__inline static double 
_DEFUN(frexp, (x, exp),
    double x _AND
    int *exp)
{
  double float_exponent;
  int int_exponent;
  double mantissa;

  __asm ("fgetexp%.x %1,%0"
	 : "=f" (float_exponent) 	/* integer-valued float */
	 : "f" (x));
  int_exponent = (int) float_exponent;
  __asm ("fgetman%.x %1,%0"
	 : "=f" (mantissa)		/* 1.0 <= mantissa < 2.0 */
	 : "f" (x));
  if (mantissa != 0)
    {
      __asm ("fscale%.b %#-1,%0"
	     : "=f" (mantissa)		/* mantissa /= 2.0 */
	     : "0" (mantissa));
      int_exponent += 1;
    }
  *exp = int_exponent;
  return mantissa;
}

__inline static double 
_DEFUN(modf, (x, ip),
    double x _AND
    double *ip)
{
  double temp;

  __asm ("fintrz%.x %1,%0"
	 : "=f" (temp)			/* integer-valued float */
	 : "f" (x));
  *ip = temp;
  return x - temp;
}

#undef _DEFUN
#undef _AND
#undef _CONST
