/*
 * standard "print error message" function
 */

#include <stdio.h>
#include <errno.h>

#define	SYS_NERR	(34)

int	sys_nerr = SYS_NERR;

char *sys_errlist[SYS_NERR+1] =
	{
        "Ok",
        "No such file or directory",
        "No such process",
        "Interrrupted system call",
        "I/O error",
        "No such device or address",
        "Arg list is too long",
        "Exec format error",
        "Bad file number",
        "No child process",
        "No more processes allowed",
        "No memory available",
        "Access denied",
        "Badd address",
        "Bulk device required",
        "Resource is busy",
        "File already exists",
        "Cross-device link",
        "No such device",
        "Is not a directory",
        "Is a directory",
        "Invalid argument",
        "No more files (system)",
        "No more files (process)",
        "Not a terminal",
        "Text file is busy",
        "File is too large",
        "No space left",
        "Seek issued to pipe",
        "Read-only file system",
        "Too many links",
        "Broken pipe",
        "Math function argument error",
        "Math function result is out of range" 

	};

char *strerror(err)
	int err;
	{
	if(is_syserr(err))
		return(sys_errlist[-err]);
	return(NULL);
	}

void perror(msg)
	char *msg;
	{
	if(msg && *msg)
		{
		fputs(msg, stderr);
		fputs(": ", stderr);
		}
	if(msg = strerror(errno))
		fputs(msg);
	fputs(".\n", stderr);
	}
