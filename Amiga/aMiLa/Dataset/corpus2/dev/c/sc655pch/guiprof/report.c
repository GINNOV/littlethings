/*-------------------------------------------------------------------*/
/* Copyright (c) 1992-1995 SAS Institute Inc., Cary NC               */
/*                                                                   */
/* AUTHORS:    Doug Walker and Lisa Dixon                            */
/*                                                                     */
/* 1. The external array GPInfo contains all the information needed    */
/*    to put up the histogram.  GPCur is the number of elements in     */
/*    the GPInfo array.  Do not modify GPInfo or GPCur.                */
/*    Look in the file guiprofpriv.h for the definition of the         */
/*    structure pointed to by GPInfo.                                  */
/*                                                                     */
/* 2. The external variable report_type tells you what kind of report  */
/*    to produce:                                                      */
/*       Percentage - percentage of total time                         */
/*       Count      - Count of number of calls                         */
/*       Time(incl) - Time in function including subroutines           */
/*       Time(excl) - Time in function excluding subroutines           */
/*                                                                     */
/* 4. The function InitReport will be run at GUIPROF startup.          */
/*    _STDReport will run after it exits.  Use these functions for     */
/*    initialization and cleanup.                                      */
/*-------------------------------------------------------------------*/

#include <assert.h>
#include <string.h>
#include <ctype.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/gadtools.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include "guiprofpriv.h"
#include "SMBar.h" /* Controls the scroll bar */

#define GADP(x) ((struct Gadget *)(x))

/* These two defines calculate the position and size of the scroll bar */
/* based on the external variables GPCur and NumOnScreen.  GPCur is the*/
/* total number of functions we have data on, and NumOnScreen is the   */
/* number that will fit on the screen at once.  VBMAXPOS, defined in   */
/* "smbar.h", is the maximum range of the scroll bar.                  */
#define VBPOS(x) (GPCur-NumOnScreen ? (ULONG)VBMAXPOS*(x)/(GPCur-NumOnScreen) : 0)
#define VBSIZ(x) (GPCur ? VBMAXPOS*(x)/GPCur : VBMAXPOS)

#if 0
#define RBUG(x) printf x ;
#else
#define RBUG(x) ;
#endif

static void KillCaches(void); /* Forces a complete redraw */
static void SetNums(void);    /* Calculates range and sets up NumOnScreen */
static void InstallMenus(struct VisualInfo *vi); /* install menus */

/* report_type contains a RPT_ value as defined in guiprofpriv.h */
/* oldreport_type contains the value of report_type as of the  */
/* last time Report() was called to generate a report.  This is*/
/* used to determine how much of the information on the screen */
/* we can reuse.                                               */
int report_type;
static int oldreport_type = -1;

/* oldmaxval 'remembers' the maximum range of the last time    */
/* Report() was called.  If the maximum range has changed, we  */
/* need to redraw just about everything.                       */
static ULONG oldmaxval;

/* oldfullnames 'remembers' the old value of the 'fullnames'   */
/* option.                                                     */
static int oldfullnames = -1;

/* These two are the array index of the first function to   */
/* appear on screen, and the number of entries that can fit */
/* on the screen, respectively.                             */
static int FirstOnScreen, NumOnScreen;

/* This variable is nonzero if the user is currently holding down the */
/* mouse button on the scroll bar.  If this is the case, we don't     */
/* update the scroll bar, since this would jerk the knob out from the */
/* user's control.                                                    */
static int bardown;

/* These are the IDCMP flags we use when we open the window. */
#define IDCMPFLAGS (IDCMP_CLOSEWINDOW   | IDCMP_MENUPICK   | \
                    IDCMP_REFRESHWINDOW | IDCMP_INTUITICKS | \
                    IDCMP_GADGETDOWN    | IDCMP_GADGETUP   | \
                    IDCMP_RAWKEY        | IDCMP_NEWSIZE)

/* Several #defines follow which define the edges of the drawing area */
/* and its various subareas.                                          */

/* These four define the sizes of the margins on the various sides of */
/* drawing area.  They use 'win', which points to the display window. */
#define LEFT_MARGIN (win->BorderLeft+5)   
#define RIGHT_MARGIN (win->BorderRight+5)
#define TOP_MARGIN (win->BorderTop+5)
#define BOTTOM_MARGIN (win->BorderBottom+5)

/* TEXT_LEFT is the leftmost edge of the function label area          */
#define TEXT_LEFT LEFT_MARGIN

/* These four define the four boundaries of the histogram area        */
/* They use the externs 'win', 'hist_bottom', and 'text_width', all   */
/* which are defined later in this file.                              */
#define HIST_LEFT (TEXT_LEFT+text_width+3)
#define HIST_RIGHT (win->Width - RIGHT_MARGIN)
#define HIST_BOTTOM hist_bottom
#define HIST_TOP TOP_MARGIN

