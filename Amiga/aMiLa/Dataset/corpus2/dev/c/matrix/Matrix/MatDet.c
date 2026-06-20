
/*
 *	Function	MatDet
 *	Programmer	N.d'Alterio
 *	Date		28/11/94
 *
 *  Synopsis:	This function calculates the determinant of a matrix by
 *		the use of LU decomposition.
 *
 *  Arguments:	MATRIX *mat	-	matrix to calculate determinant of
 *
 *  Returns:	double		-	determinant of matrix
 *		0.0		-	if error
 *
 *  Variables:	low		-	lower tri matrix
 *		up		-	upper tri matrix
 *		up_diag		-	product of upper tri matrix diag
 *		i		-	general loop variable
 * 
 *  Functions:	MatLUdecomp	-	calculates the LU decomposition
 *		MatAlloc	-	allocates a matrix
 *		MatFree		-	frees a matrix
 *
 *  $VER: MatDet.c 1.4 (11.07.95) $
 *  $Log: MatDet.c $
 * Revision 1.5  1995/09/04  00:31:36  daltern
 * BUGFIX args for calling MatLUdecomp wrong order so always
 * gave answer of 1 or 0. STUPID
 *
 * Revision 1.4  1995/07/11  00:26:14  daltern
 * Fixed some major bugs - products alway multiplied by 0 !
 *                       - no check to see if matrix square
 *                       - was doing product of product of upper and lower
 *
 *
 */


#include "Matrix.h"


double MatDet( MATRIX *mat )

 {

  register int i;

  MATRIX *low;
  MATRIX *up;
  MATRIX *val;

  double up_diag;

/*
 *  Check to see if matrix is square otherwise this method will
 *  not work.
 */

  if ( mat->Rows != mat->Cols ) return 0.0;

/*========================================================================*
                          ALLOCATE MEMORY
 *========================================================================*/

  if ( ( low = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return 0.0;

  }   /* end if */

  if ( ( up = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return 0.0;

  }   /* end if */

/*
 *  This is only needed because the LU decomp routine has it as 
 *  an argument.
 */

  if ( ( val = MatAlloc( mat->Rows, 1 ) ) == NULL ) {

	return 0.0;

  }   /* end if */


/*========================================================================*
                       LU DECOMPOSE AND CALCULATE
 *========================================================================*/

  if ( MatLUdecomp( mat, low, up, val ) > 0 ) {

	return 0.0;

  }   /* end if */

  MatFree( val );
  MatFree( low );
	
/*
 *  Calculate the product of the diagonal of the upper triangular
 *  matrix this is the determinant.
 */


  up_diag = up->Mat[1][1];
  for ( i = 2; i < ( mat->Rows + 1 ); i++ ) {

	up_diag = up_diag * up->Mat[i][i];

  }   /* end for i */


/*========================================================================*
                       FREE MATRICES AND RETURN
 *========================================================================*/

  MatFree( up );


  return up_diag;
  
}   /* end function MatDet */

/*========================================================================*
                                   END
 *========================================================================*/
