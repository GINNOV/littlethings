/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)uerror.c	1.1 86/10/09";

#include	<stdio.h>
#include <errno.h>

#ifndef AMIGA
extern int	errno;
extern int	sys_nerr;
extern char	*sys_errlist[];
#endif
extern char	*MyName;

char	cannot[] = "%s: Cannot %s `%s' (%s)\n";

char *
uerror(void)
{
	static char	errbuf[10];

	if (errno == 0 || errno >= __sys_nerr) {
		sprintf(errbuf, "error %d", errno);
		return(errbuf);
	}
	return(__sys_errlist[errno]);
}

void
filerr(char *syscall,char *fileName)
{
	fprintf(stderr, cannot, MyName, syscall, fileName, uerror());
}
