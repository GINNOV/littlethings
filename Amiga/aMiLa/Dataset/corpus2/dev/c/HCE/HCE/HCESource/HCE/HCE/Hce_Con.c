/* Copyright (c) 1994, by Jason Petty.
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *
 * Hce_Con.c:
 *           
 *       Console routines based on console routines by Russel Wallace 1987.
 *
 */
 
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <exec/errors.h>
#include <exec/memory.h>
#include <devices/timer.h>
#include <devices/console.h>
#include <devices/printer.h>
#include <libraries/dos.h>
#include <libraries/asl.h>
#include <graphics/gfxmacros.h>

#include <clib/stdio.h>
#include <clib/string.h>
#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"
#include "Hce_Block.h"

/************************ Globals ****************************/

UBYTE penshop[3];             /* Console pen/paper and marking colours. */
UWORD prt_error=TRUE;         /* Printer Device error. */
UWORD tm_error=TRUE;          /* Timer Device error.   */
UWORD NsPens[2];              /* Used to set WBench2-3, 3D embossed look*/
WORD font_width,font_height;  /* For GfxBase default font sizes. */
long ecurtime=0;              /* Eclock current time.  */
long enewtime=0;              /* Eclock new time.      */
char TRep[10];                /* Used to store ANSI commands for console*/
char TBuf[10];                /* Used when two `TRep` funcs may clash.  */
char *got_env;                /* Pointer to env string or NULL if prob. */
int prt_num[2];               /* Keep from and to lines for printing.   */

unsigned char letter;         /* Console buffer for key presses. */
extern int Enable_Abort;      /* Used to disable Ctrl-C Handling.*/

/******************* Structure Definitions **********************/

union printerIO   /* Printer Request Block. */
{
  struct IOStdReq ios;
  struct IODRPReq iodrp;
  struct IOPrtCmdReq iopc;
};

union printerIO *prt_req=0;
struct EClockVal tm_eclock;
struct IOStdReq *consoleWriteMsg=0;
struct IOStdReq *consoleReadMsg=0;
struct MsgPort *consoleWritePort=0;
struct MsgPort *consoleReadPort=0;
struct MsgPort *prt_reply=0;
struct MsgPort *tm_reply=0;
struct timerequest *tm_tr=0;
chip struct Menu *my_menu=0;
struct FileRequester *TxFileReq=0;
struct GfxBase *GfxBase=0;
struct Device *TimerBase=0;
struct TagItem NsTags[2];
long IntuitionBase=0;
long GadToolsBase=0;
long AslBase=0;


/********************** FUNCTIONS FROM HERE *********************/

 /* Start() must be called at beginning; returns window pointer. If 0,
  * program has failed ... everything already cleaned up here, main()
  * must do its own cleaning up then exit. 
  */

