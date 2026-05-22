/* DiskMaster2 windows module  open/close/refresh/scroll/select/display
**
** 2.7
**
** 06-01-05 rri - Post-Alpha work on new Reaction based windows.
**
** 06-01-14 rri - Added struct DirInfo DInfo.
**
** 06-01-21 rri - More Alpha work on Reaction based windows, fixed a stupid
**                bug and now the listbrowsernodes are created as set
**                by the user with 'SetFormat'.
**
** 06-02-05 rri - Added new global var initialised by InitScreenDefaults()
**                for OS4: vpadding
**
** 06-03-05 rri - TimeDelay() is replaced by usleep() when compiling for Newlib.library.
**
** 06-03-11 rri - Changed the define for Newlib to "__NEWLIB__".
**
** 06-03-18 rri - Gave up the idea to use custom vertical scrolling with
**                ListBrowser.gadget after a test reveiled that allocating
**                42.000 nodes takes only a second on my A1 and displaying
**                them only annother second.
**                So upto 10.000 dir-entries should be displayed in a flash.
**
** 06-08-23 rri - Removing all old GUI code now to have a fresh restart...
**
** 06-08-27 rri - Complete ListBrowser rendering is now done over a single hook.
**                At least the display looks perfect now.
**              - Removed some unused global vars.
**
** 06-09-02 rri - Not beeing able to find out why the system crashes when the
**                windows are closed individually DoWindow() calls FreeUserData()
**                for now to completely quit instead of closing a single window.
**              - Removed some not anymore used code.
**
** 06-09-17 rri - Various fixes to add_entry()
**              - Removed "pos" from add_entry() prototype
**
** 06-11-29 rri - Must admit that I made way more little changes and tweaks than I documented...
**              - New functions: update_entry(), append_entry(), remove_entry() to deal with
**                ListBrowser-list entries while the list is attached.
**              - Removed the ListBrowser-Renderhook from the OS4 build.
**
** 06-12-03 rri - Missed the point that FindNewDirection() has to be called with an invalid
**                pointer from CloseDirWindow() so it must not be NULL'ed.
**              - Slightly modified dis_name() and add_entry() again.
**              - Removed rdis_files() from active code
**
** 06-12-04 rri - Stupid bug, in DoWindow() I placed the ReplyMsg() after the IDCMP check and
**                on refresh the window which the message was from did not exist anymore...
**
** 06-12-05 rri - Disabled some debug-output.
**
** b2
**
** 06-12-09 rri - Adding some lines to clear DMFLAG_RESET if it set to DoWindow() fixed the
**                problem with 'Auto' that only the command-line for the first selected entry
**                was executed.
**              - Added a "LISTBROWSER_Top, 0," in dis_files() to reset the lists to top
**                when they are reloaded.
**
** 06-12-10 rri - Added "LISTBROWSER_TitleClickable, TRUE," and CIF_SORTABLE in OpenDirWindow()
**                to make the collumn-titles clickable.
**
** b3
**
** 06-12-12 rri - Reduced the day/month/year collumns to a single 'date' collumn.
**              - Re-implemented the color-option for command-window buttons.
**              - Empty command-window lines no longer have a button as well but a
**                horizontal separator that is read-only.
**
** 06-12-13 rri - OpenDirWindow() was no longer using the global NewWin_Flags and therefore
**                the NOCLOSE option for the windows was no longer working.
**                Thanks to Javier de las Rivas for spotting that in the first beta!
**
** 06-12-14 rri - Changed OpenDirWindow() to use DMFONTS_CMDWIN for command-windows.
**
** b4
**
** 06-12-16 rri - Propably not the best idea to access a message that already
**                has been replied - fixed in DoWindow()...
**              - Conditionally removed the var "drag_delay" from the OS4 build.
**              - Did some textual cleanup.
**              - New function collumn_expand() to make collumns wider in case their text
**                does not fit in the ci_width of the collumn.
**              - Bugifx: opening a dir by double-click and a second window already displayed
**                that path AutoFiler() was executed for the first entry in that dir.
**
** 06-12-17 rri - Since ExamineDir() breaks compatibility with Examine() by always reporting "-1"
**                for the filesize of a directory and not "0" for most filesystems or the number
**                of blocks used as CD-FS, the size is only printed now when it is above now
**                after checking the size of a dir.
**                This means that CD based dirs do not have sizes displayed anymore.
**              - Removed an obsolete "->parent" reference from freezewindows()
**              - Added hot-click feature to DoWindow().
**              - Some general cleanup.
**
** b7
**
** 06-12-27 rri - Added disposal of command-window "button" images as ListBrowser won't free them.
**
** 06-12-28 rri - Added DMTextAttrs[] to replace the single dedicated TextAttr structures.
**
** 06-12-30 rri - Saved DMWindows.c with Window.class windows for possible later use as it turned
**                out that using a Window.class scroller in the bottom border looked bad.
**              - Restored DMWindows.c from backup and re-did the last changes that were not
**                related to Window.class.
**              - When selecting a dir and then clicking fast enough with the menu-button it happened
**                that an additional window was openend.
**              - Activated the select-window-click-in-next-window-to-open-it-there code that
**                I did earlier and commented-out again without adding a comment...
**                ...and fixed it...
**              - Modified collum_expand() to also return TRUE when the collumn is wider than necessary
**                but removed that again, this would only be usefull if it would be for the
**                widest entry in that collumn...
**              - Activated the path-history and removed it again, something is very wrong
**                with that part...
**              - Copied over some chooser-gadget code from DMPreferences.c and while only function
**                it looks like to make a nice addition, deactivated for now again.
**
** 07-01-02 rri - Removed a whole bunch of obsolete vars.
**              - Removed IDCMP_MOUSEBUTTONS and IDCMP_MOUSEMOVE.
**              - Removed the proto for sel_file() - does not exist anymore.
**              - Commented out proto and function freeze_windows(), should be obsolete now.
**              - Made setuplbtags() a lot shorter by avoiding redundancy.
**
** b8
**
** 07-01-02 rri - Fix: forgot to de-select the original dir-entry on select-point-open operations.
**
** 07-01-04 rri - Fix: setuplbtags() does actually print 64 bit file-sizes now.
**                Thanks to Javier de las Rivas for the report!
**
** 07-01-05 rri - Disabled the not used remove_entry().
**
** 07-01-06 rri - Two new functions: attach_list(), detach_list() - these save some bytes,
**                need less typing and changing them has a global impact.
**
** 07-01-08 rri - DoWindow(), update_entry() and append_entry() use attach_list()/detach_list() now.
**              - dis_files() uses detach_list() now.
**              - Added window-activation by RMB and MouseWheel.
**              - attach_list() always uses LISTBROWSER_AUTOFIT, TRUE, now.
**
** b9
**
** 07-01-10 rri - Fix: The DEV/VOL/ASN list showed size, date and protection data.
**                     Thanks to Javier de las Rivas for the report!
**              - Fix: Clicking on the collumn-titles of DEV/VOL/ASN-lists does not
**                     re-sort these list anymore.
**
** b10
**
** 07-01-22 rri - Implemented parent-by-click-on-border.
**
** 07-01-28 rri - Before going a level up or down the file-pattern is cleared now.
**
** 07-02-04 rri - Re-implemented SHIFT-select/deselect for ListBrowser.gadget.
**
** b11
**
** 07-02-10 rri - 68k: disabled the render-hook for command-windows.
**              - 68k: added 2 lines of spacing to the command-windows.
**              - 68k: test - disabled the render-hook for dir-windows.
**              - 68k: partly rewrote the listbrowser render-hook.
**              - 68k: added a workaround for the broken double-click in pre OS4 ListBrowser.gadget
**
** 07-02-25 rri - OpenDirWindow() does not initialise the command-window path anymore.
**
**
*/


#include "DM.h"

