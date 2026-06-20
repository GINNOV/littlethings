/* ========================================================================== *
 * $Id: fmtstrutil.c,v 1.3 1996/10/26 14:23:53 d93-hyo Stab d93-hyo $
 * -------------------------------------------------------------------------- *
 * Some functions for handling format strings.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */

#include <putchprocs.h>
#include <fmtstrutil.h>

#include <exec/memory.h>

#include <proto/exec.h>

/* ========================================================================== */

/****** fmtstrutil.lib/SafeSPrintf ********************************************
*
*   NAME
*       SafeSPrintf -- Safe sprintf function.
*
*   SYNOPSIS
*       buffer = SafeSPrintf (fmt, args)
*       D0                    A0   A1
*
*       STRPTR SafeSPrintf (STRPTR, APTR);
*
*   FUNCTION
*       Creates a string buffer big enough to fit the string. Then
*       exec.library/RawDoFmt() is used to fill the buffer.
*
*   INPUTS
*       fmt  - A "C"-language-like NULL terminated format string. See
*           exec.library/RawDoFmt() for more information.
*       args - Data stream that gets passed to exec.library/RawDoFmt().
*
*   RESULT
*       buffer - The resulting string. If there was not enough memory
*           available for the buffer, NULL is returned.
*
*   NOTES
*       The ruturned buffer must be freed with exec.library/FreeVec().
*
*   SEE ALSO
*       NextFmtArg(), exec.library/RawDoFmt(), exec.library/FreeVec()
*
*******************************************************************************
*
*/
STRPTR __asm
SafeSPrintf (
    register __a0 STRPTR   fmt,
    register __a1 APTR     args)
{
    LONG     length = 0;
    STRPTR   buf;
    
    RawDoFmt (fmt, args, CountChar, &length);
    buf = AllocVec (length*sizeof (*buf), MEMF_ANY | MEMF_PUBLIC);
    if (buf != NULL)
    {
	RawDoFmt (fmt, args, SimplePutChar, buf);
    } /* if */
    
    return buf;
} /* SafeSPrintf */


/****** fmtstrutil.lib/NextFmtArg *********************************************
*
*   NAME
*       NextFmtArg -- Finds the first unused argument.
*
*   SYNOPSIS
*       unusedArgs = SafeSPrintf (fmt, args)
*       D0                 A0   A1
*
*       APTR SafeSPrintf (STRPTR, APTR);
*
*   FUNCTION
*       Finds the first argument in the data stream that the format string
*       would not use.
*
*   INPUTS
*       fmt  - A "C"-language-like NULL terminated format string. See
*           exec.library/RawDoFmt() for more information.
*       args - Data stream that gets passed to exec.library/RawDoFmt().
*
*   RESULT
*       unusedArgs - Argument array starting with the first unused argument.
*           If all arguments would be used, NULL is returned.
*
*   SEE ALSO
*       exec.library/RawDoFmt()
*
*******************************************************************************
*
*/
APTR __asm
NextFmtArg (
    register __a0 STRPTR   fmt,
    register __a1 APTR     args)
{
    return RawDoFmt (fmt, args, DummyPutChar, NULL);
} /* NextFmtArg */
