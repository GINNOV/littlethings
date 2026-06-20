/*
 * DATE/TIME FUNCTIONS:
 *
 *	To use the functions in this section, you must include "TIME.H"
 *	in your source file.
 */

#include <stdio.h>
#include <time.h>
#include	<exec/types.h>
#include	<exec/lists.h>
#include	<devices/timer.h>

static struct tm	the_time;

static char		timebuf[26] =
			"Day Mon dd hh:mm:ss yyyy\n";
static char		*day[] =
			{"", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
static char		*month[] =
			{"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
			"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

long julian_date(time)
	register struct tm *time;
/*
 *	Number of days since the base date of the Julian calendar.
 */
	{
	register long c, y, m, d;

	y = time->tm_year + 1900;	/* year - 1900 */
	m = time->tm_mon;		/* month, 1..12 */
	d = time->tm_mday;		/* day, 1..31 */
	if(m > 2)
		m -= 3L;
	else
		{
		m += 9L;
		y -= 1L;
		}
	c = y / 100L;
	y %= 100L;
	return(	((146097L * c) >> 2) +
		((1461L * y) >> 2) +
		(((153L * m) + 2) / 5) +
		d +
		1721119L );
	}

static char *notimer = "Warning: can't open timer device\n";
#define	MSGSIZE 33L
typedef struct MsgPort	MSG;

time_t time(rawtime)
	register long *rawtime;
/*
 *	Get the current system clock date/time value.  Under many systems,
 *	this function returns the number of seconds since 00:00:00 GMT on
 *	Jan 1, 1970.  This implementation returns an encoded date/time
 *	value instead.  Therefore any programs which depend on this value
 *	being a number of seconds will not work properly.  However, other
 *	functions in this section which make use of the raw time value
 *	returned by time() are implemented to be compatible with this
 *	encoding, and will work properly.  In addition to returning the
 *	raw time value, if the <rawtime> pointer in not NULL, the value
 *	is stored in the long <rawtime> points to.
 *
 *	Note: Amigatime is # seconds since midnight, Jan 1st, 1978.
 */
{
	extern MSG *CreatePort();
	extern long Output(), OpenDevice();
	register time_t t;
	struct timerequest tr;


	if (OpenDevice( TIMERNAME, UNIT_VBLANK, &tr, 0L) ){
		Write( Output(), notimer, MSGSIZE );
		return 0;
	}

	tr.tr_node.io_Message.mn_ReplyPort = CreatePort(0L, 0L);
	tr.tr_node.io_Command = TR_GETSYSTIME;
	DoIO(&tr);
	t = tr.tr_time.tv_secs + (tr.tr_time.tv_micro + 500000) / 1000000;
	CloseDevice(&tr);
	DeletePort(tr.tr_node.io_Message.mn_ReplyPort);

	if(rawtime)
		*rawtime = t;
	return(t);
}

struct tm *gmtime()
/*
 *	Can't determine Greenwich Mean Time, so return NULL
 *	as specified by ANSI standard.
 */
	{
	return(NULL);
	}

#define SECPERDAY	(24L*60L*60L)
#define SECPERHR	(60L*60L)
#define SECPERMIN	(60L)
struct tm *localtime(rawtime)
	time_t *rawtime;
/*
 *	Convert <rawtime> to fill time structure fields.  A pointer to an
 *	internal structure is returned.  Refer to "TIME.H" for the values
 *	of the various structure fields.
 *
 *	This routine is adapted from Tomas Rokicki's exellent example,
 *	"ShowDate.c" - Jeff.
 */
	{
	register time_t n, y, m;
	register time_t time;
	register struct tm *t;

	time = *rawtime;
	t = &the_time;

/*
 *   Set $n$ to the number of days since Amiga day -671, which is
 *   March 1, 1976.  It's easier to figure years starting in March,
 *   since then the lengths of the months are 31, 30, 31, 30, 31,
 *   31, 30, 31, 30, 31, 31, 28.  This is almost linear.
 */
   	n = time / SECPERDAY + 671;
/*
 *   The easiest is the weekday.  This is simply the number of days
 *   modulo 7, corrected for the start date.  March 1, 1976 was a
 *   Monday, so we add 1 to get back to a Sunday, take the modulo,
 *   and add one to start our days on Sunday.
 */
	t->tm_wday = (n + 1) % 7 + 1 ;
/*
 *   There are exactly 1461 days every four years, until 2100, which
 *   is the first year divisible by 4 that is not a leap year AA
 *   (After Amiga.)  This gives the years lengths of 365 (1976),
 *   365 (1977), 365 (1978), and 366 (1979).  Note that this is
 *   correct because we start our years in March, so 1979 is the
 *   leap year.
 */
	y = (4 * n + 3) / 1461 ;
/*
 *   We now subtract off the years (see them melt off her face.)
 *   We use a long constant for 16-bit systems.  Again we use the
 *   fact that the leap year is the fourth year, not the first.
 */
	n -= 1461L * y / 4 ;
	t->tm_yday = n + 60;
/*
 *   Now we can adjust the year to the proper value by adding
 *   1976.
 */
	y += 76 ;
/*
 *   We calculate the month.  Since we start in March, the length
 *   of the months are always 30 or 31, except for the last month,
 *   which is shorter.  This is fortunate, as it allows us to use
 *   a simple mathematical formula for the month.  The lengths of
 *   the months are (31, 30, 31, 30, 31), repeated three times and
 *   the end lopped off.  So, our slope is 153/5.  An intercept of
 *   2 gives us the 31 and 30 lengths.
 */
	m = (5 * n + 2) / 153 ;
/*
 *   And now we subtract off the months.  Oh, yeah, we add 1 because
 *   the first day of each month is the first, not the zeroth.
 */
   	t->tm_mday = n - (153 * m + 2) / 5 + 1 ;
/*
 *   Now we convert from March-based years back to January-based
 *   years.  We add 2 for this shift, and another 1 to give us
 *   January = 1 through December = 12.
 */
	m += 3 ;
/*
 *   And, if we've gone over 12, we increment the year.
 */
	if (m > 12) {
		y++ ;
		m -= 12 ;
	}

	t->tm_year = y;
	t->tm_mon  = m;

/*
 * Guess I'll have to figure out the rest myself.  Thanks, Tomas.
 */

	time %= SECPERDAY;	/* # seconds since midnight today */
	n = time / SECPERHR;	/* hours since midnight */	
	t->tm_hour = n;

	time -= n * SECPERHR;	
	n = time / SECPERMIN;
	t->tm_min = n;

	time -= n * SECPERMIN;
	t->tm_sec = time;

	t->tm_isdst = (-1);
	return(t);
	}

char *asctime(time)
	register struct tm *time;
/*
 *	Convert <time> structure value to a string.  The same format, and
 *	the same internal buffer, as for ctime() is used for this function.
 */
	{
	sprintf(timebuf, "%.3s %.3s%3d %02d:%02d:%02d %04d\n",
		day[time->tm_wday], month[time->tm_mon], time->tm_mday,
		time->tm_hour, time->tm_min, time->tm_sec, 1900+time->tm_year);
	return(timebuf);
	}

char *ctime(rawtime)
	time_t *rawtime;
/*
 *	Convert <rawtime> to a string.  A 26 character fixed field string
 *	is created from the raw time value.  The following is an example
 *	of what this string might look like:
 *		"Wed Jul 08 18:43:07 1987\n\0"
 *	A 24-hour clock is used, and due to a limitation in the ST system
 *	clock value, only a resolution of 2 seconds is possible.  A pointer
 *	to the formatted string, which is held in an internal buffer, is
 *	returned.
 */
	{
	char *asctime();
	struct tm *localtime();

	return(asctime(localtime(rawtime)));
	}
