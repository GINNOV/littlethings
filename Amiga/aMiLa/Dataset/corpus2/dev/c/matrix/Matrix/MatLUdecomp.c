
/*
 *	Function	MatLUdecomp
 *	Programmer	N.d'Alterio
 *	Date		25/11/94
 *
 *  Synopsis:	This function takes a matrix and performs LU decomposition
 *		on it with partial pivotting. It produces two new matrices
 *		containing the upper and lower triagular decompostions.
 *		If the matrix can not be decomposed the function will return
 *		a non-zero number.
 *
 *  Arguments:	MATRIX *mat	-	the matrix to be decomposed
 *		MATRIX *low	-	matrix to contain lower triangular part
 *		MATRIX *up	-	matrix to contain upper triangular part
 *
 *  Returns:	0		-	if no errors
 *		>0		-	if error
 *
 *  Variables:	i, j, k		-	general loop variables
 *		Lij		-	lower tri matrix value
 *		idx		-	index of matrix element
 *		temp		-	temporary matrix
 * 
 *  Functions:	MatPPivot	-	performs partial pivotting around a 
 *					matrix value
 *		malloc		-	memory allocation
 *
 *  $VER: MatLUdecomp.c 1.5 (11.07.95) $
 *  $Log: MatLUdecomp.c $
 * Revision 1.5  1995/07/11  12:40:12  daltern
 * code tidy up
 *
 *
 */

#include "Matrix.h"

int MatLUdecomp( MATRIX *mat, MATRIX *low, MATRIX *up, MATRIX *val )

{

  register int i, j, k;

  double Lij;

  INDEX *idx;

  idx  = ( INDEX * ) malloc( sizeof( INDEX ) );

/*========================================================================*
                          DECOMPOSE MATRIX
 *========================================================================*/

/*
 *  Check matrix is square.
 */

  if ( mat->Rows != mat->Cols ) {

	return NULL;
	
  }   /* end if */


/*
 *  Copy mat to up and low.
 */

  for ( i = 1; i < ( mat->Rows + 1 ); i++ ) {
	for ( j = 1; j < ( mat->Cols + 1 ); j++ ) {

		up->Mat[i][j]  = mat->Mat[i][j];
		low->Mat[i][j] = 0.0;

	}   /* end for j */

  }   /* end for i : copy matrix */

/*
 *  Loop for each diagonal element except the last.
 */

  for ( i = 1; i < mat->Rows; i++ ) {

/*
 *  Pivot for each new diagonal element checking if LUdecomp is possible.
 */

	idx->R = idx->C = i;

	if ( MatPPivot( up, low, val, idx ) > 0 ) {

		return 10;

	}   /* end if : check decomposition is possible */

/*
 *  Loop for each row making the element in the column zero.
 */

	for ( k = 1; k < ( up->Rows - i + 1 ); k++ ) {

		Lij = up->Mat[i+k][i] / up->Mat[i][i];

/*
 *  Lij is the lower matrix element i+1,i so put it in appropriate position.
 *  It is also the value by which each element of the first row is multiplied
 *  by before being subtracted from the second row.
 */

		low->Mat[i+k][i] = Lij;

/*
 *  Multiply each element of top row by Lij and subtract from 2nd row.
 */

		for ( j = 1; j < ( up->Cols + 1 ); j++ ) {

			up->Mat[i+k][j] = up->Mat[i+k][j] - ( Lij * up->Mat[i][j] ); 

		}   /* end for j : loop over cols */

	}   /* end for k : loop over rows */

  }  /* end for i : loop over rows for each diagonal element */

/*
 *  Make diag of low 1.0.
 */

  for ( i = 1; i < ( mat->Rows + 1 ); i++ ) {

	low->Mat[i][i] = 1.0;

  }   /* end for i */

  return 0;

}   /* end function MatLUdecomp */

/*========================================================================*
                                   END
 *========================================================================*/










