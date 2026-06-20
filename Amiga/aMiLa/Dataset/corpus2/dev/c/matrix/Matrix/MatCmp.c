
/*
 *	Function	MatCmp
 *	Programmer	N.d'Alterio
 *	Date		12/12/94
 *
 *  Synopsis:	This function compares 2 matrices, it does this by
 *              comparing each element individually until it finds
 *              a difference  greater than specified.
 *		SIGN IS IGNORED
 *
 *  Arguments:	MATRIX *mat1	-	matrix 1
 *		MATRIX *mat2	-	matrix 2
 *		double diff	-	max difference between elements
 *					for them to be considered equal
 *
 *  Returns:	int		-	 0 if same
 *				-	 1 if different
 *
 *  Variables:	i,j		-	general loop variables
 * 
 *  Functions:	fabs		-	floating point absolute value
 *
 *  $VER: MatCmp.c 1.1 (10.07.95) $
 *  $Log: MatCmp.c $
 * Revision 1.1  1995/07/10  22:18:59  daltern
 * Initial revision
 *
 *
 */

#include "Matrix.h"
#include <math.h>

int MatCmp( MATRIX *mat1, MATRIX *mat2, double diff )

{

  int i, j;


/*
 *  Loop over each element of matrix.
 */

  for ( i = 1; i < ( mat1->Rows + 1 ); i++ ) {
	for ( j = 1; j < ( mat2->Cols + 1 ); j++ ) {

		if ( fabs( fabs( mat1->Mat[i][j] ) - 
			   fabs( mat2->Mat[i][j] ) ) > diff )  {

			return 1;

		}   /* end if */


	}   /* end for j */

  }   /* end for i : loop over matrix */


/*
 *  All elements similar so exit.
 */

  return 0;

}   /* end function MatCmp */

/*========================================================================*
                                   END
 *========================================================================*/