#ifdef __NEWLIB__ /* 2.7 rri */
#include <unistd.h>
#endif


extern struct DateStamp setStamp;
extern struct DirList *DClickDir;
extern struct DirWindow *DirWin[],*CDWin,*DestWin,*CmdWin;
extern struct FileInfoBlock     Fib;
//extern struct InfoData InfoData;

#ifdef __amigaos4__ /* 2.5.31 rri */
extern struct Library *GfxBase;
extern struct Library *IntuitionBase;
#else
extern struct GfxBase *GfxBase;
extern struct IntuitionBase *IntuitionBase;
#endif
extern struct Library *LayersBase; /* 2.6 rri */

extern struct Menu *DMMenu;
extern struct MsgPort *WinPort,*NotifyPort; /* 2.5b7 rri */
extern struct Process *process;
extern struct Screen *Screen;//,*MyScreen;

extern struct TextAttr DMTextAttrs[]; /* 2.7b7 rri */

extern struct TextFont *DMFonts[];
extern struct StringHistory PathHistory;  /* 2.5b10 jjt */
extern struct Hook          EditHook;     /* 2.5b10 jjt */
extern struct DirInfo DInfo; /* 2.7 rri */

//extern UWORD Pens20[];

extern UBYTE dcPath[],
//             *DMcmt,   /* 2.5.27 rri */
             DispFormat[], /* 2.6 rri */
             DMname[], /* 2.5RC6 rri */
             PGadStr[],
             sPath[], /* 2.7 rri */
             sbuff[];

extern int // FontSize,
           SortType;

//extern APTR CommentPool; /* 2.5.27 rri */
//extern APTR NamePool; /* 2.5RC6 rri */
extern APTR StringPool; /* 2.5RC6 rri */

extern ULONG FLAGS; /* 2.5RC2 rri */

extern  LONG  Bar_Height, /* 2.5.24 rri */
              separator, /* 2.6 rri */
              sizes; /* 2.6 rri */

extern ULONG  defx, defy, Screen_Width,Screen_Height; /* 2.5.24 rri */

//int LastY;

UBYTE UndoBuff[516],
      WorkBuf[516];  /* 2.5b10 jjt */

WORD zooming[4]; /* 2.5b13 rri */

LONG DirPen, FilePen, BackPen, SelectPen; /* 2.5b12 rri */
//LONG LastI; /* 2.5.23 rri */

uint32 DMicros,
       DSecs;

uint32 DWNum, /* 2.5RC10 rri */
       oldnum = DMMAXWINDOWS + 2, /* 2.7b10 rri */
       oldstate, /* 2.7b10 rri */
       OldDir = DMMAXWINDOWS + 2; /* 2.7b10 rri */

uint16 oldentry = 65535; /* 2.7b10 rri */
int32 oldselections = 65535; /* 2.7b10 rri */

uint32 NewWin_Flags = WFLG_ACTIVATE|WFLG_CLOSEGADGET|WFLG_SIZEGADGET|  /* 2.5.23 gcc rri */
                      WFLG_DRAGBAR|WFLG_DEPTHGADGET|
                      WFLG_SIMPLE_REFRESH| /* 2.7 rri WFLG_SMART_REFRESH| */
                      WFLG_SIZEBBOTTOM| /* 2.7 rri */
                      WFLG_NOCAREREFRESH;

uint32 wheel_multiply = 3; /* 2.6 rri */

#ifndef __amigaos4__ /* 2.7 rri - obsolete with Reaction */
uint32 drag_delay = 5000; /* 2.6 jjt */
#endif

//struct TextAttr ta_dirgad, ta_main, ta_cmdwin; /* 2.7 rri - needed for Reaction */

/*
void freeze_windows(LONG x); // 2.5RC2 rri

void freeze_windows(LONG x) // 2.5RC2 rri
{
struct DirWindow *dw;
LONG i;

for(i=0;i<DMMAXWINDOWS;i++) // 2.5.23 rri
 {
  dw=DirWin[i];
  if(dw&&dw->Window)
   {
    if(x==1)
     {
      dw->Window->MinWidth=dw->Window->Width;
      dw->Window->MaxWidth=dw->Window->Width;
      dw->Window->MinHeight=dw->Window->Height;
      dw->Window->MaxHeight=dw->Window->Height;
     }
    if(x==0)
     {
      dw->Window->MinWidth = dw->Window->BorderLeft + dw->Window->BorderRight + 150;
      dw->Window->MinHeight = dw->Window->BorderTop + dw->Window->BorderBottom + 150;
      dw->Window->MaxWidth=0xFFFF;
      dw->Window->MaxHeight=0xFFFF;
     }
    RefreshGList(dw->dwgadmain, dw->Window, NULL, 1);
   }
 }
}
*/

