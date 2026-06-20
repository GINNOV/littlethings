/* Copyright (c) 1986, Greg McGary */
/* @(#)string.h	1.1 86/10/09 */

#ifdef RINDEX
#define	strchr	index
#define	strrchr	rindex
#endif

#ifdef AMIGA
#include <dos.h>
#endif

#ifdef LATTICE
#include <string.h>	/* get the lattice one as well */
#else
extern char
	*strcpy(),
	*strncpy(),
	*strcat(),
	*strncat(),
	*strchr(),
	*strrchr(),
	*strpbrk(),
	*strtok();

extern long strtol();
#endif

#undef strcmp

#define strequ(s1,s2)		(strcmp((s1),(s2)) == 0)
#define	strnequ(s1,s2, n)	(strncmp((s1), (s2), (n)) == 0)

char *strsav(const char *s);
char *strnsav(const char *s,int n);

#ifdef AMIGA
#define striequ(s1,s2)		(stricmp((s1),(s2)) == 0)
#endif