/* This one defines the width of the histogram area.  labellen is an  */
/* extern which is the number of pixels to reserve for the histogram  */
/* label.                                                             */
#define HIST_WIDTH (HIST_RIGHT - HIST_LEFT - labellen)

/* MAX_TEXT_WIDTH is the biggest the text area will grow to.  MIN is  */
/* the smallest it will ever be, and its initial size.                */
#define MAX_TEXT_WIDTH 200
#define MIN_TEXT_WIDTH  80

/* labellen is the size of the biggest histogram label.  We need to save */
/* room on the right of the histogram for these labels.                  */
ULONG labellen;

/* text_width is the current size, in pixels, of the text area (used to  */
/* label the histogram.)  old_text_width stores the text_width value as  */
/* of the previous call to Report(), so we can detect changes and force  */
/* a redraw.                                                             */
USHORT text_width = MIN_TEXT_WIDTH;
USHORT old_text_width;

/* TICK_HEIGHT is the height (in pixels) of the tick marks on the axis.  */
#define TICK_HEIGHT 8  // Needs to be divisible by 2

/* axis_top is the position of the top of the axis.  hist_bottom is the */
/* bottom position of the histogram.  They are closely related: if we   */
/* are in fact drawing an axis, they are 5 pixels apart.  If we are not,*/
/* they are the same value.                                             */
static int axis_top;
static int hist_bottom;

/* The following #define computes x as a percentage of m, returning */
/* the results as an integer and performing rounding.  Everything is*/
/* done using integer math.                                         */
#define PCTOF(x,m) ((m) == 0 ? 0 : (((x)*1000+5)/((m)*10)))

/* NOTE: Keep the #defines in this array up to date wrt the contents. */
/*       They are used to update the checkmarks before creating the   */
/*       menus, in InstallMenus() below.                               */
static struct NewMenu mynewmenu[] =
      {
         {NM_TITLE, "Draw Histogram",   0 , 0, 0, 0,},
         #define DRAW_TYPE_INDEX 1
         { NM_ITEM, "Percent",          "1",  CHECKIT, ~1, 0,},
         { NM_ITEM, "Time (excl.)" ,    "2", CHECKIT, ~2, 0,},
         { NM_ITEM, "Time (incl.)" ,    "3", CHECKIT, ~4, 0,},
         { NM_ITEM, "Count" ,           "4", CHECKIT, ~8, 0,},
         { NM_ITEM, NM_BARLABEL,        0 , 0, 0, 0,},
         { NM_ITEM, "Quit...",         "Q", 0, 0, 0,},
         {NM_TITLE, "Options",          0 , 0, 0, 0,},
         #define SORT_INDEX 8
         { NM_ITEM, "Numeric Sort",    "N", CHECKIT, 2, 0,},
         { NM_ITEM, "Alphabetic Sort", "A", CHECKIT, 1, 0,},
         { NM_ITEM, NM_BARLABEL,        0 , 0, 0, 0,},
         #define DRAW_AXIS_INDEX 11
         { NM_ITEM, "Draw Axis",       "X", CHECKIT|MENUTOGGLE, 4, 0,},
         #define FULL_NAMES_INDEX 12
         { NM_ITEM, "Full Names",      "F", CHECKIT, 8, 0,},
         {  NM_END, NULL,               0 , 0, 0, 0,}, 
      };

static struct VBar       *VBar;      // Controls the scroll bar
static struct Window     *win;       // Our display window
static struct Menu       *menuStrip; // Our menus
static struct TextAttr   myTextAttr; // TextAttr for the font
static struct IntuiText  myIText;    // A convenient IntuiText struct
static int baseline;                 // Baseline of the font we're using

#define YSIZE    myTextAttr.ta_YSize // Size of a single histogram line

/* externs from the SAS/C library.  _WBenchMsg is a quick'n'easy way  */
/* to tell if we were invoked from WorkBench: it will be non-NULL if  */
/* we were.   __stdiowin[] is the CON: specification for the stdio    */
/* window, in case we need to give the user an error message.         */
extern struct WBStartup *_WBenchMsg;
extern char __stdiowin[];

