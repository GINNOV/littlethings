
/*
 *	Function	MatSwapRow
 *	Programmer	N.d'Alterio
 *	Date		21/11/94
 *
 *  Synopsis:	This function swaps over two rows of a matrix.
 *
 *  Arguments:	MATRIX *mat	-	matrix to perform swapping on
 *		int row1	-	upper row
 *		int row2	-	lower row
 *
 *  Variables:	temp_row	-	temp row to hold row during swap
 * 
 *  Functions:	malloc		-	memory allocation
 *		free		-	free up memory
 *
 *  $VER: MatSwapRow.c 1.3 (10.07.95) $
 *  $Log: MatSwapRow.c $
 * Revision 1.3  1995/07/10  23:21:39  daltern
 * changed to use pointers
 *
 *
 */


#include "Matrix.h"


void MatSwapRow( MATRIX *mat, int row1, int row2 )

{

  double	*temp_row;

/*
 *  Move 1st row to temp space.
 */

  temp_row = mat->Mat[row1];

/*
 *  Move 2nd row over first row.
 */

  mat->Mat[row1] = mat->Mat[row2];

/*
 *  Finally copy out to row 2.
 */

  mat->Mat[row2] = temp_row;


/*
 *  Free mem and exit.
 */

  return;

}   /* end function MatSwapRows */

/*========================================================================*
                                   END
 *========================================================================*/

