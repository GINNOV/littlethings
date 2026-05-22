#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern char *MyName;

void *
xmalloc(size_t size)
{
	void *m;

	if(m = malloc(size))
		return(m);
	else
	{
		fprintf(stderr,"%s: out of memory\n",MyName);
		exit(1);
	}
}

void *
xcalloc(size_t number,size_t size)
{
	void *m;

	size *= number;

	if(m = xmalloc(size))
		memset(m,0,size);

	return(m);
}
