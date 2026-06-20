
/*
 *	Function	MatMul
 *	Programmer	N.d'Alterio
 *	Date		17/11/94
 *
 *  Synopsis:	This function multiplies two matrices providing that the
**		multiplication is possible. It returns NULL if there was 
**		an error.
 *
 *  Arguments:	MATRIX *mat1	-	first matrix
**		MATRIX *mat2	-	second matrix
 *
 *  Returns:	MATRIX *	-	product mat1 * mat2
**		NULL		-	if error occured
 *
 *  Variables:	i, j, k		-	general loop variables
**		resMat		-	temp store for product
 * 
 *  Functions:	MatAlloc	-	allocates a matrix
 *
 *  $VER: MatMul.c 1.3 (10.07.95) $
 *  $Log: MatMul.c $
 * Revision 1.4  1995/07/11  13:14:58  daltern
 * typo in last rev
 *
 * Revision 1.3  1995/07/10  22:57:32  daltern
 * fixed bug in multiplication of diagonals
 *
 *
 */


#include "Matrix.h"


MATRIX *MatMul( MATRIX *mat1, MATRIX *mat2 )

 {

  MATRIX *resMat = NULL;

  int i, j, k;

/*
 *  Test if multiplication possible.
 */

  if ( mat1->Cols != mat2->Rows ) {

 	return NULL;

  }   /* end if */


/*
 *  Allocate matrix of correct size.
 */

  if ( ( resMat = MatAlloc( mat1->Rows, mat2->Cols ) ) == NULL ) {

	return NULL;

  }   /* end if */

/*========================================================================*
                            CALCULATE PRODUCT
 *========================================================================*/

/*
 *  Loop for each element of product matrix.
 */

  for ( i = 1; i < ( resMat->Rows + 1 ); i++ ) {
	for ( j = 1; j < ( resMat->Cols + 1 ); j++ ) {

/*
 *  Loop for each column in mat1.
 */

/*
 *  Make sure each result matrix is initialised to 0.
 */

		resMat->Mat[i][j] = 0.0;

		for ( k = 1; k < ( mat1->Cols + 1 ); k++ ) {

			resMat->Mat[i][j] = resMat->Mat[i][j] +
					    mat1->Mat[i][k] * mat2->Mat[k][j];

		}   /* end for k: loop for mat1.Cols */

	}   /* end for j */

  }   /* end for i: loop over product matrix */

/*========================================================================*
                             RETURN PRODUCT
 *========================================================================*/

  return resMat;

}   /* end function MatMul */


/*========================================================================*
                                   END
 *========================================================================*/
