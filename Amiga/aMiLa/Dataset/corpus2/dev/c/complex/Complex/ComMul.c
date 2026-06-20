
/*
 *	Function	ComMul
 *	Programmer	N.d'Alterio
 *	Date		31/10/94
 *
 *  Synopsis:	This function multiplies two complex numbers and returns the
 *  		answer as a complex number.
 *
 *  Arguments:	COMPLEX first	-	1st complex #
 *		COMPLEX second	-	2nd complex #
 *
 *  Returns:	COMPLEX		-	the product
 *
 *  Variables:	product		-	the product of the args
 *      	first		-	first complex argument
 *      	second		-	second complex argument
 * 
 *  $VER: ComMul.c 1.1 (10.07.95) $
 *  $Log: ComMul.c $
 * Revision 1.1  1995/07/10  18:17:20  daltern
 * Initial revision
 *
 *
 */


#include "Complex.h"


COMPLEX ComMul( COMPLEX first, COMPLEX second )

 {

  COMPLEX    product;


/*
 *  Do the real part.
 */

  product.Real = ( first.Real * second.Real ) - ( first.Imag * second.Imag );


/*
 *  Do the imaginary part.
 */

  product.Imag = ( first.Real * second.Imag ) + ( first.Imag * second.Real );


/*
 *  Now return the result.
 */

  return product;

}   /* end function ComMul */

/*========================================================================*
                                   END
 *========================================================================*/















