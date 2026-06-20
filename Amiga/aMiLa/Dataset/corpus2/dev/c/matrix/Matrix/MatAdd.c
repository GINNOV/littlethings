
/*
 *	Function	MatAdd
 *	Programmer	N.d'Alterio
 *	Date		17/11/94
 *
 *  Synopsis:	This function performs an addition of two matrices if 
 *		the addition is possible.
 *
 *  Arguments:	MATRIX *mat1		-	first matrix
 *		MATRIX *mat2		-	second matrix
 *
 *  Returns:	MATRIX *	-	sum of mat1 and mat2
 *		NULL		-	if there was a problem
 *
 *  Variables:	ResMat		-	temp variable for sum result
 *		i, j		-	general loop variables
 * 
 *  Functions:	MatAlloc	-	allocate mem and init matrix
 *
 *  $VER: MatAdd.c 1.2 (10.07.95) $
 *  $Log: MatAdd.c $
 * Revision 1.3  1995/07/26  12:46:27  daltern
 * BUGFIX: last column was missed for additions
 *
 * Revision 1.2  1995/07/10  22:00:42  daltern
 * code tidy up version
 *
 *
 */

#include "Matrix.h"


MATRIX *MatAdd( MATRIX *mat1, MATRIX *mat2 )

{

  MATRIX *ResMat = NULL;

  int i, j;

/*
 *	First check that the addition is possible.
 */

  if ( ( mat1->Rows != mat2->Rows ) || ( mat1->Cols != mat2->Cols ) ) {

	return NULL;

  }   /* end if */

/*
 *	Now allocate mem for resulting matrix
 */

  if ( ( ResMat = MatAlloc( mat1->Rows, mat1->Cols ) ) == NULL ) {
	
	return NULL;

  }   /* end if */

/*
 *	Perform matrix addition.
 */


  for ( i = 1; i < ( mat1->Rows + 1 ); i++ ) {
 	for ( j = 1; j < ( mat2->Cols + 1 ); j++ ) {

		ResMat->Mat[i][j] = mat1->Mat[i][j] + mat2->Mat[i][j];

	}   /* end for j */

  }   /* end for i: addition loop */

/*
 *	Now return result and exit.
 */

  return  ResMat;

}   /* end of function MatAdd */

/*========================================================================*
                                   END
 *========================================================================*/
