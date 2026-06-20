#include <ctype.h>

char *strlwr(string)
	register char *string;
	{
	register char *p = string;

	while(*string)
		tolower(*string++);
	return(p);
	}
