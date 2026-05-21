/* DiskMaster II Palette-Requester
**
** 2.5RC4
**
** 02-05-31 rri - Pens20[] is pre-initialised again based on a 4 color screen.
**                Just to guarantee a correct look in case DM2 is
**                started without Startup.DM
**
** 02-06-30 rri - Removed internal palette-requester.
**              - Placed opening of Reqtools library here to have it only
**                opened in case it's really needed.
**
** 2.5RC6
**
** 02-10-04 rri - Replaced one atoi() call with an atol() call.
**
** 02-10-07 rri - Modified one LibOpen() call.
**
** 2.5RC9
**
** 03-01-21 rri - Replaced one atol() call with a StrToLong().
**
** 2.5RC10
**
** 03-03-07 rri - Increased Pens20[] to 50 entries.
**
** 03-04-09 rri - Bitmap-depth in AllocPens() is now determined thru
**                GetBitMapAttr(&MyScreen->RastPort.BitMap,BMA_DEPTH)
**                when DM2 runs under V39+
**
** 03-04-11 rri - Adjusted the internal color-map ColMap[] to 62 entries,
**                more possible arguments, more possible colors...
**              - Added init "UserCols=0", this prevents loading the colore-table
**                with random-values in case no colors are defined.
**              - Added a--; to AllocPens()
**              - In SetPens() allowed 49 pens to be set for first 59 colors.
**              - Removed V39+ dependany within AllocPens() as it won't be
**                executed in the first place if DM2 does not run under V39+...
**              - Changed the Pens20[] to default V50.
**
** 2.5.23
**
** 03-05-18 rri - Added includes for Reqtools.library.
**              - Added a few double-brackets to assignments to avoid
**                warnings with GCC.
**
** 2.5.26
**
** 03-09-07 rri - Removed old comments from top of file.
**              - Removed a few "new!" style comments.
**              - Added OS4 PPC support thru alternative LibOpen().
**
** 2.5.29
**
** 04-04-02 rri - Changed default "HighFill Pen" from "3" to "0" to reduce blinking of the
**                cmd-window with the internal config.
**              - Replaced two "#ifdef __PPC__" with "#ifdef __amigaos4__".
**
** 2.5.31
**
** 04-10-31 rri - Changed one LibOpen() call to the new format.
**              - Made ReqToolsBase a "struct Library" for OS4, well somehow it's obsolete anyways...
** 04-12-22 rri - Removed "use30" checking code - DM2 goes V39+!
**
** 2.6
**
** 05-10-05 jjt - Rewrote SetColors().  Now supports 24-bit color values, as well as 12-bit
**                (for backwards compatability only).
**              - Removed ReqTools code.  "Color", without any args, opens the "Colors" page
**                of DMPrefReq().
**              - Increased ColMap to cope with LoadRGB32().
**
** 05-10-08 jjt - Bugfix: SetColors() - It should now be harder to overflow the ColorMap.
**              - SetColors() - Changed "ULONG" to "uint32".
**
** 05-10-09 jjt - Bugfix: SetColors() - UserCols gets properly initalized.
**              - Bugfix: AllocPens() - Added a test to keep <a> less than 256.
**              - SetColors() - "Offset" doesn't have to be the first option anymore.
**
*/

#include "DM.h"

extern struct Screen    *Screen,*MyScreen;
extern struct TextFont  *DMFonts[];

extern UBYTE  *ActionArgs[];
extern UBYTE  Version[];

extern LONG   BackPen; /* 2.5b12 rri */

extern ULONG FLAGS; /* 2.5RC2 rri */

UWORD Pens20[50]={0,1,1,2,1,0,1,0,2,1,2,1,2,0,2,1,2,1,0,1,2,1,0,3,2,1,0,1,2,1,3,2,2,1,1,0,1,0,1,1,2,1,1,0,0,0,0,0,0,0}; /* 2.5RC10 rri */

ULONG ColMap[770], /* 2.6 jjt  */
      UserCols=0, /* 2.5RC10 rri */
      UserColors=4; /* 2.5b11 rri */


void PenAllocation(ULONG i); /* 2.5b13 rri */


void SetColors()
{
  UBYTE *aaptr;
  uint32 offidx, aaidx=1, cmidx=1, i, l, xh, xl;

  /* 2.6 jjt */

  if (ActionArgs[1])
  {
    /* Set the offset into the Color Map */
    if ((offidx = GetActionArg("OFFSET", AATYPE_BOOL, 0)))
    {
      UserCols = GetActionArg("OFFSET", AATYPE_NUM, 0);
      cmidx = (UserCols * 3) + 1;
    }
    else
    {
      UserCols = 0;
    }

    /* Fill in the color map */
    while ((aaptr = ActionArgs[aaidx]) && (cmidx < 767)) /* 766 = color 255 */ /* 2.6 jjt */
    {
      if (aaidx != offidx) /* Skip the "Offset=" arg. */
      {
        l = strlen(aaptr);
        for (i=0; i < 3; i++)  /* Fill in Color Map R, G, & B values... */
        {
          if (l == 3)  /* 12-bit color value */
          {
            xh = Char2Nibble((ULONG) *aaptr++) & 0xF;
            xl = xh;
          }
          else if (l == 6)  /* 24-bit color value */
          {
            xh = Char2Nibble((ULONG) *aaptr++);
            xl = Char2Nibble((ULONG) *aaptr++) & 0xF;
          }
          else  /* Worthless color value.  Use 0. */
          {
            xh = 0;
            xl = 0;
          }
          ColMap[cmidx++] = (xh << 28) | (xl << 24) | 0x00FFFFFF;
        } /* end for */
        UserCols++;
      } /* end if !offidx */
      aaidx++;
    }

    ColMap[cmidx] = 0;
    ColMap[0] = UserCols << 16;

    if(MyScreen)
    {
      LoadRGB32(&(MyScreen->ViewPort), ColMap);
      AllocPens(); /* 2.5.31 rri */
    }
  }
  else
  {
    /* No args; open the "Colors" page of DMPrefs */
    DMPrefReq(DMPPAGE_COLORS);
  }
}


void SetPens()
{
int i=1;
LONG x;

if(MyScreen) /* do nothing when own screen already is open */
 {
  return;
 }

while(ActionArgs[i]&&i<49) /* 2.5RC10 rri */
 {
  Pens20[i-1]=0;
  StrToLong(ActionArgs[i],&x); /* 2.5RC9 rri */
  Pens20[i-1]=x;
  if(Pens20[i-1]>59) Pens20[i-1]=0; /* 2.5RC10 rri */
  i++;
 }

BackPen=Pens20[BACKGROUNDPEN];

}


void PenAllocation(ULONG i) /* 2.5b13 rri */
{
ObtainPen(Screen->ViewPort.ColorMap,i,0,0,0,PEN_EXCLUSIVE|PEN_NO_SETCOLOR);
}


/* only executed under V39+ ! */
void AllocPens(void) /* 2.5b13 rri */
{
ULONG i,a;

for(i=0;i<UserColors;i++)
 {
  PenAllocation(i);
 }

a = ( 1 << ( GetBitMapAttr(MyScreen->RastPort.BitMap,BMA_DEPTH) ) ); /* 2.5RC10 rri */
a = min(a, 256); /* 2.6 jjt */

a--; /* 2.5RC10 rri */

i=a-Pens20[BACKGROUNDPEN];
PenAllocation(i);

i=a-Pens20[TEXTPEN];
PenAllocation(i);

i=a-Pens20[HIGHLIGHTTEXTPEN];
PenAllocation(i);
}
