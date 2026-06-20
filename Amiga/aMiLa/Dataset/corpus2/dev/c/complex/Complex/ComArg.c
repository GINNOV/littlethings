
/*
 *	Function	ComArg
 *	Programmer	N.d'Alterio
 *	Date		31/10/94
 *
 *  Synopsis:	This function calculates the argument of a complex number and
 *  		returns the answer. If imaginary part is zero it returns 0.
 *
 *  Arguments:	COMPLEX	first	-	a complex number	   
 *
 *  Returns:	double		-	the argument
 *		 0.0		-	if Im z  = 0.0
 *
 *  Variables:	arg		-	(double) the argument of the complex number
 *      	first		-	complex argument
 * 
 *  Functions:	atan2()		-	standard inverse of tan
 *
 *  $VER: ComArg.c 1.1 (10.07.95) $
 *  $Log: ComArg.c $
 * Revision 1.1  1995/07/10  17:57:09  daltern
 * Initial revision
 *
 *
 */


#include <math.h>

#include "Complex.h"


double ComArg( COMPLEX first )

 {

  double arg;


/*
 *  Check imaginary part != 0.
 */


  if ( first.Imag == 0 ) return 0.0;


/*
 *  Calculate the argument.
 */


  arg = atan2( first.Real, first.Imag );


/*
 *  Return the result.
 */


  return arg;

}   /* end function comarg */


/*========================================================================*
                                   END
 *========================================================================*/