/* InitReport() is an initialization routine.  It's called just after */
/* arguments are parsed, but before anything else is done.            */
int InitReport(void)
{
   BPTR fh;
   struct DrawInfo *drawinfo;
   APTR  visual_info;
   struct Screen     *screen;    // Our screen
   char *msg;

   /* Open window, attach menus and gadgets, then return. */
   /* the struct Window * has to be an external variable  */

   if (screen = LockPubScreen(NULL)) 
   {
      if (drawinfo = GetScreenDrawInfo(screen))
      {
         myIText.FrontPen = drawinfo->dri_Pens[TEXTPEN];
         myIText.BackPen  = drawinfo->dri_Pens[BACKGROUNDPEN];
         myIText.DrawMode           = JAM2;
         myIText.LeftEdge           = 0;
         myIText.TopEdge            = 0;
         myIText.ITextFont          = &myTextAttr;
         myIText.NextText           = NULL;

         myTextAttr.ta_Name  = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
         myTextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
         if(myTextAttr.ta_YSize <= 0) myTextAttr.ta_YSize = 8;
         myTextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
         myTextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;
         baseline = drawinfo->dri_Font->tf_Baseline;

         FreeScreenDrawInfo(screen,drawinfo);
      }
   }
   if (NULL != (win = OpenWindowTags(NULL,
                           WA_Width,        500,    
                           WA_Height,       400,    
                           WA_MinWidth,     400,    
                           WA_MinHeight,    150,
                           WA_MaxWidth,     -1,    
                           WA_MaxHeight,    -1,    
                           WA_Activate,     TRUE,
                           WA_CloseGadget,  TRUE,
                           WA_Title,        "GUIPROF: Waiting", 
                           WA_DragBar,      TRUE,
                           WA_DepthGadget,  TRUE,
                           WA_SizeGadget,   TRUE,
                           WA_PubScreen,    screen,
                           WA_SmartRefresh, TRUE,
                           WA_IDCMP,        IDCMPFLAGS,
                           TAG_END)))
   {
      /* Initialize the scrollbar and menus */
      if(VBar = VBInit(win))
      {
         VBUpdate(VBar, VBMAXPOS, 0);
         if(visual_info = GetVisualInfo(win->WScreen, TAG_END))
         {
            DoTitle(NULL);
            InstallMenus(visual_info);
            FreeVisualInfo(visual_info);
            SetNums();
            UnlockPubScreen(NULL,screen);
            return 0;
         }
      }
   }

   msg = "GUIPROF: Fatal error: can't initialize\n";

domsg:
   if(screen) UnlockPubScreen(NULL,screen);
   if((fh=Output()) == NULL)
      fh = Open(__stdiowin, MODE_NEWFILE);
   
   if(fh)
   {
      #define MSG(a,b) Write(a,b,strlen(b))
      MSG(fh, msg);
      if(_WBenchMsg != NULL) Delay(200);
      if(fh != Output()) Close(fh);
   }
   
   return 1;
}

/* Cleans up and closes down */
void CleanupWindowStuff(void)
{
   if(win)
   {
      if(menuStrip)
      {
         /* Kill and free the menus */
         ClearMenuStrip(win);
         FreeMenus(menuStrip);
         menuStrip = NULL;
      }
      /* Kill the scroll bar */
      if(VBar) VBTerm(VBar);

      /* Close the window */
      CloseWindow(win);
      win = NULL;
   }
}

/* Scroll the display up 'count' elements */
static void ScrollUp(int count)
{
   if(FirstOnScreen >= count) FirstOnScreen-=count;
   else FirstOnScreen = 0;
   if(!bardown) VBUpdate(VBar, VBSIZ(NumOnScreen), VBPOS(FirstOnScreen));
}

/* Scroll the display down 'count' elements */
static void ScrollDown(int count)
{
   FirstOnScreen += count;
   if(FirstOnScreen+NumOnScreen > GPCur)
      FirstOnScreen = GPCur - NumOnScreen;
   if(!bardown) VBUpdate(VBar, VBSIZ(NumOnScreen), VBPOS(FirstOnScreen));
}

