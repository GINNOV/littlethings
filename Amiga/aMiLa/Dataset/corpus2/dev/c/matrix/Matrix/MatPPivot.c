
/*
 *	Function	MatPPivot
 *	Programmer	N.d'Alterio
 *	Date		21/11/94
 *
 *  Synopsis:	This function sorts a column of a matrix so that the
 *		maximum value is at the current index position. The 
 *		following values range max at top to min at bottom. 
 *		This function also sorts RHS column matrix appropriately.
 *
 *  Arguments:	MATRIX *mat	-	matrix to sort column
 *		MATRIX *mat1	-	matrix to sort positions
 *		INDEX *idx	-	index to sort around
 *
 *  Returns:	0		-	if successful
 *		>0		-	if failed
 *
 *  Variables:	j		-	general loop variable
 *		max_row		-	row index with containing max val
 *		cur_row		-	row being looked at
 *		count		-	number of rows until max from cur
 *		max		-	current maximum value
 * 
 *  Functions:	MatSwapRow	-	swaps two matrix rows
 *
 *  $VER: MatPPivot.c 1.9 (10.07.95) $
 *  $Log: MatPPivot.c $
 * Revision 1.9  1995/07/10  23:52:51  daltern
 * added code to give error if 0 ended up on diagonal
 *
 *
 */


#include "Matrix.h"
#include <math.h>

int MatPPivot( MATRIX *mat, MATRIX *mat1, MATRIX *val, INDEX *idx )

 {
	
  int j;
  int max_row;
  int cur_row;
  int count;

  double max;

  for ( cur_row = idx->R; cur_row < mat->Rows; cur_row++ ) {

/*
 *  Initialise varibles for each new loop.
 */

	max     = mat->Mat[cur_row][idx->C];
	max_row = cur_row;
	count	= 1;              

/*
 *  Loop over rows to find max value.
 */

	for ( j = ( cur_row + 1 ); j < ( mat->Rows + 1 ); j++ ) {

		if ( fabs( mat->Mat[j][idx->C] ) > fabs( max ) ) {

			max     = mat->Mat[j][idx->C];
	 		max_row = max_row + count;
			count   = 1;

		} else {

			count++;

		}   /* end if */

  }   /* end for */

/*
 *  Check if maximum value = 0. Exit if it is.
 */

	if ( ( fabs( max ) < SMALL ) && ( idx->R == cur_row ) ) {

		return 10;

	}   /* end if */

/*
 *  Now swap the rows of matrix. Don't bother if already
 *  at the maximum value.
 */

	if ( idx->C != max_row ) {

		MatSwapRow( mat, cur_row, max_row );
		MatSwapRow( mat1, cur_row, max_row );
		MatSwapRow( val, cur_row, max_row );

	}   /* end if */

  }   /* end for: loop down col */

  return 0;

}   /* end function MatPPivot */

/*========================================================================*
                                   END
 *========================================================================*/