struct Window *start ()
{
	if (!(IntuitionBase=(long)OpenLibrary("intuition.library",0L)))
               return(NULL);
	if (!(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0L)))
	       goto FAILED;
	if (!(AslBase=(long)OpenLibrary("asl.library", 36L))) {
               Do_ReqV1("Could not open asl.library - V36 or Higher!!");
	       goto FAILED;
               }
        if (!(GadToolsBase=(long)OpenLibrary("gadtools.library", 36L))) {
               Do_ReqV1("Could not open gadtools.library - V36 or Higher!!");
               goto FAILED;
               }

    /* Disable Ctrl-C handling. */
               Enable_Abort=NULL;

    /* Printer. Note: actual printer device opened only when required. */
        if (!(prt_reply = (struct MsgPort *)CreatePort( NULL, 0)))
               goto FAILED;
        if (!(prt_req = (union printerIO *) 
               CreateExtIO(prt_reply, sizeof(union printerIO))))
               goto FAILED;
               prt_num[0] = 0;   /* Default print From line. */
               prt_num[1] = 1;   /* Default print To line. */

    /* Screen. */
        NsPens[0] = DRIF_NEWLOOK;           /* Set new WBench2-3 look. */
        NsPens[1] = -1;
        NsTags[0].ti_Tag = SA_Pens;         /* pens. */
        NsTags[0].ti_Data = (ULONG)NsPens;  /* Pointer to pen array.  */
        NsTags[1].ti_Tag = TAG_END;         /* No more Tags. */
        NsTags[1].ti_Data = TAG_END;
   if(!(my_screen=(struct Screen *)OpenScreenTagList(&my_new_screen,NsTags)))
        goto FAILED;

    /* GadTools */
        if (!(Alloc_VisualInfoA()))    /* Get Visual info for gad tools. */
                 goto FAILED;
        if (!(Alloc_G_Gadgets()))      /* Allocate 'Gadget Bar' gadgets. */
                 goto FAILED;

        my_new_win.Screen=my_screen;   /* Attach Windows to Screen.*/ 
        g_new_window.Screen=my_screen;
        gfx_new_win.Screen=my_screen;
        gfx_new_win.FirstGadget = gb_gadlist; /* Gadget bar gadgets.*/

    /* Gfx Window. */
	if (!(gfx_window = (struct Window *)OpenWindow(&gfx_new_win))) {
            Do_ReqV1("Could not open Gfx Window!!");
            goto FAILED;
            }
    /* Console Window. (Opens on top gfx_window). */
	if (!(my_window = (struct Window *)OpenWindow(&my_new_win))) {
            Do_ReqV1("Could not open Console Window!!");
            goto FAILED;
            }
    /* Graphics. */
                font_width=GfxBase->DefaultFont->tf_XSize;
	        font_height=GfxBase->DefaultFont->tf_YSize;
                Set_Graphics(); /* Set all Window/Screen Graphics. */

    /* Menus. */
                NewMenu(1, "Hce");
                NewItem("About Hce       ", NULL);
                NewItem("About Hcc       ", NULL);
                NewItem("Clear text buf  ", NULL);
                NewItem("First error     ", 'E');
                NewItem("First warning   ", 'W');
                NewItem("Print           ", NULL);
                NewItem("Prefs/Config    ", '/');
                NewItem("Cli             ", NULL);
                NewItem("Program size    ", '1');
                NewItem("Quit            ", 'Q');

                NewMenu(NULL, "Disk");
                NewItem("Load. (c/a-source)", 'L');
                NewItem("Load. (lock......)", 'O');
                NewItem("Load. (append....)", 'A');
                NewItem("Save. (c/a-source)", 'S');
                NewItem("Save. (as........)", 'V');

                NewMenu(NULL, "Compile");
                NewItem("Compile only(test)           'F1' ", NULL);
                NewItem("Compile + Optimize           'F2' ", NULL);
                NewItem("Compile + Opt + Assemble     'F3' ", NULL);
                NewItem("Compile + Opt + Assem List   'F4' ", NULL);
                NewItem("Compile + Opt + Assem + Link 'F5' ", NULL);
                NewItem("--------------------------------  ", NULL);
                NewItem("Optimizer - options       Ctrl+O  ", NULL);
                NewItem("Compiler  - options       Ctrl+C  ", NULL);

                NewMenu(NULL, "Assemble");
                NewItem("Assemble this file    'F6' ", NULL);
                NewItem("Assemble compiled     'F7' ", NULL);
                NewItem("Assemble selected     'F8' ", NULL);
                NewItem("Assemble + Link       'F9' ", NULL);
                NewItem("-------------------------  ", NULL);
                NewItem("Assembler-options  Ctrl+A  ", NULL);

                NewMenu(NULL, "Link");
                NewItem("Link (a/l/b)     'F10' ", NULL);
                NewItem("Link selected          ", NULL);
                NewItem("Link list      ", 'G');
                NewItem("---------------------- ", NULL);
                NewItem("Linker-options  Ctrl+L ", NULL);

                NewMenu(NULL, "Other");
                NewItem("Run Linked    ", 'K');
                NewItem("Run?          ", NULL);
                NewItem("Lock this path", NULL);
                NewItem("Lock df0:     ", 'U');
                NewItem("Lock?         ", NULL);
                NewItem("Copy file(s)  ", 'Y');
                NewItem("Delete Linked ", 'D');
                NewItem("Delete file(s)", 'Z');
                NewItem("Make directory", NULL);
                NewItem("Assign device ", NULL);
                NewItem("Rename (v/d/f)", NULL);

                NewMenu(NULL, "Block");
                NewItem("Mark  ", 'M');
                NewItem("Hide  ", 'H');
                NewItem("Cut   ", 'X');
                NewItem("Copy  ", 'C');
                NewItem("Insert", 'I');
                NewItem("Print ", 'P');

                NewMenu(NULL, "Search/Cursor");
                NewItem("Find?        ", 'F');
                NewItem("Find next    ", 'N');
                NewItem("Find/Replace ", 'R');
                NewItem("-------------", NULL);
                NewItem("B/End of line", 'B');
                NewItem("B/End of file", 'T');
                NewItem("Jump to Line ", 'J');

        if(!(my_menu = AttachMenu(my_window)))
                goto FAILED;

   /* Asl filerequester. */
        if (!(TxFileReq=(struct FileRequester *)
                AllocAslRequest(ASL_FileRequest, NULL)))
                {
                Do_ReqV1("Could not allocate Asl-FileRequester!!");
                goto FAILED;
                }
   /* Timer stuff */
        if (!(tm_reply = (struct MsgPort *)CreatePort(NULL, 0)))
                goto FAILED;
        if (!(tm_tr = (struct timerequest *)
                CreateExtIO(tm_reply, sizeof(struct timerequest))))
                goto FAILED;
        if ((tm_error = OpenDevice(TIMERNAME, UNIT_ECLOCK, tm_tr ,0)))
                goto FAILED;
                TimerBase = tm_tr->tr_node.io_Device;  /* Important line. */
   /* Console stuff */
	if (!(consoleWritePort=CreatePort("my.con.write",0)))
		goto FAILED;
	if (!(consoleReadPort=CreatePort("my.con.read",0)))
		goto FAILED;
	if (!(consoleWriteMsg=CreateStdIO(consoleWritePort)))
		goto FAILED;
	if (!(consoleReadMsg=CreateStdIO(consoleReadPort)))
		goto FAILED;
	if (OpenConsole (consoleWriteMsg,consoleReadMsg,my_window))
		goto FAILED;

	 QueueRead (consoleReadMsg,&letter);

   /* Config. */
         penshop[CON_PEN] = (UBYTE)9;
      if(read_CONFIG(NULL)) {      /* Try to get default config. */
         new_Palette();
         } else {
         Do_ReqV1("Could not find Hce.config file! - (devs, s)");
         }
      if(penshop[CON_PEN] == (UBYTE)9) { /* No config file!.(use defaults).*/
         penshop[CON_PEN] = (UBYTE)HITEXT_PEN;
         penshop[CON_PAPER] = (UBYTE)DIM_PEN;
         penshop[CON_MARKER] = (UBYTE)BACK_PEN;
         P_GadBN[1] = 8; /* tab stop. */
         }
   /* Fine tuning. */
         c_WindColor(penshop[CON_PAPER]); /* Set new console window colour.*/
         c_BPen(penshop[CON_PAPER]);      /* Console back pen colour.      */
         c_FPen(penshop[CON_PEN]);        /* Console front pen colour.     */
         c_Command('J');                  /* Clear console window.         */
         checkinput();                    /* Dummy call. (Must do this!!). */

   /* Parse the envirenment variable. (used by compiler 'main.c') */
         got_env = (char *)getenv("INCLUDE");

         Hce_Credits();                   /* Show Credits. */
	 return (my_window);
