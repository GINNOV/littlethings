/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2005
 *
 * $Id: math.h,v 1.2 2021/12/18 12:30:54 phx Exp $
 */

#ifndef _MATH_H_
#define _MATH_H_

#include_next <math.h>

#if !defined(_ANSI_SOURCE) && !defined(_POSIX_C_SOURCE)
#ifndef hypot
double hypot(double,double);
#endif
#endif

#endif /* _MATH_H_ */
