head	1.730;
access;
symbols;
locks
	lilja:1.730; strict;
comment	@ * @;


1.730
date	96.08.02.21.57.32;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.150;

1.150
date	96.02.11.16.38.55;	author lilja;	state Exp;
branches;
next	0.700;

0.700
date	95.09.24.00.57.34;	author lilja;	state Exp;
branches;
next	0.563;

0.563
date	95.09.10.20.59.20;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Functions to read/parse remote directory.
@


1.730
log
@AmiFTP starts even if no TCP/IP-stack is running.
No 'please insert inet:...' when starting.
Still has to fix the ARexx stuff to cope with no stack running.
@
text
@/* RCS Id: $Id: readdir.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"

int parse_line(struct List *filelist,char *line,int *temp_non_unix);
int parse_line_ls(struct List *filelist,char *line);
int parse_line_pattern(struct List *filelist,char *pattern,char *line,int *temp_non_unix);
int parse_line_vms(struct List *filelist,char *line,int *temp_non_unix);
int parse_line_dos(struct List *filelist,char *line,int *temp_non_unix);
char *dir_parse_to_pattern(char *dir_parse);
int unix_perms(char *s,int *temp_non_unix);
int vms_perms(char *s,int *temp_non_unix);
int vms_perms_set(char *s);
int vms_filetype(char *s);

extern int dirlastmtime;

struct List *read_remote_dir()
{
    struct List *filelist;
    int	old_unix, temp_non_unix = 0;
    int          din = -1;
    int		vms_expect_dir;

  restart:
    old_unix = temp_non_unix;
    filelist=(struct List *)malloc(sizeof(struct List));
    if (!filelist) {
	ShowErrorReq(GetAmiFTPString(Str_Outofmem));
	return NULL;
    }
    NewList(filelist);

    /* read the remote directory, adding files and directories to a list */
    /* send dir command */

    if (non_unix || temp_non_unix) {
	din = open_remote_ls(1);
	vms_expect_dir = 0;
    } else {
	din = open_remote_ls(0);
	vms_expect_dir = 1;
    }
    if (din == -1) {
	/* always have .. */
	return filelist;
    }

    for (;;) {
	if (next_remote_line(din) == NULL)
	  goto out;
	if (!strncmp(response_line, "226", 3) ||
	    !strncmp(response_line, "250", 3)) {
	    /* done */
//	    printf(response_line);
	    break;
	}
	/* ignore blank lines */
	if (*response_line == '\n' || *response_line == '\0')
	  continue;
	/* VMS also prints the directory name */
	if (remote_os_type == REMOTE_OS_VMS && vms_expect_dir) {
	    /* first non-blank line is directory name */
	    vms_expect_dir = 0;
	    continue;
	}
	/* VMS goofy total line before 226 */
	if (!strncmp(response_line, "Total of", 8)||!strncmp(response_line, "Total ",6))
	  continue;

	if (parse_line(filelist, response_line, &temp_non_unix)) {
	    if (old_unix != temp_non_unix) {
		/* start over */
		free_dirlist(filelist);
		free(filelist);
		filelist=NULL;
		while (sgetc(din) != -1)
		  /* NULL */;
		close_remote_ls(din);
		din = -1;
		goto restart;
	    } else
	      goto out;
	}
    }

  out:
    if (din>=0)
      close_remote_ls(din);
    if (timedout) {
	free_dirlist(filelist);
	free(filelist);
	timeout_disconnect();
	return NULL;
    }
    if (filelist)
      return filelist;
    return NULL;
}


#define	NULLCHECK() if (*curr == '\0') { *temp_non_unix = 1; return 1; }


int	parse_line(struct List *filelist, char *line, int *temp_non_unix)
{
    if (non_unix || *temp_non_unix) {
	return parse_line_ls(filelist, line);
    }
    switch (remote_os_type) {
      case REMOTE_OS_UNIX:
	return parse_line_pattern(filelist, unix_dir_pattern, line,
				   temp_non_unix);
	break;
      case REMOTE_OS_VMS:
	return parse_line_vms(filelist, line, temp_non_unix);
	break;
      case REMOTE_OS_DOS:
	return parse_line_dos(filelist, line, temp_non_unix);
	break;
      case REMOTE_OS_OTHER:
	return parse_line_pattern(filelist, other_dir_pattern, line,
				   temp_non_unix);
	break;
    }
    return 1;
}

