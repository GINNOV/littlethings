/*
*-----------------------------------------------------------------------------
*	file:	bptrain.c
*	desc:	back propagation Multi Layer Perceptron (MLP) training
*	by:	patrick ko
*	date:	02 aug 1991
*	revi:	v1.32u 26 apr 1992
*	revi:	v1.33u 19 nov 1992 - cparser.c bug fixed
*-----------------------------------------------------------------------------
*/

#include <stdio.h>
#include <stdlib.h>
#ifdef __TURBOC__
#include <mem.h>
#include <alloc.h>
#endif

#include "nntype.h"
#include "nncreat.h"
#include "nntrain.h"
#include "nnerror.h"
#include "cparser.h"
#include "bptrainv.h"
#include "timer.h"

#define MAXHIDDEN	128

static INTEGER	hiddencnt = 0;
static INTEGER	hidden[MAXHIDDEN];
static INTEGER	output;
static INTEGER	input;
static INTEGER	totalhidden;
static INTEGER	totalpatt = 0;
static REAL	trainerr = ERROR_DEFAULT;
static INTEGER	report = 0;
static INTEGER	timer = 0;
static long int	tdump = 0;

static VECTOR	**inputvect;
static VECTOR	**targtvect;

extern REAL	TOLER;

static char	tname[128];
/*
*	dump file name with default
*/
static char	dname[128] = "bptrain.dmp";
static char	dinname[128] = "";

int	usage( )
{
	printf( "%s %s - by %s\n", PROGNAME, VERSION, AUTHOR );
	printf( "Copyright (c) 1992 All Rights Reserved. %s\n\n", DATE );
	printf( "Description: backprop neural net training with adaptive coefficients\n");
	printf( "Usage: %s @file -i=# -o=# -hh=# {-h=#} -samp=# -ftrain=<fn>\n", PROGNAME);
	printf( "[-fdump=<fn>] [-fdumpin=<fn>] -r=# [-t] [-tdump=#] [-w+=# -w-=#]\n" );
	printf( "[-err=] [-torerr=] [// ...]\n");
	printf( "Example: " );
	printf( "create and train a 2x4x3x1 dimension NN with 10 samples\n");
	printf( "%s -i=2 -o=1 -hh=2 -h=4 -h=3 -err=0.01 ", PROGNAME );
	printf( "-ftrain=input.trn -samp=10\n" );
	printf( "Where:\n" );
	printf( "-i=,-o=     dimension of input/output layer\n" );
	printf( "-hh=        number of hidden layers\n" );
	printf( "-h=         each hidden layer dimension (may be multiple)\n" );
	printf( "-ftrain=    name of train file containing inputs and targets\n" );
	printf( "-fdump=     name of output weights dump file\n" );
	printf( "-fdumpin=   name of input weights dump file (if any)\n");
	printf( "-samp=      number of train input patterns in train file\n" );
	printf( "-r=         report training status interval\n" );
	printf( "-t          time the training (good for non-Unix)\n" );
	printf( "-tdump=     time for periodic dump (specify seconds)\n");
	printf( "-w+=        initial random weight upper bound\n" );
	printf( "-w-=        initial random weight lower bound\n" );
	printf( "-err=       mean square per unit train error ");
	printf( "(def=%f)\n", ERROR_DEFAULT );
	printf( "-torerr=    tolerance error (def=%f)\n", TOLER_DEFAULT);
	exit (0);
}

