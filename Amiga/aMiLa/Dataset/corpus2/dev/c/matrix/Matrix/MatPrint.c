
/*
 *	Function	MatPrint
 *	Programmer	N.d'Alterio
 *	Date		15/12/94
 *
 *  Synopsis:	This function prints out a matrix to stdout
 *
 *  Arguments:	MATRIX *	-	matrix to print
 *
 *  Variables:	i, j		-	general loop variables
 * 
 *  Functions:	fprintf		-	print to stream
 *
 *  $VER: MatPrint.c 1.5 (10.07.95) $
 *  $Log: MatPrint.c $
 * Revision 1.5  1995/07/10  23:27:13  daltern
 * code cleanup revision
 *
 *
 */

#include "Matrix.h"
#include <stdio.h>

void MatPrint( MATRIX *mat )

{

  int i, j;
  
  for ( i = 1; i < ( mat->Rows + 1 ); i++ ) {

    	fprintf( stdout, "\n" );
    	for ( j = 1; j < ( mat->Cols + 1 ); j++ ) {

      		fprintf( stdout, "%.3g\t\t", mat->Mat[i][j] );

  	}   /* end for j */

  }   /* end for i: loop over matrix */

  fprintf( stdout, "\n" );

}   /* end function MatPrint */

/*========================================================================*
                                   END
 *========================================================================*/
