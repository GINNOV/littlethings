
/*
 *	Function	MatForSub
 *	Programmer	N.d'Alterio
 *	Date		28/11/94
 *
 *  Synopsis:	This function performs forward substitution on a lower triangular
 *		matrix to get the vector for which the matrix equation holds.
 *		If there is an error then this function returns a non zero
 *		integer.
 *
 *  Arguments:	MATRIX *low	-	triangular matrix to be solved
 *		MATRIX *val	-	RHS of eqn column matrix
 *		MATRIX *vec	-	vector answer of eqn
 *
 *  Returns:	0		-	if successful
 *		>0		-	if error
 *
 *  Variables:	i, j		-	general loop variables
 *		lhs		- 	stores result of multipling row
 *					of matrix by column vector.
 * 
 *  Functions:	fabs		-	absolutes floating point value
 *
 *  $VER: MatForSub.c 1.4 (11.07.95) $
 *  $Log: MatForSub.c $
 * Revision 1.4  1995/07/11  12:19:53  daltern
 * code tidy up version
 *
 *
 */


#include "Matrix.h"


int MatForSub( MATRIX *low, MATRIX *val, MATRIX *vec )

{

  register int i, j;
	
  double lhs;

/*
 *  Initialise vec matrix to 0.0 
 */

  for ( i = 1; i < ( vec->Rows + 1 ); i++ ) {
	
	vec->Mat[i][1] = 0.0;

  }   /* end for i : init vec */

/*
 *  Loop from the top of the matrix down.
 */

  for ( i = 1; i < ( low->Rows + 1 ); i++ ) {

/*
 *  Calculate the LHS current row of matrix.
 */

	lhs = 0.0;

	for ( j = 1; j < ( low->Cols + 1 ); j++ ) {

		lhs = lhs + low->Mat[i][j] * vec->Mat[j][1];

	}  /* end for j */

/*
 *  Make sure don't divide by zero. Calculate the next vector element.
 */

	if ( fabs( low->Mat[i][i] ) > SMALL ) {

		vec->Mat[i][1] = ( val->Mat[i][1] - lhs ) / low->Mat[i][i];

	} else {

		return 10;

	}   /* end if */

  }   /* end for i: loop for all values of vector */

  return 0;

}   /* end function MatForSub */

/*========================================================================*
                                   END
 *========================================================================*/