int	parse( )
{
	int	cmd;
	char	rest[128];
	int	resti;
	long	restl;

	while ((cmd = cmdget( rest ))!= -1)
		{
		resti = atoi(rest);
		restl = atol(rest);
		switch (cmd)
			{
			case CMD_DIMINPUT:
				input = resti; break;
			case CMD_DIMOUTPUT:
				output = resti; break;
			case CMD_DIMHIDDENY:
				if (input <= 0 || output <= 0)
					{
					error( NNIOLAYER );
					}
				if (resti > MAXHIDDEN)
					{
					error( NN2MANYLAYER );
					}
				totalhidden = resti; break;
			case CMD_DIMHIDDEN:
				if (hiddencnt >= totalhidden)
					{
					/*
					* hidden layers more than specified
					*/
					break;
					}
				hidden[hiddencnt++] = resti;
				break;
			case CMD_TRAINFILE:
				strcpy( tname, rest );
				break;
			case CMD_TOTALPATT:
				totalpatt = resti;
				break;
			case CMD_DUMPFILE:
				strcpy( dname, rest );
				break;
			case CMD_DUMPIN:
				strcpy( dinname, rest );
				break;
			case CMD_TRAINERR:
				trainerr = atof( rest );
				break;
			case CMD_TOLER:
				TOLER = atof( rest );
				break;
			case CMD_REPORT:
				report = resti;
				break;
			case CMD_TIMER:
				timer = 1;
				break;
			case CMD_TDUMP:
				tdump = restl;
				break;
			case CMD_WPOS:
				UB = atof(rest);
				break;
			case CMD_WNEG:
				LB = atof(rest);
				break;
			case CMD_COMMENT:
				break;
			case CMD_NULL:
				printf( "%s: unknown command [%s]\n", PROGNAME, rest );
				exit (2);
				break;
			}
		}
		if (hiddencnt < totalhidden)
			{
			error( NN2MANYHIDDEN );
			}
}

int	gettrainvect( tname )
char	*tname;
{
	int	i, j, cnt;
	VECTOR	*tmp;
	FILE	*ft;


	ft = fopen( tname, "r" );
	if (ft == NULL)
		{
		error( NNTFRERR );
		}

	inputvect = (VECTOR **) malloc( sizeof(VECTOR *) * totalpatt );
	targtvect = (VECTOR **) malloc( sizeof(VECTOR *) * totalpatt );

	if (totalpatt <= 0)
		{
		error( NN2FEWPATT );
		}
	for (i=0; i<totalpatt; i++)
		{
		/*
		*	allocate input patterns
		*/
		tmp = v_creat( input );
		for (j=0; j<input; j++)
			{
			cnt = fscanf( ft, "%lf", &tmp->vect[j] );
			if (cnt < 1)
				{
				error( NNTFIERR );
				}
			}
		*(inputvect + i) = tmp;

		tmp = v_creat( output );
		for (j=0; j<output; j++)
			{
			cnt = fscanf( ft, "%lf", &tmp->vect[j] );
			if (cnt < 1)
				{
				error( NNTFIERR );
				}
			}
		*(targtvect + i) = tmp;
		}
	fclose( ft );
}


int	main( argc, argv )
int	argc;
char	** argv;
{
	NET	*nn;
	FILE	*fdump;

	if (argc < 2)
		{
		usage();
		}
	else
		{
		cmdinit( argc, argv );
		parse();
		}

	/* create a neural net */
	nn = nn_creat( totalhidden + 1, input, output, hidden );

	gettrainvect( tname );

	/* read last dump, if any */
	if (*dinname != NULL)
		{
		printf( "%s: opening dump file [%s] ...\n", PROGNAME, dinname);
		if ((fdump = fopen( dinname, "r" )) != NULL)
			{
			nn_load( fdump, nn );
			fclose( fdump );
			}
		}

	printf( "%s: start\n", PROGNAME );

	if (timer)
		timer_restart();
	/*
	* the default training error, ..., etc can be incorporated into
	* the interface - if you like.
	*/
	nnbp_train( nn, inputvect, targtvect, totalpatt,
	trainerr, ETA_DEFAULT, ALPHA_DEFAULT, report, tdump, dname );

	if (timer)
		printf("%s: time elapsed = %ld secs\n", PROGNAME, timer_stop());

	printf( "%s: dump neural net to [%s]\n", PROGNAME, dname );

	fdump = fopen( dname, "w" );
	nn_dump( fdump, nn );
	fclose(fdump);
}