FAILED:
         closeall ();
         return (NULL);
}

	/* Call finish() at end, if start() was successful!. */
void finish ()
{
	AbortIO (consoleReadMsg);
	CloseConsole (consoleWriteMsg);
	closeall ();
}

void closeall ()  /* Close everything opened by this file. */
{                 /* Free anything allocated by this file. */
        if (!prt_error)                 /* Close printer device. */
                  CloseDevice( prt_req );
        if (prt_req)
                  DeleteExtIO( prt_req, sizeof(union printerIO) );
        if (prt_reply)
                  DeletePort( prt_reply);
        if (!tm_error)
                 CloseDevice( tm_tr );  /* Timer device. */
        if (tm_tr)
                 DeleteExtIO( tm_tr, sizeof( struct timerequest) );
        if (tm_reply)
                DeletePort(tm_reply);
        if (my_menu)
                LoseMenu( my_window, my_menu );
	if (my_window)
		CloseWindow (my_window);
	if (gfx_window)
		CloseWindow (gfx_window);
  
         Close_GWind();         /* Close g_window. (Tests for opened). */
         Free_GT_Gadgets();     /* (Tests if allocated). */
         Free_VisualInfo();     /* (Tests if allocated). */
         FREE_MiscGads();       /* (Tests if allocated). */
         (void)FreeForExit();   /* Free any mem allocated by the compiler. */

        if (my_screen)
                CloseScreen (my_screen);
	if (consoleWritePort)
		DeletePort (consoleWritePort);
	if (consoleReadPort)
		DeletePort (consoleReadPort);
	if (consoleWriteMsg)
		DeleteStdIO (consoleWriteMsg);
	if (consoleReadMsg)
		DeleteStdIO (consoleReadMsg);
        if (TxFileReq)
                FreeAslRequest(TxFileReq);
        if (GadToolsBase)
                CloseLibrary(GadToolsBase);
        if (AslBase)
                CloseLibrary (AslBase);
	if (GfxBase)
		CloseLibrary (GfxBase);
	if (IntuitionBase)
		CloseLibrary (IntuitionBase);
}

