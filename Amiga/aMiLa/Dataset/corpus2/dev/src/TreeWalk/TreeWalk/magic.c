/*
 * magic - code for dealing with magic strings. All functions take a
 *	null terminated string, and  return either the code to be used
 *	in place of the string, or -1 indicating that things failed.
 *	If -1 is a valid value, then we got problems...
 *
 *	Copyright (C) 1989  Mike Meyer
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 1, or any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <exec/types.h>
#include <libraries/dos.h>
#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <dos.h>
#include "errors.h"

static short monthdays[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30} ;

long
date(char *in) {
	static int	today = 0, now, weekday ;	/* Do now only once */
	short		month, dom, year, hour ;	/* Scratch */
	long		outday, outminute ;
	char		day[FMSIZE], *time ;
	

	if (!today) {
		getclk((unsigned char *) &day) ;
		weekday = day[0] ;
		now = day[4] * 60 + day[5] ;
		year = 2 + day[1] ;	/* Convert to datestamp base of '78 */
		month = day[2] ;
		today = day[3] - 1 ;	/* Days count from 0, not 1 */
		if ((year + 2) % 4 == 0 && month > 2) today += 1 ;
		while (--month)
			today += monthdays[month - 1] ;
		today += year * 365 + (year + 1) / 4 ;
		}
	outday = today ;

	time = stpblk(stptok(stpblk(in), day, FMSIZE, " \t")) ;

	if (isdigit(*day)) {	/* Hard date, use it that way */
		if (strchr(day, ':')) /* No, it's not a date, it's a time */
			time = day ;
		else if (sscanf(day, "%d/%d/%d", &month, &dom, &year) != 3)
				return -1 ;	/* Bleah */
		else if (year > 99) return -1 ;
		else {
			year -= 78 ;
			outday = dom - 1 + year * 365 + (year + 1) / 4 ;
			if ((year + 2) % 4 == 0 && month > 2) outday += 1 ;
			while (--month)
				outday += monthdays[month - 1] ;
			}
		}
	else if (!stricmp(day, "noon")) time = day ;
	else if (!stricmp(day, "yesterday")) outday -= 1 ;
	else if (stricmp(day, "today")) {	/* Today means no change */
		/* These are ... the days of the week */
		if (!stricmp(day, "sunday")) dom = 0 ;
		else if (!stricmp(day, "monday")) dom = 1 ;
		else if (!stricmp(day, "tuesday")) dom = 2 ;
		else if (!stricmp(day, "wednesday")) dom = 3 ;
		else if (!stricmp(day, "thursday")) dom = 4 ;
		else if (!stricmp(day, "friday")) dom = 5 ;
		else if (!stricmp(day, "saturday")) dom = 6 ;
		else return -1 ;

		outday -= (dom == weekday) ? 7 : abs(dom - weekday) ;
		}

	if (!*time) return outday * 24 * 60 ;	/* Well, we dont do time */
	if (!stricmp(time, "noon")) outminute = 12 * 60 ;
	else if (!isdigit(*time)
	     || sscanf(time, "%d:%d", &hour, &outminute) != 2) return -1 ;
	else outminute += hour * 60 ;

	if (outminute >= now && outday == today) outday -= 1 ;

	return outday * 24 * 60 + outminute ;
	}

/* HIDDEN isn't real, but we want to have a way to specify it */
#define FIBB_HIDDEN	7
#define FIBF_HIDDEN	(1<<FIBB_HIDDEN)

long
prot(char *in) {
	long	out = 0 ;

	while (*in)
		switch (*in++) {
		    case 'd':	out |= FIBF_DELETE ;
			break ;
		    case 'e':	out |= FIBF_EXECUTE ;
			break ;
		    case 'w':	out |= FIBF_WRITE ;
			break ;
		    case 'r':	out |= FIBF_READ ;
			break ;
		    case 'a':	out |= FIBF_ARCHIVE ;
			break ;
		    case 'p':	out |= FIBF_PURE ;
			break ;
		    case 's':	out |= FIBF_SCRIPT ;
			break ;
		    case 'h':	out |= FIBF_HIDDEN ;
			break ;
		    default: return -1 ;
		    }
	return out ;
	}