void DoWindow()
{
struct IntuiMessage *msg;
struct DirWindow *dw;
//struct Gadget *gad;
//static struct Gadget *lastgad; /* 2.5b9 rri */
struct MenuItem *item;
ULONG  class,
       DiskKludge=TRUE;  /* 2.5b12 jjt */
UWORD  code,qual;
uint16 relcode = 0; /* 2.7 rri */
uint32 gid = 0; /* 2.7 rri */
uint32 opt; /* 2.7 rri */
uint32 msgmicros,msgsecs; /* 2.7 rri */
WORD   my;
//int32  id,w,t,hot=0;
struct DirList **dl,*dlp;
struct IntuiWheelData *iwd = NULL; /* 2.7 rri */

while( (msg=(struct IntuiMessage *)GetMsg(WinPort)) != 0 ) /* 2.5.23 gcc rri */
 {
  if(RexxSysBase&&do_rexx_cmd((struct RexxMsg *)msg)) continue;

  code=msg->Code;
  qual=msg->Qualifier;
  class=msg->Class;
  my=msg->MouseY;

  if(CDWin && msg->IDCMPWindow == CDWin->Window) /* 2.5.31 rri */
   {
    DWNum = CDWin->Number;
    dw = CDWin;
   }
  else
   {
    dw = FindDMWin(msg->IDCMPWindow);
    DWNum = dw->Number; /* 2.5.31 rri */
   }

  dl=dw->DirList;

  msgmicros = msg->Micros;
  msgsecs = msg->Seconds;

  /* 2.7 rri */
  switch (class) /* pre-init of some vars before the message is replied */
  {
   /* 2.7b7 rri */
   case IDCMP_ACTIVEWINDOW: /* window activated */
//        DSecs = msg->Seconds;
//        DMicros = msg->Micros;
        /* select-dir-click-next-window-to-open-it-there feature */
/* pretty flaky, maybe best to be re-implemted for use with window.class ... */

        if (!(dw->Flags&DW_CMD) && OldDir < DMMAXWINDOWS && DirWin[OldDir] && DClickDir != 0 && DWNum != OldDir)
        {
         if ( DoubleClick(DSecs,DMicros,msgsecs,msgmicros) )
         {
          dw->Pattern[0] = 0; /* 2.7b10 rri - clear filter-pattern on destination */
          strcpy(sbuff,DirWin[OldDir]->Path);
          AddPart(sbuff,DClickDir->name,4096);
          CloneBuffer(dw,sbuff);

          /* 2.7b8 rri - de-select previously selected entry in other window */
          detach_list(DirWin[OldDir]); /* 2.7b8 rri */
          SetListBrowserNodeAttrs(DClickDir->node, LBNA_Selected, FALSE, TAG_DONE, 0);
          attach_list(DirWin[OldDir],FALSE); /* 2.7b8 rri */
          InitDir(dw,0);
          DClickDir = 0;
         }
        }

   case IDCMP_IDCMPUPDATE:
        relcode = GetTagData(LAYOUT_RelCode, 0, msg->IAddress);
        gid = GetTagData(GA_ID, 42, msg->IAddress);

        if (gid == GID_List) /* store the time in case a dir was single-selected */
        {
         GetAttr(LISTBROWSER_RelEvent, dw->dwgad[GID_List], &opt);
         if (opt == LBRE_NORMAL)
         {
          dlp=dl[relcode];

#ifndef __amigaos4__ /* 2.7b11 rri - simulate double-clicks for broken pre V52 ListBrowser.gadget */
          if (DWNum == oldnum) /* same window than before? */
           {
            if (oldentry == relcode) /* a different entry got selected */
             {
              if ( DoubleClick(DSecs,DMicros,msgsecs,msgmicros) )
              {
               if(dlp->dir&&dlp->dir<3) /* dir double-clicked ? */
                {
                 dw->Pattern[0] = 0; /* clear filter-pattern on destination */
                 strcpy(sbuff,dw->Path);
                 AddPart(sbuff, dlp->name, 4096); /* in case of error nothing is changed! */
                 CloneBuffer(dw,sbuff);
                 InitDir(dw,0);
                }
               else if(!dlp->dir)
                {
                 AutoFiler(dw,dlp->name);
                }
               WinTitle(dw);
               DClickDir = 0;
               OldDir = DMMAXWINDOWS + 2;
               break;
              }
             }
           }
#endif

         if (dlp->dir && dlp->dir < 3) /* user selected a dir */
          {
//           DSecs = msg->Seconds;
//           DMicros = msg->Micros;
           DClickDir = dlp;
           OldDir = DWNum;
          }
          else if (dlp->dir == 0) /* 2.7b7 rri */ /* user selected a file */
          {
           DClickDir = 0;
           OldDir = DMMAXWINDOWS + 2;
          }
// test!
          DSecs = msg->Seconds;
          DMicros = msg->Micros;
         }
        }
        break;

#ifdef __amigaos4__
   case IDCMP_EXTENDEDMOUSE:
        iwd = (struct IntuiWheelData *)msg->IAddress;
#endif

   /* 2.7b8 rri */
   case IDCMP_MENUPICK:
        /* limited sun-mouse support to activate DM2 windows on RMB */
        if (1)
        {
         struct Layer_Info *li;
         struct Layer *layer;
         WORD sx,sy;
         struct Window *lwin = NULL;
         uint32 i;

         sx = Screen->MouseX;
         sy = Screen->MouseY;
         li = &Screen->LayerInfo;

         LockLayerInfo(li);
         if ((layer = WhichLayer(li,sx,sy)))
         {
          lwin = layer->Window; /* this is the window under the mouse-pointer */
         }
         UnlockLayerInfo(li);

         if (lwin != NULL && lwin != dw->Window) /* the window found is not the current one */
         {
          for(i=0;i<DMMAXWINDOWS;i++)
          {
           if(DirWin[i] && lwin == DirWin[i]->Window)
           {
            ActivateWindow(DirWin[i]->Window); /* ...activate it */
            DClickDir = 0;
            dw = DirWin[i]; /* make this the current window */
            DWNum = dw->Number;
            dl=dw->DirList;
            break;
           }
          }
         }
        }
        break;

    default: break;
  };

  ReplyMsg((struct Message *)msg);

  if (dw)
   {
    switch (class)
    {
     case IDCMP_MOUSEBUTTONS: /* 2.7b10 rri */ /* parent by click on border ... */
                   if (code == SELECTDOWN && dw == CDWin)
                   {
                    dw->Pattern[0] = 0; /* 2.7b10 rri - clear filter-pattern on destination */
                    strcpy(sbuff,dw->Path);
                    GetParent(sbuff,1);
                    CloneBuffer(dw,sbuff);
                    InitDir(dw,0);
                   }
                   break;

     case IDCMP_DISKINSERTED:
                   Delay(25);
                   ReSort();

     case IDCMP_DISKREMOVED:  /* 2.5b12 jjt */
                   if (DiskKludge) {  /* 2.5b12 jjt */
                    /* Every open window will send a DISKINSERTED/REMOVED,
                      so only act on one. */
                    RefreshDevLists();
                    DiskKludge = FALSE;
                   }
                   break;

     case IDCMP_CHANGEWINDOW: /* 2.6 rri */
                   if(dw->Window->Flags&WFLG_ZOOMED) /* 2.5b13 rri */
                   {
                    dw->zoom[0]=dw->Window->LeftEdge;
                    dw->zoom[1]=dw->Window->TopEdge;
                    dw->zoom[2]=dw->Window->Width;
                    dw->zoom[3]=dw->Window->Height;
                   }
                   else /* 2.5b13 rri */
                   {
                    dw->norm[0]=dw->Window->LeftEdge;
                    dw->norm[1]=dw->Window->TopEdge;
                    dw->norm[2]=dw->Window->Width;
                    dw->norm[3]=dw->Window->Height;
                   }
                   break;

     case IDCMP_VANILLAKEY:
     case IDCMP_RAWKEY:
// 2.7 rri - test! works better without somehow... if (code != 13) /* Ignore Returns (string gad kludge) */ /* 2.6 jjt */
                   {
                    DoKeyCmd(dw,code,qual,class);
                   }
                   break;

     case IDCMP_CLOSEWINDOW:
                   CloseDirWindow(DWNum);
                   break;

     case IDCMP_IDCMPUPDATE:

                   if(FLAGS&DMFLAG_RESET) /* 2.7 rri - no idea why this has to be here but */
                   {                      /* without this 'Auto' does not work as DMFLAG_RESET */
                    FLAGS&=~DMFLAG_RESET; /* is set which bring things to halt in DoCmd()... */
                   }

                   if(gid == GID_String)
                   {
                    STRPTR newpath;

                    dw->Pattern[0]=0;
                    GetAttr(STRINGA_TextVal, dw->dwgad[GID_String], (ULONG *)(void *) &newpath);
                    CloneBuffer(dw,newpath);
                    if(FindPattern(dw->Path))
                    {
                     Separate(dw);
                    }
                    InitDir(dw,0);
                    break;
                   }

                   else if (gid == GID_BParent && dw == CDWin)
                   {
                    SplitLine(PGadStr,CmdWin);
                    break;
                   }
                   else if (gid == GID_List)
                   {
                    GetAttr(LISTBROWSER_RelEvent, dw->dwgad[GID_List], &opt);

                    dlp=dl[relcode];

                    switch (opt)
                    {
                     case LBRE_TITLECLICK:

                       if (dw->Path[0] != 0) /* 2.7b9 rri */ /* only allow operation on normal dir-windows */
                       {
                        if ( dw->Sorting == DInfo.sorting[relcode])
                        {
                         dw->Sorting++;
                        }
                        else
                        {
                         dw->Sorting = DInfo.sorting[relcode];
                        }
                        dw->Flags|=DWFLAG_RESORT;
                        ReSort();
                       }
                       break;

                     case LBRE_NORMAL:

                        if(dw->Flags&DW_CMD /*dlp->dir==3*/) /* 2.7b10 rri */ /* selected command-window entry? */
                        {
                         if(FLAGS&DMFLAG_CHGCMD)
                         {
                          EditCmd(dw,(int) relcode);
                         }
                         else
                         {
                          UBYTE *cmd_line;                        /* clone cmd-line in case there is */

                          cmd_line=CloneStr(dlp->cmt,StringPool); /* a 'Close' in it which would */
                          ActionCmd(dw->Number,cmd_line);         /* remove the line from memory */
                          PoolFreeVec(cmd_line);
                      /*
                          if(CDWin&&CmdWin&&CmdWin->Window->Flags&WFLG_WINDOWACTIVE)
                          {
                           ActivateWindow(CDWin->Window);
                          }
                      */
                         }
                        }

                        /* 2.7b10 rri */
                        else
                        {
                         int32 selections;
                         uint32 selectstate;

                         if (DWNum == oldnum) /* same window than before? */
                         {
                          if (oldentry != relcode) /* a different entry got selected */
                          {
                           GetAttr(LISTBROWSER_NumSelected,dw->dwgad[GID_List], &selections);

                           if (selections == (oldselections +1) || selections == (oldselections -1) ) /* no drag-selection */
                           {
                            GetListBrowserNodeAttrs(dlp->node, LBNA_Selected, &selectstate, TAG_DONE, 0);

                            if (selectstate == oldstate)
                            {
                             qual = PeekQualifier(); /* needed because BOOPSI eats qualifiers... */

                             if (qual&0x0003) /* if left or right SHIFT is pressed */
                             {
                              uint16 xx;

                              if (oldentry > relcode) /* we want to go top to bottom */
                              {
                               xx = oldentry;
                               oldentry = relcode;
                               relcode = xx;
                              }

                              detach_list(dw);
                              for (xx=oldentry+1;xx<relcode;xx++)
                              {
                               SetListBrowserNodeAttrs(dl[xx]->node, LBNA_Selected, selectstate, TAG_DONE, 0);
                              }
                              attach_list(dw,FALSE);
                              GetAttr(LISTBROWSER_NumSelected,dw->dwgad[GID_List], &selections);
                             }
                            }
                           }
                          }
                        }
                         oldnum = DWNum;
                         oldentry = relcode;
                         oldselections = selections;
                         oldstate = selectstate;
                        }

                       WinTitle(dw);
                       break;

                     case LBRE_DOUBLECLICK:

                          if(dlp->dir&&dlp->dir<3) /* dir double-clicked ? */
                          {
                           dw->Pattern[0] = 0; /* 2.7b10 rri - clear filter-pattern on destination */
                           strcpy(sbuff,dw->Path);
                           AddPart(sbuff, dlp->name, 4096); /* in case of error nothing is changed! */
                           CloneBuffer(dw,sbuff);
                           InitDir(dw,0);
                          }
                          else if(!dlp->dir)
                          {
                           AutoFiler(dw,dlp->name);
                          }

                          WinTitle(dw);
                          DClickDir = 0; /* 2.7b7 rri */
                          break;
                    }
                   }
                  break;

#ifdef __amigaos4__
    case IDCMP_EXTENDEDMOUSE:
                   if (code & IMSGCODE_INTUIWHEELDATA)
                    {
                     int32 position;

                     if ((qual&0x0003) && iwd->WheelY != 0) /* if left- or right-shift is pressed... */
                      {
                       iwd->WheelX = iwd->WheelY;
                      }

                     if (iwd->WheelX != 0)
                      {
                       GetAttr(LISTBROWSER_Left,dw->dwgad[GID_List], &position);
                       position += iwd->WheelX * wheel_multiply * 8;
                       SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,LISTBROWSER_Left,position, TAG_END,0);
                      }
                     if (iwd->WheelY != 0 && !(qual&0x0003))
                      {
                       GetAttr(LISTBROWSER_Top,dw->dwgad[GID_List], &position);
                       position += iwd->WheelY * wheel_multiply;
                       if (position < 0)
                        {
                         position = 0;
                        }
                       SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,LISTBROWSER_Top,position, TAG_END,0);
                      }
                    }
                   break;
#endif

     case IDCMP_MENUPICK:
                        if((item=ItemAddress(DMMenu,(ULONG) code))) /* 2.5.23 gcc rri */
                         {
                          ActionCmd(DWNum, GTMENUITEM_USERDATA(item)); /* 2.5RC10 rri */
                          break;
                         }

                        /* hotclick-window feature! */
                        if ( DClickDir != 0)
                        {
                         if ( DoubleClick(DSecs,DMicros,msgsecs,msgmicros) )
                         {
                          uint32 pos;

                          strcpy(sbuff,CDWin->Path);
                          AddPart(sbuff,DClickDir->name,4096);
                          detach_list(CDWin); /* 2.7b8 rri */
                          SetListBrowserNodeAttrs(DClickDir->node, LBNA_Selected, FALSE, TAG_DONE, 0);
                          attach_list(CDWin,FALSE); /* 2.7b8 rri */
                          zooming[0]=CDWin->zoom[0];
                          zooming[1]=CDWin->zoom[1];
                          zooming[2]=CDWin->zoom[2];
                          zooming[3]=CDWin->zoom[3];
                          pos = CDWin->Window->TopEdge;
                          OpenDirWindow(sbuff,CDWin->Window->LeftEdge,
                                        ((my+pos-50) < pos) ? pos : (my+pos-50),
                                        CDWin->Window->Width, 200);
                          WinTitle(DestWin);
                          DClickDir = 0;
                          break;
                         }
                        }
                        break;

     case IDCMP_NEWSIZE:
        if (dw->Flags&DW_CMD)
        {
         RefreshCmdWin(dw);
        }
     break;

     default:  break;
    };
   }
 }
}


