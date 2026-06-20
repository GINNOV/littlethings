/****h* cmacros/macrotest.c [2.00] *
*
*  NAME
*    macrotest.c
*  COPYRIGHT
*    $VER: macrotest.c 2.00 (07.08.98) © by Stefan Kost 1998-1998
*  FUNCTION
*    Just a few tests for 'cmacros.h'.
*  AUTHOR
*    Stefan Kost
*  CREATION DATE
*    07.Aug.1998
*  MODIFICATION HISTORY
*    07.Aug.1998	V 2.00	actual version
*    03.Jul.1995	V 1.00	initial version
*  NOTES
*
*******
*/

/*-- includes ---------------------------------------------------------------*/

#include <stdio.h>

#include <exec/types.h>
#include "cmacros.h"

/*-- definitions ------------------------------------------------------------*/

void main(void)
{
	char a=5,b=14,c=0;

	printf("a : %3d\nb : %3d\n",a,b);

	printf("BitSet(a,4)     : %3d\n",BitSet(a,4));
	printf("BitClr(b,1)     : %3d\n",BitClr(b,1));
	printf("BitTest(a,0)    : %3d\n",BitTest(a,0));
	printf("BitToggle(a,0)  : %3d\n",BitToggle(a,0));

	Swap(a,b,c);
	printf("Swap(a,b,c)     : %3d %3d\n",a,b);
	Swap(a,b,c);

	printf("RangeX(b,-5,5)  : %3d\n",RangeX(b,-5,5));
	printf("RangeI(b,-5,5)  : %3d\n",RangeI(b,-5,5));

	printf("Odd(a)          : %3d\n",Odd(a));
	printf("Even(a)         : %3d\n",Even(a));
}

/*-- eof --------------------------------------------------------------------*/