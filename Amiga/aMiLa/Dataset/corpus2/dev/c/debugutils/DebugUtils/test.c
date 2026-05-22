/*									FILE:	test.c
 *
 *	Project:			Debug Utilities
 *	Version:			v1.1
 *
 *
 * This file contains:
 *
 *						1.	main()
 *						2. func1()
 *						3. func2()
 *
 *
 * Created:			Thursday 07-May-92 22:15:44
 * Author:        Mark Porter (fog)
 *
 *
 *	Copyright © 1992 if...only Amiga
 *
 *	Permission is granted to distribute this program's source, executable,
 *	and documentation for non-commercial use only, provided the copyright
 *	and header information are left intact.
 *
 */



#include	"debug.h"

void func1(),func2();



/*------------ main() ------------
 *
 *
 * FUNCTION:	Tests the trace.lib debugging utilities.
 *
 * ARGUMENTS:	Standard command line arguments.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	
 *
 */

main( argc,argv )
	int	argc;
	char *argv[];
{
	ENTER( "main" );

	DB( Trace( 0,"main","First Message to appear\n" ));

	func1();
	func2();

	DB( Trace( 0,"main","About to exit to AmigaDos\n" ));

	EXIT( "main" );
}



/*------------ func1() ------------
 *
 *
 * FUNCTION:	Tries out some of the DB_Level options.
 *
 * ARGUMENTS:	None.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	
 *
 */

void func1()
{
	int	i;
	int	num = 1234;
	float x	 = 45.678;

	ENTER( "func1" );

	DB( Trace( 0,"func1","Testing Floating Point x = %3.2f\n",x ));
	DB( Trace( 0,"func1","About to enter loop\n" ));

	for ( i = 0; i < 10; i++ )
	{
		DB( Trace( 1,"func1","Looping, i = %d\n",i ));

		DB( Trace( i,"func1","Incrementing DB_Level, num = %d\n",num ));
	}

	EXIT( "func1" );
}



/*------------ func2() ------------
 *
 *
 * FUNCTION:	Tries out some more of the DB_Level options.
 *
 * ARGUMENTS:	None.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	
 *
 */

void func2()
{
	ENTER( "func2" );

	DB( Trace( 0,"func2","Printing this message\n" ));

	EXIT( "func2" );
}