void RefreshGadget(struct Gadget *gad,struct Window *win)
{
 RefreshGList(gad,win,NULL,1); /* 2.5RC2 rri */
}


/*- ListBrowser.gadget list-handling -*/


void attach_list(struct DirWindow *dw, uint32 autofit)
{
 SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL, GA_ReadOnly, FALSE,
                                                       LISTBROWSER_Labels, &dw->dwgadlist,
                                                       LISTBROWSER_AutoFit, TRUE, // test!
                                                    //   LISTBROWSER_AutoFit, autofit,
                                                       GA_ReadOnly, (FLAGS&DMFLAG_READONLY) ? TRUE : FALSE,
                                                       TAG_END, 0);

}


void detach_list(struct DirWindow *dw)
{
 SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,LISTBROWSER_Labels, NULL, TAG_END,0);
}



/* 2.7 rri */ /* this is only needed for the pre-OS4 ListBrowser.gadget */
#ifndef __amigaos4__
uint32 SAVEDS ASM lb_hook(REG(a0, struct Hook *hook),
                          REG(a2, struct Node *node),
                          REG(a1, struct LBDrawMsg *msg))
{
 STRPTR data;
 struct DirList *dlp=NULL;
 uint32 Ap=FilePen,Bp=BackPen;
 uint32 justification;
 uint32 length;

 if(msg->lbdm_MethodID != LV_DRAW)
 {
  return(LBCB_UNKNOWN);
 }

 GetListBrowserNodeAttrs(node, LBNA_UserData, (ULONG *)(void *) &dlp,
                               LBNA_Column, (uint32) hook->h_Data,
                               LBNCA_Text, (ULONG *)(void *) &data,
                               LBNCA_Justification, &justification,
                               TAG_DONE,0);

 if(msg->lbdm_State == LBR_SELECTED)
 {
  Bp=SelectPen;
  if (SelectPen==BackPen) Bp++;
 }
 if(dlp->dir && dlp->dir < 3) Ap=DirPen;

 if(Ap==Bp) Ap++;

 SetBPen(msg->lbdm_RastPort,Bp);

 /* clear the line */
 SetAPen(msg->lbdm_RastPort,Bp);
 RectFill(msg->lbdm_RastPort, msg->lbdm_Bounds.MinX, msg->lbdm_Bounds.MinY,
                              msg->lbdm_Bounds.MaxX, msg->lbdm_Bounds.MaxY);
 SetAPen(msg->lbdm_RastPort,Ap);

 if (data == NULL || *data == 0) /* empty cell, just leave here */
 {
  return(LBCB_OK);
 }

 length = strlen(data);

 if (justification == LCJ_RIGHT)
 {
  Move(msg->lbdm_RastPort,
       msg->lbdm_Bounds.MaxX - TextLength(msg->lbdm_RastPort,data,length),
       msg->lbdm_Bounds.MinY + msg->lbdm_RastPort->TxBaseline);
 }
 else
 {
  Move(msg->lbdm_RastPort,
       msg->lbdm_Bounds.MinX,
       msg->lbdm_Bounds.MinY + msg->lbdm_RastPort->TxBaseline);
 }

 Text(msg->lbdm_RastPort,data,length);

 return(LBCB_OK);
}
#endif


