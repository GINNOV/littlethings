#include <libraries/dosextens.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

extern int      _argc;
extern char     **_argv;

typedef struct Process PROCESS;
typedef struct CommandLineInterface CLI;

static char errmsg[] = "Too many arguments\n";
static char *_malloc(size)
int size;
/*
 * Internal error checking interface for the malloc() function
 */
	{
	register char *p;
	char *malloc();
	long Output();

	if(p = malloc(size))
		return(p);
	Write( Output(), errmsg, 19L);
	_exit(ENOMEM);
	}
	
/*
 * When invoked from the CLI, sets up argc and argv[].
 */
void _cli_parse(tp, cmdlen, cmdline)
PROCESS *tp;
int cmdlen;
char *cmdline;
{
	register unsigned char *p, *q;
	register int i, n;
	unsigned char *argbuf, delim;
	CLI	*cli;

	/*
	 * Get the name I was called by.
	 */

	cli = (CLI *)(tp->pr_CLI << 2);
	p = (unsigned char *) ( cli->cli_CommandName << 2);
	i = p[0];
	argbuf  = (unsigned char *)_malloc( (int)(i + cmdlen + 2) );

	/*
	 * copy the command line 'cause we're going to munge it.
	 */

	strncpy( argbuf, &p[1], i);
	argbuf[i] = ' ';
	argbuf[i+1] = '\0';
	strncat( argbuf, cmdline, (int)cmdlen);

	/*
	 * Trim any trailing non-white space (like a newline).
	 */

	p = &argbuf[i+cmdlen+1];
	while ( p > argbuf && *p < ' ')
		*p-- = '\0';

	/*
	 * Break the copy of the command line into tokens based on
	 * the break characters " \t".  Break characters within double
	 * quotation marks will be ignored.
	 *
	 * This is tricky since we are doing an in-place compression to
	 * eliminate leading and break characters.
	 * p points to next character to be tested in argbuf[].
	 * q points to where the next character should be put in argbuf[].
	 */

	/*
	 * parse command line image based on whitespace or delimiter.
	 */

	n = 0;
	for ( p=q=argbuf; *p; ++n,p++ ) {
		while ( *p == ' ' || *p == '\t' )
			p++;
		if ( p == (unsigned char *)NULL)
			break;

		if ( *p != '\"' ) {
			do {
				*q++ = *p++;
			} while ( *p && *p != ' ' && *p != '\t' );
		} else {
			delim = *p++;
			while ( *p && *p != delim )
				*q++ = *p++;
		}

		/*
		 * Mark the end of this string in argbuf[].
		 */
	
		*q++ = '\0';
	
	}

	*q = '\0';
	/*
	 * Allocate _argv array and store the indexes into the argbuf
	 * string.
	 */
	_argv = (char **)_malloc( (n+1) * sizeof( char *));
	p = argbuf;
	for ( i=0; i<n; i++ ) {	
		_argv[i] = (char *)p;
		p += strlen(p) + 1;
	}
	_argv[i] = (char *)NULL;
	_argc = n;
}
