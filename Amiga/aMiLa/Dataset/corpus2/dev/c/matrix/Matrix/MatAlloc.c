
/*
 *	Function	MatAlloc
 *	Programmer	N.d'Alterio
 *	Date		17/11/94
 *
 *  Synopsis:	This function allocates memory for a matrix of size rows * cols.
 *		The matrix is initialised to the identity matrix.
 *
 *  Arguments:	rows		-	number of rows in matrix
 *		cols		-	number of cols in matrix
 *
 *  Returns:	MATRIX *	-	pointer to an allocated a matrix structure
 *		NULL		-	if there was an error
 *
 *  Variables:	mat		-	pointer to a matrix structure
 *		i, j		-	general loop variables
 * 
 *  Functions:	malloc		-	memory allocation
 *
 *  $VER: Prog:Work/matrix/MatAlloc.c 1.1 (10.07.95) $
 *  $Log: MatAlloc.c $
 * Revision 1.1  1995/07/10  22:10:01  daltern
 * Initial revision
 *
 *
 */


#include "Matrix.h"


MATRIX *MatAlloc( int rows, int cols )

 {

  int i, j;

  MATRIX *mat;

/*
 *	Allocate matrix.
 */

  if ( ( mat = ( MATRIX * ) malloc( sizeof( MATRIX ) ) ) == NULL ) {

	return NULL;

  }   /* end if */

/*
**	Allocate mem for matrix elements.
*/

  if ( ( mat->Mat = ( double ** ) malloc( ( rows + 1 ) * sizeof( double * ) ) ) == NULL ) {

	free( mat );
	return NULL;

  } else {

	for ( i = 0; i < ( rows + 1 ); i++ ) {

		if ( ( mat->Mat[i] = ( double * ) malloc( ( cols + 1 ) * sizeof( double ) ) ) == NULL ) {

			for ( j = (i-1); j > 0; j-- ) {

				free( mat->Mat[j] );

			}   /* end for j : return elements allocated */
	
			free( mat->Mat );
			free( mat );

			return NULL;

		}   /* end if */

	}   /* end for */

  }   /* end if */

/*
 *	Initialise matrix to identity matrix.
 */

  mat->Rows = rows;
  mat->Cols = cols;

  for ( i = 0; i < ( rows + 1 ); i++ ) {
	for ( j = 0; j < ( cols + 1 ); j++ ) {

		if ( i == j ) {

			mat->Mat[i][j] = 1.0;

		} else {

			mat->Mat[i][j] = 0.0;
	
		}   /* end if */

	}   /* end for j */

  }   /* end for i : init mat->Mat to 0 */

  return mat;

}   /* end function MatAlloc */

/*========================================================================*
                                   END
 *========================================================================*/
	