
/*
 *	Function	VecMod
 *	Programmer	N.d'Alterio
 *	Date		06/12/94
 *
 *  Synopsis:	This function calculates the modulus of a vector.
 *
 *  Arguments:	MATRIX *	-	vector to calc mod of
 *
 *  Returns:	double		-	modulus of vector
 *		-1		-	if error
 *
 *  Variables:	temp		-	temp variable
 * 
 *  Functions:	VecDot		-	dot product of 2 vectors
 *		sqrt		-	square root
 *
 *  $VER: VecMod.c 1.1 (11.07.95) $
 *  $Log: VecMod.c $
 * Revision 1.1  1995/07/11  12:47:48  daltern
 * Initial revision
 *
 *
 */

#include <math.h>
#include <float.h>

#include "Matrix.h"


double VecMod( MATRIX *vec )

{

  double temp;

/*
 *  Calculate mod**2 and check for error.
 */

  if ( ( temp = VecDot( vec, vec ) ) == DBL_MAX ) {

	return -1;

  }   /* end if */

  return sqrt( temp );

}   /* end function VecMod */

/*========================================================================*
                                   END
 *========================================================================*/