/* 2.7 rri */
char lbtime[16],
     lbdate[16],
     lbdigit[20], /* 2.7b8 rri */
     lbprotectbits[10];

struct TagItem * setuplbtags(struct DirWindow *dw,struct DirList *dlp)
{
UBYTE *dptr=DispFormat,*ptr2;

int32 c, // counter for tags
      column;

struct BaseConvert winbase;
struct DateTime DateTime;

struct TagItem * listtags;

uint32 Ap=FilePen,Bp=BackPen,Fp=SelectPen;

DateTime.dat_Format  = FORMAT_DEF;
DateTime.dat_Flags   = 0;
DateTime.dat_StrDay  = NULL;
DateTime.dat_StrDate = lbdate;
DateTime.dat_StrTime = lbtime;

if(dw->Flags&DW_CMD)
 {
  Ap=dlp->attr&0xF;
  Bp=(dlp->attr>>4)&0xF;
  if(Ap == Bp) Ap++;
 }
else /* set colors for dir-window entries */
 {
  if (SelectPen==BackPen) Fp++;
  if(dlp->dir && dlp->dir < 3) Ap=DirPen;
  if(Ap == Bp || Ap == Fp) Ap++;
 }

DateTime.dat_Stamp=dlp->ds;
DateToStr(&DateTime);

if(FLAGS & DMFLAG_TIMEPLUS)
 {
  sprintf(lbdigit,":%02ld",dlp->ds.ds_Tick % 50);
  DMstrcat(lbtime,lbdigit);
 }
else
 {
  lbtime[5]=0;
 }

c=0;
column=0;
listtags = (struct TagItem *) PoolAllocVec(StringPool, sizeof(struct TagItem) * (DInfo.num * 20));

if(dw->Flags&DW_CMD)
 {
  struct Image *cmd_button=NULL;
  uint16 style=BVS_BUTTON;
  uint32 flags=LBFLG_CUSTOMPENS;

  if (!dlp->name)
  {
   style = BVS_SBAR_VERT;
   flags |= LBFLG_READONLY;
  }

  cmd_button = BevelObject, BEVEL_Label, dlp->name,
       BEVEL_LabelPlace, BVJ_IN_LEFT,
       BEVEL_Style, style,
       BEVEL_TextPen, Ap,
       BEVEL_FillPen, Bp,
       BevelEnd;

  listtags[c].ti_Tag = LBNA_Column;
  listtags[c++].ti_Data = column;
  listtags[c].ti_Tag = LBNA_Flags;
  listtags[c++].ti_Data = flags;

  listtags[c].ti_Tag = LBNCA_Image;
  listtags[c++].ti_Data = (uint32) cmd_button;

  listtags[c].ti_Tag = LBNCA_Justification;
  listtags[c++].ti_Data = LCJ_LEFT;

  listtags[c].ti_Tag = LBNA_UserData;
  listtags[c++].ti_Data = (uint32) dlp;

#ifdef __amigaos4__

#else
/* no render-hook for command-windows!
  dw->columnhook[column].h_Entry = (HOOKFUNC) lb_hook;
  dw->columnhook[column].h_SubEntry = NULL;
  dw->columnhook[column].h_Data = (APTR) column;
  listtags[c].ti_Tag = LBNCA_RenderHook;
  listtags[c++].ti_Data = (uint32) &dw->columnhook[column];
*/
#endif
 }

else /* we have a file-lister entry */

 {
#ifdef __amigaos4__
  listtags[c].ti_Tag = LBNA_Flags;
  listtags[c++].ti_Data = LBFLG_CUSTOMPENS;
#endif
  listtags[c].ti_Tag = LBNA_UserData;
  listtags[c++].ti_Data = (uint32) dlp;

  dptr=DispFormat;

  while(*dptr)
   {

    /* 2.7b7 rri - these are always the same for all options so need to make this redundant */
    switch(ToUpper(*dptr))
    {
     case 'N':
     case 'C':
     case 'S':
     case 'T':
     case 'D':
     case 'A':

               listtags[c].ti_Tag = LBNA_Column;
               listtags[c++].ti_Data = column;
               listtags[c].ti_Tag = LBNCA_CopyText;
               listtags[c++].ti_Data = TRUE;

#ifdef __amigaos4__
               listtags[c].ti_Tag = LBNCA_FGPen;
               listtags[c++].ti_Data = Ap;
               listtags[c].ti_Tag = LBNCA_BGPen;
               listtags[c++].ti_Data = Bp;
               listtags[c].ti_Tag = LBNCA_FillPen;
               listtags[c++].ti_Data = Fp;
#else
#if 1 // test!
               dw->columnhook[column].h_Entry = (HOOKFUNC) lb_hook;
               dw->columnhook[column].h_SubEntry = NULL;
               dw->columnhook[column].h_Data = (APTR) column;
               listtags[c].ti_Tag = LBNCA_RenderHook;
               listtags[c++].ti_Data = (uint32) &dw->columnhook[column];
#endif
#endif
               column++;
               break;
     default:  break;
   }

    switch(ToUpper(*dptr++))
     {
      case 'N': listtags[c].ti_Tag = LBNCA_Text;
                listtags[c++].ti_Data = (uint32) dlp->name;
          //      listtags[c].ti_Tag = LBNCA_Editable;
          //      listtags[c++].ti_Data = TRUE;
          //      listtags[c].ti_Tag = LBNCA_MaxChars;
          //      listtags[c++].ti_Data = 110;
                break;

      case 'C': listtags[c].ti_Tag = LBNCA_Text;
                if(dlp->dir==2)
                 {
                  ptr2=0;
                  if(dlp->attr==DLT_DEVICE) ptr2="(DEV)";
                  else if(dlp->attr==DLT_VOLUME) ptr2="(VOL)";
                  else if(dlp->attr==DLT_DIRECTORY) ptr2="(ASN)";
                 }
                else
                 {
                  ptr2=dlp->cmt;
                 }
                listtags[c++].ti_Data = (ULONG) ptr2;
        //        listtags[c].ti_Tag = LBNCA_Editable;
        //        listtags[c++].ti_Data = TRUE;
        //        listtags[c].ti_Tag = LBNCA_MaxChars;
        //        listtags[c++].ti_Data = 80;
                break;

      case 'S':
                if (dlp->dir>1) break; /* 2.7b9 - no sizes for Dev/Vol/Asn - List */
                listtags[c].ti_Tag = LBNCA_Justification;
                listtags[c++].ti_Data = LCJ_RIGHT;
                listtags[c].ti_Tag = LBNCA_Text;
                winbase.BlocksFree=dlp->size;
                *sbuff = 0;
                sbuff[0] = 0;
                if(dlp->dir==1)
                 {
                  if(dlp->size > 0) /* 2.7 rri ExamineDir() breaks compatibility which this field */
                   {
                    winbase.BytesPerBlock=dw->BytesPerBlock;
                    ConvertBase(&winbase);
                    sprintf(sbuff,"%s",winbase.String);
                   }
                 }
                else if (dlp->dir < 1)
                 {
                  if(sizes==1)
                   {
                    sprintf(sbuff,"%lld",dlp->size); /* 2.7b8 rri */
                   }
                  if(sizes==2)
                   {
                    winbase.BytesPerBlock=1;
                    ConvertBase(&winbase);
                    sprintf(sbuff,"%s",winbase.String);
                   }

                  if(sizes==3)
                   {
                    int32 ai=0, xi=0, ci;

                    sprintf(lbdigit,"%lld",dlp->size); /* 2.7b8 rri */
                    ci = ((strlen(lbdigit) % 3) * 2) % 3; // 1=2; 2=1; 3=0; 4=2; 5=1; 6=0; 7=2; 8=1; 9=0; ...

                    while(lbdigit[xi])
                     {
                      if(ci==3)
                       {
                        sbuff[ai++]=separator; /* insert separator every three chars */
                        ci=0;
                        continue;
                       }
                      sbuff[ai++] = lbdigit[xi++];
                      ci++;
                     }
                    sbuff[ai] = 0;
                  }
                 }
                listtags[c++].ti_Data = (ULONG) sbuff;
                break;

      case 'T': if(dlp->dir<2) /* 2.7b9 - no display for Dev/Vol/Asn - List */
                {
                 listtags[c].ti_Tag = LBNCA_Text;
                 listtags[c++].ti_Data = (ULONG) lbtime;
                }
                break;

      case 'D': if(dlp->dir<2) /* 2.7b9 - no display for Dev/Vol/Asn - List */
                {
                 listtags[c].ti_Tag = LBNCA_Text;
                 listtags[c++].ti_Data = (ULONG) lbdate;
                }
                break;

      case 'A': if(dlp->dir<2) /* 2.7b9 - no display for Dev/Vol/Asn - List */
                {
                 listtags[c].ti_Tag = LBNCA_Text;
                 StampProt(lbprotectbits,dlp->attr);
                 listtags[c++].ti_Data = (ULONG) lbprotectbits;
//                listtags[c].ti_Tag = LBNCA_MaxChars;
//                listtags[c++].ti_Data = 8;
                }
                break;

      default:  break;

      } /* switch ... */
    } /* while ... */
 } /* dlp->sel < 2 ... */
listtags[c].ti_Tag = TAG_DONE;
return(listtags);

}