void PrtError(error) /* Prints the appropriate printer error message. */
BYTE error;          /* (Uses Message Box). */
{
  switch( error ) /* Errors found in 'exec/errors.h' & 'devices/printer.h' */
  {
    case IOERR_ABORTED:
      Show_Status("The printer request was aborted!");
      break;
    case IOERR_NOCMD:
      Show_Status("Unknown printer command was sent!");
      break;
    case IOERR_BADLENGTH:
      Show_Status("Bad length in the printer command - data!");
      break;
    case PDERR_CANCEL:
      Show_Status("All Printing Cancelled!");
      break;
    case PDERR_NOTGRAPHICS:
      Show_Status("Printer doesn`t support Graphics!.(check prefs)");
      break;
    case PDERR_BADDIMENSION:
      Show_Status("Printer dimension is not valid!");
      break;
    case PDERR_INTERNALMEMORY:
      Show_Status("Not enough memory for the internal printer functions!");
      break;
    case PDERR_BUFFERMEMORY:
      Show_Status("Not enough memory for the print buffer!");
      break;
    default:
      Show_Status("Unkown printer error received!");
      break;
  }
}

BYTE DO_PrtText(data) /* Sends translated Text to the printer. */
BYTE *data;           /* Obays WB printer prefs. */
{                     /* Note: Printer Device opened on first call. */
 if(prt_error) {
   if((prt_error = OpenDevice("printer.device", 0, prt_req, 0)))
       return((BYTE)prt_error);
   }
   prt_req->ios.io_Command = CMD_WRITE;
   prt_req->ios.io_Data = (APTR)data;
   prt_req->ios.io_Length = -1;
   return( (BYTE) DoIO( prt_req ) );   /* 0 = Ok else error. */
}

void Prt_LINE(flg)   /* Send part or all lines in 'LINE' to the Printer. */
int flg;
{
 BYTE err;
 int i=0;

          if(flg) {    /* Print all */
                    Show_Status("Printing-all...");
             while(LINE[i][0] != '\0' && i < T_MAXLINE-1) 
                 {
                    err = (BYTE)DO_PrtText(LINE[i++]);
               if(err) {
                    PrtError(err);  /* Show appropriate error message, */
                    return;         /* in message box. */
                    }
                  }
              }
            else {  /* Print from/to. */
                    Show_Status("Printing-(from/to)...");
                    i = prt_num[0];
              while(LINE[i][0] != '\0' && i <= prt_num[1] && i < T_MAXLINE-1)
                    {
                      err = (BYTE)DO_PrtText(LINE[i++]);
                  if(err) {
                      PrtError(err);
                      return;
                      }
                    }                 
               }
 Show_StatOK(MIN_DELAY);
}

int OpenConsole (writerequest,readrequest,window)
struct IOStdReq *writerequest,*readrequest;
struct Window *window;
{
	register int error;
	writerequest->io_Data=(APTR)window;
	writerequest->io_Length=sizeof(*window);
	error=OpenDevice ("console.device",0,writerequest,0);
	readrequest->io_Device=writerequest->io_Device;
	readrequest->io_Unit  =writerequest->io_Unit;
	return (error);
}

void QueueRead (request,whereto)
struct IOStdReq *request;
char *whereto;
{
	request->io_Command=CMD_READ;
	request->io_Data=(APTR)whereto;
	request->io_Length=1;
	SendIO (request);
}

