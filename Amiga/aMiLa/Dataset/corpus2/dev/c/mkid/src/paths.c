/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)paths.c	1.1 86/10/09";

#include	"bool.h"
#include	<stdio.h>
#include	"string.h"

char * spanPath(char *dir,char *arg);
char * skipJunk(char *path);
char * suffName(char *path);
bool canCrunch(char *path1,char *path2);
char * getDirToName(char *topName);

char *
spanPath(char *dir,char *arg)
{
	static char	pathBuf[BUFSIZ];
	char		*path;
	char		*argTail;
	char		*dirTail;
	int		argLength;
	int		dirLength;

	if(dir)	/* didn't check for NULL  -olsen */
	{
		for (dirTail = &dir[strlen(dir)-1]; *dirTail == '/'; dirTail--)
			*dirTail = '\0';
	}

	(path = pathBuf)[0] = '\0';	/* was lower REJ */
	/* while dir and arg are the same loop REJ */
#ifdef AMIGA
	/* two complete path names, find minimal traverse, using ///... */
	/* first, the volume names must match */
	if(dir)	/* didn't check for NULL  -olsen */
		dirTail = strchr(dir,':');
	else
		dirTail = NULL;
	argTail = strchr(arg,':');
	if (dirTail && argTail)	/* should always be true, but paranoia */
	{
		dirLength = dirTail - dir;
		argLength = argTail - arg;

		if (argLength == dirLength)
		{
			if (!strnicmp(arg, dir, argLength))
			{
				arg = argTail;
				dir = dirTail;
#endif
	for (;;) {
		dir = skipJunk(dir);
		if ((dirTail = strchr(dir, '/')) == NULL)
			dirTail = &dir[strlen(dir)];
		dirLength = dirTail - dir;

		arg = skipJunk(arg);
		if ((argTail = strchr(arg, '/')) == NULL)
			break;
		argLength = argTail - arg;

		if (argLength != dirLength)
			break;
		if (!strnequ(arg, dir, argLength))
			break;
		arg = argTail;
		dir = dirTail;
	}

	for (; dir && *dir; dir = skipJunk(strchr(dir, '/'))) {
#ifdef UNIX
		strcpy(path, "../");
		path += 3;
#endif
#ifdef AMIGA
		*path++ = '/';
		*path = '\0';
#endif
	}
#ifdef AMIGA
			}
		}
	}
#endif

	strcat(path, arg);
	return pathBuf;
}

char *
skipJunk(char *path)
{
	if (path == NULL)
		return NULL;
#ifdef AMIGA
	if (*path == ':' || *path == '/')
		path++;
#endif
#ifdef UNIX
	while (*path == '/')
		path++;
	while (path[0] == '.' && path[1] == '/') {
		path += 2;
		while (*path == '/')
			path++;
	}
	if (strequ(path, "."))
		path++;
#endif

	return path;
}

char *
rootName(char *path)
{
	static char	pathBuf[BUFSIZ];
	char		*root;
	char		*dot;

	if ((root = strrchr(path, '/')) == NULL)
#ifdef AMIGA
		if ((root = strrchr(path, ':')) == NULL)
			root = path;
		else
			root++;
#endif
#ifdef UNIX
		root = path;
#endif
	else
		root++;

	if ((dot = strrchr(root, '.')) == NULL)
		strcpy(pathBuf, root);
	else {
		strncpy(pathBuf, root, dot - root);
		pathBuf[dot - root] = '\0';
	}

	return pathBuf;
}

char *
suffName(char *path)
{
	char		*dot;

	if ((dot = strrchr(path, '.')) == NULL)
		return "";
	return dot;
}

