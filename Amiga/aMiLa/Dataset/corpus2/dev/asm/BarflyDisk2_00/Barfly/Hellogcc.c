;/*
gcc -g -gstabs -o hellogcc -lger -lamiga hellogcc.c
quit
;*/

#include	"exec/execbase.h"
#include	"dos/dosextens.h"
#include	"inline/dos.h"
/*#undef	amiga*/
#include	<stdio.h>

void volatile exit __P((int));

typedef struct CommandLineInterface	CLI;
typedef struct Process			PROCESS;

extern struct ExecBase			*SysBase;

PROCESS	*p;
CLI	*cli;

void	testfunc(void)
{
	Printf("testfunc()\n");
}

int	main(int	ac,
             char	*av[]) 
{
	short	i;
	char	s[256], *ps;

	testfunc();
	if (GetProgramName(s, 256))
		Printf("Program name = '%s'\n", s);
	else
		Printf("No program name\n");

	p = (PROCESS *)SysBase->ThisTask;
	cli = BADDR(p->pr_CLI);

	ps = BADDR(cli->cli_CommandName);
	Printf("hello, world\n");
	Printf("Command Line = '%s'\n", ps);
	for (i=0; i<ac; i++)
		Printf("arg %d = '%s'\n", i, av[i]);

        return(0);
}

void	abort(void)
{
	exit(0);
}
