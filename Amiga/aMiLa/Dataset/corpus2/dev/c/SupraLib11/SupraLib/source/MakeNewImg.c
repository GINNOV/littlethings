/****** MakeNewImg *************************************************
*
*   NAME
*       MakeNewImg -- Remap an image to any new colours (V10)
*
*   SYNOPSIS
*       newImage = MakeNewImg(oldImage, palette)
*
*       struct Image * = MakeNewImg(struct Image *, ULONG *);
*
*   FUNCTION
*       This function creates a new clone image of a provided
*       image, and it remaps the new image according to a provided
*       pen colour list.
*       This is very useful when you need your image to use
*       specific colours anywhere in the available palette.
*       (e.g. you obtained some free pens from a palette, and
*       you want your image to be shown with those pens).
*       It is possible to modify an image's pens with PlanePick and
*       PlaneOnOff fields (see Image structure), but this has a major
*       limitation: most colour combinations are not possible to get.
*
*       If your image has four colours (0,1,2,3), and you want to
*       remap these to (0,16,4,7), you simply call this function,
*       providing it with the image and a new colour map, and a
*       new image will be created for you.
*
*   INPUTS
*       oldImage - pointer to an Image structure to be remapped
*       palette  - pointer to a list of new pens
*
*       A pens list should contain the exact number of pens as
*       an old image uses. (2 if image's depth is 1, 4 if image's
*       depth is 2, etc.). An image's colour 0 will be remapped to the
*       first pen on the list, image's colour 1 will be remapped to
*       the second pen on the list and so on.
*
*   RESULT
*       newImage - pointer to a newly initialized remapped old image's
*                  clone. If there is not enough memory, newImage will
*                  be NULL.
*       IMPORTANT: If a new image was created you have to call
*       FreeNewImg() to free the allocated memory, when you no longer
*       need to use it!
*
*   EXAMPLE
*
*       We have a depth 2 image (4 colours), and we want to use pens
*       0,16,4,7 instead of 0,1,2,3:
*
*
*       struct Image OldImage = {
*           ....    \* This is a data of our original image *\
*
*       struct Image *NewImage;
*       ULONG pal[] = {0, 16, 4, 7}; \* The new pen list *\
*
*       if (NewImage = MakeNewImg(&OldImage, &pal[0])) {
*          DrawImage(rp, NewImage);
*          FreeNewImg(NewImage);    \* We will no longer use it *\
*       }
*
*   NOTE
*       A new image's depth will change to a depth that can hold
*       the largest pen number from a pens list. It does not have
*       any smart routine to check if the depth can be optimized
*       down, by altering PlanePick and PlaneOnOff, yet.
*       Bear in mind that if you provide a pen 255, then a new image's
*       depth will be at least 8.
*
*       You MUST free a new image with FreeNewImg() when it's no longer
*       needed!
*
*       This function can take much time when remapping larger images
*       with more depths.
*
*   BUGS
*       None found.
*
*   SEE ALSO
*       FreeNewImg()
*
**********************************************************************/

#include<proto/exec.h>
#include<exec/exec.h>
#include<intuition/intuition.h>

char __asm mkImg(register __a1 UWORD *,
                    register __a2 UWORD *,
                    register __a3 ULONG *,
                    register __d4 LONG,
                    register __d5 LONG,
                    register __d6 LONG);

struct Image *MakeNewImg(struct Image *img, ULONG *pal)
{
struct Image *newimg;
UWORD i, num, max=0, dep;
WORD wid;
LONG mask=0;

    if (newimg = AllocMem(sizeof(struct Image), 0)) {
        dep = img->Depth;
        num = 1<<dep;

        /* Get the maximum palette color entry */
        for (i=0; i<num; i++) if (pal[i] > max) max = pal[i];

        /* Get a destination depth */
        while (max>>dep > 0) dep++;

        /* Width must be word aligned */
        i=0;
        wid = img->Width;
        while(i < wid) i+=16;
        wid = i; /* NOTE: Width=0 is not considered yet */

        /* Alloc Planes */
        if (newimg->ImageData = AllocMem(img->Height*wid*dep/8, MEMF_CHIP | MEMF_CLEAR)) {
            /* Fill newimg fields */

            newimg->Depth = dep;
            newimg->Height = img->Height;
            newimg->Width = img->Width;
            newimg->LeftEdge = img->LeftEdge;
            newimg->TopEdge = img->TopEdge;
            for (i=0; i<dep; i++) mask |= 1<<i;
            newimg->PlanePick = mask;
            newimg->PlaneOnOff = 0;
            newimg->NextImage = NULL;

            mkImg(img->ImageData, newimg->ImageData, pal,
                     img->Height*wid/8, img->Depth, dep);

        }
    }

    if (newimg) {
        if (newimg->ImageData) return(newimg);
        else {
            FreeMem(newimg, sizeof(struct Image));
            return(NULL);
        }
    } else return(NULL);
}