long checkinput ()   /* Return constant Key/Menu and other events.    */
{                    /* 0 is returned if nothing has happened.        */
 int class;          /* Gets events from 'my_window' and 'gfx_window' */
 int code;           /* note: mostly used by main(). */
 static int md_flag = FALSE;
 static WORD mouse_x = 0;
 static WORD mouse_y = 0;
 static WORD om_x=0;
 static WORD om_y=0;
 struct IntuiMessage *message;

  if (message=(struct IntuiMessage *)GetMsg (my_window->UserPort))
      {
          class=message->Class;
          code=message->Code;
          mouse_x=message->MouseX;
          mouse_y=message->MouseY;

          ReplyMsg (message);

       switch(class)
          {
	  case IDCMP_CLOSEWINDOW:
		                return (1000);
                                break;
	  case IDCMP_NEWSIZE:
		                return (1001);
                                break;
	  case IDCMP_MENUPICK: 
                             if(code!=MENUNULL)
                                return((code + 500));
                                break;
          case IDCMP_ACTIVEWINDOW:
                                return(class);
                                break;
          case IDCMP_INACTIVEWINDOW:
                                return(class);
                                break;
          case IDCMP_MOUSEBUTTONS:
                              if(code == SELECTDOWN) {
                                if(Mouse_LEGAL(message))
                                 {
                                    Check_MMARK(); /* Already mouse marked.*/
                                    Check_KMARK(); /* Already key marked.  */
                                    Place_MCURS(message);
                                    om_x=mouse_x;
                                    om_y=mouse_y;
                                    blk_SY = LINE_Y;
                                    blk_SX = LINE_X;
                                    md_flag++;
                                  }
                                }
                              if(code == SELECTUP)
                                 {
                                   if(BLOCK_ON) {
                                      B_End();
                                      BLOCK_ON=FALSE;
                                      MOUSE_MARKED=TRUE;
                                      }
                                      md_flag=0;
                                  }
                               break;
          case IDCMP_MOUSEMOVE:
                        if((Mouse_DIF(message,om_x,om_y,4) && md_flag)) {
                                  if(!BLOCK_ON) {
                                     Show_Status("Marking out - Block...");
                                     BLOCK_ON=TRUE;
                                     }
                                     Mouse_MARK(message);
                               }
                              break;
          }
      }
    if(GetMsg (consoleReadPort))
        {
	   code=letter;
	   QueueRead (consoleReadMsg,&letter);
	   return (code);
	 }
    gfx_chinput();  /* Check graphics window for any gadget presses. */
                    /* Calls the required routines. */
  return (0);
}

void writechar (c)  /* Write single console character. */
char c;
{
	consoleWriteMsg->io_Command=CMD_WRITE;
	consoleWriteMsg->io_Data=(APTR)&c;
	consoleWriteMsg->io_Length=1;
	DoIO (consoleWriteMsg);
}

void nprint (string) /* Print a none-formatted string in console window. */
char *string;
{
	consoleWriteMsg->io_Command=CMD_WRITE;
	consoleWriteMsg->io_Data=(APTR)string;
	consoleWriteMsg->io_Length=-1;
	DoIO (consoleWriteMsg);
}

int CheckTL(etime)  /* Use Eclock to get time intervals less than a sec. */
long etime;         /* Check use in main(). (controls cursor flash).     */
{
    ReadEClock(&tm_eclock);       /* Fill eclock struct */
      if(!ecurtime)
         ecurtime = tm_eclock.ev_lo;

         enewtime = (tm_eclock.ev_lo - ecurtime); /* Get time differnce. */

      if(enewtime >= etime) {    /* If time reached return TRUE. */
         ecurtime = 0;
         return(1);
         }
return(0);
}

ULONG TotalMemB() /* Get maximum available memory of any type. */
{                 /* Return total memory in bytes. */
 ULONG tmem;
 tmem = AvailMem((ULONG)MEMF_PUBLIC);
 return(tmem);
}

ULONG TotalMemK() /* Get maximum available memory of any type. */
{                 /* Return total memory in 'K'. */
 ULONG tmem;
 tmem = AvailMem((ULONG)MEMF_PUBLIC);
 return((tmem /= 1024));
}


/******************* CONSOLE **********************/

int c_ConRows()      /* Returns maximum console rows. */ 
{
 return(((my_window->Height - YOFFSET) / font_height) + 1);
}

int c_ConCols()      /* Returns maximum console columns. */ 
{
 return(((my_window->Width - XOFFSET) / font_width) + 1);
}

int c_LEGAL_RX()     /* Check LINE_X is not at maximum X position. */
{
  if (LINE_X && (LINE_X * font_width) + XOFFSET > my_window->Width)
     return(FALSE);  /* not legal. */
    else
     return(TRUE);   /* legal.    */
}

int c_LEGAL_LX()     /* Check LINE_X is not at minimum X position. */
{
  if (LINE_X <= 0)
     return(FALSE);  /* not legal. */
    else
     return(TRUE);   /* legal.    */
}

int c_LEGAL_BY()     /* Check CURS_Y is not at maximum Y position. */
{
  if ((CURS_Y * font_height)+YOFFSET > my_window->Height)
     return(FALSE);  /* not legal. */
    else
     return(TRUE);   /* legal.    */
}

