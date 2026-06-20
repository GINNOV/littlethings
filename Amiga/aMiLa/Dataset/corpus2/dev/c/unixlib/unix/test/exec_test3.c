/* test program for exec() in unix.lib
 *
 * Launches as a child a program specified on the command line. The child
 * must perform input and output from its standard I/O. Precisely it must
 * request something in input and produce output conseguently.
 * The program: 1) attaches the write end of a pipe to the standard output of
 * the child and reads its output from the read end; 2) attaches the read
 * end of another pipe to the standard input of the child and passes input
 * to it from the write end.
 */

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <dos/dos.h>
#include <proto/dos.h>

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

int fd;

void
sendc(int sig)
{				/* if the child doesn't output the wanted */
	write(fd, ">", 1);	/* char '>' within the amount of time     */
	close(fd);		/* specified in alarm(), we do it for him */
}				/* so as to non block the parent          */

int
main(int ac, char **av)
{
	int  pid, status;
	int  std_in[2];
	int  std_out[2];
	int  c;
	char *comm;
	char *argv[3];
	FILE *infp;
	FILE *outfp;

	if (ac == 1 || ac > 3) {
	    fprintf(stderr, "Usage: %s test-program [argument]\n", av[0]);
	    exit(EXIT_FAILURE);
	}

	program = av[0];
	comm = av[1];
	argv[0] = av[1];
	if (ac == 3)
	    argv[1] = av[2];
	else
	    argv[1] = NULL;
	argv[2] = NULL;

	/* The exec() function in unix.lib starts a child process. */
	/* It is possible to give the child input, output, current */
	/* dir and stack different from the parent. If the input   */
	/* or the output of the child are changed, they are closed */
	/* after the child exits. Exec() returns the child pid.    */

	if (pipe(std_in) != 0 || pipe(std_out) != 0)
		LogFatal("Cannot get a pipe.", "");

	if (!(infp = fdopen(std_out[0], "r")) ||
	    !(outfp = fdopen(std_in[1], "w")))
		LogFatal("Cannot attach a stream to pipe.", "");

	/* fd is used in sendc() to provide the '>' char */
	fd = dup(std_out[1]);
	pid = exec(comm, argv, std_in[0], std_out[1], NULL, 4096);
	if (pid < 0)
	    LogFatal("Cannot exec %s.", comm);

	printf("child request: ");
	signal(SIGALRM, sendc);
	alarm(2);
	while((c = getc(infp)) != '>')
		putchar(c);
	alarm(0);
	fflush(stdout);
	
	while((c = getchar()) != '\n')
		putc(c, outfp);
	putc('\n', outfp);
	fclose(outfp);

	printf("child response: ");
	while((c = getc(infp)) != '\n')
		putchar(c);
	putchar('\n');
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
