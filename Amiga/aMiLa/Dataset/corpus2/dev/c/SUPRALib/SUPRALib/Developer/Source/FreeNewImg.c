/****** FreeNewImg *****************************************************
*
*   NAME
*       FreeNewImg -- frees memory allocated by MakeNewImg() (V10)
*
*   SYNOPSIS
*       FreeNewImg(newImage)
*
*       void FreeNewImg(struct Image *);
*
*   FUNCTION
*       You must free a new created image with this function, when
*       it is no longer needed.
*
*   SEE ALSO
*       MakeNewImg()
*
****************************************************************/

#include <proto/exec.h>
#include <intuition/intuition.h>

void FreeNewImg(struct Image *img)
{
	UWORD i=0;
	WORD wid=img->Width;

    /* Get width word aligned */
    while (i < wid) i+=16;
    wid = i;

    /* Free Memory */
    FreeMem(img->ImageData, wid*img->Height*img->Depth/8);
    FreeMem(img, sizeof(struct Image));
}  

