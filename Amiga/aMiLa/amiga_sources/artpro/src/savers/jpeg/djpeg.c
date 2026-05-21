/*
 * djpeg.c - Decompress a JPEG file to a PBMPLUS file.
 *
 * This uses Input()/Output() to work with pipes.
 *
 * Copyright © 1994 Christoph Feck, TowerSystems.
 * This file is NOT distributable.
 */

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <codecs/jpeg.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/tower.h>

#include <string.h>

struct IntuitionBase *IntuitionBase;
struct Library *TowerBase;

APTR obj;

ULONG width;
ULONG height;
ULONG colorspace;

ULONG row;

UBYTE *buffer;
ULONG bufsize;
char textbuf[30];


/* Hack to avoid sprintf */
static void RawFormatString(STRPTR string, STRPTR ctrl, ...)
{
	RawDoFmt(ctrl, ((ULONG *) &ctrl) + 1, (void (*))"\x16\xc0\x4e\x75", string);
}


int main(int argc, char *argv[])
{
	if (IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 37))
	{
		if (TowerBase = OpenLibrary(TOWERLIBRARY, 1))
		{
			if (obj = NewExtObject(JPEGCODEC,
			 CDA_Coding, FALSE,
			 CDA_StreamType, CDST_FILE,
			 CDA_Stream, Input(),
			TAG_DONE))
			{
				if (DoMethod(obj, CDM_READHEADER) == HEADER_READY)
				{
					if (GetAttr(PCDA_ColorSpace, obj, &colorspace)
					 && GetAttr(PCDA_Width, obj, &width)
					 && GetAttr(PCDA_Height, obj, &height))
					{
						SetAttrs(obj,
						 PCDA_ColorSpace, colorspace == PCDCS_GRAYSCALE ? PCDCS_GRAYSCALE : PCDCS_RGB, /* Force RGB, if not gray */
						TAG_DONE);
						if (DoMethod(obj, CDM_START))
						{
							bufsize = (colorspace == PCDCS_GRAYSCALE ? width : 3 * width);
							if (buffer = AllocVec(bufsize, MEMF_PUBLIC))
							{
								if (colorspace == PCDCS_GRAYSCALE)
								{
									RawFormatString(textbuf, "P5\n%lu %lu\n255\n", width, height);
								}
								else
								{
									RawFormatString(textbuf, "P6\n%lu %lu\n255\n", width, height);
								}
								Write(Output(), textbuf, strlen(textbuf));
								for (row = 0; row < height; row++)
								{
									if (DoMethod(obj, CDM_PROCESS, buffer, bufsize) != bufsize) break;
									Write(Output(), buffer, bufsize);
								}
								if (row == height) DoMethod(obj, CDM_FINISH);
								FreeVec(buffer);
							}
						}
					}
				}
				DisposeExtObject(obj);
			}
			CloseLibrary(TowerBase);
		}
		CloseLibrary((struct Library *) IntuitionBase);
	}
	return (0);
}


