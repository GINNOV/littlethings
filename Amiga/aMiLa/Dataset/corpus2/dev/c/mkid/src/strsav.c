#include <string.h>
#include <stdlib.h>

extern void *xmalloc(size_t size);

char *
strsav(const char *s)
{
	char *t;

	if(t = xmalloc(strlen(s) + 1))
		strcpy(t,s);

	return(t);
}

char *
strnsav(const char *s,int n)
{
	char *t;

	if(t = xmalloc(n+1))
	{
		memset(t,0,n+1);
		strncpy(t,s,n);
	}

	return(t);
}