int	parse_line_ls(struct List *filelist, char *line)
{
	char	*curr;
	static char	name[MAXPATHLEN + 1];
	char	*tmp;
	mode_t	type;

	/* Assume that if the first character is upper case, */
	/* it is non-unix (since ls never puts upper case as the type */
	/* And it appears that the filename is all the characters at the */
	/* start of the line up to but not including white space on VMS and */
	/* tops20. This would make it functional, partially at least */
	/* Also, may need to turn on temp_non_unix_mode, so that cd is */
	/* possible on anything, since we can't tell if they're directories. */
	/* or not */
	curr = line;

	while (*curr && isspace(*curr))
		curr++;
	tmp = name;
	while (*curr && !isspace(*curr)) {
		*tmp = *curr;
		tmp++;
		curr++;
	}
	*tmp = '\0';
	curr++;

	type = S_IFLNK;
	if (name[strlen(name)] == '/')
		type = S_IFDIR;

	if (add_direntry(filelist, name, "unknown", "unknown", "unknown", type,
		(size_t)-1, SortMode, remote_sort_direction) == NULL) {
		ShowErrorReq(GetAmiFTPString(Str_ErrorBuildingDirList));
		return 1;
	}
	return 0;
}

int	parse_line_pattern(struct List *filelist, char *pattern,
	char *line, int *temp_non_unix)
{
	/* default mode is a symbolic link. This is so if you don't have */
	/* UNIX PERMS, it can be either a file or a directory. Maybe.  */
	mode_t	mode = S_IFLNK;
	int		intmode;
	char	*curr;
	static char	date[20];
	static char	month[10];
	static char	day[10];
	static char	timeyear[10];
	static char	name[MAXPATHLEN + 1];
	static char owner[25];
	static char group[25];
	size_t	size = (size_t)-1;
	char	*tmp;
	char	*dirtmp;

	month[0] = '\0';
	day[0] = '\0';
	timeyear[0] = '\0';
	date[0] = '\0';
	name[0] = '\0';
	strcpy(owner, "unknown");
	strcpy(group, "unknown");

	curr = line;
	dirtmp = pattern;
	while (*dirtmp != '\0') {
		NULLCHECK();
		switch (*dirtmp) {
		case ' ':
			while (*curr && isspace(*curr))
				curr++;
			break;
		case SKIP:
			while (*curr && !isspace(*curr))
				curr++;
			break;
		case PERMS:
			intmode = unix_perms(curr, temp_non_unix);
			if (intmode == 0)
				return 0;
			else if (intmode == -1)
				return 1;
			mode = (mode_t)intmode;
			while (*curr && !isspace(*curr))
				curr++;
			break;
		case LINKS:
			/* dump link count */
			while (isdigit(*curr))
				curr++;
			break;
		case USER:
			/*
			 * this should be the user name, surrounded by
			 * white space
			 */
			tmp = owner;
			while (*curr && !isspace(*curr)) {
				*tmp = *curr;
				tmp++;
				curr++;
			}
			*tmp = '\0';
			break;
		case GROUP:
			/*
			 * this should be the group name, surrounded by
			 * white space
			 */
			tmp = group;
			while (*curr && !isspace(*curr)) {
				*tmp = *curr;
				tmp++;
				curr++;
			}
			*tmp = '\0';
			break;
		case SIZE:
			/* first test only true for UNIX case, where we have */
			/* seen the perms */
			if (S_ISCHR(mode) || S_ISBLK(mode)) {
				/* size is actually major, minor */
				while (isdigit(*curr) || *curr == ',')
					curr++;
				NULLCHECK();
				while (*curr && isspace(*curr))
					curr++;
				NULLCHECK();
				while (isdigit(*curr))
					curr++;
				size = -1;
			} else {
				sscanf(curr, "%d", &size);
				while (isdigit(*curr))
					curr++;
			}
			break;
		case MONTH:
			tmp = month;
			while (isalpha(*curr)) {
				*tmp = *curr;
				tmp++;
				curr++;
			}
			*tmp = '\0';
			break;
		case DAY:
			tmp = day;
			while (isdigit(*curr)) {
				*tmp = *curr;
				tmp++;
				curr++;
			}
			*tmp = '\0';
			break;
		case TIME:
			tmp = timeyear;
			while (isdigit(*curr) || (*curr == ':')) {
				*tmp = *curr;
				tmp++;
				curr++;
			}
			*tmp = '\0';
			break;
		case NAME:
		case LOWERNAME:
			tmp = name;
			/*
			 * The following test makes sure we have seen the
			 * PERMS field.  If not, the permissions will
			 * still be 0. symlinks normally have 777 for
			 * permissions
			 */
			if (mode != S_IFLNK && S_ISLNK(mode)) {
				while (*curr && *curr != '\n') {
					*tmp = *curr;
					tmp++;
					curr++;
				}
			} else {
				/* if token last in line, eat till newline */
				if (*(dirtmp + 1) == '\0') {
					while (*curr && *curr != '\n') {
						*tmp = *curr;
						tmp++;
						curr++;
					}
				} else {
					while (*curr && !isspace(*curr) &&
					    *curr != ';') {
						*tmp = *curr;
						tmp++;
						curr++;
					}
				}
				/* VMS */
				if (*curr == ';') {
					while (*curr && !isspace(*curr))
						curr++;
				}
			}
			*tmp = '\0';
			if (*dirtmp == LOWERNAME) {
				for (tmp = name; *tmp != '\0'; tmp++)
					if (isupper(*tmp))
						*tmp = tolower(*tmp);
			}
			break;
		default:
			if (*dirtmp == *curr) {
				curr++;
			} else {
				*temp_non_unix = 1;
				return 1;
			}
		}
		dirtmp++;
	}
	sprintf(date, "%s %2s %5s", month, day, timeyear);

	/* The wuarchive ftp server prints . and .. in the listing */
	/* ignore them */
	if ((name[0] == '.' && name[1] == '\0') ||
	    (name[0] == '.' && name[1] == '.' && name[2] == '\0')) {
		return 0;
	}

	if (add_direntry(filelist, name, date, owner, group, mode, size,
		SortMode, remote_sort_direction) == NULL) {
		ShowErrorReq(GetAmiFTPString(Str_ErrorBuildingDirList));
		return 1;
	}
	return 0;
}

