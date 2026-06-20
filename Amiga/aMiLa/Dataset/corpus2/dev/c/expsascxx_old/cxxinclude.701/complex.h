/*-------------------------------------------------------------------*/
/* Copyright (c) 1993-1994        by SAS Institute Inc., Cary NC     */
/*                                                                   */
/* NAME:       complex.h                                             */
/* AUTHOR:     Gavin Koch - IBM 370 C Compiler department            */
/* DATE:                                                             */
/* SUPPORT:    sasgak - IBM 370 C Compiler department                */
/* PRODUCT:    C++ Library                                           */
/* LANGUAGE:   C++                                                   */
/* MACHINE:    all                                                   */
/* PURPOSE:                                                          */
/*                                                                   */
/* HISTORY:    action                                   date   name  */
/*             spilt iobase.h out of iostream.h       96/03/27  gak  */
/*             Added __alignmem to each class def.    94/03/16  led  */
/*             Added #ifndef's around each #include   93/07/02  hlc  */
/*             Added this description header.         93/03/18  gww  */
/*             Changed __alignmem to #define          94/10/04  gak  */
/* NOTES:                                                            */
/* ALGORITHM:                                                        */
/* END                                                               */
/*-------------------------------------------------------------------*/
#ifndef __COMPLEX_H
#define __COMPLEX_H

#ifndef __I370__

#ifndef _MATH_H
#include <math.h>
#endif

#else

#ifndef __IncLMath
#include <lcmath.h>
#endif

#endif

/* All include's for this file must happen before here. */

#ifdef __I370__
#define __SASCXXLIB_CLASS_DEF_KEYS __alignmem
#else
#define __SASCXXLIB_CLASS_DEF_KEYS 
#endif 

__SASCXXLIB_CLASS_DEF_KEYS class complex {
public:
   // constructors
   complex(){}
   complex(double r, double i = 0.0)  { re = r; im = i; }

   // complex operators
   friend complex operator+ (complex a, complex b)
                            {return complex(a.re+b.re,a.im+b.im);}
   friend complex operator- (complex a)
                            {return complex(-a.re,-a.im);}
   friend complex operator- (complex a, complex b)
                            {return complex(a.re-b.re,a.im-b.im);}
   friend complex operator* (complex a, complex b)
                            {return complex(a.re*b.re-a.im*b.im,
                                            a.re*b.im+a.im*b.re);}
   friend complex operator/ (complex a, complex b);
   friend complex operator/ (complex a, double d)
                            {return complex(a.re/d,a.im/d);}

   friend int     operator==(complex a, complex b)
                            {return a.re==b.re && a.im==b.im;}
   friend int     operator!=(complex a, complex b)
                            {return a.re!=b.re || a.im!=b.im;}

          void    operator+=(complex a) {re += a.re; im += a.im;}
          void    operator-=(complex a) {re -= a.re; im -= a.im;}
          void    operator*=(complex a)
                            {double re_temp;
                             re_temp = re*a.re - im*a.im;
                             im = re*a.im + im*a.re;
                             re = re_temp;}
          void    operator/=(complex a) {(*this) = (*this) / a;}
          void    operator/=(double d) {re /= d; im /= d;}

   // cartesian and polar coordinate functions
   friend double  abs   (complex a);
   friend double  arg   (complex a) {return atan2(a.im,a.re);}
   friend complex conj  (complex a) {return complex(a.re,-a.im);}
   friend double  imag  (complex a) {return a.im;}
   friend double  norm  (complex a) {return a.re*a.re+a.im*a.im;}
   friend complex polar (double r, double t = 0.0)
                        {return complex(r*cos(t),r*sin(t));}
   friend double  real  (complex a) {return a.re;}

   // exponential, logarithmic, power, and square root functions
   friend complex exp  (complex a);
   friend complex log  (complex a);
   friend complex pow  (double d, complex a);
   friend complex pow  (complex a, int i);
   friend complex pow  (complex a, double d);
   friend complex pow  (complex x, complex y);
   friend complex sqrt (complex a);

   // trignometric and hyperbolic functions
   friend complex sin  (complex a);
   friend complex cos  (complex a);
   friend complex sinh (complex a);
   friend complex cosh (complex a);

private:
   double re, im;
   int unbalanced();
   complex sinhcosh(int sincos);
   complex powzero();
};

// I/O functions
class ostream;
class istream;
ostream& operator<<(ostream&, complex);
istream& operator>>(istream&, complex&);

#undef __SASCXXLIB_CLASS_DEF_KEYS

#endif /* __COMPLEX_H */



