#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

char *
tempnam(const char *tmpdir, const char *prefix)
{
	char *ptr, *tmp, buffer[L_tmpnam + 1];
	int extra = 1;

	if ((ptr = strchr(tmpnam(buffer), ':')) != NULL)
		++ptr;
	else
		ptr = buffer;
	
	if (tmpdir[strlen(tmpdir)-1] != ':' && tmpdir[strlen(tmpdir)-1] != '/')
		extra = 2;
	tmp = malloc(strlen(tmpdir)+strlen(prefix)+strlen(ptr)+extra);
	if (!tmp) {
		errno = ENOMEM;
		return(0);
	}
	strcpy(tmp, tmpdir);
	if (extra == 2)
		strcat(tmp, "/");
	strcat(tmp, prefix);
	strcat(tmp, ptr);
	return(tmp);
}