extern char *abbrev_month[];

int	parse_line_vms(struct List *filelist, char *line, int *temp_non_unix)
{
    /* default mode is a symbolic link. This is so if you don't have */
    /* UNIX PERMS, it can be either a file or a directory. Maybe.  */
    mode_t	mode = S_IFLNK;
    int		intmode;
    char	*curr;
    static char	date[20];
    static char	month[10];
    static char	day[10];
    static char	hour[10];
    static char	year[10];
    static char	name[MAXPATHLEN + 1];
    static char owner[25];
    static char group[25];
    static int partial = 0;
    size_t	size = (size_t)-1;
    char	*tmp;
    time_t	curtime, filetime;
    extern int cummonthdays[];
    int	i;
    int	founddash;
    int day_i, month_i, year_i, min_i, hour_i;

    month[0] = '\0';
    day[0] = '\0';
    hour[0] = '\0';
    year[0] = '\0';
    date[0] = '\0';
    if (partial == 0)
      name[0] = '\0';

    strcpy(owner, "unknown");
    strcpy(group, "unknown");

    curr = line;

    /* Format is */
    /*
     *
     * NETINFO_ROOT:[000000]
     *
     * 0README.;25            7   1-DEC-1991 16:55 NETINFO (RWD,RWD,,R)
     * STATUS.19-MAR-1992;1
     *                        7  19-MAR-1992 12:48 NETINFO (RWED,RWED,RE,RE)
     * UOFA.DIR;1             2  15-SEP-1989 11:49 NETINFO (RWE,RWE,RE,RE)
     *
     */
    /*
     * Blank lines are already ignored.
     * Directory name should already be ignored too.
     */
    if (partial == 0) {
	tmp = name;
	while (*curr && !isspace(*curr)) {
	    *tmp = *curr;
	    tmp++;
	    curr++;
	}
	*tmp = '\0';
	/*
	 * Got the name. However, it may break lines into two, as
	 * STATUS above. After reading a name, see if we have to
	 * save and wait for the next line.
	 */
	tmp = curr;
	while (*tmp && isspace(*tmp))
	  tmp++;
	if (*tmp == '\0') {
	    partial = 1;
	    return 0;
	}
    } else {
	/* already have name from previous call */
	partial = 0;
    }

    while (isspace(*curr))
      curr++;
    NULLCHECK();

    /* size, in 512 byte blocks? */
    /* could be missing. */
    tmp = curr;
    founddash = 0;
    while (!isspace(*tmp)) {
	if (*tmp == '-') {
	    founddash = 1;
	    break;
	}
	tmp++;
    }
    if (!founddash) {
	sscanf(curr, "%d", &size);
	while (isdigit(*curr))
	  curr++;
	size *= 512;
    }

    while (isspace(*curr))
      curr++;

    /* Date: 1-DEC-1991 16:55 */
    tmp = day;
    while (isdigit(*curr)) {
	*tmp = *curr;
	tmp++;
	curr++;
    }
    *tmp = '\0';
    if (*curr != '-')
      return 1;
    curr++;
    NULLCHECK();

    tmp = month;
    while (isalpha(*curr)) {
	if (tmp != month && isupper(*curr))
	  *tmp = tolower(*curr);
	else
	  *tmp = *curr;
	tmp++;
	curr++;
    }
    *tmp = '\0';
    if (*curr != '-')
      return 1;
    curr++;
    NULLCHECK();

    tmp = year;
    while (isdigit(*curr)) {
	*tmp = *curr;
	tmp++;
	curr++;
    }
    *tmp = '\0';
    if (*curr != ' ')
      return 1;
    curr++;
    NULLCHECK();

    tmp = hour;
    while (isdigit(*curr) || *curr == ':') {
	*tmp = *curr;
	tmp++;
	curr++;
    }
    *tmp = '\0';
    if (*curr != ' ')
      return 1;
    curr++;
    NULLCHECK();

    /*
     * this should be the user name, surrounded by white space
     */
    tmp = owner;
    while (!isspace(*curr)) {
	*tmp = *curr;
	tmp++;
	curr++;
    }
    *tmp = '\0';
    curr++;
    NULLCHECK();

    while (isspace(*curr))
      curr++;

    intmode = vms_perms(curr, temp_non_unix);
    if (intmode == 0)
      return (0);
    else if (intmode == -1)
      return (1);
    mode = (mode_t)(intmode | vms_filetype(name));

    day_i = atoi(day);
    month_i = 0;
    for (i = 0; i < 12; i++)
      if (!strncmp(month, abbrev_month[i], 3))
	break;
    if (i != 12)
      month_i = i;
    year_i = atoi(year);
    year_i -= 1970;		/* time kept since 1970 */

    hour_i = min_i = 0;
    sscanf(hour, "%d:%d", &hour_i, &min_i);


    filetime = ((year_i * 365) + cummonthdays[month_i] + day_i) * 24 * 60;
    filetime += min_i + (hour_i * 60);
    curtime = time((time_t *)NULL);
    curtime /= 60;		/* seconds -> minutes */


    if ((curtime - filetime) < (6 * 30 * 24 * 60))
      sprintf(date, "%s %2s %5s", month, day, hour);
    else
      sprintf(date, "%s %2s %5s", month, day, year);

    /* change name to lowercase, and remove ';num' */
    tmp = strrchr(name, ';');
    if (tmp != NULL)
      *tmp = '\0';
    for (tmp = name; *tmp != '\0'; tmp++)
      if (isupper(*tmp))
	*tmp = tolower(*tmp);
    if (add_direntry(filelist, name, date, owner, group, mode, size,
		    SortMode, remote_sort_direction) == NULL) {
	ShowErrorReq(GetAmiFTPString(Str_ErrorBuildingDirList));
	return (1);
    }
    return (0);
}