bool
canCrunch(char *path1,char *path2)
{
	char		*slash1;
	char		*slash2;

	slash1 = strrchr(path1, '/');
	slash2 = strrchr(path2, '/');
#ifdef AMIGA
	if (slash1 == NULL)
		slash1 = strrchr(path1,':');
	if (slash2 == NULL)
		slash2 = strrchr(path2,':');
#endif

	if (slash1 == NULL && slash2 == NULL)
#ifdef AMIGA
		return striequ(suffName(path1), suffName(path2));
#else
		return strequ(suffName(path1), suffName(path2));
#endif
	if ((slash1 - path1) != (slash2 - path2))
		return FALSE;
	if (!strnequ(path1, path2, slash1 - path1))
		return FALSE;
#ifdef AMIGA
	return striequ(suffName(slash1), suffName(slash2));
#else
	return strequ(suffName(slash1), suffName(slash2));
#endif
}

#ifdef UNIX
#include	<sys/types.h>
#include	<sys/stat.h>
#ifdef NDIR
#include	<ndir.h>
#else
#include	<sys/dir.h>
#endif
#endif /* UNIX */

static char	dot[]	 = ".";
static char	dotdot[] = "..";

/*
	Return our directory name relative to the first parent dir
	that contains a file with a name that matches `topName'.
	Fail if we hit the root, or if any dir in our way is unreadable.
*/
char *
getDirToName(char *topName)
{
	static char	nameBuf[BUFSIZ];
	char		*name;
#ifdef UNIX
	register struct direct	*dirp;
	register DIR	*dirdp;
	struct	stat	dStat;
	struct	stat	ddStat;
#endif
#ifdef AMIGA
	char		path[BUFSIZ];	/* used to be 64  -olsen */
	char		home[BUFSIZ];
	char		*temp;

	if (getcd(0,home) == -1)	/* this is where we want to return to */
		return NULL;
#endif

	name = &nameBuf[sizeof(nameBuf)-1];
	*name = '\0';
	for (;;) {
#ifdef UNIX
		if (stat(topName, &dStat) == 0) {
			if (!*name)
				name = dot;
			else
				chdir(name);
			return name;
		}
		if (stat(dot, &dStat) < 0)
			return NULL;
		if ((dirdp = opendir(dotdot)) == NULL)
			return NULL;
		if (fstat(dirdp->dd_fd, &ddStat) < 0)
			return NULL;
		if (chdir(dotdot) < 0)
			return NULL;
		if (dStat.st_dev == ddStat.st_dev) {
			if (dStat.st_ino == ddStat.st_ino)
				return NULL;
			do {
				if ((dirp = readdir(dirdp)) == NULL)
					return NULL;
			} while (dirp->d_ino != dStat.st_ino);
		} else {
			do {
				if ((dirp = readdir(dirdp)) == NULL)
					return NULL;
				stat(dirp->d_name, &ddStat);
			} while (ddStat.st_ino != dStat.st_ino || ddStat.st_dev != dStat.st_dev);
		}
		closedir(dirdp);

		if (*name != '\0')
			*--name = '/';
		name -= dirp->d_namlen;
		strncpy(name, dirp->d_name, dirp->d_namlen);
#endif /* UNIX */
#ifdef AMIGA
		if (access(topName,0) == 0) {	/* got it */
			if (!*name)
				name = "";
			else
			{
				if (chdir(name) == -1)
				{
					chdir(home);	/* return to original drawer  -olsen */

					return NULL;
				}
			}

			chdir(home);	/* return to original drawer  -olsen */

			return name;
		}
		if (getcd(0,path) == -1 || path[strlen(path)-1] == ':')
		{
			chdir(home);	/* return to original drawer  -olsen */
			return NULL;
		}

		/* add current dir to list */
		if (*name != '\0')
			*--name = '/';

		/* assumes xxx:yyy[{/zzz}...] */
		if ((temp = strrchr(path,'/')) == NULL)
			temp = strchr(path,':');	/* root - take volume */
		else
			temp++;		/* point past '/' */
		name -= strlen(temp);
		strncpy(name, temp, strlen(temp));

		chdir("/");
#endif
	}
}
