/* - C *
 * cartpole.c
 *
 * Program to test fuzzy.lib for Amiga 
 * Written by M. Kaiser
 *
 * Based on cartpole balancing equations as given by A. Barto et. al.,
 * "Neuronlike elements that can solve difficult learning control problems",
 * IEEE SMC, 1983
 *
 * If you're using SAS/C, compile this using 
 * sc link cartpole.c LIB lib:fuzzy.lib lib:scmieee.lib lib:sc.lib
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "fuzzlib.h"

/* These are the data for the simulation ------------------------------------------------------ */

#define GRAVITY          9.8
#define MASSCART         1.0
#define MASSPOLE         0.1
#define TOTAL_MASS       (MASSPOLE + MASSCART)
#define LENGTH           0.5	
#define POLEMASS_LENGTH  (MASSPOLE * LENGTH)
#define TAU              0.02  

void ExecPole(double force, double *x, double *x_dot, double *theta, double *theta_dot)

{
    double xacc,thetaacc,costheta,sintheta,temp;

    costheta = cos(*theta);
    sintheta = sin(*theta);

    temp = (force + POLEMASS_LENGTH * *theta_dot * *theta_dot * sintheta)
		         / TOTAL_MASS;

    thetaacc = (GRAVITY * sintheta - costheta* temp)
	       / (LENGTH * (1.3333333 - MASSPOLE * costheta * costheta
                                              / TOTAL_MASS));

    xacc  = temp - POLEMASS_LENGTH * thetaacc* costheta / TOTAL_MASS;

    /* Euler's method to do update state variables */

    *x           += TAU * *x_dot;
    *x_dot       += TAU * xacc;
    *theta       += TAU * *theta_dot;
    *theta_dot   += TAU * thetaacc;
}

/* Main module -------------------------------------------------------------------------------- */

int main(int argc, char **argv)

{
  struct FL_system   *fuzzysystem;
  double              x,x_dot,theta,theta_dot,force;
  int                 i,num_runs;

  printf("# cartpole %s \n",__DATE__,FL_Getinfo());
  if (argc != 7)
    {
      printf("# Usage: cartpole num_runs controller x x´ ø ø´ \n");
      return(0);
    }

  /* Initialize simulation with commandline parameters - no error checking ! */

  num_runs  = atoi(argv[1]);  
  x         = atof(argv[3]);  
  x_dot     = atof(argv[4]);  
  theta     = atof(argv[5]);
  theta_dot = atof(argv[6]);

  if (FL_Initialize())
    {
      printf("# Version info : %s\n",FL_Getinfo());
      if (fuzzysystem = FL_Read_System(argv[2])) 
	{
	  force = 0;
	  i     = 0;
	  do {
	    FL_System_Reset(fuzzysystem);
	    ExecPole(force,&x,&x_dot,&theta,&theta_dot);
	    FL_Set_Variables(fuzzysystem,"Pos",x,"Posdot",x_dot,"Angle",theta,"Angledot",theta_dot,0,0);
	    FL_System_Run(fuzzysystem);
	    FL_Get_Variable(fuzzysystem,"Control",&force);
	    
	    printf("%8.3lf %8.3lf %8.3lf %8.3lf %8.3lf\n",
		   x,x_dot,theta,theta_dot,force);
		   
	    i ++;
	  } while (i < num_runs);
	  FL_Kill_System(fuzzysystem);
	}
      else
	printf("Error: %s is not a valid file!\n",argv[1]);
    }
  return(0);
}

