/* ========================================================================== *
 * $Id: putchprocs.h,v 1.1 1996/10/20 21:34:41 d93-hyo Stab $
 * -------------------------------------------------------------------------- *
 * Various "PutChProc" functions for use with exec.library/RawDoFmt().
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */

#ifndef PUTCHPROCS_H
#define PUTCHPROCS_H


#include <exec/types.h>

/* ========================================================================== */

/*
 * SimplePutChar
 * -------------
 * Appends character to data string.
 */
void __asm
SimplePutChar (
    register __d0 char     ch,      /* character to append */
    register __a3 STRPTR   data);   /* data string */


/*
 * DummyPutChar
 * ------------
 * Does nothing.
 */
void __asm
DummyPutChar (
    register __d0 char     ch,      /* (not used) */
    register __a3 STRPTR   data);   /* (not used) */


/*
 * CountChar
 * ---------
 * Increases data with one.
 */
void __asm
CountChar (
    register __d0 char   ch,      /* (not used) */
    register __a3 LONG  *data);   /* pointer to length counter */


#endif /* PUTCHPROCS_H */
