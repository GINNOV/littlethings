/*
 * TimePrefs v1.0 - Time Preferences v1.0 ©1998 by Rod Schnell
 *
 *                             using ClassAct GUI.
 *
 *                  also requires classes/gadgets/calendar.gadget
 *
 *
 * What is it?    TimePrefs is a replacement for Sys:Prefs/Time, used to
 *                the system date and time.
 *
 *
 * Why write it?  To kill a few hours, try a few things and because we can
 *                allways use some more simple, yet usefull example sources
 *                using ClassAct. 
 *
 *   History
 *   ~~~~~~~
 *   21-Jun-98 - Released for comments on IRC.
 *
 *   31-Aug-98 - Fixed 128 byte memory leak... Forgot to FreeChooserLabels()
 *               Oops :)
 *             - Minor changes to scroller values, see source comments.
 *             - First public release.
 *
 */

/* system includes  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>
#include <graphics/gfxmacros.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>
#include <proto/wb.h>
#include <proto/icon.h>

#include <resources/battclock.h>
#include <proto/battclock.h>

/* ClassAct includes  */

#include <classact.h>

/* other gadget includes */

#include <gadgets/calendar.h>

char vers[] = "\0$VER: TimePrefs v1.0 "__AMIGADATE__"";
char scrtitle[] = "Time Preferences v1.0 ©1998 by Rod Schnell";

enum
{
	GID_MAIN=0,
	GID_YEAR,
	GID_MONTH,
	GID_CALENDAR,
	GID_HOURS,
	GID_MINUTES,
	GID_SECONDS,
	GID_TIME,
	GID_SAVE,
	GID_USE,
	GID_NETSYNC,
	GID_CANCEL,
	GID_LAST
};

enum
{
	WID_MAIN=0,
	WID_LAST
};

enum
{
	OID_MAIN=0,
	OID_LAST
};


/* function protos */

struct ClassLibrary *openclass (STRPTR name, ULONG version);
void maketime( char *buf, struct tm *thetime, struct ClockData *thedate);
void savetime(ULONG t);
void usetime(ULONG t);


