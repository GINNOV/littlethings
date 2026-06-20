#ifndef _NROOT_H
#define _NROOT_H
extern double nroot(long int,double);
#endif

/********************************************************************

  Extracts n-th root from x.

  result = nroot( n , x );

  double   result;
  long int n;
  double   x;

If n is less than 1 result is 0 and global integer errno contains value EDOM.
If n is even and x is negative, result is 0 and global integer errno 
contains value EDOM.

*********************************************************************/
