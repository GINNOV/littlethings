/*
 *  Some SAS/C 6.0 code to show all 2^24 colors available with HAM8
 *  on a sequence of successive screens without ever changing the
 *  64 base color registers after the initial setup.
 *
 *  This code, except the ListRequest () routine, is PD.  Donated to
 *  the public domain by the author, Loren J. Rittle <rittle@comm.mot.com>.
 *  Have fun with it, but please don't claim this work as your own.  As it
 *  is PD, please feel free to take my pieces to your own projects.
 *
 *  ListRequest () is by Willy Langeveld.  You will have to ask Willy
 *  what his license terms are. :-)
 *
 *  Loren J. Rittle
 *  Sun Nov  8 09:52:11 1992
 */

/* To allow this to compile with the STRICT ANSI WARNING=ALL options: */
#pragma msg 148 ignore
#pragma msg 149 ignore push
#pragma msg 61 ignore push
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/gadtools.h>
#pragma msg 149 pop
#pragma msg 61 pop
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Thanks to Chris Green: */
LoadRGB32 (struct ViewPort *, unsigned long *table);
#pragma libcall GfxBase LoadRGB32 372 9802

/* Let's hope that more entry points are revealed on UseNet to tide us
   over until the real includes are available...
   For example, I'd like the pragma info on the system calls that allow
   me to do double bufferred animation under the OS... :-) */

/* Prototype to allow this to compile with WARNING=ALL option: */
int main (int argc, char *argv[]);

struct ModeNode
{
  struct Node n;
  ULONG mode;
  UBYTE	name[DISPLAYNAMELEN + 4 + 1];
};

static struct TextAttr topaz80 = { "topaz.font", 8, 0, 0 };

/*
 *  ListRequest() originally by Willy Langeveld, October 1991.
 *  Changes for this project by myself.
 *  Willy gave me permission to include this code with another
 *  package.  As it is quite useful, I have included it here in
 *  another form.  Thanks Willy!
 */
static struct Node *ListRequest(struct Screen *scr, struct List *list,
				long x, long y, long width, long height)
{
#define MARGIN 10
#define GADGET_SPACING 5

  struct VisualInfo *vi = NULL;
  struct Gadget *glist = NULL, *gad;
  struct NewGadget ng;
  struct Window *w = NULL;
  long top;
  enum {NOTDONE, NOCHANGE, CHANGE} quitflag = NOTDONE;
  ULONG class;
  WORD code, selected;
  struct IntuiMessage *msg;
  struct Node *n = NULL;

  if (width < 80)
    width = 80;
  if (height < 70)
    height = 70;

  if (scr)
    if (((scr->Flags & SCREENTYPE) == PUBLICSCREEN) ||
        ((scr->Flags & SCREENTYPE) == CUSTOMSCREEN))
      vi = GetVisualInfoA (scr, NULL);

  if (!vi)
    {
      scr = LockPubScreen (NULL);
      if (!scr)
	goto cleanup;

      vi = GetVisualInfoA (scr, NULL);
      UnlockPubScreen (NULL, scr);
    }

  if (!vi)
    goto cleanup;

  w = OpenWindowTags (NULL,
                      WA_Left,         (ULONG) x,
                      WA_Top,          (ULONG) y,
                      WA_Width,        (ULONG) width,
                      WA_Height,       (ULONG) height,
                      WA_IDCMP,        (ULONG) LISTVIEWIDCMP | CLOSEWINDOW,
                      WA_Flags,        (ULONG) WINDOWCLOSE  | SMART_REFRESH |
                                               WINDOWDRAG   | WINDOWDEPTH   |
                                               ACTIVATE,
                      WA_Title,        (ULONG) "Select display mode:",
                      WA_CustomScreen, (ULONG) scr,
                      TAG_DONE);

  if (!w)
    goto cleanup;

  gad = CreateContext(&glist);

  if (!gad)
    goto cleanup;

  top = w->BorderTop + GADGET_SPACING;

  ng.ng_LeftEdge   = MARGIN;
  ng.ng_TopEdge    = top;
  ng.ng_Width      = width - 2 * MARGIN;
  ng.ng_Height     = height - top - GADGET_SPACING;
  ng.ng_GadgetText = NULL;
  ng.ng_GadgetID   = 1;
  ng.ng_Flags      = 0;
  ng.ng_TextAttr   = &topaz80;
  ng.ng_VisualInfo = vi;
  CreateGadget (LISTVIEW_KIND, gad, &ng, GTLV_Labels, list,
                GTLV_ScrollWidth, 16, TAG_DONE);

  AddGList (w, glist, -1, -1, NULL);
  RefreshGList (glist, w, NULL, -1);
  GT_RefreshWindow (w, NULL);

  while (quitflag == NOTDONE)
    {
      WaitPort(w->UserPort);
      while (msg = GT_GetIMsg(w->UserPort))
	{
          class  = msg->Class;
          code   = (WORD) msg->Code;

          GT_ReplyIMsg (msg);

          if (class == GADGETUP)
	    {
              selected = code;
              quitflag = CHANGE;
            }
          else if (class == CLOSEWINDOW)
	    {
              quitflag = NOCHANGE;
            }
        }
    }

cleanup:
  if (w)
    CloseWindow(w);
  if (glist)
    FreeGadgets(glist);
  if (vi)
    FreeVisualInfo(vi);

  if ((quitflag == CHANGE) && list)
    {
      n = list->lh_Head;
      while (selected--)
	n = n->ln_Succ;
    }

  return(n);
}