/* 2.7 rri */
/*
   returns TRUE if one of the collumns is too narrow to display the text
 */
BOOL collumn_expand(struct DirWindow *dw,struct Node *node)
{
int16 width;
int32 x;
STRPTR text;
struct IntuiText itext;

 memset (&itext, 0, sizeof (itext));
 itext.ITextFont = &DMTextAttrs[DMFONTS_MAIN]; /* 2.7b7 rri */

 for (x=0;x<DInfo.num;x++)
 {
  GetListBrowserNodeAttrs(node, LBNA_Column, x,
                                LBNCA_Text, (ULONG *)(void *) &text,
                                TAG_DONE,0);
  if (text)
  {
   itext.IText = text;
   width = IntuiTextLength(&itext) + 3; /* the "+3" is bad style !!! */
  }
  else
  {
   width = 0;
  }

  if (width > dw->dwgadcollumn[x].ci_Width) // || dw->dwgadcollumn[x].ci_Width > width) /* 2.7b7 rri */
  {
//   Printf("%s %ld %ld\n",text,dw->dwgadcollumn[x].ci_Width, width); // test!
   return TRUE;
//   dw->dwgadcollumn[x].ci_Width = width; // test!
  }
 }
return FALSE;
}



/* 2.7 rri */ /* modify an entry while the list is attached */
void update_entry(struct DirWindow *dw, struct DirList *dlp)
{
struct TagItem * listtags;
BOOL autofit;

listtags = setuplbtags(dw,dlp);

detach_list(dw); /* 2.7b8 rri */
SetListBrowserNodeAttrsA(dlp->node, listtags);
autofit = collumn_expand(dw, dlp->node);
attach_list(dw,autofit); /* 2.7b8 rri */

PoolFreeVec(listtags);
}


/* 2.7 rri */ /* append a new entry to the end of the attached list */
void append_entry(struct DirWindow *dw, struct DirList *dlp)
{
struct TagItem * listtags;
struct Node *node;
BOOL autofit = FALSE;

listtags = setuplbtags(dw,dlp);

detach_list(dw); /* 2.7b8 rri */

if ((node = AllocListBrowserNodeA(DInfo.num,listtags)))
{
 dlp->node = node;
 AddTail(&dw->dwgadlist, node);
 autofit = collumn_expand(dw, dlp->node);
}

attach_list(dw,autofit); /* 2.7b8 rri */

PoolFreeVec(listtags);
}


/* 2.7 rri */ /* remove an entry from the list while it is attached */
/* not needed, smartrementry() works without it! */
/*
void remove_entry(struct DirWindow *dw, struct DirList *dlp)
{

if (dlp && dw)
{

}

//SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,LISTBROWSER_Labels, NULL, TAG_END,0);

//SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL, LISTBROWSER_Labels, &dw->dwgadlist, TAG_END, 0);
}
*/


/* 2.7 rri */ /* add a new entry to the end of the list while it is detached */
void add_entry(struct DirWindow *dw,LONG file)
{
struct DirList **dl,*dlp;
struct Node *node;
struct TagItem * listtags;

if( !dw || !dw->Window || DInfo.num == 0 || dw->FileCount == 0)
 {
  return;
 }

dl=dw->DirList;
dlp=dl[file];

listtags = setuplbtags(dw,dlp);
if ((node = AllocListBrowserNodeA(DInfo.num,listtags)))
 {
  dlp->node = node;
  AddTail(&dw->dwgadlist, node);
 }
PoolFreeVec(listtags);
}


void dis_name(struct DirWindow *dw,LONG file,LONG pos)
{
if (dw && file && pos)
{

}

}


void dis_files(struct DirWindow *dw)
{
int32 i=0; /* 2.6 rri */

/* 2.7 rri */
detach_list(dw); /* 2.7b8 rri */
FreeListBrowserList(&dw->dwgadlist);
NewList(&dw->dwgadlist);

for(i=0;i < dw->FileCount;i++)
{
 add_entry(dw,i); /* reset node by node */
}

SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,
                                                LISTBROWSER_Labels, &dw->dwgadlist,
                                                LISTBROWSER_Top, 0,
                                                LISTBROWSER_AutoFit, TRUE,
                                                TAG_END,0);
WinTitle(dw);
}


void ShowDirection(struct DirWindow *dw,int n)
{
STRPTR buttonlabels[] = { "S","D","C"," ",NULL };

if(dw)
 {
  if(dw->Flags&DW_SOURCE) n=0;
  if(dw->Flags&DW_DEST) n=1;
  if(dw->Flags&DW_CMD) n=2;
  if(n==4)
   {
    n=1;
    if(dw==CDWin) n=0;
   }

  SetGadgetAttrs(dw->dwgad[GID_BParent],dw->Window, NULL,
                          GA_Text, buttonlabels[n],
                          TAG_END,0);
 }
}


void NewSize(struct DirWindow *dw)
{
 dis_files(dw);
}


/* --------------------- Open/Close windows -------------------------------- */

void FindNewDirection(struct DirWindow *dw)
{
struct DirWindow *dw2;
int i=0;

if(dw == CmdWin)
 {
  CmdWin = NULL;
  if(dw == CDWin) CDWin = NULL;
  for(i=DMMAXWINDOWS-1;i>=0;i--) /* 2.5.23 rri */
   {
    if((dw2=DirWin[i])) /* 2.5.23 gcc rri */
     {
      if(dw2->Flags&DW_CMD)
       {
        CmdWin=dw2;
        DWNum=i;
        return;
       }
     }
        return;
   }
 }

if(dw == DestWin)
 {
  DestWin = NULL;
  i=1;
 }
if(dw == CDWin)
 {
  CDWin = DestWin;
  i=1;
 }

if(i)
 {
  for(i=DMMAXWINDOWS-1;i>=0;i--) /* 2.5.23 rri */
   {
    if((dw2=DirWin[i])) /* 2.5.23 gcc rri */
     {
      if(dw2->Flags&DW_CMD)
       {
        DWNum=i;
        ShowDirection(dw2,2);
       }
      else if(CDWin==dw2) DWNum=i;
      else
       {
        DestWin=dw2;
        break;
       }
     }
   }
  ShowDirection(DestWin,1);
  ShowDirection(CDWin,0);
 }
}


