/*
*-----------------------------------------------------------------------------
*	file:	bprecog.c
*	desc:	recognizing program
*	by:	patrick ko
*	date:	20 aug 1991
*	revi:	v1.32u 26 apr 1992
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
#include "bprecogv.h"

#define MAXHIDDEN	128

static INTEGER	hiddencnt = 0;
static INTEGER	hidden[MAXHIDDEN];
static INTEGER	output;
static INTEGER	input;
static INTEGER	totalhidden;
static INTEGER	totalpatt = 0;

static VECTOR	**inputvect;
static VECTOR	**targtvect;

static char	tfilename[128];

/*
*	default dump file name
*/
static char	dfilename[128] = "bptrain.dmp";
static char	ofilename[128] = "bprecog.out";

int	usage( )
{
	printf( "%s %s - by %s\n", PROGNAME, VERSION, AUTHOR );
	printf( "(C)Copyright 1992 All Rights Reserved. %s\n\n", DATE );
	printf( "Description: backprop neural net recognition\n");
	printf( "Usage:\n%s @file -i=# -o=# -hh=# {-h=#} -samp=# -frecog=<fn> [-fdump=<fn>] -fout=<fn>\n\n", PROGNAME );
	printf( "Examples:\n" );
	printf( "Recognize 2 patterns in myinput.rgn with the NN created in bptrain example 1\n" );
	printf( "and generate a result file result.out:\n" );
	printf( "%s -i=2 -o=1 -hh=2 -h=3 -h=4 -samp=2 -frecog=myinput.rgn -fout=result.out\n", PROGNAME );
	printf( "\n" );
	printf( "Where\n\n" );
	printf( "-i=         dimension of input layer\n" );
	printf( "-o=         dimension of output layer\n" );
	printf( "-hh=        number of hidden layers\n" );
	printf( "-h=         each hidden layer dimension (may be multiple)\n" );
	printf( "-samp=      number of train input patterns in train file\n" );
	printf( "-frecog=    name of recog file containing inputs\n" );
	printf( "-fdump=     name of neural net file dumped by bptrain\n" );
	printf( "-fout=      name of recognition result file\n" );
	exit (1);
}

int parse( )
{
	int	cmd;
	char	rest[128];
	int	resti;

	while ((cmd = cmdget( rest ))!= -1)
		{
		resti = atoi(rest);
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
			case CMD_RECOGFILE:
				strcpy( tfilename, rest );
				break;
			case CMD_TOTALPATT:
				totalpatt = resti;
				break;
			case CMD_DUMPFILE:
				strcpy( dfilename, rest );
				break;
			case CMD_OUTFILE:
				strcpy( ofilename, rest );
				break;
			case CMD_COMMENT:
				break;
			case CMD_NULL:
				printf( "unknown command [%s]\n", rest );
				exit (2);
				break;
			}
		}
		if (hiddencnt < totalhidden)
			{
			error( NN2MANYHIDDEN );
			}
}

int getrecogvect( recogfile )
char	*recogfile;
{
	int	i, j, cnt;
	VECTOR	*tmp;
	FILE	*ft;


	ft = fopen( recogfile, "r" );
	if (ft == NULL)
		{
		error( NNRFRERR );
		}

	inputvect = (VECTOR **) malloc( sizeof(VECTOR *) * totalpatt );

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
		}
	fclose( ft );
}


int main( argc, argv )
int	argc;
char	**argv;
{
	INTEGER	i;
	NET	*nn;
	FILE	*fdump, *fout;

	if (argc < 2)
		{
		usage();
		}
	else
		{
		cmdinit( argc, argv );
		parse();
		}

	/*
	*	create a neural net
	*/
	nn = nn_creat( totalhidden + 1, input, output, hidden );

	printf( "opening dump file [%s] ...\n", dfilename );
	fdump = fopen( dfilename, "r" );
	nn_load( fdump, nn );
	fclose( fdump );

	printf( "start recognizing...\n" );
	getrecogvect( tfilename );

	fout = fopen( ofilename, "w" );
	if (fout == NULL)
		{
		error (NNOUTNOTOPEN);
		}
	for (i=0; i<totalpatt; i++)
		{
		nnbp_forward( nn, *(inputvect + i) );
		nn_dumpout( fout, nn );
		}
	fclose( fout );
}

