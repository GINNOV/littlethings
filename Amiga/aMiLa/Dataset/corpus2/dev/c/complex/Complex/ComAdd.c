
/*
 *	Function	ComAdd
 *	Programmer	N.d'Alterio
 *	Date		31/10/94
 *
 *  Synopsis: This function adds together two complex numbers and returns the
 *            the complex answer.
 *
 *  Arguments:  COMPLEX	first		-	1st complex #
 *		COMPLEX	second		-	2nd complex #
 *
 *  Returns:	COMPLEX sum		-	result of addition
 *
 *  Variables:	sum         		-       the complex sum of the arguments
 *     		first       		-       first complex arg
 *      	second      		-       second complex arg 
 *
 *  $VER: ComAdd.c 1.2 (10.07.95) $
 *  $Log: Comadd.c $
 * Revision 1.2  1995/07/10  17:28:16  daltern
 * function to add 2 complex numbers.
 *
 * Revision 1.1  1995/07/10  17:09:18  daltern
 * Initial revision
 *
 *
 */


#include "Complex.h"


COMPLEX ComAdd( COMPLEX first, COMPLEX second )

{

  COMPLEX    sum;


/*
 *  Add real parts.
 */

  sum.Real = first.Real + second.Real;


/*
 *  Add imaginary parts.
 */

  sum.Imag = first.Imag + second.Imag;


/*
 *  Return the answer.
 */

  return sum;

}   /* end function */

/*========================================================================*
                                   END
 *========================================================================*/


