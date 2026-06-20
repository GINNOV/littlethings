/* test program for exec() in unix.lib
 *
 * Launches as a child a program specified on the command line, redirecting
 * its standard output (by mean of dup2()) to the file "pippo". The standard
 * input is left indisturbed, so the child reads from the console and
 * writes to "pippo".
 */

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <proto/dos.h>
#include <proto/exec.h>

typedef unsigned char bool;

#define FALSE 0
#define TRUE  1

char *program;

void
LogFatal(char *x0, char *x1)
{
	extern char *sys_errlist[];
	static bool entered = FALSE;

	if (entered)
		return;
	entered = TRUE;

	fprintf(stderr, "%s: ", program);
	if (errno)
		fprintf(stderr, "%s: ", sys_errlist[ errno ]);
	fprintf(stderr, x0,x1);
	fprintf(stderr, "  Stop.\n");
	exit(20);
}

void
LogFatalI(char *s, int i)
{
	/*NOSTRICT*/
	LogFatal(s, (char *)i);
}

int
main(int ac, char **av)
{
	int pid, status;
	char *comm;
	char *argv[2];
	FILE *outfp = fopen("pippo", "w");

	if (ac != 2) {
	    fprintf(stderr, "Usage: %s test-program\n", av[0]);
	    exit(EXIT_FAILURE);
	}

	program = av[0];
	comm = av[1];
	argv[0] = av[1];
	argv[1] = NULL;

	/* The exec() function in unix.lib starts a child process. */
	/* It is possible to give the child input, output, current */
	/* dir and stack different from the parent. If the input   */
	/* or the output of the child are changed, they are closed */
	/* after the child exits. Exec() returns the child pid.    */

	dup2(fileno(outfp), 1);
	pid = exec(comm, argv, -1, -1, NULL, 4096);
	if (pid < 0)
	    LogFatal("Cannot exec %s.", comm);
	/* Simply wait child completion */
	if (wait(&status) > 0) {
		if (WIFSIGNALED(status))
			LogFatalI("Signal %d.", WTERMSIG(status));
		if (WIFEXITED(status) && WEXITSTATUS(status))
			LogFatalI("Exit code %d.", WEXITSTATUS(status));
	}

	fclose(outfp);
	fprintf(stderr, "Job done.\n");
	printf("Above is the output of the child.\n");
	return(WEXITSTATUS(status));
}