int main(void)
{
  struct ClassLibrary *CalendarBase = NULL;

	struct MsgPort *AppPort;
	struct Window *windows[WID_LAST];

	Object *objects[OID_LAST];
	struct Gadget *gadgets[GID_LAST];

	struct List *monthlist = NULL;

	ULONG seconds, micros;
	struct ClockData thedate;

	UBYTE timebuffer[256];
	struct tm thetime;

	ULONG n;

	if (!(CalendarBase = openclass ("gadgets/calendar.gadget", 37)))
		return(30);

	/* make sure our classes opened... */

	if (!ButtonBase || !IntegerBase || !ChooserBase || !WindowBase || !LayoutBase)
	{
		CloseLibrary ((struct Library *) CalendarBase);
		return(30);
	}
	else if ( AppPort = CreateMsgPort() )
	{
		monthlist = ChooserLabels( "January","February","March","April","May","June", "July", "August", "September", "October", "November", "December", NULL );
 		CurrentTime( &seconds, &micros);
 		
 		/* need struct ClockData thedate for calendar.gadget */

		Amiga2Date( seconds,  &thedate );
		
		maketime(timebuffer, &thetime, &thedate);

		/* Create the window object.
		 */
		objects[OID_MAIN] = WindowObject,
			WA_ScreenTitle, scrtitle,
			WA_Title, "Time Preferences",
			WA_Activate, TRUE,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_SizeGadget, TRUE,
			WA_SizeBBottom,	TRUE,
			WINDOW_IconifyGadget, TRUE,
			WINDOW_IconTitle, "TimePrefs",
			WINDOW_AppPort, AppPort,
			WINDOW_Position, WPOS_CENTERMOUSE,
			WA_IDCMP, IDCMP_GADGETUP,
			WINDOW_ParentGroup, gadgets[GID_MAIN] = VGroupObject,
				LAYOUT_SpaceOuter, TRUE,
				LAYOUT_DeferLayout, TRUE,

				StartHGroup,

					LAYOUT_AddChild, gadgets[GID_YEAR] = IntegerObject,
						GA_ID, GID_YEAR,
						GA_RelVerify, TRUE,
						INTEGER_Arrows, TRUE,
						INTEGER_MaxChars, 4,
						INTEGER_Minimum, 1978,
						INTEGER_Maximum, 3000,
						INTEGER_Number, thedate.year,
					IntegerEnd,
					CHILD_WeightedHeight, 0,

					LAYOUT_AddChild, gadgets[GID_MONTH] = ChooserObject,
						GA_ID, GID_MONTH,
						GA_RelVerify, TRUE,
						CHOOSER_Labels, monthlist,
						CHOOSER_Selected, thedate.month-1, /* MONTH # - 1 */
					ChooserEnd,
					CHILD_WeightedHeight, 0,

				EndHGroup,
				CHILD_WeightedHeight, 0,

				LAYOUT_AddChild, gadgets[GID_CALENDAR] = CalendarObject,
					GA_ID, GID_CALENDAR,
					GA_RelVerify, TRUE,
					GA_Immediate,		TRUE,
					CALENDAR_ClockData, &thedate,
				CalendarEnd,

				StartVGroup, EvenSized,

					LAYOUT_AddChild, gadgets[GID_HOURS] = ScrollerObject,
						GA_ID, GID_HOURS,
						GA_RelVerify, TRUE,
						SCROLLER_Total, 24, /* 0-23 */
						SCROLLER_Arrows, TRUE,
						SCROLLER_ArrowDelta, (WORD)1,
						SCROLLER_Orientation, SORIENT_HORIZ,
						SCROLLER_Visible, 2,
						SCROLLER_Top, thedate.hour,
					ScrollerEnd,
					CHILD_Label, LabelObject, LABEL_Text, "Hours", LabelEnd,
					CHILD_WeightedHeight, 0,

					LAYOUT_AddChild, gadgets[GID_MINUTES] = ScrollerObject,
						GA_ID, GID_MINUTES,
						GA_RelVerify, TRUE,
						SCROLLER_Total, 60, /* 0-59 */
						SCROLLER_Arrows, TRUE,
						SCROLLER_ArrowDelta, (WORD)1,
						SCROLLER_Orientation, SORIENT_HORIZ,
						SCROLLER_Visible, 5,
						SCROLLER_Top, thedate.min,
					ScrollerEnd,
					CHILD_Label, LabelObject, LABEL_Text, "Minutes", LabelEnd,
					CHILD_WeightedHeight, 0,

					LAYOUT_AddChild, gadgets[GID_SECONDS] = ScrollerObject,
						GA_ID, GID_SECONDS,
						GA_RelVerify, TRUE,
						SCROLLER_Total, 60, /* 0-59 */
						SCROLLER_Arrows, TRUE,
						SCROLLER_ArrowDelta, (WORD)1,
						SCROLLER_Orientation, SORIENT_HORIZ,
						SCROLLER_Visible, 5,
						SCROLLER_Top, thedate.sec,
					ScrollerEnd,
					CHILD_Label, LabelObject, LABEL_Text, "Seconds", LabelEnd,
					CHILD_WeightedHeight, 0,

				EndVGroup,
				CHILD_WeightedHeight, 0,

				LAYOUT_AddChild, gadgets[GID_TIME] = ButtonObject,
					GA_ID, GID_TIME,
					GA_Text, timebuffer,
					GA_ReadOnly, TRUE,
					BUTTON_Justification, BCJ_CENTER,
				ButtonEnd,
				CHILD_WeightedHeight, 0,

				StartHGroup, EvenSized,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_SAVE,
						GA_RelVerify, TRUE,
						GA_Text,"_Save",
					ButtonEnd,
					CHILD_WeightedHeight, 0,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_USE,
						GA_RelVerify, TRUE,
						GA_Text,"_Use",
					ButtonEnd,
					CHILD_WeightedHeight, 0,
/*
					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_NETSYNC,
						GA_Disabled, TRUE,
						GA_RelVerify, TRUE,
						GA_Text,"_Net Sync",
					ButtonEnd,
					CHILD_WeightedHeight, 0,
*/
					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_CANCEL,
						GA_RelVerify, TRUE,
						GA_Text,"_Cancel",
					ButtonEnd,
					CHILD_WeightedHeight, 0,
				EndHGroup,
				CHILD_WeightedHeight, 0,

			EndGroup,
		EndWindow;

		if (objects[OID_MAIN])
		{
		 	/*  Object creation was sucessfull, open the window. */

			if (windows[WID_MAIN] = (struct Window *) CA_OpenWindow(objects[OID_MAIN]))
			{
				ULONG wait, signal, app = (1L << AppPort->mp_SigBit);
				ULONG done = FALSE;
				ULONG result;
				UWORD code;

			 	/* Obtain the window wait signal mask. */

				GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);

				while (!done)
				{
					wait = Wait( signal | SIGBREAKF_CTRL_C | app );

					if ( wait & SIGBREAKF_CTRL_C )
					{
						/* received CTRL-C, time to quit */

						done = TRUE;
					}
					else
					{
						while ( (result = CA_HandleInput(objects[OID_MAIN], &code) ) != WMHI_LASTMSG )
						{
							switch (result & WMHI_CLASSMASK)
							{
								case WMHI_CLOSEWINDOW:
									windows[WID_MAIN] = NULL;
									done = TRUE;
									break;

								case WMHI_GADGETUP:
									switch (result & WMHI_GADGETMASK)
									{
										case GID_YEAR:
											GetAttr(INTEGER_Number, gadgets[GID_YEAR], &n);
											thedate.year = n;
											break;

										case GID_MONTH:
											GetAttr(CHOOSER_Active, gadgets[GID_MONTH], &n);
											thedate.month = n+1;
											break;

										case GID_CALENDAR:
											thedate.mday = code;
											break;

										case GID_HOURS:
/* clicking scroller (not arrows) changes SCROLLER_Top by SCROLLER_Visible - 1 */
/* clicking arrows changes SCROLLER_Top by the value of SCROLLER_ArrowDelta    */
											thedate.hour = code;
											break;

										case GID_MINUTES:
											thedate.min = code;
											break;

										case GID_SECONDS:
											thedate.sec = code;
											break;

										case GID_SAVE:
											savetime( Date2Amiga( &thedate ) );
											done = TRUE;
											break;

										case GID_USE:
											usetime( Date2Amiga( &thedate ) );
											done = TRUE;
											break;

										case GID_NETSYNC:
											done = TRUE;
											break;

										case GID_CANCEL:
											done = TRUE;
											break;
										
										default:
											break;
									}
									switch (result & WMHI_GADGETMASK)
									{
										/* refresh calendar and date/time as necessary */

										case GID_SAVE:
										case GID_USE:
										case GID_NETSYNC:
										case GID_CANCEL:
											/* Do nothing */
											break;

										case GID_YEAR:
										case GID_MONTH:
											SetGadgetAttrs(	gadgets[GID_CALENDAR], windows[WID_MAIN], NULL,
																			CALENDAR_ClockData, &thedate,
																			TAG_DONE);
											RefreshGList( gadgets[GID_CALENDAR], windows[WID_MAIN], NULL, 1 );

										/* Fall through and update time string too */

										default:
											maketime(timebuffer, &thetime, &thedate);
											SetGadgetAttrs(	gadgets[GID_TIME], windows[WID_MAIN], NULL,
																			GA_Text, timebuffer,
																			TAG_DONE);
											RefreshGList( gadgets[GID_TIME], windows[WID_MAIN], NULL, 1 );
											break;
									}
									break;

								case WMHI_ICONIFY:
									CA_Iconify(objects[OID_MAIN]);
									windows[WID_MAIN] = NULL;
									break;

								case WMHI_UNICONIFY:
									windows[WID_MAIN] = (struct Window *) CA_OpenWindow(objects[OID_MAIN]);

									if (windows[WID_MAIN])
									{
										GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);
									}
									else
									{
										done = TRUE;	// error re-opening window!
									}
								 	break;
							}
						}
					}
				}
			}

			/* Disposing of the window object will also close the window if it is
			 * already opened, and it will dispose of the layout object attached to it.
			 */
			DisposeObject(objects[OID_MAIN]);
		}

		if( monthlist) FreeChooserLabels( monthlist );
		DeleteMsgPort(AppPort);
	}
	if( CalendarBase ) CloseLibrary ((struct Library *) CalendarBase);

	return(0);
}


