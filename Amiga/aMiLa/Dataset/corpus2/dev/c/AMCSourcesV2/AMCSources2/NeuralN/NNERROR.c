/*
*----------------------------------------------------------------------------
*	file:	nnerror.c
*	desc:	define all errors
*	by:	patrick ko
*	date:	2 aug 91
*----------------------------------------------------------------------------
*/

#include "nnerror.h"

struct error {
	int	error;
	char	*errmsg;
	};

static struct error	errtbl[] =

{
	{ NNMALLOC,	"malloc error" },
	{ NNTFRERR,	"train file reading error" },
	{ NNRFRERR,	"recognition file reading error" },
	{ NNTFIERR,	"train file input error" },
	{ NNIOLAYER,	"input/output layer must be specified first" },
	{ NN2MANYLAYER,	"hidden layer more than specified" },
	{ NN2FEWPATT,	"no training pattern" },
	{ NN2MANYHIDDEN,"too many hidden layers specfied" },
	{ NNOUTNOTOPEN,	"output file cannot be opened" }
};

int error( errno )
int	errno;
{
	printf( "nnerror %d: %s\n", errno, errtbl[errno].errmsg );
	exit (errno);
}