void CloseDirWindow(ULONG num) /* 2.5RC10 rri */
{
struct DirWindow *dw=DirWin[num];
struct DirList **dl,*dlp; /* 2.7 rri */
struct Image *cmd_button; /* 2.7 rri */
int32 i; /* 2.7 rri */

 if(dw == NULL) return; /* 2.7 rri */

 ClearMenuStrip(dw->Window);
 RemoveGList(dw->Window,dw->dwgadmain, -1); /* 2.7 rri */
 CloseSharedWindow(dw->Window);
 DisposeObject(dw->dwgadmain); /* 2.7 rri */
 dw->dwgadmain = NULL;

 if(dw->Fib) FreeDosObject(DOS_FIB,dw->Fib); /* 2.5.28 rri */

 /* 2.7b7 rri - dispose cmd-window "button" images as ListBrowser won't */
 if ( dw->Flags&DW_CMD)
 {
  dl=dw->DirList;

  for(i=0;i<dw->FileCount;i++)
  {
   dlp=dl[i];
   GetListBrowserNodeAttrs(dlp->node, LBNCA_Image, (ULONG *)(void *) &cmd_button, TAG_DONE,0);
   DisposeObject(cmd_button);
  }
 }

 FreeDirTable(dw);
 FreeMem(dw->DirList,(ULONG) (dw->MaxFile<<2)); /* 2.5b10 rri */
 FreeListBrowserList(&dw->dwgadlist); /* 2.7 rri */
 if(dw->dwgadcollumn != NULL)
  {
   PoolFreeVec(dw->dwgadcollumn);
  }

 FreeMem(dw,sizeof(*dw)); /* 2.5.23 rri */
 DirWin[num]=NULL;

 FindNewDirection(dw); /* calling with a now invalid pointer!! */

 for(i=0;i<DMMAXWINDOWS;i++) if(DirWin[i] != NULL) /* 2.7 rri */
  {
   if(!DirWin[DWNum]) DWNum=i;
   process->pr_WindowPtr=(APTR)DirWin[i]->Window;
   break;
  }

 if(i==DMMAXWINDOWS) /* 2.5.23 rri */
  {
   process->pr_WindowPtr=(APTR)-1;
   FLAGS&=~DMFLAG_KEEPGOING; /* 2.5RC2 rri */
  }
}


