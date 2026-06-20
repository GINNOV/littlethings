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
 *      Amiga OS lowres blitting routines.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include <libraries/Picasso96.h>
#include "agraphics.h"

void gfx_blit_low_res(BITMAP *aBitmap, struct RenderInfo *aRenderInfo, int aTopLine, int aDestWidth, int aWidth, int aHeight)
{
	int X, Y, Modulo;

	switch (gDepth)
	{
		case 8 :
		{
			unsigned char *Source;
			unsigned long *Dest, *Dest2, Pixel;

			/* aDestWidth is in bytes but we are working in 32 bit pixels */

			aDestWidth /= 4;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start and the fact that each line is actually */
			/* 2 pixels high (hence the * 2 in the Dest calculation) */

			Source = (((unsigned char *) aBitmap->dat) + (aTopLine * aWidth));
			Dest = (((unsigned long *) aRenderInfo->Memory) + (aTopLine * 2 * aDestWidth));

			/* Also calculate a ptr to the second destination line */

			Dest2 = (Dest + aDestWidth);

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels, again taking into account */
			/* that each line is 2 pixels high.  Note that aWidth is in pixels */

			Modulo = (aDestWidth - (aWidth * 2));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					/* Get the source pixel and write it 4 times, in a small "square," thereby */
					/* doubling the width & height of the pixel */

					Pixel = gPalette[*Source++];

					*Dest++ = Pixel;
					*Dest++ = Pixel;
					*Dest2++ = Pixel;
					*Dest2++ = Pixel;
				}

				/* And point to the start of the next destination lines */

				Dest = (Dest + aDestWidth + Modulo);
				Dest2 = (Dest2 + aDestWidth + Modulo);
			}

			break;
		}

		case 15 :
		case 16 :
		{
			unsigned short *Source, *Dest, *Dest2, Pixel;

			/* aDestWidth is in bytes but we are working in 16 bit pixels */

			aDestWidth /= 2;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start and the fact that each line is actually */
			/* 2 pixels high (hence the * 2 in the Dest calculation) */

			Source = (((unsigned short *) aBitmap->dat) + (aTopLine * aWidth));
			Dest = (((unsigned short *) aRenderInfo->Memory) + (aTopLine * 2 * aDestWidth));

			/* Also calculate a ptr to the second destination line */

			Dest2 = (Dest + aDestWidth);

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels, again taking into account */
			/* that each line is 2 pixels high.  Note that aWidth is in pixels */

			Modulo = (aDestWidth - (aWidth * 2));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					/* Get the source pixel and write it 4 times, in a small "square," thereby */
					/* doubling the width & height of the pixel */

					Pixel = *Source++;

					*Dest++ = Pixel;
					*Dest++ = Pixel;
					*Dest2++ = Pixel;
					*Dest2++ = Pixel;
				}

				/* And point to the start of the next destination lines */

				Dest = (Dest + aDestWidth + Modulo);
				Dest2 = (Dest2 + aDestWidth + Modulo);
			}

			break;
		}

		case 24 :
		{
			unsigned char *Source, *Dest, *Dest2, Pixel;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start and the fact that each line is actually */
			/* 2 pixels high (hence the * 2 in the Dest calculation).  Note that unlike most */
			/* other modes, both source *and* destination are bytes, not pixels, as each */
			/* pixel is 3 bytes and therefore unaligned */

			Source = (((unsigned char *) aBitmap->dat) + (aTopLine * aWidth * 3));
			Dest = (((unsigned char *) aRenderInfo->Memory) + (aTopLine * 2 * aDestWidth));

			/* Also calculate a ptr to the second destination line */

			Dest2 = (Dest + aDestWidth);

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels, again taking into account */
			/* that each line is 2 pixels high and that each pixel is 3 bytes.  Note that both */
			/* aDestWidth and aWidth is in bytes in this case */

			Modulo = (aDestWidth - (aWidth * 3 * 2));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					/* Get the source pixel and write it 4 times, in a small "square," thereby */
					/* doubling the width & height of the pixel */

					Pixel = *Source++;
					*Dest = Pixel;
					*(Dest + 3) = Pixel;
					*Dest2 = Pixel;
					*(Dest2 + 3) = Pixel;

					Pixel = *Source++;
					*(Dest + 1) = Pixel;
					*(Dest + 4) = Pixel;
					*(Dest2 + 1) = Pixel;
					*(Dest2 + 4) = Pixel;

					Pixel = *Source++;
					*(Dest + 2) = Pixel;
					*(Dest + 5) = Pixel;
					*(Dest2 + 2) = Pixel;
					*(Dest2 + 5) = Pixel;

					Dest += 6;
					Dest2 += 6;
				}

				/* And point to the start of the next destination lines */

				Dest = (Dest + aDestWidth + Modulo);
				Dest2 = (Dest2 + aDestWidth + Modulo);
			}

			break;
		}

		case 32 :
		{
			unsigned long *Source, *Dest, *Dest2, Pixel;

			/* aDestWidth is in bytes but we are working in 32 bit pixels */

			aDestWidth /= 4;

			/* Calculate ptrs to the source and destination bitmaps, taking into account */
			/* the line at which copying will start and the fact that each line is actually */
			/* 2 pixels high (hence the * 2 in the Dest calculation) */

			Source = (((unsigned long *) aBitmap->dat) + (aTopLine * aWidth));
			Dest = (((unsigned long *) aRenderInfo->Memory) + (aTopLine * 2 * aDestWidth));

			/* Also calculate a ptr to the second destination line */

			Dest2 = (Dest + aDestWidth);

			/* P96 BitMaps are usually wider than requested, so take this into account by */
			/* calculating a modulo to use to skip the unused pixels, again taking into account */
			/* that each line is 2 pixels high.  Note that aWidth is in pixels */

			Modulo = (aDestWidth - (aWidth * 2));

			/* Loop around and copy Allegro's bitmap into the P96 BitMap */

			for (Y = 0; Y < aHeight; ++Y)
			{
				for (X = 0; X < aWidth; ++X)
				{
					/* Get the source pixel and write it 4 times, in a small "square," thereby */
					/* doubling the width & height of the pixel */

					Pixel = *Source++;

					*Dest++ = Pixel;
					*Dest++ = Pixel;
					*Dest2++ = Pixel;
					*Dest2++ = Pixel;
				}

				/* And point to the start of the next destination lines */

				Dest = (Dest + aDestWidth + Modulo);
				Dest2 = (Dest2 + aDestWidth + Modulo);
			}

			break;
		}
	}
}
