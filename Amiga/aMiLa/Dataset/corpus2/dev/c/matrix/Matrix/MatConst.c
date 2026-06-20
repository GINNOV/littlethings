
/*
 *	Function	MatConst
 *	Programmer	N.d'Alterio
 *	Date		12/12/94
 *
 *  Synopsis:	This function carries out a basic arithmetic operation
 *		on each element of a matrix by a constant.
 *
 *  Arguments:	MATRIX *mat	-	the matrix
 *		double val	-	the constant 
 *		int op		-	the operation 1 = add
 *						      2 = sub
 *						      3 = mult
 *						      4 = div
 *
 *  Returns:	MATRIX *	-	answer
 *		NULL		-	if errors
 *
 *  Variables:	i, j		-	general loop variables
 *
 *  $VER: MatConst.c 1.1 (10.07.95) $
 *  $Log: MatConst.c $
 * Revision 1.1  1995/07/10  22:28:06  daltern
 * Initial revision
 *
 *
 */

#include "Matrix.h"


MATRIX *MatConst( MATRIX *mat, double val, int op )

{


  int i, j;

  MATRIX *ans;

  if ( ( ans = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return NULL;

  }   /* end if */

/*
 *  Check not dividing by zero.
 */

  if ( ( op == 4 ) && ( val == 0.0 ) ) {

	return NULL;

  }   /* end if */

/*
 *  Loop over matrix.
 */

  for ( i = 1; i < ( mat->Rows + 1 ); i++ ) {
	for ( j = 1; j < ( mat->Cols + 1 ); j++ ) {

/*
 *  Perform appropriate operation.
 */

		switch ( op ) {


			case 1:

				ans->Mat[i][j] = mat->Mat[i][j] + val;
				break;
					
			case 2: 

				ans->Mat[i][j] = mat->Mat[i][j] - val;
				break;

			case 3:

				ans->Mat[i][j] = mat->Mat[i][j] * val;
				break;

			case 4:

				ans->Mat[i][j] = mat->Mat[i][j] / val;
				break;

			default:

				return NULL;
				break;

		}   /* end switch */

	}   /* end for j */

  }   /* end for i : loop over matrix */

  return ans;

}   /* end function MatConst */

/*========================================================================*
                                   END
 *========================================================================*/

