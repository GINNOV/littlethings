/* - C *
 * fuzzcheck.c
 *
 * Program to test integrity of fuzzy files
 * Written by M. Kaiser
 *
 * If you're using SAS/C, compile this using 
 * sc link fuzzcheck.c LIB fuzzy.lib lib:scmieee.lib lib:sc.lib
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "fuzzlib.h"

/* Main module -------------------------------------------------------------------------------- */

void main(int argc, char **argv)

{
  struct FL_system   *fuzzysystem;
  register int        i;
  int      command;
  double   value;

  printf("fuzzcheck [%s] \n",__DATE__);
  if (argc != 2)
    {
      printf("Usage: fuzzcheck <fuzzysystem file> \n");
      return;
    }

  if (FL_Initialize())
    {
      printf("Version info : %s\n",FL_Getinfo());
      if (!(fuzzysystem = FL_Read_System(argv[1])))
	{
	  printf("Error: %d:%s [%s] \n",FL_Geterror(),FL_GeterrorName(),FL_GeterrorText());
	}
      else
	{
	  printf("# File is valid.\n");
	  printf("# Fuzzysystem: %s \n",fuzzysystem->name);

	  printf("# %3d membership functions are defined:\n",fuzzysystem->num_memfuncs);
	  for (i = 0; i < fuzzysystem->num_memfuncs; i++)
	    printf("#    MF  %3d: %s \n",i, fuzzysystem->memfunc[i].name);

	  printf("# %3d variables are defined:\n",fuzzysystem->num_variables);
	  for (i = 0; i < fuzzysystem->num_variables; i++)
	    printf("#    VAR %3d: %s \n",i, fuzzysystem->variable[i].name);

	  printf("# %3d objects are defined:\n",fuzzysystem->num_objects);
	  for (i = 0; i < fuzzysystem->num_objects; i++)
	    printf("#    OBJ %3d: %s \n",i, fuzzysystem->object[i].name);

	  do {
	    printf("Check memfunc no.: ");
	    scanf("%d",&command);
	    if ((command >= 0) && (command < fuzzysystem->num_memfuncs))
	      {
		printf("Enter value: ");
		scanf("%lf",&value);
		for (i = 0; i < fuzzysystem->memfunc[command].num_subsets; i++)
		  printf("Subset %20s: %lf \n",
			 fuzzysystem->memfunc[command].subset[i].name,
			 FL_Subset_Memship(&fuzzysystem->memfunc[command].subset[i],value));
	      }
	  } while (command >= 0);

	  FL_Kill_System(fuzzysystem);
	}
    }
}

