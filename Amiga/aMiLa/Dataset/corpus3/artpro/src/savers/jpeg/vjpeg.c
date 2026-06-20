/*
 * vjpeg.c - View a JPEG file.
 *
 * It isn't really a good viewer, but it works.
 *
 * Copyright © 1994 Christoph Feck, TowerSystems.
 * This file is NOT distributable.
 */

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <graphics/rastport.h>
#include <graphics/displayinfo.h>
#include <codecs/jpeg.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/tower.h>

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *TowerBase;

BPTR fh;

APTR obj;

ULONG width;
ULONG height;
ULONG colorspace;
ULONG numcolors;
UBYTE **colormap;
UBYTE *buffer;

BOOL V39;

LONG i;
LONG row;

struct Screen *screen;
struct Window *window;
struct Message *msg;

struct RastPort temp_rp;
struct BitMap *temp_bm;

LONG maxdepth = 4;
struct DimensionInfo dim_info;


/* V37 compatible bitmap functions */

static struct BitMap *CreateBitMap(LONG width, LONG height, LONG depth)
{
	struct BitMap *bm;

	if (V39)
	{
		bm = AllocBitMap(width, height, depth, 0, NULL);
	}
	else
	{
		if (bm = AllocMem(sizeof(struct BitMap), MEMF_CLEAR | MEMF_PUBLIC))
		{
			LONG rassize = RASSIZE(width, height);

			InitBitMap(bm, depth, width, height);
			/* For simplicity, we allocate all planes in one big chunk */
			if (bm->Planes[0] = (PLANEPTR) AllocVec(depth * rassize, MEMF_CHIP))
			{
				LONG i;

				for (i = 1; i < depth; i++)
				{
					bm->Planes[i] = bm->Planes[i - 1] + rassize;
				}
			}
			else
			{
				FreeMem(bm, sizeof(struct BitMap));
				bm = NULL;
			}
		}
	}
	return (bm);
}


static void DeleteBitMap(struct BitMap *bm)
{
	if (bm)
	{
		if (V39)
		{
			FreeBitMap(bm);
		}
		else
		{
			FreeVec(bm->Planes[0]);
			FreeMem(bm, sizeof(struct BitMap));
		}
	}
}


static ULONG BitMapDepth(struct BitMap *bm)
{
	if (V39)
	{
		return (GetBitMapAttr(bm, BMA_DEPTH));
	}
	else
	{
		return (bm->Depth);
	}
}


static void DoJPEG(void)
{
	if (GetAttr(PCDA_Width, obj, &width)
	 && GetAttr(PCDA_Height, obj, &height)
	 && GetAttr(PCDA_ColorMap, obj, (ULONG *) &colormap)
	 && GetAttr(PCDA_NumColors, obj, &numcolors))
	{
		/* Add a few bytes for use with WritePixelLine8() */
		if (buffer = AllocVec(width + 32, MEMF_ANY))
		{
			if (screen = OpenScreenTags(NULL,
			 SA_Width, width,
			 SA_Height, height,
			 SA_Depth, maxdepth,
			 SA_DisplayID, HIRES | LACE,
			 SA_Quiet, TRUE,
			 SA_Behind, TRUE,
			 SA_AutoScroll, TRUE,
			 SA_Overscan, OSCAN_STANDARD,
			 SA_Interleaved, TRUE,
			 SA_BackFill, LAYERS_NOBACKFILL,
			 SA_MinimizeISG, TRUE,
			TAG_DONE))
			{
				/* temporary bitmap for WPA8() */
				if (temp_bm = CreateBitMap(width, 1, BitMapDepth(screen->RastPort.BitMap)))
				{
					InitRastPort(&temp_rp);
					temp_rp.BitMap = temp_bm;
					if (window = OpenWindowTags(NULL,
					 WA_CustomScreen, screen,
					 WA_Borderless, TRUE,
					 WA_Backdrop, TRUE,
					 WA_IDCMP, IDCMP_MOUSEBUTTONS | IDCMP_VANILLAKEY,
					 WA_RMBTrap, TRUE,
					 WA_BusyPointer, TRUE,
					 WA_Activate, TRUE,
					 V39 ? WA_BackFill : TAG_IGNORE, LAYERS_NOBACKFILL,
					TAG_DONE))
					{
						/* Really should use LoadRGBxx() instead... */
						for (i = 0; i < numcolors; i++)
						{
							if (colorspace == PCDCS_GRAYSCALE)
							{
								ULONG gray = colormap[0][i];

								if (V39)
								{
									SetRGB32(&screen->ViewPort, i, gray << 24, gray << 24, gray << 24);
								}
								else
								{
									SetRGB4(&screen->ViewPort, i, gray >> 4, gray >> 4, gray >> 4);
								}
							}
							else
							{
								ULONG red = colormap[0][i];
								ULONG green = colormap[1][i];
								ULONG blue = colormap[2][i];

								if (V39)
								{
									SetRGB32(&screen->ViewPort, i, red << 24, green << 24, blue << 24);
								}
								else
								{
									SetRGB4(&screen->ViewPort, i, red >> 4, green >> 4, blue >> 4);
								}
							}
						}
						ScreenToFront(screen);
						for (row = 0; row < height; row++)
						{
							if (DoMethod(obj, CDM_PROCESS, buffer, width) != width) break;
							if (msg = GetMsg(window->UserPort)) break;
							WritePixelLine8(&screen->RastPort, 0, row, width, buffer, &temp_rp);
						}
						ClearPointer(window);
						if (row == height)
						{
							DoMethod(obj, CDM_FINISH);
							if (msg == NULL)
							{
								WaitPort(window->UserPort);
								msg = GetMsg(window->UserPort);
							}
						}
						if (msg) ReplyMsg(msg);
						ScreenToBack(screen);
						CloseWindow(window);
					}
					else
					{
						Printf("Error opening window\n");
					}
					DeleteBitMap(temp_bm);
				}
				else
				{
					Printf("Error allocating temporary bitmap\n");
				}
				CloseScreen(screen);
			}
			else
			{
				Printf("Error opening screen\n");
			}
			FreeVec(buffer);
		}
		else
		{
			Printf("Error allocating buffer\n");
		}
	}
	else
	{
		Printf("Error obtaining attributes\n");
	}
}