/* Get and handle all pending Intuition messages */
/* If the 'wait' parameter is nonzero, we wait for the CLOSE message */
/* otherwise, we return as soon as we've done all pending messages.  */
/* The 'now' parameter tells us the current moment's index so we can */
/* compute time spent on the stack correctly; we just pass it through*/
/* to Report().                                                      */
/* Note that this routine is called from Report(), but it also calls */
/* Report() at times.                                                */
static void handle_window_events(int wait, sptime now)
{
   struct IntuiMessage *msg;
   int done;
   unsigned long pos;
   UWORD menuNumber;
   UWORD menuNum;
   UWORD itemNum;
   struct MenuItem *item;
   static int eattick;

   done = FALSE;
   while(!done)
   {
      while(!done && (msg=(struct IntuiMessage *)GetMsg(win->UserPort)))
      {
         switch (msg->Class)
         {
            case IDCMP_SIZEVERIFY:
               RBUG(("IDCMP_SIZEVERIFY\n"))
               break;

            case IDCMP_CLOSEWINDOW:
               RBUG(("IDCMP_CLOSEWINDOW\n"))
               /* They hit the close gadget.  Set 'broken' so we behave */
               /* like they hit CTRL-C if the program is still running. */
               done = TRUE;
               broken = TRUE;
               break;
            
            case IDCMP_RAWKEY:
               #define UP_ARROW   0x4c
               #define DOWN_ARROW 0x4d
               #define PAGE_UP    0x3f
               #define PAGE_DOWN  0x1f
               RBUG(("IDCMP_RAWKEY KeyCode 0x%02.2x\n", msg->Code))
               switch(msg->Code)
               {
                  case UP_ARROW:   ScrollUp(1);             break;
                  case DOWN_ARROW: ScrollDown(1);           break;
                  case PAGE_UP:    ScrollUp(NumOnScreen);   break;
                  case PAGE_DOWN:  ScrollDown(NumOnScreen); break;
               }
               break;
            
         case IDCMP_GADGETDOWN:
            if(VBSelected(VBar, VB_DOWN))
            {
               /* Down arrow on scroll bar */
               RBUG(("IDCMP_GADGETDOWN VB_DOWN\n"))
               ScrollDown(1);
               /* We set 'eattick' so that the next IntuiTick will not */
               /* result in the display changing if they continue to   */
               /* hold the button down.                                */
               eattick = 1;
            }
            else if(VBSelected(VBar, VB_UP))
            { 
               /* Up arrow on scroll bar */
               RBUG(("IDCMP_GADGETDOWN VB_UP\n"))
               ScrollUp(1);
               /* We set 'eattick' so that the next IntuiTick will not */
               /* result in the display changing if they continue to   */
               /* hold the button down.                                */
               eattick = 1;
            }  
            else 
            {
               if(VBSelected(VBar, VB_SLIDER))
               {
                  /* Diddling with scroll bar knob */
                  RBUG(("IDCMP_GADGETDOWN scroll bar\n"))
                  bardown = 1;
               }
               else if(GADP(msg->IAddress)->GadgetID == VB_SLIDER)
               {
                  /* Click on scroll bar box */
                  RBUG(("IDCMP_GADGETDOWN scroll bar box\n"))
               }
               else
                  break;

               /* Update our position wrt the scroll bar */
               pos = VBRead(VBar);
               FirstOnScreen = (int)((GPCur - NumOnScreen)*pos / VBMAXPOS);
               assert(FirstOnScreen < GPCur);
               assert(FirstOnScreen >= 0);
            }
            break;

         case IDCMP_GADGETUP:
            /* They let the bar up; resume setting it when things change */
            bardown = 0;
            break;

         case IDCMP_INTUITICKS:
            if(eattick) 
            {
               /* They pushed down on a scroll bar up or down gadget */
               /* recently; don't update wrt the scroll bar in this  */
               /* case since we just did it.                         */
               eattick = 0; 
               break;
            }
            //if up arrow gadget is selected and held down then scroll text up
            //in small increments
            if(VBSelected(VBar,VB_UP))
            {
               ScrollUp(1);
            }
            //else if down arrow gadget is selected and held down then scroll 
            //text down in small increments 
            else if(VBSelected(VBar,VB_DOWN))
            {
               ScrollDown(1);
            }
            else if(VBSelected(VBar, VB_SLIDER))
            {
               /* If the slider is selected, update the display wrt it */
               pos = VBRead(VBar);
               FirstOnScreen = (int)((GPCur - NumOnScreen)*pos / VBMAXPOS);
               assert(FirstOnScreen < GPCur);
               assert(FirstOnScreen >= 0);
            }
            break;

         case IDCMP_MENUPICK:
            RBUG(("IDCMP_MENUPICK\n"))
            menuNumber = msg->Code;
            while ((menuNumber != MENUNULL) && (!done))
            {
               item = ItemAddress(menuStrip, menuNumber);
               
               menuNum = MENUNUM(menuNumber);
               itemNum = ITEMNUM(menuNumber);
               //subNum  = SUBNUM(menuNumber);

               /* See "guiprofpriv.h" for menu item #defines */
               switch(menuNum)
               {
                  case MENU_HIST:
                     if(itemNum == HIST_QUIT)
                        done = TRUE;
                     else if(report_type != itemNum)
                     {
                        report_type = itemNum;
                        KillCaches();
                        Report(now);
                     }
                     break;

                  case MENU_OPT:
                     if(itemNum == OPT_AXIS)
                     {
                        axis = !axis;
                        SetNums();
                        KillCaches();
                        Report(now);
                     }
                     else if(itemNum == OPT_FULLNAME)
                     {
                        fullnames = !fullnames;
                        SetNums();
                        KillCaches();
                        Report(now);
                     }
                     else if(itemNum+1 != sortby)
                     {
                        sortby = itemNum+1;
                        KillCaches();
                        Report(now);
                     }
                     break;
               }
               menuNumber = item->NextSelect;
            }
            break;
         
         case IDCMP_NEWSIZE:
            RBUG(("IDCMP_NEWSIZE\n"))
            SetNums();
            /* Fall through */

         case IDCMP_REFRESHWINDOW:
            RBUG(("IDCMP_REFRESHWINDOW\n"))
            KillCaches();  /* Forces an erase */
            Report(now);
            break;

         default:
            RBUG(("unknown IDCMP message\n"))
            assert(1);
         }
      ReplyMsg((struct Message *)msg);
      }
      if(wait && !done && !autoexit)
      {
         Report(now);
         Wait(1L << win->UserPort->mp_SigBit);
      }
      else done = TRUE;
   }
}

