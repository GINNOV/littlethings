/* DiskMaster II  Key Module    AddKeyCmd,DoKeyCmd,CheckAbort,FreeKeyCmd
**
** 00-07-08 rri - changed MyStrUpper() calls to new StrToUpper() calls
**              - replaced all c++ style comments by ANSI ones
**
** 2.5b10
**
** 00-12-07 rri - removed a "warning 220" and a "warning 317" from DoKeyCmd()
**
** 00-12-22 jjt - Updated DMReq() call to DMReqTagList().
**
** 00-12-26 rri - removed two "warning 220"`s
**              - replaced one unix-style movmem() by an ANSI-style memmove()
**
** 00-12-28 rri - changed a few vars from int to LONG in DoKeyCmd()
**
** 2.5b11
**
** 01-03-01 jjt - Changed obsolete Intuition flag names to v36 versions:
**                  RAWKEY to IDCMP_RAWKEY,
**                  CLOSEWINDOW to IDCMP_CLOSEWINDOW,
**                  VANILLAKEY to IDCMP_VANILLAKEY.
**
** 2.5b12
**
** 01-08-05 rri - AddKeyCmd()/FreeKeyCmds() use pooled memory now
**
** 2.5b13
**
** 01-09-09 rri - localisation: 'AddKeyCmd' - msgReqAddKey
**
** 01-10-06 rri - Bugfix: the check for "Escape" in DoKeyCmd() did nothing
**                else than blocking the "S"s and "D"s gadgets functions
**              - rewritten CheckAbortKey() to be system-friendly at last
**
** 2.5RC2
**
** 01-12-19 rri - introduced FLAGS
**
** 01-12-22 jjt - Replaced DMFont with DMFonts[DMFONTS_MAIN].
**
** 02-01-04 rri - Replaced a call to GZZWidth(dw) with dw->Window->GZZWidth
**
** 2.5RC6
**
** 02-10-27 rri - Moved function FreeKeyCmds() into FreeUserJunk()
**
** 02-12-15 rri - Corrected a little loop-abort glitch...
**
** 2.5RC7
**
** 02-12-29 rri - Removed one abandoned "extern int ColFudge".
**
** 2.5RC9
**
** 03-01-25 rri - Replaced one memmove() cally by a CopyMem() call.
**
** 2.5RC10
**
** 03-02-28 rri - Changed a call to ActionCmd() in DoKeyCmd()
**              - Removed some "new! ..." style comments.
**
** 03-04-24 rri - Simplified AddKeyCmd() - it is always fed with a
**                single command-line now...
**
** 2.5.23
**
** 03-05-30 rri - Removed a few GCC warnings.
**
** 2.5.31
**
** 04-10-12 rri - IntuitionBase is of type struct Library for OS4.
**
** 2.6
**
** 05-11-08 jjt - AddKeyCmd() - Added context help to the req.
**
** 2.7
**
** 05-12-15 jjt - Added FreeKeyCmds().
**
** 05-12-17 jjt - Removed FreeKeyCmds().  Using DMSupport.c's FreeStringArray() instead.
**
** 06-11-03 rri - Added cursor-control to ListBrowsers.
**
** 06-11-05 rri - Added LBP_PAGELEFT / LBP_PAGERIGHT for ListBrowsers
**
** b4
**
** 06-11-17 rri - Fix: a keypress activates the correct string-gadget now...
**
** b7
**
** 07-01-02 rri - Fix: It must be ActivateLayoutGadget() to activate the gadget, not ActivateGadget().
**                Otherwise the layout is not aware that the string-gadget got activated.
**
** b10
**
** 07-01-28 rri - Removed usage of the tags LBP_PAGERIGHT and LBP_PAGELEFT in DoKeyCmd() from
**                the 68k build since they do not exist for the 68k ListBrowser.gadget.
**
** 07-01-31 rri - Fix: A test-line broke the detection of "0" from the numeric keypad.
**              - New feature: when pressing an alpha-numeric key for which no keyboard-command
**                             is defined the lister will jump to the first file which name
**                             begins with the character representing that key.
**
*/

#include "DM.h"

//#include <libraries/locale.h> // test!
#include <proto/locale.h> // test!


#ifdef __amigaos4__ /* 2.5.31 rri */
extern struct Library *IntuitionBase;
#else
extern struct IntuitionBase *IntuitionBase;
#endif

extern struct MsgPort *WinPort;
extern struct DirWindow *CDWin;
extern struct TextFont  *DMFonts[];  /* 2.5RC2 jjt */
extern struct TagItem    reqtags_Help[];  /* 2.6 jjt */

extern APTR StringPool; /* 2.5b12 rri */

extern UBYTE sbuff[];

extern ULONG DWNum, FLAGS; /* 2.5RC2 rri */


