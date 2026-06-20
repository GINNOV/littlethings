/* test program for exec() in unix.lib
 *
 * Launches as a child a program specified on the command line, redirecting
 * its standard output (by mean of dup2()) to the write end of a pipe,
 * attaches a stream to the read end of the pipe to read the child output,
 * reopens stdout towards the console. The standard input is left indisturbed,
 * so the child reads from the console and writes to the pipe.
 */

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

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
	int p_io[2];
	char *comm;
	char *argv[3];
	FILE *infp;

	if (ac < 2 | ac > 3) {
	    fprintf(stderr, "Usage: %s test-program [arg]\n", av[0]);
	    exit(EXIT_FAILURE);
	}

	program = av[0];
	comm = av[1];
	argv[0] = av[1];
	argv[1] = av[2];
	argv[2] = NULL;

	/* The exec() function in unix.lib starts a child process. */
	/* It is possible to give the child input, output, current */
	/* dir and stack different from the parent. If the input   */
	/* or the output of the child are changed, they are closed */
	/* after the child exits. Exec() returns the child pid.    */

	if (pipe(p_io) != 0)
		LogFatal("Cannot get a pipe.", "");

	if (!(infp = fdopen(p_io[0], "r")))
		LogFatal("Cannot attach a stream to pipe.", "");

	dup2(p_io[1], 1);
	pid = exec(comm, argv, -1, -1, NULL, 50000);
	close(p_io[1]);
	freopen("console:", "w", stdout);
	if (pid < 0)
	    LogFatal("Cannot exec %s.", comm);

	printf("child output (char, ascii): ");
	while(!feof(infp)) {
		char c = getc(infp);
		printf("(%c,%d)", c, c);
	}
	printf("\n");
	fclose(infp);

	/* Simply wait child completion */
	if (wait(&status) > 0) {
		if (WIFSIGNALED(status))
			LogFatalI("Signal %d.", WTERMSIG(status));
		if (WIFEXITED(status) && WEXITSTATUS(status))
			LogFatalI("Exit code %d.", WEXITSTATUS(status));
	}

	return(WEXITSTATUS(status));
}
