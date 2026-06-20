
/*
 *	Function	ComMod
 *	Programmer	N.d'Alterio
 *	Date		
 *
 *  Synopsis:	This function calculate the modulus of a complex number and
 *  		returns the result.
 *
 *  Arguments:	COMPLEX first	-	complex number
 *
 *  Returns:	double		-	the modulus
 *
 *  Variables:	pow()		-	standard power function
 *          	sqrt()		-	standard square root function
 * 
 *  Functions:
 *
 *  $VER: ComMod.c 1.1 (10.07.95) $
 *  $Log: ComMod.c $
 * Revision 1.1  1995/07/10  18:12:04  daltern
 * Initial revision
 *
 *
 */

#include <math.h>

#include "Complex.h"


double ComMod( COMPLEX first )

{

  double  mod;


/*
 *  Calculate the modulus.
 */


  mod = sqrt( pow( first.Real, 2.0 ) + pow( first.Imag, 2.0 ) );


/*
 *  Return the answer.
 */


  return mod;


}   /* end function ComMod */

/*========================================================================*
                                   END
 *========================================================================*/



