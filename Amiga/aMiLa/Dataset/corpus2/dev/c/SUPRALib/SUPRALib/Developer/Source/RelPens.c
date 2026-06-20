/****** RelPens *****************************************************
*
*   NAME
*       RelPens -- Release a list of pens obtained by ObtPens (V10)
*       (gfx V39)
*   SYNOPSIS
*       RelPens(cm, PalTable, PensTable)
*
*       void (struct ColorMap *, ULONG *, ULONG *);
*
*   FUNCTION
*       This function repeats calls to ReleasePen() in order to
*       release all pens obtained by ObtPens().
*
*   INPUTS
*       cm = colormap
*       PalTable - the same PalTable called with ObtPens()
*       PensTable - the same PensTable called with ObtPens()
*
*   NOTES
*       Please DO NOT modify PalTable and PensTable between calling
*       ObtPens() and RelPens(). This function uses the first long
*       word from PalTable (describing number of entries and starting
*       position), and all entries from PensTable (except those entries
*       that are lower than a starting position).
*       You MUST open graphics library (V39 or higher) before calling
*       this function!
*
*   SEE ALSO
*       ObtPens(), ReleasePen()
*
*********************************************************************/

#include <libraries/supra.h>
#include <proto/graphics.h>

void RelPens(struct ColorMap *cm, ULONG *table, ULONG *pal)
{
	UWORD i;
	UWORD num = table[0]>>16;

    for (i=(UWORD)*((UWORD *)table+1); i<num; i++) ReleasePen(cm, pal[i]);
}
