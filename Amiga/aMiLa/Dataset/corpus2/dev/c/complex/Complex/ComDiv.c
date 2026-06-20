
/*
 *	Function	ComDiv
 *	Programmer	N.d'Alterio
 *	Date		31/10/94
 *
 *  Synopsis:	This function divides two complex numbers and returns the complex
 *  		answer ( second/first ).
 *
 *  Arguments:	COMPLEX first	-	complex denominator
 *		COMPLEX second	-	complex numerator
 *
 *  Returns:	COMPLEX		-	result of division
 *		(0.0,0.0i)	-	if denom = 0
 *
 *  Variables:	div		-	the complex result of the division
 *          	first		-	complex numerator
 *          	second		-	complex denominator
 *          	denom		-	the denominator for the division
 *
 * 
 *  Functions:	ComMul		-	product of 2 complex #'s
 *
 *  $VER: ComDiv.c 1.1 (10.07.95) $
 *  $Log: ComDiv.c $
 * Revision 1.1  1995/07/10  18:07:29  daltern
 * Initial revision
 *
 *
 */

#include "Complex.h"


COMPLEX ComDiv( COMPLEX first, COMPLEX second )

{

  double     denom;

  COMPLEX    div;


/*
 *  Caculate the the numerator.
 */

  second.Imag = -second.Imag;
  div         = ComMul( first, second );


/*
 *  Calculate the denominator.
 */
 
  denom = ( second.Real * second.Real ) + ( second.Imag * second.Imag );

/* 
 *  Check to see that denom != 0
 */

  if ( denom == 0 ) {
	
	div.Real = 0.0;
	div.Imag = 0.0;
	return div;

  }   /* end if */

/*
 *  Now return the result.
 */

  div.Real = div.Real / denom;
  div.Imag = div.Imag / denom;

  return div;


}   /* end function ComDiv */

/*========================================================================*
                                   END
 *========================================================================*/