int OpenDirWindow(UBYTE *path,int Left,int Top,int Wid,int Hi) /* 2.7 rri */
{
struct DirWindow *dw;
struct NewWindow *NewWin;
struct DirList **dlist;
int returncode=0,h;
int32 dwc=0, maxf=500,x;
BOOL columntitles = TRUE;

while(DirWin[dwc]) dwc++;
if(dwc>DMMAXWINDOWS) return returncode;

if(Top < Bar_Height)
 {
  Top=Bar_Height+1;
 }

if(Left<0) Left=0;

/* scale window-layout based on given default screen-dimensions */
if(defx&&defy&&(FLAGS&DMFLAG_BATCH))
 {
  Left = ScalerDiv((ULONG)Left,Screen_Width,defx);
  if (Top > (Bar_Height+1) )
   {
    Top  = ScalerDiv((ULONG)Top,Screen_Height,defy);
   }
  Wid  = ScalerDiv((ULONG)Wid,Screen_Width,defx);
  Hi   = ScalerDiv((ULONG)Hi,Screen_Height,defy);

  zooming[0] = ScalerDiv((ULONG)zooming[0],Screen_Width,defx);
  zooming[1] = ScalerDiv((ULONG)zooming[1],Screen_Height,defy);
  zooming[2] = ScalerDiv((ULONG)zooming[2],Screen_Width,defx);
  zooming[3] = ScalerDiv((ULONG)zooming[3],Screen_Height,defy);
 }

if(Top < Bar_Height)
 {
  Top=Bar_Height+1;
 }

if(Left<0) Left=0;
if(Wid<=0) Wid=Screen_Width-Left;
if(Wid<100) Wid=150;
if(Hi<= 0) Hi=Screen_Height-Top;
if(Hi< 100) Hi=150;

while((Left+Wid) > (LONG) Screen_Width)
 {
  if(Wid>150) Wid--;
  else if(Left) Left--;
 }
while((Top+Hi) > (LONG) Screen_Height)
 {
  if(Hi>150) Hi--;
  else if(Top) Top--;
 }

if((dw=AllocMem(sizeof (*dw),MEMF_ANY | MEMF_CLEAR)))
 {
  if((dlist=AllocMem((maxf<<2),MEMF_ANY | MEMF_CLEAR)))
   {
    if((NewWin=AllocMem(sizeof(*NewWin),MEMF_ANY | MEMF_CLEAR)))
     {
      NewWin->Screen=Screen;
      NewWin->LeftEdge=Left;
      NewWin->TopEdge=Top;
      NewWin->Width=Wid;
      NewWin->Height=Hi;
      NewWin->IDCMPFlags=IDCMP_ACTIVEWINDOW|IDCMP_CLOSEWINDOW|
                         IDCMP_CHANGEWINDOW|
                         IDCMP_NEWSIZE|
                         IDCMP_MOUSEBUTTONS| // test!
                         IDCMP_IDCMPUPDATE|
                         IDCMP_DISKINSERTED|IDCMP_DISKREMOVED|
                         // test! IDCMP_GADGETDOWN|IDCMP_GADGETUP|
                         IDCMP_MENUPICK|
                         #ifdef __amigaos4__
                         IDCMP_EXTENDEDMOUSE|
                         #endif
                         IDCMP_RAWKEY|IDCMP_VANILLAKEY;
      NewWin->Flags=NewWin_Flags;
      NewWin->DetailPen=0;
      NewWin->BlockPen=1;

      NewWin->MinWidth=150;
      NewWin->MinHeight=150;

      NewWin->MaxWidth=0xFFFF;
      NewWin->MaxHeight=0xFFFF;
      NewWin->Type=CUSTOMSCREEN;

      CloneBuffer(dw,0);
      NewWin->Title=DMname;
      dw->Sorting=SortType;

      dw->DM2NotifyReq.nr_stuff.nr_Signal.nr_Task = (struct Task *) FindTask(NULL);
      dw->DM2NotifyReq.nr_Flags = NRF_SEND_MESSAGE;
      dw->DM2NotifyReq.nr_stuff.nr_Msg.nr_Port=NotifyPort;
      dw->DM2NotifyReq.nr_UserData = 0;

      dw->zoom[0]=zooming[0];
      dw->zoom[1]=zooming[1];
      dw->zoom[2]=zooming[2];
      dw->zoom[3]=zooming[3];
      dw->norm[0]=Left;
      dw->norm[1]=Top;
      dw->norm[2]=Wid;
      dw->norm[3]=Hi;

      if(path!=0 && Stricmp(path,"CMD")==0)
       {
        NewWin->Title=0;
        dw->dwgadcollumn = NULL; /* no collum-info for cmd-windows */
        columntitles = FALSE;
       }
      else
       {
        dw->dwgadcollumn = (struct ColumnInfo *) PoolAllocVec(StringPool,
                            sizeof(struct ColumnInfo) * (DInfo.num+1));

        for (x=0;x<DInfo.num;x++)
         {
          dw->dwgadcollumn[x].ci_Width = 100;
          dw->dwgadcollumn[x].ci_Title = DInfo.titles[x];
          dw->dwgadcollumn[x].ci_Flags = CIF_WEIGHTED|CIF_DRAGGABLE|CIF_SORTABLE;
         }

        dw->dwgadcollumn[x].ci_Width = -1;
        columntitles = TRUE;
      }

      NewList(&dw->dwgadlist);

      dw->dwgadmain = VGroupObject,
          LAYOUT_SpaceOuter, FALSE,
          LAYOUT_SpaceInner, FALSE,
          LAYOUT_DeferLayout, TRUE,
           LAYOUT_AddChild, LayoutObject,
            GA_RelVerify, TRUE,
            LAYOUT_SpaceInner, FALSE,
             LAYOUT_AddChild, dw->dwgad[GID_String] = StringObject,
              GA_ID, GID_String,
              GA_RelVerify, TRUE,
//              GA_GadgetHelp, TRUE,
              GA_TabCycle, TRUE,
              STRINGA_MaxChars, 512,
              STRINGA_MinVisible, 0,
//              GA_UserData, &PathHistory,   // 2.7b7 rri
//              STRINGA_EditHook, &EditHook, // 2.7b7 rri
//              STRINGA_WorkBuffer, WorkBuf, // 2.7b7 rri
              GA_TextAttr, &DMTextAttrs[DMFONTS_DIRGAD], /* 2.7b7 rri */
              STRINGA_Justification, GACT_STRINGLEFT,
//              STRINGA_HookType, SHK_CUSTOM,
             StringEnd,

/*
             LAYOUT_AddChild, dw->dwgad[GID_HScroller] = ChooserObject, // test!
              GA_ID, GID_HScroller,
              GA_RelVerify, TRUE,
              CHOOSER_DropDown, TRUE,
              // CHOOSER_LabelArray, sh->strcache,
              CHOOSER_Labels, NULL, //&histlist,
              CHOOSER_MaxLabels, STRHIST_MAX,
              CHOOSER_AutoFit, TRUE,
              ChooserEnd,
              CHILD_WeightedWidth, 0,
*/

//              LAYOUT_WeightBar, TRUE,
             LAYOUT_AddChild, dw->dwgad[GID_BParent] = ButtonObject,
              GA_ID, GID_BParent,
              GA_RelVerify, TRUE,
//              GA_GadgetHelp, TRUE,
              GA_TabCycle, TRUE,
              GA_TextAttr, &DMTextAttrs[DMFONTS_DIRGAD], /* 2.7b7 rri */
             ButtonEnd,
//             CHILD_MinWidth, 18,
             CHILD_WeightedWidth, 0,
//             CHILD_WeightedHeight, 0,
             LayoutEnd,
            CHILD_WeightedHeight, 0,

           LAYOUT_AddChild, LayoutObject,
            GA_RelVerify, TRUE,
//            LAYOUT_SpaceInner, TRUE, // FALSE,

             LAYOUT_AddChild, dw->dwgad[GID_List] = ListBrowserObject,
              GA_ID, GID_List,
              GA_RelVerify, TRUE,
//            GA_GadgetHelp, TRUE,
              GA_TabCycle, TRUE,
//              GA_ActivateKey, 'c',
              GA_TextAttr, ( columntitles ) ? &DMTextAttrs[DMFONTS_MAIN] : &DMTextAttrs[DMFONTS_CMDWIN], /* 2.7b7 rri */
              LISTBROWSER_VerticalProp, columntitles, // TRUE,
              LISTBROWSER_HorizontalProp, columntitles, // TRUE,
              LISTBROWSER_ColumnInfo, dw->dwgadcollumn,
              LISTBROWSER_Labels, &dw->dwgadlist,
              LISTBROWSER_ColumnTitles, columntitles,
              LISTBROWSER_ShowSelected, columntitles,
              LISTBROWSER_MultiSelect, columntitles,
              LISTBROWSER_Editable, columntitles, // TRUE
              LISTBROWSER_AutoFit, TRUE,
              LISTBROWSER_PersistSelect, TRUE,
              LISTBROWSER_TitleClickable, columntitles, // TRUE
#ifndef __amigaos4__ // OS4 adds extra spacing by default...
               LISTBROWSER_Spacing, ( columntitles ) ? 0 : 2,
#endif
              ListBrowserEnd,
            LayoutEnd,
/*
           LAYOUT_AddChild, LayoutObject,
            GA_RelVerify, TRUE,
             LAYOUT_AddChild, dw->dwgad[GID_VScroller] = ScrollerObject,
              GA_ID, GID_VScroller,
              GA_RelVerify, TRUE,
              GA_Width, 200,
//            GA_GadgetHelp, TRUE,
              GA_TabCycle, TRUE,
              SCROLLER_Orientation, SORIENT_HORIZ,
              SCROLLER_Arrows, TRUE,
              SCROLLER_Total, 1000,
              SCROLLER_Visible, 100,
              SCROLLER_ArrowDelta, 100,

              ScrollerEnd,
           LayoutEnd,
           CHILD_WeightedHeight, 0,
*/
          EndGroup;

      if((dw->Window=OpenSharedWindow(NewWin)))
       {
        returncode=1;

        FLAGS|=DMFLAG_KEEPGOING;

        if(DMMenu&&(!(FLAGS&DMFLAG_BATCH)))
         {
          SetMenuStrip(dw->Window,DMMenu);
         }

        SetFont(dw->Window->RPort,DMFonts[DMFONTS_MAIN]);
        SetGadgetAttrs(dw->dwgadmain, NULL, NULL,
                                            GA_Top, dw->Window->BorderTop,
                                            GA_Left, dw->Window->BorderLeft,
                                            GA_RelWidth, -(dw->Window->BorderLeft + dw->Window->BorderRight),
                                            GA_RelHeight,-(dw->Window->BorderTop + dw->Window->BorderBottom),
                                            TAG_END,0);
        AddGList(dw->Window, dw->dwgadmain, -1, -1, NULL);
        RefreshGList(dw->dwgadmain,dw->Window, NULL, 1);

        dw->MaxFile=maxf;

        dw->DirList=dlist;
        DirWin[DWNum=dwc]=dw;
        dw->Number=dwc;
        process->pr_WindowPtr=(APTR)dw->Window;

        if(!path||Stricmp(path,"CMD"))
         {
          ShowDirection(DestWin,3);
          DestWin=CDWin;
          CDWin=dw;
          ShowDirection(DestWin,1);
          ShowDirection(CDWin,0);
         }

       // GetNewPath(dw); obsolete! all it did is now in DoWindow() 2.7 rri

        if(!dw->DirLock&&!dw->Path[0])
         {
          h=0;
          if(path)
           {
            if(Stricmp(path,"CMD")==0)
             {
              dw->Flags |= DW_CMD;
//              CloneBuffer(dw,dcPath);
              CmdWin=dw;
              h=1;
             }
            else
             {
              CloneBuffer(dw,path);
             }
           }
          InitDir(dw,h);
         }
       } /* OpenSharedWindow... */
      FreeMem(NewWin,sizeof(*NewWin));
     } /* Alloc NeWin ... */
    if(returncode==0) FreeMem(dlist,(ULONG) (maxf<<2));
   } /* Alloc dlist... */
  if(returncode==0) FreeMem(dw,sizeof(*dw));
 } /* Alloc dw... */
return returncode;
}


struct Window *OpenSharedWindow(struct NewWindow *nw)
{
ULONG   flags=nw->IDCMPFlags;
struct Window   *w;

nw->IDCMPFlags=0;

if((w=OpenWindowTags(nw,WA_NewLookMenus,TRUE,WA_Zoom,zooming,TAG_END,0))) /* 2.5.23 gcc rri */

if(flags)
 {
  w->UserPort=WinPort;
  ModifyIDCMP(w,flags);
 }
nw->IDCMPFlags=flags;
return(w);
}


void CloseSharedWindow(struct Window *Window)
{
Forbid();

if(Window->UserPort)
 {
  struct Node *Node,*Next;
  for(Node=Window->UserPort->mp_MsgList.lh_Head;(Next=Node->ln_Succ);Node=Next) /* 2.5.23 gcc rri */
   {
    if(((struct IntuiMessage *)Node)->IDCMPWindow == Window)
     {
      Remove(Node);
      ReplyMsg((struct Message *)Node);
     }
   }
  Window->UserPort = NULL;
 }
ModifyIDCMP(Window,0); /* 2.5RC4 rri vbcc */
Permit();
CloseWindow(Window);
}

