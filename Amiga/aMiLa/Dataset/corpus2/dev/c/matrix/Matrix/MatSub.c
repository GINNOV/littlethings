
/*
 *	Function	MatSub
 *	Programmer	N.d'Alterio
 *	Date		17/11/94
 *
 *  Synopsis:	This function subtracts two matrices from each other if 
 *		that subtraction is possible.
 *
 *  Arguments:	MATRIX *mat1	-	first matrix
 *		MATRIX *mat2	-	second matrix
 *
 *  Returns:	MATRIX *	-	mat1 - mat2
 *		NULL		-	if error
 *
 *  Variables:	i, j		-	general loop variables
 *		resMat		-	temp store for result
 * 
 *  Functions:	MatAlloc	-	allocate matrix
 *
 *  $VER: MatSub.c 1.1 (10.07.95) $
 *  $Log: MatSub.c $
 * Revision 1.2  1995/07/11  13:15:28  daltern
 * rename several variables
 *
 * Revision 1.1  1995/07/10  23:06:01  daltern
 * Initial revision
 *
 *
 */

#include "Matrix.h"


MATRIX *MatSub( MATRIX *mat1, MATRIX *mat2 )

  {

  MATRIX	*resMat = NULL;

  int i, j;

/*
 *	First check that the subtraction is possible.
 */

  if ( ( mat1->Rows != mat2->Rows ) || ( mat1->Cols != mat2->Cols ) ) {

	return NULL;

  }   /* end if */

/*
 *	Now allocate mem for resulting matrix
 */

  if ( ( resMat = MatAlloc( mat1->Rows, mat1->Cols ) ) == NULL ) {
	
	return NULL;

  }   /* end if */

/*
 *	Perform matrix subtraction.
 */


  for ( i = 1; i < ( mat1->Rows + 1 ); i++ ) {
	for ( j = 1; j < ( mat1->Cols + 1 ); j++ ) {

		resMat->Mat[i][j] = mat1->Mat[i][j] - mat2->Mat[i][j];

	}   /* end for j */

  }   /* end for i: subtraction loop */

/*
 *	Now exit.
 */

  return resMat;

}   /* end of function MatSub */

/*========================================================================*
                                   END
 *========================================================================*/