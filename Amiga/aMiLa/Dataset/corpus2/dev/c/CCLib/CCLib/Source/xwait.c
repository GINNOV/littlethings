
/********** AMIGA STUFF ***************/
#define ANSIC
short _math = 0;
#include "functions.h"
/**************************************/


#include "string.h"
#include "time.h"
#include "stdlib.h"
#include "stdio.h"
#include "ctype.h"

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    XWAIT							   |
 | Purpose: waits until a specified time, or a key is pressed. If ^C  is   |
 |	    pressed a code of 20 is returned, if a key is pressed a code of|
 |	    10 is returned, if the time arrives to stop waiting then a 0   |
 |	    is returned. If an error occurs 30 is returned.		   |
 |									   |
 |	    The command line arguments are given as a time and a date.	   |
 |	    WAIT will stop waiting when the time is greater than or	   |
 |	    equal to that given.					   |
 |									   |
 |	    Syntax: XWAIT <time> <date> 				   |
 |									   |
 |	    Time is in HH:MM:SS 					   |
 |	    Date is in MM:DD:YY or TOMORROW,SUN,MON,TUE,WED,THU,FRI,SAT    |
 |				      TODAY is assumed			   |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/

#define CTRLC_EXIT 20
#define CONTINUE_EXIT 10
#define ERROR_EXIT 30
#define TIMEOUT_EXIT 0
#define SYNTAX "\nSyntax:\n\
   XWAIT HH:MM[:SS] [[MM-DD-YY] TOMORROW,SUN,MON,TUE,WED,THU,FRI,SAT]"
#define BANNER "\nXWAIT V1.0 By Robert W. Albrecht\n"
#define SLEEP_SECONDS 1
static char *help =
" +----------------------------------------------------------------+\n"
" | Waits until a specified time, or a key is pressed. If ^C is    |\n"
" | pressed a code of 20 is returned, if a key is pressed a code of|\n"
" | 10 is returned, if the time arrives to stop waiting then a 0   |\n"
" | is returned. If an error occurs 30 is returned.                |\n"
" |                                                                |\n"
" | The command line arguments are given as a time and a date.     |\n"
" | XWAIT will stop waiting when the time is greater than or       |\n"
" | equal to that given.                                           |\n"
" +----------------------------------------------------------------+\n";

typedef struct
{
int hour, minute, second;
int month, day, year;
} SetTime;

/************* SYSTEM DEPENDENT FUNCTIONS (NON-PORATBLE AMIGA) ************/

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    sleep_time							   |
 | Purpose: puts the process to sleep for a prescribed period of time	   |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
static void sleep_time(int sec)
{
Delay(50L*((long)sec));
}


/*-------------------------------------------------------------------------+
 |									   |
 | Name:    check_keyboard						   |
 | Purpose: checks the keyboard for input, returns exit code if key pressed|
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
static int check_keyboard(void)
{
int rv = 0;
#define SIGBREAK \
   (SIGBREAKF_CTRL_C|SIGBREAKF_CTRL_D|SIGBREAKF_CTRL_E|SIGBREAKF_CTRL_F)

long signals;

if( (signals = SetSignal(0L,0L)) & SIGBREAK )
   {
   SetSignal(0L,(long)(signals & SIGBREAK));
   if( signals & SIGBREAKF_CTRL_C )
      rv = CTRLC_EXIT;
   else
      rv = CONTINUE_EXIT;
   }
return(rv);
}

/********************* END OF SYSTEM DEPENDENT FUNCTIONS *****************/

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    month_days							   |
 | Purpose: returns the number of days in a month based on the year	   |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