static void PrintError(void)
{
	STRPTR string = "";

	GetAttr(CDA_ErrorString, obj, (ULONG *) &string);
	Printf("%s\n", string);
}


int main(int argc, char *argv[])
{
	if (IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 37))
	{
		if (GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 37))
		{
			V39 = ((struct Library *) GfxBase)->lib_Version >= 39;
			/* Find out maximum depth for HIRES | LACE mode */
			if (GetDisplayInfoData(NULL, (UBYTE *) &dim_info, sizeof(struct DimensionInfo), DTAG_DIMS, HIRES | LACE))
			{
				maxdepth = dim_info.MaxDepth;
				if (maxdepth > 8) maxdepth = 8;
			}
			if (TowerBase = OpenLibrary(TOWERLIBRARY, 1))
			{
				if (argc == 2)
				{
					if (fh = Open(argv[1], MODE_OLDFILE))
					{
						if (obj = NewExtObject(JPEGCODEC,
						 CDA_Coding, FALSE,
						 CDA_StreamType, CDST_FILE,
						 CDA_Stream, fh,
						TAG_DONE))
						{
							if (DoMethod(obj, CDM_READHEADER) == HEADER_READY)
							{
								if (GetAttr(PCDA_ColorSpace, obj, &colorspace))
								{
									SetAttrs(obj,
									 PCDA_ColorSpace, colorspace == PCDCS_GRAYSCALE ? PCDCS_GRAYSCALE : PCDCS_RGB,  /* Force RGB, if not grayscale */
									 PCDA_QuantizeColors, TRUE,
									 PCDA_NumColors, 1 << maxdepth,
									 PCDA_TwoPassQuantize, FALSE,
									TAG_DONE);
									if (DoMethod(obj, CDM_START))
									{
										DoJPEG();
									}
									else
									{
										PrintError();
									}
								}
							}
							else
							{
								PrintError();
							}
							DisposeExtObject(obj);
						}
						else
						{
							Printf("Error creating JPEG object\n");
						}
						Close(fh);
					}
					else
					{
						Printf("Error opening file %s\n", argv[1]);
					}
				}
				else
				{
					Printf("Usage: %s filename\n", argv[0]);
				}
				CloseLibrary(TowerBase);
			}
			else
			{
				Printf("Error opening tower.library version 1\n");
			}
			CloseLibrary((struct Library *) GfxBase);
		}
		CloseLibrary((struct Library *) IntuitionBase);
	}
	return (0);
}