int	parse_line_dos(struct List *filelist, char *line, int *temp_non_unix)
{
	/* default mode is a symbolic link. This is so if you don't have */
	/* UNIX PERMS, it can be either a file or a directory. Maybe.  */
	mode_t	mode = S_IFLNK;
	char	*curr;
	static char	date[20];
	static char	month[10];
	static char	day[10];
	static char	year[10];
	static char	hour[10];
	static char	name[MAXPATHLEN + 1];
	size_t	size = (size_t)-1;
	char	*tmp;
	time_t	curtime, filetime;
	int	i;
	int	day_i, month_i, year_i, min_i, hour_i;
	extern int cummonthdays[];

	month[0] = '\0';
	day[0] = '\0';
	year[0] = '\0';
	hour[0] = '\0';
	date[0] = '\0';
	name[0] = '\0';

	/* Format is */
	/*
    	 * 	33430            IO.SYS   Tue Apr 09 05:00:00 1991
    	 * 	37394         MSDOS.SYS   Tue Apr 09 05:00:00 1991
    	 * 	47845       COMMAND.COM   Tue Apr 09 05:00:00 1991
	 * <dir>                    DOS   Wed Sep 23 19:43:32 1992
	 * <dir>                  WPWIN   Fri Oct 30 03:04:50 1992
     	 * 	9349         WINA20.386   Tue Apr 09 05:00:00 1991
	 * <dir>                VWCOMMS   Tue Dec 01 02:52:44 1992
     	 * 	123          CONFIG.SYS   Fri Nov 27 03:17:40 1992
     	 * 	589        AUTOEXEC.BAT   Tue Dec 01 02:42:42 1992
	 */
	curr = line;
	while (isspace(*curr))
		curr++;
	NULLCHECK();

	/* directory or file+size? */
	if (isdigit(*curr)) {
		/* file size */
		mode = S_IFREG;
		sscanf(curr, "%d", &size);
		while (isdigit(*curr))
			curr++;
	} else if (!strncmp(curr, "<dir>", 5)) {
		/* directory */
		mode = S_IFDIR;
		while (!isspace(*curr))
			curr++;
	} else {
		*temp_non_unix = 1;
		return (1);
	}
	while (isspace(*curr))
		curr++;
	NULLCHECK();

	/* name */
	tmp = name;
	while (!isspace(*curr)) {
		*tmp = *curr;
		tmp++;
		curr++;
	}
	*tmp = '\0';
	while (isspace(*curr))
		curr++;
	NULLCHECK();

	/* Skip day of week */
	while (!isspace(*curr))
		curr++;
	while (isspace(*curr))
		curr++;
	NULLCHECK();

	/* month */
	tmp = month;
	while (isalpha(*curr)) {
		*tmp = *curr;
		tmp++;
		curr++;
	}
	*tmp = '\0';
	while (isspace(*curr))
		curr++;
	NULLCHECK();

	/* day */
	tmp = day;
	while (isdigit(*curr)) {
		*tmp = *curr;
		tmp++;
		curr++;
	}
	*tmp = '\0';
	while (isspace(*curr))
		curr++;
	NULLCHECK();


	/* hour:minute:seconds */
	tmp = hour;
	while (isdigit(*curr) || *curr == ':') {
		*tmp = *curr;
		tmp++;
		curr++;
	}
	*tmp = '\0';
	while (!isspace(*curr))
		curr++;
	NULLCHECK();

	/* year */
	tmp = year;
	while (isdigit(*curr)) {
		*tmp = *curr;
		tmp++;
		curr++;
	}
	*tmp = '\0';

	day_i = atoi(day);
	month_i = 0;
	for (i = 0; i < 12; i++)
		if (!strncmp(month, abbrev_month[i], 3))
			break;
	if (i != 12)
		month_i = i;
	year_i = atoi(year);
	year_i -= 1970; /* time kept since 1970 */

	hour_i = min_i = 0;
	sscanf(hour, "%d:%d", &hour_i, &min_i);


	filetime = ((year_i * 365) + cummonthdays[month_i] + day_i) * 24 * 60;
	filetime += min_i + (hour_i * 60);
	curtime = time((time_t *)NULL);
	curtime /= 60; /* seconds -> minutes */


	if ((curtime - filetime) < (6 * 30 * 24 * 60))
		sprintf(date, "%s %2s %5s", month, day, hour);
	else
		sprintf(date, "%s %2s %5s", month, day, year);

	/* change name to lowercase */
	for (tmp = name; *tmp != '\0'; tmp++)
		if (isupper(*tmp))
			*tmp = tolower(*tmp);

	if (add_direntry(filelist, name, date, "unknown", "unknown", mode, size,
		SortMode, remote_sort_direction) == NULL) {
		ShowErrorReq(GetAmiFTPString(Str_ErrorBuildingDirList));
		return (1);
	}
	return (0);
}

