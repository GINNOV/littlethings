
/*
 *	Function	ComSub
 *	Programmer	N.d'Alterio
 *	Date		31/10/94
 *
 *  Synopsis:	This function subtracts two complex numbers and returns the
 *  		the complex answer ( second - first ).
 *
 *  Arguments:	COMPLEX first	-	1st complex #
 * 		COMPLEX second	-	2nd complex #
 *
 *  Returns:	COMPLEX		-	the result
 *
 *  Variables:	diff		-	the complex diffence of the arguments
 *
 *  $VER: ComSub.c 1.1 (10.07.95) $
 *  $Log: ComSub.c $
 * Revision 1.1  1995/07/10  18:22:29  daltern
 * Initial revision
 *
 *
 */

#include "Complex.h"


COMPLEX ComSub( COMPLEX first, COMPLEX second )

{

  COMPLEX    diff;

/*
 *  Subtract real parts.
 */

  diff.Real = second.Real - first.Real;


/*
 *  Subtract imaginary parts.
 */

  diff.Imag = second.Imag - first.Imag;


/*
 *  Return the answer.
 */

  return diff;

}   /* end function ComSub */

/*========================================================================*
                                   END
 *========================================================================*/

