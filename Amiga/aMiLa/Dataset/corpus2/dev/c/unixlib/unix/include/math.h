#ifndef _UNIX_MATH_H
#define _UNIX_MATH_H
#include "include:math.h"
#ifndef _STRICT_ANSI
double	copysign __ARGS((double, double));
int	finite __ARGS((double));
double	hypot __ARGS((double, double));
double	logb __ARGS((double));
double	scalb __ARGS((double, int));
#endif
#endif
