/* example program for the GimmeDir routines	*/
/* by Daniel Mealha Cabrita (dancab@polbox.com)	 19th june, 1998	*/

#include <stdio.h>
#include <dos/exall.h>
#include "GimmeDir.h"

void MyTest (void);

main ()
{
	MyTest();
	printf ("\nfinished!\n");
}

void MyTest (void)
{
	struct tGimmeDir *MeuDir;
	struct ExAllData *MeuTemp;

	/* I'll need both filename+type_of_file so i'll put ED_TYPE		*/
	/* If i wanted just, eg., filename i could put ED_NAME			*/
	/* (ED_TYPE or higer would be	waste of memory and processing)	*/
	if (MeuDir=InitGimmeDir("dh1:", ED_TYPE, "#?"))
	{
		while (MeuTemp=GimmeDir(MeuDir))
		{
			/* look at dos/exall.h for ExAllData structure format	*/
			printf ("%p %s\n", MeuTemp->ed_Type, MeuTemp->ed_Name);	
		}

		/* ALWAYS finish things!	*/
		EndGimmeDir (MeuDir);
	}
}