/*
 * cjpeg.c - Compress a JPEG file from a PBMPLUS file.
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

LONG width;
LONG height;
ULONG colorspace;
UWORD fileid;

LONG row;
LONG maxval;

UBYTE *buffer;
ULONG bufsize;


/* We use unbuffered I/O */
static int GetC(BPTR file)
{
	TEXT c;

	if (Read(file, &c, 1) == 1) return (c);
	return (-1);
}


static TEXT SkipWhite(BPTR file)
{
	TEXT c;

	do
	{
		c = GetC(file);
		if (c == '#')
		{
			while ((c = GetC(file)) != '\n') { };
			c = GetC(file);
		}
	} while (c == ' ' || c == '\n' || c == '\t' || c == '\r');
	return (c);
}


LONG GetPBMWord(BPTR file)
{
	TEXT buffer[16], c;
	STRPTR ptr = buffer;
	LONG value = 0;

	*ptr++ = SkipWhite(file);
	do
	{
		c = GetC(file);
		*ptr++ = c;
	} while (c >= '0' && c <= '9');
	StrToLong(buffer, &value);
	return (value);
}


int main(int argc, char *argv[])
{
	BPTR file = Input();

	if (IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 37))
	{
		if (TowerBase = OpenLibrary(TOWERLIBRARY, 1))
		{
			if (obj = NewExtObject(JPEGCODEC,
			 CDA_Coding, TRUE,
			 CDA_StreamType, CDST_FILE,
			 CDA_Stream, Output(),
			TAG_DONE))
			{
				Read(file, &fileid, 2);
				if (fileid == 0x5035)
				{
					colorspace = PCDCS_GRAYSCALE;
				}
				else if (fileid == 0x5036)
				{
					colorspace = PCDCS_RGB;
				}
				else
				{
					colorspace = PCDCS_UNKNOWN;
				}
				if (colorspace != PCDCS_UNKNOWN)
				{
					width = GetPBMWord(file);
					height = GetPBMWord(file);
					maxval = GetPBMWord(file);
					if (maxval == 255 && width > 0 && height > 0)
					{
						SetAttrs(obj,
						 PCDA_Width, width,
						 PCDA_Height, height,
						 PCDA_Components, colorspace == PCDCS_GRAYSCALE ? 1 : 3,
						 PCDA_ColorSpace, colorspace,
						TAG_DONE);
						if (DoMethod(obj, CDM_START))
						{
							bufsize = (colorspace == PCDCS_GRAYSCALE ? width : 3 * width);
							if (buffer = AllocVec(bufsize, MEMF_PUBLIC))
							{
								for (row = 0; row < height; row++)
								{
									Read(file, buffer, bufsize);
									if (DoMethod(obj, CDM_PROCESS, buffer, bufsize) != bufsize) break;
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


