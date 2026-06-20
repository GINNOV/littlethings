
/*
 *	Function	MatInv
 *	Programmer	N.d'Alterio
 *	Date		28/11/94
 *
 *  Synopsis:	This function calculates the inverse of a matrix by the
 *		use of LU decompositions and the rule that a matrix *
 *		its inverse = identity matrix.
 *
 *  Arguments:	MATRIX *mat	-	the matrix to be inverted
 *
 *  Returns:	MATRIX *	-	inverse of matrix
 *		NULL		-	if there was an error
 *
 *  Variables:	up		-	upper tri matrix
 *		low		-	lower tri matrix
 *		inv		-	inverse matrix
 *		ident_col	-	current col in ident matrix
 *		col_vec		-	current column vector
 *		i, j		-	general loop variables
 * 
 *  Functions:	MatSimul	-	solve simultaneous eqns
 *		MatLUdecomp	-	LU decompose matrix
 *		MatAlloc	-	allocate matrix
 *		MatFree		-	free matrix
 *
 *  $VER: MatInv.c 1.7 (11.07.95) $
 *  $Log: MatInv.c $
 * Revision 1.8  1995/09/04  01:09:10  daltern
 * BUGFIX: During pivotting the row order was not maintained for
 * the identity matrix being used to solve the simulataneous eqns
 * so column order of inverse wrong
 *
 * Revision 1.7  1995/07/11  12:33:10  daltern
 * code tidy up
 *
 *
 */


#include "Matrix.h"

MATRIX *MatInv( MATRIX *mat )

{

  MATRIX *up;
  MATRIX *low;
  MATRIX *inv;
  MATRIX *col_vec;
  MATRIX *ident_col;

  register int i, j;

/*========================================================================*
                          ALLOCATE MATRICES
 *========================================================================*/


  if ( ( up = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return NULL;

  }   /* end if */

  if ( ( low = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return NULL;

  }   /* end if */

  if ( ( inv = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return NULL;

  }   /* end if */

  if ( ( ident_col = MatAlloc( mat->Rows, 1 ) ) == NULL ) {

	return NULL;

  }   /* end if */

/*========================================================================*
                              LU DECOMPOSE
 *========================================================================*/

/*
 *   inv is currently the identity matrix, it is passed to
 *   LUdecomp so that on pivotting the row order is maintained
 */

  if ( MatLUdecomp( mat, low, up, inv ) > 0 ) {

	return NULL;

  }   /* end if */

/*========================================================================*
                           BUILD UP INVERSE
 *========================================================================*/


/*
 *  Build up inverse one column at a time by solving for each column of
 *  the identity matrix at a time.
 */

/*
 *  Loop for all columns. Copy each to ident_col from inv.
 */

  for ( i = 1; i < ( mat->Cols + 1 ); i++ ) {

/*
 *  Create appropriate column from identity matrix.
 */

	for ( j = 1; j < ( mat->Rows + 1 ); j++ ) {

		ident_col->Mat[j][1] = inv->Mat[j][i];

	}   /* end for j : create ident col */

/*
 *  Solve current eqn.
 */

	if ( ( col_vec = MatSimul( up, low, ident_col ) ) == NULL ) {

		return NULL;

	}   /* end if */

/*
 *  Copy solution to current column.
 */

	for ( j = 1; j < ( mat->Rows + 1 ); j++ ) {

		inv->Mat[j][i] = col_vec->Mat[j][1];
	
	}   /* end for : copy result */

	MatFree( col_vec );

  }   /* end for i : loop over cols */

/*========================================================================*
                         FREE MEMORY AND RETURN
 *========================================================================*/


  MatFree( ident_col );

  return inv;

}   /* end function */

/*========================================================================*
                                   END
 *========================================================================*/