/*
 * take the dir_parse string, in the form of
 *	PERMS LINKS USER GROUP SIZE MONTH DAY TIME NAME
 * and return a NULL-terminated array of character values of the above
 *
 * The values would be control-characters, so they are not in danger
 * of being typed (right!). A ' ' represents whitespace, any other character
 * must be matched exactly.
 */
/*
char	*lex_string;

char *dir_parse_to_pattern(char *dir_parse)
{
	char 	pattern[MAXPATHLEN+1];
	char	*nextpos = pattern;
	char	*s;
	int		token;
	int		found_bitmask = 0;
	int		yylex();
	static char *tokval[] = {
		"",
		"PERMS",
		"LINKS",
		"USER",
		"GROUP",
		"SIZE",
		"MONTH",
		"DAY",
		"TIME",
		"NAME",
		"SKIP",
		"NONUNIX",
		"LOWERNAME",
	};

	lex_string = strdup(dir_parse);
	if (lex_string == NULL) {
		ShowErrorReq("Out of memory");
		exit(1);
	}
	s = lex_string;
	while ((token = yylex()) != 0) {
		*nextpos = (char)token;
		nextpos++;
		if (token <= MAXTOKENS) {
			if (found_bitmask & (1 << token)) {
				fprintf(stderr,
				    "Duplicate token %s in DIR template.\n",
				    tokval[token]);
				free(s);
				return (NULL);
			}
			if (token != SKIP)
				found_bitmask |= 1 << token;
		}
	}
	*nextpos = '\0';
	free(s);
	if ((found_bitmask & (1 << NONUNIX)) != 0) {
		pattern[0] = (char)NONUNIX;
		return (strdup(pattern));
	}
	
	if ((found_bitmask & (1 << NAME)) == 0 &&
	    (found_bitmask & (1 << LOWERNAME)) == 0) {
		printf("You must specify a NAME token in the parse field.\n");
		return (NULL);
	}
	return (strdup(pattern));
}
*/
#undef NULLCHECK
#define	NULLCHECK() if (*s == '\0') { *temp_non_unix = 1; return (-1); }