int c_LEGAL_TY()     /* Check CURS_Y is not at minimum Y position. */
{
  if (CURS_Y <= 0)
     return(FALSE);  /* not legal. */
    else
     return(TRUE);   /* legal.    */
}

void c_Command(c)          /* Do ANSI console command. */
char c;
{
  TBuf[0] = 0x9b;
  TBuf[1] = c;
  TBuf[2] = '\0';
  nprint(TBuf);
}

void c_PlaceCURS(dx,dy)   /* Place Cursor at specific coords. */
int dx,dy;                /* Coords must be visible window coords. */
{
     char *tr, *tb;       /* esc[num;numH */
     dx++;
     dy++;

     itoa(dy, TBuf, 10);
     tr = TRep;
     tb = TBuf;

     *tr++ = 0x9b;        /* esc.*/

     do                   /* Y. */
       *tr++ = *tb++;
     while(*tb != '\0');

     *tr++ = ';';

     itoa(dx, TBuf, 10);
     tb = TBuf;

     do                   /* X. */
       *tr++ = *tb++;
     while(*tb != '\0');

     *tr++ = 'H';         /* CUP. */
     *tr++ = '\0';
     *tr = '\0';
     nprint(TRep);        /* Put cursor at dy,dx   */
}

void c_MoveCURS(d,n)  /* Move cursor required amount of chars. */
int d,n;              /* d = direction. n = num of chars.      */
{
    TRep[0] = 0x9b;
    switch(d) {
       case 1 || 0:
              TRep[1] = 0x41;  /* Up.    */
              break;
       case 2:
              TRep[1] = 0x42;  /* Down.  */
              break;
       case 3:
              TRep[1] = 0x43;  /* Right. */
              break;
       case 4:
              TRep[1] = 0x44;  /* Left.  */
              break;
              }
    TRep[2] = '\0';
    do
       nprint(TRep);
    while(--n >= 1);
}

void c_CursOff()  /* Turn console window Cursor off. */
{
     TRep[0] = 0x9b;
     TRep[1] = '0';
     TRep[2] = ' ';
     TRep[3] = 'p';
     TRep[4] = '\0';
     nprint(TRep);
}

void c_CursOn()   /* Turn Cursor back on. */
{
     TRep[0] = 0x9b;
     TRep[1] = ' ';
     TRep[2] = 'p';
     TRep[3] = '\0';
     nprint(TRep);
}

void c_FPen(t)  /* Set console foreground pen.(Uses Screens colour map) */
UBYTE t;
{
    TRep[0] = 0x9b;
    itoa(((int)t+30), TBuf, 10);
    TRep[1] = TBuf[0];
    TRep[2] = TBuf[1];
    TRep[3] = 'm';
    TRep[4] = '\0';
    nprint (TRep);
}

void c_BPen(t)  /* Set background pen colour. */
UBYTE t;
{
    TRep[0] = 0x9b;
    itoa(((int)t+40), TBuf, 10);
    TRep[1] = TBuf[0];
    TRep[2] = TBuf[1];
    TRep[3] = 'm';
    TRep[4] = '\0';
    nprint (TRep);
}

void c_WindColor(c) /* Set console window colour.(No good on 1.3 Amigas. */
UBYTE c;
{
    TRep[0] = 0x9b;
    itoa((int)c, TBuf, 10);
    TRep[1] = '>';
    TRep[2] = TBuf[0];
    TRep[3] = 'm';
    TRep[4] = '\0';
    nprint (TRep);  
}

void c_NewConPens() /* Show con win ,pen changes. */
{
   c_WindColor(penshop[CON_PAPER]);
   c_BPen(penshop[CON_PAPER]);
   c_FPen(penshop[CON_PEN]);
   FixDisplay();
   c_PlaceCURS(LINE_X, CURS_Y);
}

void c_SGR1(c)     /* Does single parameter Graphics Commands. */
char c;            /* Examples: Set Faint/Concealed/Reversed.  */
{
    TRep[0] = 0x9b;
    TRep[1] = c;
    TRep[2] = 'm';
    TRep[3] = '\0';
    nprint (TRep); 
}

void c_SGR2(c1,c2) /* Same as c_SGR1 except allows two args to Command. */
char c1,c2;
{
    TRep[0] = 0x9b;
    TRep[1] = c1;
    TRep[2] = ';';
    TRep[3] = c2;
    TRep[4] = 'm';
    TRep[5] = '\0';
    nprint (TRep); 
}
