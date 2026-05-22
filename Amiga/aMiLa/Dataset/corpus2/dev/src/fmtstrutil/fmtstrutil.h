/* ========================================================================== *
 * $Id: fmtstrutil.h,v 1.3 1996/10/26 14:25:29 d93-hyo Stab $
 * -------------------------------------------------------------------------- *
 * Some functions for handling format strings.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */

#ifndef FMTSTRUTIL_H
#define FMTSTRUTIL_H


#include <exec/types.h>

/* ========================================================================== */

extern STRPTR __asm
SafeSPrintf (
    register __a0 STRPTR   fmt,
    register __a1 APTR     args);


extern APTR __asm
NextFmtArg (
    register __a0 STRPTR   fmt,
    register __a1 APTR     args);


#endif /* FMTSTRUTIL_H */
