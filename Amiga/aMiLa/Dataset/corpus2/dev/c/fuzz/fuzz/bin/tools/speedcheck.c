/* - C *
 * speedcheck.c
 *
 * Program to test speed improvement of X functions
 * Written by M. Kaiser
 *
 * If you're using SAS/C, compile this using 
 * sc link speedcheck.c LIB fuzzy.lib lib:scmieee.lib lib:sc.lib
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "fuzzlib.h"

/* Main module -------------------------------------------------------------------------------- */

int main(int argc, char **argv)

{
  struct FL_system   *fuzzysystem;
  register int        i,l,num;
  time_t              start,end;
  double              hertz;

  printf("speedcheck [%s] \n",__DATE__);
  if (argc != 3)
    {
      printf("Usage: speedcheck <fuzzysystem file> <num_runs>\n");
      return(1);
    }

  num = atoi(argv[2]);
  if (num <= 0)
    {
      return(1);
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
	  printf("# Checking speed of fuzzysystem \n");
	  
	  srand48(time(0));
	  start = time(0);
	  for (i = 0; i < num; i ++)
	    {
	      FL_System_Reset(fuzzysystem);
	      for (l = 0; l < fuzzysystem->num_variables; l++)
		FL_Set_Variable(fuzzysystem,fuzzysystem->variable[l].name,drand48());
	      FL_System_Run(fuzzysystem);
	    }

	  end = time(0);
	  printf("# Standard functions required %g seconds\n",difftime(end,start));

	  hertz  = difftime(end,start);
	  hertz /= (double)num;
	  if (hertz > 0)
	    hertz = 1.0/hertz;
	  else
	    hertz = 0;

	  printf("# Allows for a control frequency of %.2lf Hz on this machine.\n",hertz);

	  FL_Kill_System(fuzzysystem);
	}
    }
  return(0);
}

