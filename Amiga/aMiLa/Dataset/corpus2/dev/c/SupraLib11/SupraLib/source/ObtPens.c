/****** ObtPens ***************************************************
*
*   NAME
*       ObtPens -- Obtain best pens from a list of colors (V10)
*       (gfx V39)
*
*   SYNOPSIS
*       number = ObtPens(cm, PalTable, PensTable, TagItem)
*
*       ULONG  = ObtPens(struct ColorMap *, ULONG *, ULONG *,
*                 struct TagItem *);
*
*   FUNCTION
*       This function calls ObtainBestPen() on a list of color
*       entries, and puts results into a new pens list.
*
*       It will attempt to find colors in your viewport closest to
*       the provided colors list (PalTable).
*       This is usefull when you want to use an image with more
*       specific colors on a public screen with a sharable palette.
*
*   INPUTS
*       cm = colormap
*       PalTable - list of RGB entries for each color you want to use.
*                  The format of this table is the same as for LoadRGB32():
*
*             1 Word with the number of colors to obtain
*             1 Word with the first color to be obtained
*             3 longwords representing a left justified 32 bit RGB triplet
*             The list is terminated by a count value of 0.
*
*             examples:
*               ULONG PalTable[]={2l<<16+1,0,0,0, 0xffffffff,0,0, 0};
*                   two entries (black, red); obtains only red one
*
*       PensTable - list of pen numbers on your viewport, obtained by
*                   this function. First entry in PensTable will represent
*                   the first color in PalTable, and so on.
*                   NOTE that entries in PensTable with count number lower
*                   than the first color to be obtained (provided in
*                   PalTable) will be unaffected!
*
*       TagItem - this tagitem will be passed to ObtainBestPen() function,
*                 that is called within ObtPens(). Please see ObtainBestPen()
*                 in order to decide what kind of precision for obtaining
*                 colors you will need. If this is NULL, PRECISION_IMAGE will
*                 be used.
*
*   RESULT
*       number = number of obtained colours (always the same as the first
*       Word in PalTable), or 0 if failed. If it succeeds you must call
*       RelPens() to free obtained colors.
*
*
*   EXAMPLES
*
*       The following example will obtain red, green and blue colours in a
*       viewport, and will put obtained pens into pens[] table. pens[0] will
*       be untouched (will remain the same colour as viewport's background).
*
*       ULONG pal[((4<<16)+1, \* 4 entries, starting with the second one *\
*                   0, 0, 0,          \* black - will ignore this one *\
*                   0xffffffff, 0, 0, \* red *\
*                   0, 0xffffffff, 0, \* green *\
*                   0, 0, 0xffffffff, \* blue *\
*                   0};
*
*       ULONG pens[4];
*
*       ObtPens(cm, pal, pens, NULL);
*
*       SetAPen(rp, pens[1]);   \* Set the primary pen to red *\
*       Text(rp, "I'm red!", 8);
*
*
*   NOTES
*       You MUST call RelPens() to free all obtained colors if ObtPens()
*       have succeeded, but you must not call it if ObtPens() returns 0.
*       You MUST open graphics library (V39 or higher) before calling this
*       function.
*
*   SEE ALSO
*       RelPens(), ObtainBestPen(), LoadRGB32()
*
*************************************************************************/

#include <proto/graphics.h>
#include <libraries/supra.h>

ULONG ObtPens(struct ColorMap *cm, ULONG *paltab, ULONG *pens, struct TagItem *tags)
{
int i,j;
int num = paltab[0]>>16;

    for (i = (WORD)*((WORD *)paltab+1); i<num; i++) {
        if ((pens[i] = ObtainBestPenA(cm, paltab[3*i+1],
                                         paltab[3*i+2],
                                         paltab[3*i+3],
                                         tags)) == -1) {

                                            for (j=(WORD)*((WORD *)paltab+1); j<i; j++) ReleasePen(cm, pens[j]);
                                            return(0);
                                         }

    }

    return((ULONG)num);
}

