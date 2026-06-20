/*
**  $VER: commmacs.h 1.00 (22.08.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef _COMMMACS_H
#define _COMMMACS_H

#ifdef _FROM_MATH_H

#ifndef max
#define   max(a,b)    ((a) > (b) ? (a) : (b))
#endif

#ifndef min
#define   min(a,b)    ((a) <= (b) ? (a) : (b))
#endif

#undef _FROM_MATH_H
#endif /* _FROM_MATH_H */


#ifdef _FROM_STDLIB_H
#ifndef abs
#define abs(i)   ((i) < 0 ? -(i) : (i))
#endif

#ifndef labs
#define labs(i)  ((i) < 0 ? -(i) : (i))
#endif

#undef _FROM_STDLIB_H
#endif /* _FROM_STDLIB_H */


#endif /* _COMMMACS_H */
