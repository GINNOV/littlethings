
/*
 *  SUBS.C
 *
 *  (c)Copyright 1990, All Rights Reserved
 */

#include "defs.h"
#include <exec/execbase.h>

Prototype int ExtArgsEnv(short, char ***, char *);
Prototype char *skipspace(char *);
Prototype char *skipnspace(char *);
Prototype void CreateObjPath(char *);

extern struct ExecBase *SysBase;

/*
 *  ExtArgsEnv()        DCCOPTS
 */

int
ExtArgsEnv(ac, pav, envname)
short ac;
char ***pav;
char *envname;
{
    long len = -1;
    char *str;
    char *ptr;
    int nac = 0;
    char **nav;

#ifndef LATTICE
    if (SysBase->LibNode.lib_Version < 36) {
#else
    {
#endif
	char buf[64];
	int fd;

	sprintf(buf, "ENV:%s", envname);

	fd = open(buf, O_RDONLY);

	if (fd >= 0) {
	    if ((len = lseek(fd, 0L, 2)) > 0) {
		str = malloc(len + 1);

		lseek(fd, 0L, 0);
		read(fd, str, len);
		str[len] = 0;
	    }
	    close(fd);
	}
    }
#ifndef LATTICE
      else {
	str = malloc(1024);
	len = GetVar(envname, str, 1024, 0);
	if (len > 0)
	    str = realloc(str, len + 1);
	else
	    free(str);
    }
#endif

    if (len < 0)
	return(ac);

    /*
     *	parse
     */

    ptr = skipspace(str);
    while (*ptr) {
	++nac;
	ptr = skipnspace(ptr);
	ptr = skipspace(ptr);
    }
    nav = malloc((ac + nac + 1) * sizeof(char *));
    movmem(*pav, nav, ac * sizeof(char *));
    nac = ac;
    ptr = skipspace(str);
    while (*ptr) {
	nav[nac] = ptr;
	ptr = skipnspace(ptr);
	if (*ptr)
	    *ptr++ = 0;
	ptr = skipspace(ptr);
	++nac;
    }
    nav[nac] = NULL;
    ac = nac;
    *pav = nav;
    return(ac);
}

char *
skipspace(ptr)
char *ptr;
{
    while (*ptr == ' ' || *ptr == 9)
	++ptr;
    return(ptr);
}

char *
skipnspace(ptr)
char *ptr;
{
    while (*ptr != ' ' && *ptr != 9 && *ptr)
	++ptr;
    return(ptr);
}

/*
 *  check for path existance
 */

void
CreateObjPath(file)
char *file;
{
    short i;
    short j;
    BPTR lock;
    char tmp[128];

    for (i = strlen(file); i >= 0 && file[i] != '/' && file[i] != ':'; --i);

    if (i <= 0)
	return;
    strncpy(tmp, file, i);
    tmp[i] = 0;

    /*
     *	valid directory
     */

    if (lock = Lock(tmp, SHARED_LOCK)) {
	UnLock(lock);
	return;
    }

    /*
     *	invalid, attempt to create directory path.
     */

    for (j = 0; j <= i; ++j) {
	if (file[j] == '/') {
	    strncpy(tmp, file, j);
	    tmp[j] = 0;
	    if (mkdir(tmp) < 0 && errno != EEXIST)
		break;
	}
    }
}

