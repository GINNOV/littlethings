/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)basename.c	1.1 86/10/09";

#include	"string.h"

#ifndef NULL
#define NULL ((char *) 0)
#endif

char *
basename(char *path)
{
	char		*base;

	if ((base = strrchr(path, '/')) == 0)
#ifdef AMIGA
		if ((base = strchr(path,':')) != NULL)
			return ++base;
		else
#endif
		return path;
	else
		return ++base;
}

char *
dirname(char *path)
{
	char		*base;

	if ((base = strrchr(path, '/')) == 0)
#ifdef UNIX
		return ".";
#endif
#ifdef AMIGA
	{
		if ((base = strrchr(path,':')) == NULL)
			return "";
		else
			return strnsav(path, base - path + 1); /* for : */
	}
#endif
	else
		return strnsav(path, base - path);
}