#ifdef USE_PROTOTYPES
int unix_perms(char *s, int *temp_non_unix)
#else
int unix_perms(s, temp_non_unix)
char	*s;
int		*temp_non_unix;
#endif
{
    int mode;

    switch (*s) {
      case 'd':
	mode = S_IFDIR;
	break;
      case 'F':
      case 'f':
      case 'm':			/* Cray and convex migrated files */
      case '-':
	mode = S_IFREG;
	break;
      case 'l':
	mode = S_IFLNK;
	break;
      case 'b':
	mode = S_IFBLK;
	break;
      case 'c':
	mode = S_IFCHR;
	break;
      case 's':
	mode = S_IFSOCK;
	break;
      case 'p':
	mode = S_IFIFO;
	break;
      case 'D':
	mode = S_IFDIR;
	break;
      case 'B':
	mode = S_IFBLK;
	break;
      case 'C':
	mode = S_IFCHR;
	break;
      case 'S':
	mode = S_IFSOCK;
	break;
      case 'P':
	mode = S_IFIFO;
	break;
      case 't':
	if (!strncmp(s, "total", 5))
	  return (0);
	/* fall through */
#ifdef notdef
      case '.':
	if (s[1] == ':') {
	    ftperr = ftp_error(' ', "Permission denied");
	    footer_message(ftperr);
	    return (0);
	} else if (!strncmp(s, ". unreadable", 12)) {
	    footer_message(". unreadable.");
	    return (0);
	}
#endif
      default:
	*temp_non_unix = 1;
	return (-1);
	break;
    }

    s++;
    if (*s == ' ' || *s == '\0' || *s == '\t')
      return (mode);		/* OK to not have permissions */
    NULLCHECK();
    /*
     * Determine permissions.
     */

#define	SET_PERM1(ch, val) \
    { \
      if (*s == ch) {\
         mode |= val; \
      } else if (*s != '-') { \
	 *temp_non_unix = 1;\
 	 return (-1); \
      }\
      s++; \
    }

#define	SET_PERM2(ch1, ch2, val) \
    { \
      if (*s == ch1 || *s == ch2) {\
	 mode |= val; \
      } else if (*s != '-' && *s != 'l') { \
	 *temp_non_unix = 1;\
	return (-1); \
      } \
      s++; \
    }
    {

	SET_PERM1('r', S_IRUSR);
	NULLCHECK();

	SET_PERM1('w', S_IWUSR);
	NULLCHECK();

	SET_PERM2('x', 's', S_IXUSR);
	NULLCHECK();

	SET_PERM1('r', S_IRGRP);
	NULLCHECK();

	SET_PERM1('w', S_IWGRP);
	NULLCHECK();

	SET_PERM2('x', 's', S_IXGRP);
	NULLCHECK();

	SET_PERM1('r', S_IROTH);
	NULLCHECK();

	SET_PERM1('w', S_IWOTH);
	NULLCHECK();

	SET_PERM2('x', 't', S_IXOTH);
	NULLCHECK();
    }
													return (mode);
												    }