static ULONG GetUserMode (void)
{
  ULONG mode = INVALID_ID;
  struct List list;
  struct ModeNode *nodep;

  NewList (&list);

  do
    {
      DisplayInfoHandle dih;
      struct DisplayInfo di;
      struct NameInfo ni;

      mode = NextDisplayInfo (mode);
      dih = FindDisplayInfo (mode);
      if (GetDisplayInfoData (dih, (UBYTE *) &di, sizeof di, DTAG_DISP, NULL) &&
	  (!di.NotAvailable) && (di.PropertyFlags & DIPF_IS_HAM) &&
	  (di.PaletteRange > 65534))
	{
	  nodep = malloc (sizeof (struct ModeNode));
	  if (!nodep)
	    {
	      PutStr ("gtest: no more memory\n");
	      exit (0);
	    }

	  dih = FindDisplayInfo (mode & ~HAM_KEY);
	  if (GetDisplayInfoData (dih, (UBYTE *) &ni, sizeof ni, DTAG_NAME, NULL))
	    sprintf (nodep->name, "%s HAM", ni.Name);
	  else
	    sprintf (nodep->name, "%lx (?) HAM", mode);
	  nodep->n.ln_Name = nodep->name;
	  nodep->n.ln_Pri = 0;
	  nodep->mode = mode;
	  AddTail (&list, nodep);
	}
    }
  while (mode != INVALID_ID);

  nodep = (struct ModeNode *) ListRequest (NULL, &list, 10, 50, 300, 140);

  if (!nodep)
    {
      PutStr ("gtest: no display mode selected\n");
      exit (0);
    }

  return nodep->mode;
}

static void MText (struct RastPort *rp, ULONG x, ULONG y, char *s)
{
  Move (rp, x, y);
  Text (rp, s, strlen (s));
}

static void MDraw (struct RastPort *rp, ULONG x, ULONG y, ULONG tx, ULONG ty)
{
  Move (rp, x, y);
  Draw (rp, tx, ty);
}