void _STDReport(void)
{
   /* Handle window events until the user selects QUIT   */
   /* then clean up, close the window and return         */

   if(win)
   {
      DoTitle("Complete");
      handle_window_events(1,0);
   }

   CleanupWindowStuff();
}

/* The following routines are called from qsort() to sort based */
/* on different criteria                                        */

/* Sort by ETime */
static int GPByETime(struct GPInfo **a, struct GPInfo **b)
{
   sptime atime = (*a)->time + (*a)->stkval;
   sptime btime = (*b)->time + (*b)->stkval;
   return(atime < btime ? 1 : atime > btime ?  -1 : 0);
}

/* Sort by ITime */
static int GPByITime(struct GPInfo **a, struct GPInfo **b)
{
   sptime atottime = (*a)->tottime + (*a)->stkval;
   sptime btottime = (*b)->tottime + (*b)->stkval;
   return(atottime < btottime ? 1 : atottime > btottime ?  -1 : 0);
}

/* Sort by Count */
static int GPByCount(struct GPInfo **a, struct GPInfo **b)
{
   int acount = (*a)->count + (*a)->stkval;
   int bcount = (*b)->count + (*b)->stkval;
   return(acount < bcount ? 1 : acount > bcount ?  -1 : 0);
}

/* Sort alphabetically by function name (ignore case) */
static int GPByAlpha(struct GPInfo **a, struct GPInfo **b)
{
      int i;
      char *ap = GPINAME(*a);
      char *bp = GPINAME(*b);
      int ac, bc;
      i = 0;

      do
      {
         ac = toupper(ap[i]);
         bc = toupper(bp[i]);
         i++;
      }
      while(ac && ac == bc);

      return(ac < bc ? -1 : ac > bc ? 1 : 0);
}

/* Given a 'long' name in the form "\module\func\line", return */
/* the function name.                                          */
char *FuncName(char *p)
{
   static char tmpname[256];
   char *q;
   int j;

   assert(p != NULL);

   q = strchr(p+1, '\\');
   if(*p != '\\' || q == NULL)
   {
      /* Badly formed name string */
      strncpy(tmpname, p, sizeof(tmpname));
      tmpname[sizeof(tmpname)-1] = 0;
   }
   else
   {
      p = q+1;
      for(j=0; j<sizeof(tmpname)-1 && p[j] != '\\' ; j++)
         tmpname[j] = p[j];
      tmpname[j] = '\0';
   }
   return tmpname;
}

/* Return the length of the specified name in pixels */
USHORT GetLength(char *name)
{
   myIText.IText = name;
   return (USHORT)IntuiTextLength(&myIText);
}

/* Truncate the specified name to whatever will fit in the text area. */
/* Return the length it's been truncated to in 'len'.                 */
USHORT Truncate(char *name, USHORT *len)
{
   int namelen = strlen(name);
   USHORT newlen;

   while(namelen>0 && (newlen=GetLength(name)) > MAX_TEXT_WIDTH)
      name[--namelen] = 0;

   if(*len < newlen) *len = newlen;

   return (USHORT)namelen;
}

/* 'scale' is the histogram scale - i.e. how many units each pixel */
/* represents.                                                     */
static ULONG scale;

/* KillCaches resets the various cached values so we can be assured    */
/* that EVERYTHING will be redrawn the next time Report() gets called. */
static void KillCaches(void)
{
   scale = 0xffffffff;
   oldmaxval = 0xffffffff;
   oldreport_type = 0xffffffff;
   old_text_width = 0xffff;
   oldfullnames = -1;
}

/* SetNums calculates the axis_top, hist_bottom, and NumOnScreen externs.*/
static void SetNums(void)
{
   if(axis)
   {
      axis_top = win->Height - BOTTOM_MARGIN - YSIZE - TICK_HEIGHT;
      hist_bottom = axis_top - 5;
   }
   else
   {
      axis_top = hist_bottom = win->Height - BOTTOM_MARGIN;
   }
   NumOnScreen = (HIST_BOTTOM-HIST_TOP)/YSIZE;
   if(NumOnScreen > GPCur) NumOnScreen = GPCur;
}

/* CalcRange calculates the histogram range */
/* 'maxval' is the maximum data value that must be graphed */
/* 'minmax' and 'maxmax' are the minimum and maximum acceptable values */
/* for the histogram range.  (maxmax is primarily used to limit the    */
/* PERCENTAGE histogram to no more than 100%.                          */
static ULONG CalcRange(ULONG maxval, int minmax, int maxmax)
{
   int len;
   char buf[32];

   /* First check to see if we can reuse the current scale  */
   /* We can do this if the new maxval is less than the     */
   /* current scale, and it's not "too small".  We consider */
   /* anything less than 3/5 of the current maximum to be   */
   /* too small.                                            */
   if(scale != 0xffffffff && 
      maxval<=scale && 5*maxval/3 >= scale) return scale;

   /* The old scale won't work.  Pick a new one that allows */
   /* room for growth.                                      */
   scale = 4*maxval/3;

   /* Make sure our choice is within any specified limits */
   if(maxmax>0 && scale > maxmax) scale = maxmax;
   if(minmax>0 && scale < minmax) scale = minmax;

   /* Double-check to make sure the scale includes the values */
   if(scale < maxval) scale = maxval;

   /* Reduce the range as needed to get the labels in */
   /* labellen is used by the HIST_WIDTH macro        */
   sprintf(buf, " %d", scale);
   myIText.IText = buf;
   if((len=IntuiTextLength(&myIText)) > labellen)
   {
      labellen = len;
      /* Force a redraw */
      oldreport_type = -1;
   }
   
   return scale;
}

