/* Some SAS/C 6.0 code to show all 2^24 colors available with HAM8
   on a sequence of successive screens without ever changing the
   64 base color registers after the initial setup.

   This code is PD.  Donated to the public domain by the author,
   Loren J. Rittle <rittle@comm.mot.com>.  Have fun with it, but
   please don't claim this work as your own.  As it is PD, please
   feel free to take pieces to your own projects.

   Loren J. Rittle
   Sun Nov  8 09:52:11 1992
*/

/* To allow this to compile with the STRICT ANSI WARNING=ALL options: */
#pragma msg 148 ignore
#pragma msg 149 ignore push
#pragma msg 61 ignore push
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#pragma msg 149 pop
#pragma msg 61 pop

/* Thanks to Chris Green: */
LoadRGB32 (struct ViewPort *, unsigned long *table);
#pragma libcall GfxBase LoadRGB32 372 9802

/* Let's hope that more entry points are revealed on UseNet to tide us
   over until the real includes are available...
   For example, I'd like the pragma info on the system calls that allow
   me to do double bufferred animation under the OS... :-) */

/* Prototype to allow this to compile with WARNING=ALL option: */
int main (int argc, char *argv[]);

int main (int argc, char *argv[])
{
  /* Open a HAM8 screen: */
  UWORD t[] = {0xffff};
  struct Screen *s = OpenScreenTags (NULL, SA_Pens, t, SA_SysFont, 1,
		SA_Title, "AGA HAM8 mode test by Loren J. Rittle",
		SA_DisplayID, HIRES_KEY | HAM_KEY, SA_Depth, 8, TAG_DONE);

  /* We don't need to look at the command line arguments that get
     stacked on Input ().  Flush () 'em: */
  Flush (Input ());

  if (s)
    {
      /* Open a window on the HAM8 screen: */
      struct Window *w = OpenWindowTags (NULL, WA_CustomScreen, s,
		WA_Borderless, 1, TAG_DONE);

      if (w)
	{
	  /* Set up 64 base color registers for HAM8 screen: */
	  int i, j, k;
	  static unsigned long ct[1 + 64 * 3 + 1];

	  ct[0] = (64 << 16) + 0;
	  for (i = 0; i < 4; i++)
	    for (j = 0; j < 4; j++)
	      for (k = 0; k < 4; k++)
		{
		  ct[(k * 16 + j * 4 + i) * 3 + 1] = i << 24;
		  ct[(k * 16 + j * 4 + i) * 3 + 2] = j << 24;
		  ct[(k * 16 + j * 4 + i) * 3 + 3] = k << 24;
		}
	  LoadRGB32 (&(s->ViewPort), ct);

	  /* We will never change the base color registers again,
	     after this point, but yet, we can display all 2^24
	     colors available on a HAM8 screen. :-) */

	  {
	    int r, g, b;

	    /* Set up static pixels on the screen: */
	    for (j = 0; j < 4; j++)
	      for (k = 0; k < 4; k++)
		for (i = 0; i < 4; i++)
		  {
	            SetAPen (w->RPort, j * 16 + k * 4 + i);
	            WritePixel (w->RPort, 97 + j * 100, 100 + i + k * 20);
	            SetAPen (w->RPort, 0xc0 + 0);
	            WritePixel (w->RPort, 98 + j * 100, 100 + i + k * 20);
	            SetAPen (w->RPort, 0x40 + 0);
	            WritePixel (w->RPort, 99 + j * 100, 100 + i + k * 20);
	            for (r = 0; r < 64; r++)
		      {
		        SetAPen (w->RPort, 0x80 + r);
		        WritePixel (w->RPort, 100 + r + j * 100, 100 + i + k * 20);
		      }
	          }

	    /* Loop over all high order green and blue combos: */
	    for (b = 0; b < 64; b++)
	      for (g = 0; g < 64; g++)
		{
		  if (CheckSignal (SIGBREAKF_CTRL_C))
		    goto out;

		  WaitTOF ();
		  WaitTOF ();

		  /* Change dynamic pixels on screen: */
		  for (j = 0; j < 4; j++)
		    for (k = 0; k < 4; k++)
		      for (i = 0; i < 4; i++)
		        {
		          SetAPen (w->RPort, 0xc0 + g);
		          WritePixel (w->RPort, 98 + j * 100, 100 + i + k * 20);
		          SetAPen (w->RPort, 0x40 + b);
		          WritePixel (w->RPort, 99 + j * 100, 100 + i + k * 20);
		        }
		}
	  }

	  /* Done, we have now seen all 2^24 colors without ever
	     changing the base registers. */
	  FGetC (Input ());
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
