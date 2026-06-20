/*
 * File ClearF.c generated from ClearG (source file ClearG.c)
 */

#include "Clear.h"
#define FUNCTION Clear1
#define UNROLL          1
#include "ClearX.c"
#undef FUNCTION
#undef UNROLL
#undef FUNCTION_PTRS
#undef POINT_DRAW

#define FUNCTION ClearPoint1
#define POINT_DRAW
#define UNROLL          1
#include "ClearX.c"
#undef FUNCTION
#undef UNROLL
#undef FUNCTION_PTRS
#undef POINT_DRAW

