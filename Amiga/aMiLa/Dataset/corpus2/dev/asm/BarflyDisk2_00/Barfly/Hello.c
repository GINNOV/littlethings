#include	"exec/execbase.h"
#include	"dos/dosextens.h"
#include	"proto/dos.h"

typedef struct CommandLineInterface	CLI;
typedef struct Process			PROCESS;

extern struct ExecBase			*SysBase;

PROCESS	*p;
CLI	*cli;

void	testfunc() {
	printf("testfunc()\n");
}

void	main(ac, av) 
int	ac;
char	*av[];
{
	short	i;
	char	s[256], *ps;

	testfunc();
	if (GetProgramName(s, 256))
		printf("Program name = '%s'\n", s);
	else
		printf("No program name\n");

	p = (PROCESS *)SysBase->ThisTask;
	cli = BADDR(p->pr_CLI);

	ps = BADDR(cli->cli_CommandName);
	printf("hello, world\n");
	printf("Command Line = '%s'\n", ps);
	for (i=0; i<ac; i++)
		printf("arg %d = '%s'\n", i, av[i]);
}

abort() {
	exit(0);
}
