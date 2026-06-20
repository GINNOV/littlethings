/* 
 * Copyright 1993, 1995 Christopher Seiwald.
 *
 * This file is part of Jam - see jam.c for Copyright information.
 */

/*
 * execas400.c - execute a command on an AS/400 system.
 *
 * The AS/400 implementation of system(3) is pretty lame. It returns
 * only -1, 0, or 1 so you can't easily spot interruptions. To get
 * that information you need to use spawn() or spawnp() which don't 
 * block signals to the parent process; but of course you have to
 * manage the process creation in much more detail.
 * 
 * External routines:
 *	execcmd() - launch an async command execution
 * 	execwait() - wait and drive at most one execution completion
 *
 * Internal routines:
 *	onintr() - bump intr to note command interruption
 *
 *
 * 06/08/05 (tony smith) - First implementation
 */

# include "jam.h"
# include "lists.h"
# include "execcmd.h"

# ifdef OS_AS400
# define AS400_EXEC_SPAWN

# include <stdio.h>
# include <string.h>
# include <stdlib.h>

# ifdef AS400_EXEC_SPAWN
# include <spawn.h>
# endif

extern char **environ;
static int intr = 0;

# ifdef AS400_EXEC_SPAWN

/*
 * This implementation uses the spawnp() interface on AS/400 to execute
 * commands. This allows us to get a real exit status from the child
 * instead of the lame return value from system() on AS/400.
 */

static void
onintr( int sig )
{
    printf( "...interrupted\n" );
    intr++;
}


void
execcmd( 
	char *string,
	void (*func)( void *closure, int status ),
	void *closure,
	LIST *shell )
{
	int 	rstat = EXEC_CMD_FAIL;
	void 	(*old_handler)( int );
	int	fd_map[4];
	int	pipefds[ 2 ];
	pid_t	child_pid;
	int 	wait_status;
	int	len;
	char 	*argv[4] = { 0 };
	char	buf[128];
	struct	inheritance inherit = { 0 };
	/* 
	 * Command to run. We use qsh to invoke the compiler, 
	 */
	char *qsh = "qsh";

	/* Skip leading whitespace */
	for( ; string; string++ )
	    if( !isspace( *string ) )
		break;

	argv[ 0 ] = qsh;
	argv[ 1 ] = "-c";
	argv[ 2 ] = string;

	/*
	 * Allocate a pipe so we can talk to the child process.
	 */
	if( pipe( pipefds ) )
	{
	    fprintf( stderr, "Unable to create a pipe\n" );
	    goto done;
	}

	/*
	 * Install our signal handler 
	 */
	old_handler = signal( SIGINT, onintr );

	/*
	 * Connect the pipe fds up to the child processes stdin,stdout,stderr
	 */
	fd_map[ 0 ] = pipefds[ 0 ];
	fd_map[ 1 ] = pipefds[ 1 ];
	fd_map[ 2 ] = pipefds[ 1 ];
	    
	/*
	 * Make sure that spawn() will set up stdin, stdout and stderr in
	 * the child properly. This initializes the environ pointer so we
	 * must call it before we spawn.
	 */
	putenv( "QIBM_USE_DESCRIPTOR_STDIO=Y" );

	/* Now execute it */
	child_pid = spawnp( qsh, 3, fd_map, &inherit, argv, environ );
	if( child_pid < 0 )
	{
	    fprintf( stderr, "Error spawning sub-process\n" );
	    goto cleanup;
	}

	/* Read and print the child's output from the pipe */
	close( pipefds[ 1 ] );
	while( ( len = read( pipefds[ 0 ], buf, sizeof( buf ) - 1 ) ) > 0 )
	{
	    buf[ len ] = 0;
	    printf( "%s", buf );
	}

	/* Wait for the child to exit */
	if( waitpid( child_pid, &wait_status, 0 ) < 0 )
	{
	    fprintf( stderr, "Failed to wait for child process...\n" );
	    goto cleanup;
	}

	/*
	 * Examine the child's exit status 
	 */
	if( intr )
	    rstat = EXEC_CMD_INTR;
	else if( WIFEXITED( wait_status ) && !WEXITSTATUS( wait_status ) )
	    rstat = EXEC_CMD_OK;
	else
	    rstat = EXEC_CMD_FAIL;

cleanup:
	signal( SIGINT, old_handler );
	close( pipefds[ 0 ] );
	close( pipefds[ 1 ] );

done:
	(*func)( closure, rstat );
}



# else
/*
 * On AS/400 we can also use the system() interface to execute commands, the 
 * problem with doing this is that the AS/400 implementation of system only 
 * returns zero, 1 or -1 and doesn't tell us the reason for failure. 
 */

void
execcmd( 
	char *string,
	void (*func)( void *closure, int status ),
	void *closure,
	LIST *shell )
{
	char *s;
	int rstat = EXEC_CMD_OK;
	int status;

	/* 
	 * Command to run. We use qsh to invoke the compiler, but we
	 * can't tell if it worked or not really because the return value
	 * of system() is too vague. We also can't easily tell if we've
	 * been interrupted.
	 */
	const char *qsh = "qsh -c";

	/* Strip leading whitespace */
	for( ; string && isspace( *string ); string++ )
		;

	/* Build Q-Shell command */
	s = malloc( strlen( string ) + strlen( qsh ) + 16 );
	sprintf( s, "%s \"%s\"", qsh, string );

	/* Now execute it */
	status = system( s );
	free( s );

	if( status )
	    rstat = EXEC_CMD_FAIL;

	(*func)( closure, rstat );
}


#endif /* AS400_EXEC_SPAWN */


int 
execwait()
{
	return 0;
}


int
execmax()
{
	return MAXLINE;
}

# endif /* AS400 */