/* Try opening the class library from a number of common places */

struct ClassLibrary *openclass (STRPTR name, ULONG version)
{
	struct Library *retval;
	UBYTE buffer[256];

	if ((retval = OpenLibrary (name, version)) == NULL)
	{
		sprintf (buffer, ":classes/%s", name);
		if ((retval = OpenLibrary (buffer, version)) == NULL)
		{
			sprintf (buffer, "classes/%s", name);
			retval = OpenLibrary (buffer, version);
		}
	}
	return (struct ClassLibrary *) retval;
}


/* convert struct ClockData into struct tm and format string */

void maketime( char *buf, struct tm *thetime, struct ClockData *thedate){
	thetime->tm_sec  = thedate->sec;
	thetime->tm_min  = thedate->min;
	thetime->tm_hour = thedate->hour;
	thetime->tm_mday = thedate->mday;
	thetime->tm_mon  = thedate->month-1;
	thetime->tm_year = thedate->year-1900;
	thetime->tm_wday = thedate->wday;

	strftime(buf, 255, "%c", thetime);
}


/* Use time/date and save it to the battery backed clock too */

void savetime(ULONG t){
	struct Library *BattClockBase;

	if (BattClockBase= OpenResource(BATTCLOCKNAME))
	{
		WriteBattClock(t);
	}
	usetime( t );
}


/* Use time/date, but do not save to battery backed clock */

void usetime(ULONG t){
	struct timerequest *TimerIO;
	struct MsgPort *TimerMP;

	LONG error;

	if (TimerMP = CreatePort(0,0))
	{
		if (TimerIO = (struct timerequest *) CreateExtIO(TimerMP,sizeof(struct timerequest)) )
		{
			/* Open with UNIT_VBLANK, but any unit can be used */

			if (!(error=OpenDevice(TIMERNAME,UNIT_VBLANK,(struct IORequest *)TimerIO,0L)))
			{
				TimerIO->tr_time.tv_micro = 0;
				TimerIO->tr_time.tv_secs = t;

				/* Issue the command, wait for it to finish, then get the reply */

				TimerIO->tr_node.io_Command = TR_SETSYSTIME;
				DoIO((struct IORequest *) TimerIO);
				CloseDevice((struct IORequest *) TimerIO);
			}
			DeleteExtIO((struct IORequest *)TimerIO);
		}
		DeletePort(TimerMP);
	}
}