/* Draw the axis, if requested */
static void DoAxis(ULONG scale)
{
   char buf[32];
   int i, x, textlen;

   if(!axis) return;  // Axis option not on

   /* Erase the current axis */
   SetAPen(win->RPort, 0);
   RectFill(win->RPort, win->BorderLeft, axis_top, 
                        win->Width-win->BorderRight-1, 
                        win->Height-win->BorderBottom-1);
   
   /* Draw the horizontal axis line */
   SetAPen(win->RPort, 1);
   Move(win->RPort, HIST_LEFT, axis_top+TICK_HEIGHT/2);
   Draw(win->RPort, HIST_LEFT+HIST_WIDTH, axis_top+TICK_HEIGHT/2);

   /* Draw the tick marks */
   for(i=0; i<5; i++)
   {
      x = HIST_LEFT + HIST_WIDTH*i/4;
      Move(win->RPort, x, axis_top);
      Draw(win->RPort, x, axis_top+TICK_HEIGHT);
      sprintf(buf, "%d", scale*i/4);
      myIText.IText = buf;
      textlen = IntuiTextLength(&myIText);
      PrintIText(win->RPort, &myIText, x-textlen/2, 
                 axis_top+TICK_HEIGHT+YSIZE-baseline);
   }
}

/* Update the title bar. The title bar is of the form */
/* "GUIPROF: <status>: Report by <reptype>"             */
/* If specified, our parameter is the new status.     */
void DoTitle(char *new)
{   
   static char title[80];
   static char *graphtypes[] =
   {
     "Percent", 
     "Time (No subroutines)",
     "Time (With subroutines)",
     "Count", 
   };
   char new_title[sizeof(title)];
   static char *progstatus = "Waiting for program";

   if(new) progstatus = new;

   sprintf(new_title, "GUIPROF: %s: Report by %s", progstatus, 
           graphtypes[report_type]);

   /* Check to see if this is different from the previous title */
   /* before updating                                           */
   if(strcmp(new_title, title))
   {
      strcpy(title, new_title);
      SetWindowTitles(win, title, NULL);
   }
}