int main (int argc, char *argv[])
{
  UWORD t[] = {0xffff};
  struct Screen *s = OpenScreenTags (NULL, SA_Pens, t, SA_SysFont, 1,
			SA_Title, "AGA HAM8 mode test by Loren J. Rittle",
			SA_DisplayID, GetUserMode (), SA_Depth, 8, TAG_DONE);

  if (s)
    {
      struct Window *w = OpenWindowTags (NULL, WA_CustomScreen, s,
		WA_IDCMP, IDCMP_MOUSEBUTTONS, WA_Backdrop, 1,
		WA_Borderless, 1, TAG_DONE);

      if (w)
	{
	  int i, j, k;
	  static ULONG ct[1 + 64 * 3 + 1];

	  ct[0] = (64 << 16) + 0;
	  for (i = 0; i < 4; i++)
	    for (j = 0; j < 4; j++)
	      for (k = 0; k < 4; k++)
		{
		  ct[(k * 16 + j * 4 + i) * 3 + 1] = (i << 30) | (i << 24);
		  ct[(k * 16 + j * 4 + i) * 3 + 2] = (j << 30) | (j << 24);
		  ct[(k * 16 + j * 4 + i) * 3 + 3] = (k << 30) | (k << 24);
		}
	  LoadRGB32 (&(s->ViewPort), ct);

	  {
	    struct RastPort *rp = w->RPort;
	    struct TextFont *tf = OpenFont(&topaz80);
	    int r, g, b, lastb;

	    SetFont (rp, tf);
	    SetAPen (rp, 3);
	    MText (rp, 13, 34, "The colors in this column are all base");
	    MText (rp, 13, 42, "registers. Notice that the base");
	    MText (rp, 13, 50, "registers never change and that they");
	    MText (rp, 13, 58, "are setup in a special way to allow");
	    MText (rp, 13, 66, "all 2^24 colors to be seen. These");
	    MText (rp, 13, 74, "colors all have their upper 2 bits ==");
	    MText (rp, 13, 82, "lower 2 bits to allow you to see how");
	    MText (rp, 13, 90, "the lower 2 bits are set.");
	    MDraw (rp, 4, 28, 4, 118);

	    SetAPen (rp, 12);
	    MText (rp, 13, 98, "The green line that will appear in");
	    MText (rp, 13, 106, "this column is an artifact, ignore.");
	    MDraw (rp, 9, 92, 9, 118);

	    SetAPen (rp, 63);
	    MText (rp, 110, 120, "This block of pixels");
	    MText (rp, 110, 128, "contains 2^12 unique");
	    MText (rp, 110, 136, "colors. 2^12 screens");
	    MText (rp, 110, 144, "of these blocks will");
	    MText (rp, 110, 152, "show all 2^24 colors.");
	    MText (rp, 110, 160, "This should take about");
	    MText (rp, 110, 168, "a minute on an A4000");
	    MText (rp, 110, 176, "at 60 frames/second.");
	    MDraw (rp, 107, 115, 10, 118);
	    MDraw (rp, 107, 115, 76, 183);

	    for (j = 0; j < 4; j++)
	      for (k = 0; k < 4; k++)
		for (i = 0; i < 4; i++)
		  {
	            SetAPen (rp, j * 16 + k * 4 + i);
	            WritePixel (rp, 4, 120 + i + k * 4 + j * 16);
	            SetAPen (rp, 0xc0);
	            WritePixel (rp, 5, 120 + i + k * 4 + j * 16);
	            SetAPen (rp, 0x40);
	            WritePixel (rp, 6, 120 + i + k * 4 + j * 16);
	            SetAPen (rp, 0x80);
	            WritePixel (rp, 7, 120 + i + k * 4 + j * 16);
	            WritePixel (rp, 8, 120 + i + k * 4 + j * 16);
	            SetAPen (rp, 0xc0 + 0);
	            WritePixel (rp, 9, 120 + i + k * 4 + j * 16);
	            SetAPen (rp, 0x40 + 0);
	            WritePixel (rp, 10, 120 + i + k * 4 + j * 16);
	            for (r = 0; r < 64; r++)
		      {
		        SetAPen (rp, 0x80 + r);
		        WritePixel (rp, 10 + r, 120 + i + k * 4 + j * 16);
		      }
	          }

	    for (b = 0, lastb = -1; b < 64; b++)
	      for (g = 0; g < 64; g++)
		{
		  if (CheckSignal (SIGBREAKF_CTRL_C | (1 << w->UserPort->mp_SigBit)))
		    goto out;

		  WaitTOF ();

		  SetAPen (rp, 0xc0 + g);
		  MDraw (rp, 9, 120, 9, 183);
		  if (b != lastb)
		    {
		      SetAPen (rp, 0x40 + b);
		      MDraw (rp, 10, 120, 10, 183);
		      lastb = b;
		    }
		}

	    MText (rp, 110, 190, "Done. Click mouse button.");
	    CloseFont (tf);
	  }

	  Wait (SIGBREAKF_CTRL_C | (1 << w->UserPort->mp_SigBit));

	out:
	  CloseWindow (w);
	}
      else
	PutStr ("gtest: error opening window\n");

      CloseScreen (s);
    }
  else
    PutStr ("gtest: error opening screen\n");
  return (0);
}
