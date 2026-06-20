/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS highres blitting routines.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include <libraries/Picasso96.h>
#include "agraphics.h"

void gfx_blit_high_res(BITMAP *aBitmap, struct RenderInfo *aRenderInfo, int aTopLine, int aDestWidth, int aWidth, int aHeight)
{
	int X, Y, Modulo;

	switch (gDepth)
	{
		case 8 :
		{
			unsigned char *Source;
			unsigned long *Dest;

			/* aDestWidth is in bytes but we are working in 32 bit pixels */

			aDestWidth /= 4;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start */

			Source = (((unsigned char *) aBitmap->dat) + (aTopLine * aWidth));
			Dest = (((unsigned long *) aRenderInfo->Memory) + (aTopLine * aDestWidth));

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels */

			Modulo = ((aDestWidth - aWidth));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					*Dest++ = gPalette[*Source++];
				}

				Dest += Modulo;
			}

			break;
		}

		case 15 :
		case 16 :
		{
			unsigned short *Source, *Dest;

			/* aDestWidth is in bytes but we are working in 16 bit pixels */

			aDestWidth /= 2;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start */

			Source = (((unsigned short *) aBitmap->dat) + (aTopLine * aWidth));
			Dest = (((unsigned short *) aRenderInfo->Memory) + (aTopLine * aDestWidth));

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels */

			Modulo = ((aDestWidth - aWidth));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					*Dest++ = *Source++;
				}

				Dest += Modulo;
			}

			break;
		}

		case 24 :
		{
			unsigned char *Source, *Dest;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start */

			Source = (((unsigned char *) aBitmap->dat) + (aTopLine * aWidth * 3));
			Dest = (((unsigned char *) aRenderInfo->Memory) + (aTopLine * aDestWidth));

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels */

			Modulo = ((aDestWidth - (aWidth * 3)) / 3);

			/* 24 bit modes are slower than 32 bit because we have to copy by bytes, so */
			/* triple the width so that we copy each of the red, green and blue components */

			aWidth *= 3;

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					*Dest++ = *Source++;
				}

				Dest += Modulo;
			}

			break;
		}

		case 32 :
		{
			unsigned long *Source, *Dest;

			/* aDestWidth is in bytes but we are working in 32 bit pixels */

			aDestWidth /= 4;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start */

			Source = (((unsigned long *) aBitmap->dat) + (aTopLine * aWidth));
			Dest = (((unsigned long *) aRenderInfo->Memory) + (aTopLine * aDestWidth));

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels */

			Modulo = ((aDestWidth - aWidth));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					*Dest++ = *Source++;
				}

				Dest += Modulo;
			}

			break;
		}
	}
}
