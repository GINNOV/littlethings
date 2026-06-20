#include "amiga.h"
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>

int _sprintf(char *, const char *,...);

char *mktemp(char *name)
{
    static unsigned long next = 0;
    int n = 0, l = strlen(name);
    char letter = 'A';
    char *change;
    char id[9], *end_id;
    struct stat buf;

    __chkabort();
    for(change = name + l - 1; *change == 'X'; --change)
	++n;
    ++change;

    if(!n)
	return NULL;  /* no trailing Xs */

    _sprintf(id, "%lx", (long)_us + next++);
    l = strlen(id);
    end_id = l > n ? id + l - n : id;
    _sprintf(change, "%s", end_id);

    while (*change) {
	*change = letter++;
	if (stat(name, &buf))
	    return name;
	if (letter > 'Z') {
	    letter = 'A';
	    *change++ = letter;
	}
    }
    name[0] = '\0';
    return(NULL);
}