UBYTE *KeyCmdStr[100];


void AddKeyCmd(UBYTE *str) /* do nothing but copy the whole string */
{
ULONG i=0;

if(*str==0)
 {
  sbuff[0]=0;
  reqtags_Help[0].ti_Data = (LONG) "AddKeyCmd";  /* 2.6 jjt */
  if(!DMReqTagList(msgReqAddKey, sbuff, 512, reqtags_Help)) return;  /* 2.6 jjt */
  str=sbuff;
 }

while(KeyCmdStr[i]) i++;

if(i<100)
 {
  KeyCmdStr[i] = CloneStr(str,StringPool); /* 2.5RC10 rri */
 }
}


/*
IEQUALIFIER_LSHIFT              0x0001
IEQUALIFIER_RSHIFT              0x0002
IEQUALIFIER_CAPSLOCK            0x0004
IEQUALIFIER_CONTROL             0x0008
IEQUALIFIER_LALT                0x0010
IEQUALIFIER_RALT                0x0020
IEQUALIFIER_LCOMMAND            0x0040
IEQUALIFIER_RCOMMAND            0x0080
IEQUALIFIER_NUMERICPAD          0x0100

MapRawKey(&ie, buffer, BUFFERLEN, 0);

*/

void ShiftTest(UWORD qual, UBYTE *KeyString) /* 2.5b5 rri */
{
 if(qual&0x0003) /* if left- or right-shift is pressed... */
  {
   StrToUpper(KeyString); /* 2.5b7 rri */
  }
}


void DoKeyCmd(struct DirWindow *dw,UWORD code,UWORD qual,ULONG class)
{
LONG i,x;//,lines,collums; /* 2.5b10 rri */
UBYTE *ptr;
UBYTE CompareString[8],KeyString[8];
uint32 lbposition = 0; /* 2.7 rri */

//lines=1;
//collums=1;

KeyString[0]=0;  /* 2.5b10 rri */

//if(qual&0x0003) /* if left- or right-shift is pressed... */
// {
//  lines=dw->Rows;
//  collums=dw->Window->GZZWidth/DMFonts[DMFONTS_MAIN]->tf_XSize;  /* 2.5RC2 jjt */
// }

if(class==IDCMP_RAWKEY) /* map out cursor-keys and qualifiers only pressed */
 {
  switch(code)
   {

    case 0x4c: /* cursor up */
               lbposition = LBP_LINEUP;
               if(qual&0x0003) /* if left- or right-shift is pressed... */
               {
                lbposition = LBP_PAGEUP;
               }
               break;

    case 0x4d: /* cursor down */
               lbposition = LBP_LINEDOWN;
               if(qual&0x0003) /* if left- or right-shift is pressed... */
               {
                lbposition = LBP_PAGEDOWN;
               }
               break;

    case 0x4e: /* cursor right */
               lbposition = LBP_SHIFTRIGHT;
               #ifdef __amigaos4__
               if(qual&0x0003) /* if left- or right-shift is pressed... */
               {
                lbposition = LBP_PAGERIGHT;
               }
               #endif
               break;

    case 0x4f: /* cursor left */
               lbposition = LBP_SHIFTLEFT;
               #ifdef __amigaos4__
               if(qual&0x0003) /* if left- or right-shift is pressed... */
               {
                lbposition = LBP_PAGELEFT;
               }
               #endif
               break;

    case 0x70: /* home - Not on classic keyboards */
               lbposition = LBP_TOP;
               break;

    case 0x71: /* end - Not on classic keyboards */
               lbposition = LBP_BOTTOM;
               break;

    case 0x48: /* pageup - Not on classic keyboards */
               lbposition = LBP_PAGEUP;
               break;

    case 0x49: /* pagedown - Not on classic keyboards */
               lbposition = LBP_PAGEDOWN;
               break;

    case 0x50: /* F1 */
    case 0x51: /* F2 */
    case 0x52: /* F3 */
    case 0x53:
    case 0x54:
    case 0x55:
    case 0x56:
    case 0x57:
    case 0x58:
    case 0x59: /* F10 */
    case 0x4b: /* F11 Not on classic keyboards */
    case 0x6f: /* F12 Not on classic keyboards */
               sprintf(KeyString, "f%ld",(LONG) (code - 0x4F)); /* 2.5.23 gcc rri */
               ShiftTest(qual,KeyString); /* 2.5b5 rri */
               break;

    case 0x5f: /* Help  2.5b5 jjt (27.3.00) */
               strcpy(KeyString, "help");
               ShiftTest(qual,KeyString); /* 2.5b5 rri */
               break;
    default:   //Printf("code for key pressed: %04lx\n",code); // test!
               return;
   }
 }

if(qual&IEQUALIFIER_NUMERICPAD) /* if the key is pressed on the numeric-pad... */
{
 switch(code)
 {
  case 0x38: /* numeric-key pad 8 - up */
             lbposition = LBP_LINEUP;
             break;

  case 0x32: /* numeric-key pad 2 - down */
             lbposition = LBP_LINEDOWN;
             break;

  case 0x37: /* numeric-key pad 7 - home */
             lbposition = LBP_TOP;
             break;

  case 0x31: /* numeric-key pad 1 - end */
             lbposition = LBP_BOTTOM;
             break;

  case 0x39: /* numeric-key pad 9 - page Up */
             lbposition = LBP_PAGEUP;
             break;

  case 0x33: /* numeric-key pad 3 - page down */
             lbposition = LBP_PAGEDOWN;
             break;

  case 0x34: /* numeric-key pad 4 - left */
             lbposition = LBP_SHIFTLEFT;
             break;

  case 0x36: /* numeric-key pad 6 - right */
             lbposition = LBP_SHIFTRIGHT;
             break;

/* 2.7b10 rri - removed, broke "0" detection for numeric pad... */
//  default:   Printf("code for key pressed: %04lx\n",code); // test!
//             return;
 }
}


if (lbposition != 0) /* 2.7 rri - move listbrowser */
{
 SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,LISTBROWSER_Position,lbposition,TAG_END,0);
 return;
}