#ifdef USE_PROTOTYPES
										int vms_perms_set(char *s)
#else
										  int vms_perms_set(s)
										    char	*s;
#endif
										{
										    int	set = 0;
										    char	*tmp;

										    for (tmp = s; *tmp != '\0'; tmp++) {
											/* handle RWED */
											switch (*tmp) {
											  case 'R':
											    set |= S_IROTH;
											    break;
											  case 'W':
											    set |= S_IWOTH;
											    break;
											  case 'E':
											    set |= S_IXOTH;
											    break;
											  case 'D':
											    /* ignore */
											    break;
											  default:
											    return (set);
											}
										    }
										    return (set);
										}

#ifdef USE_PROTOTYPES
										int vms_perms(char *s, int *temp_non_unix)
#else
										  int vms_perms(s, temp_non_unix)
										    char	*s;
										int		*temp_non_unix;
#endif
										{
										    int mode;

										    /* s is of the form: */
										    /* (RWED,RWED,RWED,RWED) */
										    /* system, owner, group, world */

										    if (*s != '(')
										      return (-1);
										    s++;
										    NULLCHECK();
										    /*
										     * Skip system.
										     */
										    while (*s && *s != ',')
										      s++;
										    NULLCHECK();
										    /* otherwise, it's a comma */
										    s++;

										    /* owner */
										    mode = vms_perms_set(s) << 6;

										    while (*s && *s != ',')
										      s++;
										    NULLCHECK();
										    /* otherwise, it's a comma */
										    s++;

										    /* group */
										    mode |= vms_perms_set(s) << 3;

										    while (*s && *s != ',')
										      s++;
										    NULLCHECK();
										    /* otherwise, it's a comma */
										    s++;

										    /* world */
										    mode |= vms_perms_set(s);

										    return (mode);
										}

#ifdef USE_PROTOTYPES
										int vms_filetype(char *s)
#else
										  int vms_filetype(s)
										    char	*s;