static int month_days(int month, int year)
{
int days;
static short mo_days[12] =
{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

/* month starts at 1 */
days = mo_days[month-1];
if( month == 1 && !(year & 3) )
      days++;
return(days);
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    get_stime							   |
 | Purpose: translates a string into a numeric date and time		   |
 |	    0 is returned if the input is valid 			   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
int get_stime(SetTime *settime, char *time_ptr)
{
int rv = 1;
char *ptr;


if( ptr = strchr(time_ptr,':') )
   {
   *ptr++ = '\0';

   settime->hour = atoi(time_ptr);  /* hours */

   if( settime->hour <= 23 && settime->hour >= 0 )
      {
      time_ptr = ptr;
      if( ptr = strchr(time_ptr,':') )
	 *ptr++ = '\0';

      settime->minute = atoi(time_ptr);  /* minutes */

      if( settime->minute <= 59 && settime->minute >= 0 )
	 {
	 time_ptr = ptr;

	 if( isdigit(*time_ptr) )
	    {
	    settime->second = atoi(time_ptr);  /* seconds (optional) */
	    if( settime->second < 0 || settime->second > 59 )
	       settime->second = 0;
	    }
	 else
	    settime->second = 0;

	 rv = 0;
	 }
      }
   }

return(rv);
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    get_keyword 						   |
 | Purpose: returnd a code >= 0 if the date is one of the date keywords    |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/

static int get_keyword(char *date_ptr)
{
int i, rv;
static char *keywords[] =
   {"TOMORROW","SUN","MON","TUE","WED","THU","FRI","SAT",};
strupr(date_ptr);
for( i = 0, rv = -1; i < sizeof(keywords)/sizeof(char *); i++)
   {
   if( !strcmp(keywords[i],date_ptr) )
      {
      rv = i;
      break;
      }
   }
return(rv);
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    add_days							   |
 | Purpose: adds n days to a settime structure, n less than days in month  |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/

static void add_days(SetTime *settime, struct tm *now, int n)
{
int mdays;

/* set up todays date */
settime->month = now->tm_mon + 1;
settime->day   = now->tm_mday;
settime->year  = now->tm_year;

mdays = month_days(settime->month, settime->year);

if( (settime->day + n) > mdays )
   {
   n -= (mdays - settime->day);

   settime->day = n;

   if( (settime->month + 1) <= 12 )
      settime->month++;
   else
      {
      settime->year++;
      settime->month = 1;
      }
   }
else
   settime->day += n;
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    get_settime 						   |
 | Purpose: translates two strings into numeric date and time		   |
 |	    0 is returned if the input is valid 			   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
static int get_settime(SetTime *settime, char *time_ptr, char *date_ptr)
{
int rv = 1, days, code;
time_t tim;
struct tm *tms_ptr;
char *ptr;

if( !get_stime(settime,time_ptr) )
   {
   if( (tim = time(NULL)) != -1 )
      {
      tms_ptr = localtime(&tim);

      if( date_ptr )
	 {
	 code = get_keyword(date_ptr);
	 switch( code )
	    {
	    case 0:
	       add_days(settime,tms_ptr,1);
	       rv = 0;
	    break;

	    case 1: case 2: case 3: case 4: case 5: case 6: case 7:
	       if( (tms_ptr->tm_wday + 1) < code )
		  days =  code - (tms_ptr->tm_wday + 1);
	       else
		  days = 7 - (tms_ptr->tm_wday + 1) + code;
	       add_days(settime,tms_ptr,days);
	       rv = 0;
	    break;

	    case -1:
	       if( ptr = strchr(date_ptr,'-') )
		  {
		  *ptr++ = '\0';

		  settime->month = atoi(date_ptr);

		  if( settime->month >= 1 && settime->month <= 12 )
		     {
		     date_ptr = ptr;
		     if( ptr = strchr(date_ptr,'-') )
			{
			*ptr++ = '\0';

			settime->day = atoi(date_ptr);

			date_ptr = ptr;

			settime->year = atoi(date_ptr);
			settime->year %= 100;

			if( settime->day >= 1 && settime->day <=
			    month_days(settime->month,settime->year) )
			   rv = 0;
			}
		     }
		  }
	    break;
	    }
	 }
      else
	 { /* today */
	 settime->month = tms_ptr->tm_mon + 1;
	 settime->day	= tms_ptr->tm_mday;
	 settime->year	= tms_ptr->tm_year;
	 rv = 0;
	 }
      }
   }
return(rv);
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    compare_time						   |
 | Purpose: compares the time in the SetTime to struct tm from localtime   |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
static int compare_time(time_t *tim, SetTime *settime)
{
int rv;
struct tm *tm_ptr;

tm_ptr = localtime(tim);

if( !(rv = settime->year - tm_ptr->tm_year) )
   if( !(rv = settime->month - (tm_ptr->tm_mon + 1)) )
      if( !(rv = settime->day - tm_ptr->tm_mday) )
	 if( !(rv = settime->hour - tm_ptr->tm_hour) )
	    if( !(rv = settime->minute - tm_ptr->tm_min) )
	       rv = settime->second - tm_ptr->tm_sec;
return(rv);
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    wait_time							   |
 | Purpose: waits for a time to pass					   |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
static int wait_time(SetTime *settime)
{
time_t tim;
int waiting;
int rv;

for(waiting = TRUE; waiting ; )
   {
   if( (tim = time(NULL)) != -1 )
      {
      if( compare_time(&tim,settime) <= 0 )
	 {
	 rv = TIMEOUT_EXIT;
	 waiting = FALSE;
	 }
      else
	 if( !(rv = check_keyboard()) )
	    sleep_time(SLEEP_SECONDS);
	 else
	    waiting = FALSE;
      }
   else
      {
      rv = ERROR_EXIT;
      waiting = FALSE;
      }
   }
printf("Done\n");
return(rv);
}

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    main							   |
 | Purpose: program entry point 					   |
 |									   |
 | Author:  RWA 				   Date: 9/90		   |
 +-------------------------------------------------------------------------*/
void main(int argc, char *argv[])
{
int exit_code;
char *date_ptr, *time_ptr;
char *exit_msg = NULL;
SetTime settime;

if( argc > 0 )
   printf(BANNER);

if( argc >= 2 )
   {
   time_ptr = argv[1];
   if( argc == 3 )
      date_ptr = argv[2];
   else if( argc > 3 )
      {
      exit_msg = SYNTAX;
      exit_code = ERROR_EXIT;
      }
   else
      date_ptr = NULL;

   if( !get_settime(&settime,time_ptr,date_ptr) )
      {

      printf("Waiting for %02d-%02d-%02d, %02d:%02d:%02d\n",
	 settime.month,settime.day,settime.year,
	 settime.hour,settime.minute,settime.second);
      printf("   Press ^C to abort, another key to continue...");
      fflush(stdout);
      exit_code = wait_time(&settime);
      }
   else
      {
      exit_msg = SYNTAX;
      exit_code = ERROR_EXIT;
      }

   }
else if( argc )
   {
   exit_msg = SYNTAX;
   exit_code = ERROR_EXIT;
   if( argc == 1 )
      printf(help);
   }

if( exit_msg )
   printf("%s\n",exit_msg);
exit(exit_code);
}