if (code==0x1b) /* Escape */
 {
/*  Abort=1; */ /* 2.5b13 rri - removed from active code because it only
                                blocked the "S" and "D" gadgets */
  return;
 }


if (code==0x7f) /* Delete */
 {
  sprintf(KeyString,"del");
  ShiftTest(qual,KeyString); /* 2.5b5 rri */
 }

if (code==0x09) /* Tab -> switch between windows....later */
 {
  return;
 }

if(!KeyString[0])
 {
  KeyString[0]=code;
  KeyString[1]=0;
 }

for(i=0;i<100;i++)
 {
  if((ptr=KeyCmdStr[i])) /* 2.5.23 gcc rri */
   {
    for(x=0;x<7;x++)
     {
      CompareString[x]=0;
     }
    x=0;

    while(*ptr&&*ptr!=',')
     {
      CompareString[x]=(*ptr); /* 2.5b10 rri */
      x++;
      ptr++;
     }
    if(strcmp(CompareString,KeyString)==0)
     {
      ActionCmd(dw->Number,ptr); /* 2.5RC10 rri */
      return;
     }
   }
  else
   {
    break; /* 2.5RC6 rri */
   }
 }


/* 2.7b10 rri - makes the lister jump to the first file which starts with the character of the pressed key */
if (LocaleBase)
{
 if (KeyString[1] == 0)
 {
  struct Locale *loc = OpenLocale(NULL);

  if (IsAlNum(loc,*KeyString))
  {
   struct DirList **dl,*dlp;

   CloseLocale(loc);

   dl=CDWin->DirList;
   i = 0;

   while(i < CDWin->FileCount)
   {
    dlp=dl[i];
    if (dlp && dlp->dir == 0)
    {
     if (dlp->name[0] == *KeyString)
     {
//      detach_list(CDWin);
//      SetListBrowserNodeAttrs(dlp->node, LBNA_Selected, TRUE, TAG_DONE, 0);
//      attach_list(CDWin,FALSE);
      SetGadgetAttrs(CDWin->dwgad[GID_List], CDWin->Window, NULL, LISTBROWSER_Top, i, TAG_END,0);
      break;
     }
    }
    i++;
   }
   return;
  }
  CloseLocale(loc);
 }
}


/* path-gadget activation */
if(CDWin)
 {
  ActivateWindow(CDWin->Window);
  Delay(10);
//  ActivateGadget(&CDWin->dir_gad,CDWin->Window,0);
  ActivateLayoutGadget(CDWin->dwgadmain, CDWin->Window, NULL, (Object) CDWin->dwgad[GID_String]); /* 2.7b7 rri */
}
}


ULONG CheckAbortKey() /* 2.5RC2 rri */
{
struct IntuiMessage *msg;
UWORD code;
ULONG class;

while((msg=(struct IntuiMessage *)GetMsg(WinPort))) /* 2.5.23 gcc rri */
 {
  class=msg->Class;
  code=msg->Code;
  if(class==IDCMP_CLOSEWINDOW ||
     (class==IDCMP_VANILLAKEY&&code==0x1b) ||
     (class==IDCMP_RAWKEY&&code==0x45)
    )
   {
    FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
   }
  ReplyMsg((struct Message *)msg);
 }
return(FLAGS&DMFLAG_ABORT); /* 2.5RC2 rri */
}