#endif
										{
										    char *period;

										    period = strrchr(s, '.');
										    if (period != NULL) {
											if (!strncmp(period, ".DIR", 4)) {
											    /* Zap .DIR* for */
											    *period = '\0';
											    return (S_IFDIR);
											}
										    }
										    return (S_IFREG);
										}
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@d1 2
a2 2
/* RCS Id: $Id: readdir.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d370 1
a370 5
static char *abbrev_month[] = {
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
};

@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Locked version: $Revision$
d5 1
a5 1
#include "ftpwin.h"
@


1.531
log
@Lots of stuff
@
text
@d1 4
@


1.401
log
@Started on improving the functionnames.
Added Aminet-mode, not 100% finished yet.
Reworked the prefs-window, not everything is finished.
Started using listbrowser v41-functions.
Added parsing of URL-like commandline.
@
text
@d160 1
a160 1
		(size_t)-1, remote_sort_mode, remote_sort_direction) == NULL) {
d359 1
a359 1
		remote_sort_mode, remote_sort_direction) == NULL) {
d582 1
a582 1
		    remote_sort_mode, remote_sort_direction) == NULL) {
d748 1
a748 1
		remote_sort_mode, remote_sort_direction) == NULL) {
@


1.200
log
@GETATTR-hit fixed.
@
text
@d3 11
d34 1
a34 2
    if (DEBUG)
      Printf("r_r_d: Opening remote_ls\n");
d46 1
a46 2
    if (DEBUG)
      Printf("r_r_d: ls opened %ld\n",din);
a47 2
	if (DEBUG)
	  Printf("r_r_d: reading ls-line\n");
a49 2
	if (DEBUG)
	  Printf("r_r_d: line read:'%s'\n",response_line);
d68 1
a68 1
if (DEBUG) Printf("%s\n",response_line);
a896 1
if (DEBUG)	Printf("unix_perms() didn't like %c",*s);
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d17 1
a17 1
	return(NULL);
d34 1
a34 1
	return (filelist);
d87 1
a87 1
	return (NULL);
d90 2
a91 2
      return (filelist);
    return (NULL);
d95 1
a95 1
#define	NULLCHECK() if (*curr == '\0') { *temp_non_unix = 1; return (1); }
d101 1
a101 1
	return (parse_line_ls(filelist, line));
d105 2
a106 2
	return (parse_line_pattern(filelist, unix_dir_pattern, line,
				   temp_non_unix));
d109 1
a109 1
	return (parse_line_vms(filelist, line, temp_non_unix));
d112 1
a112 1
	return (parse_line_dos(filelist, line, temp_non_unix));
d115 2
a116 2
	return (parse_line_pattern(filelist, other_dir_pattern, line,
				   temp_non_unix));
d119 1
a119 1
    return (1);
d157 1
a157 1
		return (1);
d159 1
a159 1
	return (0);
d205 1
a205 1
				return (0);
d207 1
a207 1
				return (1);
d339 1
a339 1
				return (1);
d350 1
a350 1
		return (0);
d356 1
a356 1
		return (1);
d358 1
a358 1
	return (0);
d437 1
a437 1
	    return (0);
d478 1
a478 1
      return (1);
d493 1
a493 1
      return (1);
d505 1
a505 1
      return (1);
d517 1
a517 1
      return (1);
@


0.700
log
@Fixed bug in initconn(). Now works with mlink!!!
CPS is now cleared after each upload.
@
text
@a8 1
#ifdef SOCKIO
a9 3
#else
    FILE	*din = NULL;
#endif
a31 1
#ifdef SOCKIO
a32 3
#else
    if (din == NULL) {
#endif
a69 1
#ifdef SOCKIO
a70 3
#else
		while (getc(din) != -1)
#endif
a72 1
#ifdef SOCKIO
a73 3
#else
		din = NULL;
#endif
a80 1
#ifdef SOCKIO
a81 3
#else
    if (din)
#endif
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d45 1
a45 1
      Printf("r_r_d: ls opened\n");
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d52 1
a52 1
	  Printf("r_r_d: line read\n");
d176 1
a176 1
		ShowErrorReq("Error building filelist");
d375 1
a375 1
		ShowErrorReq( "Error building filelist");
d598 1
a598 1
	ShowErrorReq("Error building filelist");
d764 1
a764 1
		ShowErrorReq("Error building filelist");
@


0.371
log
@Localized source.
@
text
@d779 1
a779 1

d833 1
a833 1
	/* make sure that we have a filename, at least */
d841 1
a841 1

@


0.284
log
@First RCS version.
@
text
@d20 1
a20 1
	ShowErrorReq("Not enough memory\n");
@
