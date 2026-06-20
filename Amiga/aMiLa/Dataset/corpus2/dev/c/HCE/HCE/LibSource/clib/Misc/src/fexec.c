#include	<exec/types.h>
#include	<exec/tasks.h>
#include	<libraries/dosextens.h>

typedef struct CommandLineInterface CLI;
typedef struct Process PROC;

extern	long LoadSeg(), CurrentDir(), System0();
extern	PROC *FindTask();

struct pathlist {
	struct pathlist *next;
	unsigned long dirlock;
};
typedef struct pathlist PATH;

long
fexecv(cmd, argv)
char *cmd, *argv[];
{
	register CLI *cli;
	register PATH *path;
	PROC *mytask;
	long lock, rv, seglist;
	char buf[128];
	char arg[512];
	int i;

	/*
	 * Make sure I'm running from the CLI.
	 */

	mytask = FindTask(0L);
	if ((cli = (CLI *)((unsigned long)mytask->pr_CLI << 2)) == NULL) {
		return(-1);
	}

	/*
	 * Search currentdir, "Path", and finally c: for the cmd.
	 */

	if (seglist = LoadSeg(cmd))
		goto found;

	path = (PATH *) cli->cli_CommandDir;
	while (path != NULL) {
		path = (PATH *)((unsigned long)path<<2);
		lock = CurrentDir(path->dirlock);
		seglist = LoadSeg(cmd);
		(void)CurrentDir(lock);
		if (seglist)
			goto found;
		path = path->next;
	}

	strcpy(buf, "c:");
	strcat(buf, cmd);
	if (seglist = LoadSeg(buf))
		goto found;
	return(-1);

found:
	/*
	 * Copy the argv vector to arg. Separate parameters by blanks.
	 */
	arg[0] = '\0';
	if ( argv[0] != NULL ){
		for ( i=1; argv[i] != NULL; i++){
			if ( i > 1 )
				strcat(arg, " ");
			strcat( arg, argv[i] );
		}
	}
	rv = System0(cmd, seglist, arg);
	UnLoadSeg(seglist);
	return rv;
}
