#ifndef _LD40_MATHS_H
#define _LD40_MATHS_H

#include <fixmath/fixmath.h>

extern fix16_t g_pSin[256];

#define cSin(x) g_pSin[x]
#define cCos(x) g_pSin[((x)+64) & 0xFF]

void mathsInit(void);

#endif // _LD40_MATHS_H