/* This is the big enchilada.  Produce the report. */
/* Our parameter, 'now', is the timestamp of the latest event      */
/* to come in.  This allows us to factor in time spent in routines */
/* that haven't returned yet.                                      */
void Report(sptime now)
{
   typedef int (*sortfunc_p)(void const *, void const *);
   static sortfunc_p sortfuncs[] =
   {
      (sortfunc_p)GPByETime,
      (sortfunc_p)GPByETime,
      (sortfunc_p)GPByITime,
      (sortfunc_p)GPByCount,
   };
   static int already_called;

   int ypos;
   int i, indx, doname;

   sptime time, tottime, sumtime, cumtime;
   int count;
   ULONG maxval, newmaxval;
   
   int LastOnScreen, histlen;
   ULONG histval;
   
   sptime elapsed, subelapsed;
   static struct GPInfo **rptGPInfo;
   static int oldgpmax;
   struct GPInfo *gpi;
   int freebies = 1;
   char buf[20];

   /* If we haven't already been called once, handle window IDCMP */
   /* events now.  Eventually this will return to us and we'll    */
   /* continue with the report.                                   */
   if(already_called == 0)
   {
      already_called = 1;
      handle_window_events(0, now);
      already_called = 0;
   }

   /* Update the window titles, in case the report type changed */
   DoTitle(NULL);
   
   if(now != 0)
   {
      /* Accumulate data for functions that are still on the stack   */
      /* Note that if there are functions on the stack that have not */
      /* returned yet, they will be added to the list by FindGPI.    */
      /* Since FindGPI expects the list to be sorted by id, do not   */
      /* move this code after the qsort() call below.                */ 
      subelapsed = 0;
      for(i=spcur-1; i>=0; i--)
      {
         assert(spdat[i].clk <= now);
         elapsed = now - spdat[i].clk;
         if(spdat[i].id && spdat[i].id != nullid)
         {
            gpi = FindGPI(&GPInfo, spdat[i].id, &GPCur, &GPMax);
            assert(gpi->name == (char *)(gpi+1));
            assert(gpi->fullname[0] == '\\');
            assert(elapsed >= spdat[i].subrs + subelapsed);
            if(report_type == RPT_PCT || report_type == RPT_ETIME)
               gpi->stkval += (elapsed - spdat[i].subrs - subelapsed);
            else if(report_type == RPT_ITIME)
               gpi->stkval += elapsed;
            else
               gpi->stkval++;
         }
         subelapsed = elapsed;
      }
   }

   if(!GPCur) return;  // Nothing to display

   SetNums();

   /* Set the scroll bar to reflect our current status unless it's being */
   /* diddled with right now.  If so, 'bardown' will be on.              */
   if(!bardown) VBUpdate(VBar, VBSIZ(NumOnScreen), VBPOS(FirstOnScreen));

   /* We need our own private copy of the GPInfo array since we will */
   /* be sorting it.                                                 */
   if(GPMax != oldgpmax)
   {
      rptGPInfo = realloc(rptGPInfo, GPMax*sizeof(struct GPInfo *));
      if(!rptGPInfo)
      {
         fprintf(stderr, "GUIPROF: Out of memory\n");
         return;
      }
      oldgpmax = GPMax;
   }
   memcpy(rptGPInfo, GPInfo, GPCur*sizeof(struct GPInfo *));

   /* Sort the array */
   qsort(rptGPInfo, GPCur, 
         sizeof(struct GPInfo *), 
         sortby == OPT_SORTNUM ? sortfuncs[report_type]
                               : (sortfunc_p)GPByAlpha);

   /* Calculate totals */
   sumtime = cumtime = maxval = 0;
   for(i=0; i<GPCur; i++)
   {
      gpi = rptGPInfo[i];

      if(gpi->rptnamelen == 0 || oldfullnames != fullnames)
         gpi->rptnamelen = Truncate(GPINAME(gpi), &text_width);

      assert(gpi->name == (char *)(gpi+1));

      switch(report_type)
      {
         case RPT_PCT:
         case RPT_ETIME:
            time = gpi->time + gpi->stkval;
            sumtime += time;
            if(time > maxval) maxval = time;
            break;

         case RPT_CNT:
            count = gpi->count + gpi->stkval;
            if(count > maxval) maxval = count;
            break;

         case RPT_ITIME:
            tottime = gpi->tottime + gpi->stkval;
            if(tottime > maxval) maxval = tottime;
            break;
      }
   }
   oldfullnames = fullnames;

   // Compute the maximum percentage if that's the report type we're doing
   if(report_type == RPT_PCT)
      maxval = PCTOF(maxval, sumtime);

   // Set the SIZEVERIFY flag on the window so it won't be resized while 
   // we are working on it.
   ModifyIDCMP(win, IDCMPFLAGS|IDCMP_SIZEVERIFY);

   // Rescale if necessary
   SetNums();
   newmaxval = CalcRange(maxval, 0, report_type == RPT_PCT ? 100 : 0);

   /* Check to see how much we can get away without drawing */
   if(newmaxval != oldmaxval || 
      report_type != oldreport_type ||
      text_width != old_text_width)
   {
      /* Sorry, Charlie - have to redraw it all */
      freebies = 0;
      oldmaxval = newmaxval;
      oldreport_type = report_type;
      old_text_width = text_width;
      SetAPen(win->RPort, 0);
      RectFill(win->RPort, 
               win->BorderLeft,
               win->BorderTop,
               win->Width - win->BorderRight-1,
               win->Height - win->BorderBottom-1);
      DoAxis(scale);
   }
   maxval = newmaxval;

   if(axis_top > win->Height - BOTTOM_MARGIN)
   {
      /* Somebody resized the window smaller on us */
      /* Give up and let the next update do it.    */
      ModifyIDCMP(win, IDCMPFLAGS);
      return;
   }
   assert(axis_top > 0);
   assert(hist_bottom <= axis_top);

   // Figure out the index of the first and last elements on screen
   if(NumOnScreen > GPCur - FirstOnScreen)
   {
      FirstOnScreen = GPCur - NumOnScreen;
      if(FirstOnScreen < 0) FirstOnScreen = 0;
      LastOnScreen = GPCur;
      if(!bardown) VBUpdate(VBar, VBSIZ(NumOnScreen), VBPOS(FirstOnScreen));
   }
   else
      LastOnScreen = NumOnScreen + FirstOnScreen;

   assert(LastOnScreen >= 0);
   assert(LastOnScreen <= GPCur);
   assert(FirstOnScreen >= 0);
   assert(FirstOnScreen <= LastOnScreen);

   /* Reset rptindx for those that aren't on screen */
   for(i=0; i<FirstOnScreen; i++)
      rptGPInfo[i]->rptindx = -1;

   for(i=LastOnScreen; i<GPCur; i++)
      rptGPInfo[i]->rptindx = -1;

   ypos = HIST_TOP;
   indx = 1;
   
   for(i=FirstOnScreen; i<LastOnScreen; i++, ypos += YSIZE)
   {
      gpi = rptGPInfo[i];

      /* Calculate the length of the new rectangle */
      if(maxval == 0) 
         histlen = 0;
      else
      {
         if(report_type == RPT_ITIME)
            histval = gpi->tottime + gpi->stkval;
         else if(report_type == RPT_CNT)
            histval = gpi->count + gpi->stkval;
         else
         {
            histval = gpi->time + gpi->stkval;
            if(report_type == RPT_PCT) 
               histval = PCTOF(histval, sumtime);
         }
         gpi->stkval = 0;
         histlen = (histval*HIST_WIDTH)/maxval;
      }
      assert(histlen>=0 && histlen<=HIST_WIDTH);

      if(histval && !histlen) histlen = 1;

      /* At this point, histval is the numerical value of the current bar */
      /* and histlen is the length in pixels of the current bar.          */

      if(gpi->rptindx == indx)
      {
         /* This element occurred at this index last time through */
         /* Check to see if we can use any of the previous stuff  */
         if(freebies && 
            gpi->histval == histval && 
            gpi->histlen == histlen)
         {
            indx++;
            continue;  // Everything's the same
         }
         // If we're accepting freebies, then we know we can leave the
         // name as is.  Set 'doname' appropriately.
         doname = (freebies ? 0 : 1);
      }
      else  // Not the same index as last time, must redo the name
         doname = 1;

      /* Check to see if they've resized the window on us */
      if(ypos + YSIZE > win->Height - BOTTOM_MARGIN) break;

      if(doname)
      {
         /* Erase the old function name and bar */
         SetAPen(win->RPort, 0);
         RectFill(win->RPort, LEFT_MARGIN, ypos,
                  win->Width-RIGHT_MARGIN, ypos+YSIZE-1);

         /* Draw the function name */
         SetAPen(win->RPort, 1);
         myIText.IText = GPINAME(gpi);
         myIText.IText[gpi->rptnamelen] = 0;
         PrintIText(win->RPort, &myIText, TEXT_LEFT, ypos);

         /* Draw the bar */
         if(histlen > 0)
         {
            SetAPen(win->RPort, 3);
            RectFill(win->RPort, HIST_LEFT, ypos,
                     HIST_LEFT+histlen, ypos+YSIZE-2);
         }
         /* The label annotation is done below */
      }
      else if(freebies)
      {
         if(gpi->histlen > histlen)
         {
            /* New bar is smaller than the old bar - can happen with   */
            /* percentage reports.                                     */
            /* Erase the portion of the old bar that no longer applies */
            SetAPen(win->RPort, 0);
            RectFill(win->RPort, HIST_LEFT+histlen, ypos,
                     HIST_LEFT+HIST_WIDTH+labellen, ypos+YSIZE-1);
         }
         else if(gpi->histlen < histlen)
         {
            /* New bar is bigger than the old bar. */
            /* Draw the new portion of the bar     */
            if(histlen > 0)
            {
               SetAPen(win->RPort, 3);
               RectFill(win->RPort, HIST_LEFT+gpi->histlen, ypos,
                        HIST_LEFT+histlen, ypos+YSIZE-2);
            }
         }
      }
      else
      {
         /* Erase the old bar */
         SetAPen(win->RPort, 0);
         RectFill(win->RPort, HIST_LEFT, ypos, 
                  win->Width-RIGHT_MARGIN, ypos+YSIZE-1);

         /* Draw the new bar */
         if(histlen > 0)
         {
            SetAPen(win->RPort, 3);
            RectFill(win->RPort, HIST_LEFT, ypos,
                     HIST_LEFT+histlen, ypos+YSIZE-2);
         }
      }

      /* Annotate the bar with the value */
      SetAPen(win->RPort, 1);
      sprintf(buf, " %d", histval);
      myIText.IText = buf;
      PrintIText(win->RPort, &myIText, 
                 HIST_LEFT+histlen+1, ypos);

      gpi->rptindx = indx++;
      gpi->histval = histval;
      gpi->histlen = histlen;
   }
   /* Remove the SIZEVERIFY flag */
   ModifyIDCMP(win, IDCMPFLAGS);

}

static void InstallMenus(struct VisualInfo *vi)
{
   /* Make the menus reflect the user's command-line options */
   /* This is VERY dependant on the menu layouts!            */

   /* Check the selected report type */
   mynewmenu[report_type+DRAW_TYPE_INDEX].nm_Flags |= CHECKED;

   /* Check the AXIS option if selected */
   if(axis) mynewmenu[DRAW_AXIS_INDEX].nm_Flags |= CHECKED;

   /* Check the FULLNAMES option if selected */
   if(fullnames) mynewmenu[FULL_NAMES_INDEX].nm_Flags |= CHECKED;

   mynewmenu[SORT_INDEX+sortby-1].nm_Flags |= CHECKED;

   if (NULL != (menuStrip = CreateMenus(mynewmenu, TAG_END)))
   {
      LayoutMenus(menuStrip, vi, TAG_END);
      SetMenuStrip(win, menuStrip);
   }

}
