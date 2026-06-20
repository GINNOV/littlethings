/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)wmatch.c	1.1 86/10/09";

#include	"bool.h"
#include	<ctype.h>

/*
	Does `name' occur in `line' delimited by non-alphanumerics??
*/
bool
wordMatch(char *name0,register char *line)
{
	register char	*name = name0;
#define IS_ALNUM(c)	(isalnum(c) || (c) == '_')

	for (;;) {
		/* find an initial-character match */
		while (*line != *name) {
			if (*line == '\n')
				return FALSE;
			line++;
		}
		/* do we have a word delimiter on the left ?? */
		if (IS_ALNUM(line[-1])) {
			line++;
			continue;
		}
		/* march down both strings as long as we match */
		while (*++name == *++line)
			;
		/* is this the end of `name', is there a word delimiter ?? */
		if (*name == '\0' && !IS_ALNUM(*line))
			return TRUE;
		name = name0;
	}
}
