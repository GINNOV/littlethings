/* based on tmapdemo/dumpchunky.c, but made more useful ;-) */

#include <stdio.h>

FILE *fout=0;

#include <exec/types.h>
#include <clib/exec_protos.h>
#include <graphics/view.h>
#include <graphics/rastport.h>
	/*#include <intuition/intuition.h>	Hey guys, let's use the
	#include <intuition/screens.h>		correct includes ;-)    */
#include <stdio.h>
#define NO_PRAGMAS 1
/*#include "pd:ifflib/iff.h"*/

struct IFFL_BMHD {	/* i'm guessing here - i don't have the includes... */
	UWORD w,h;
	WORD x,y;
	UBYTE nPlanes,masking,compression,pad1;
	UWORD transparentColor;
	UBYTE xAspect,yAspect;
	WORD pageWidth,pageHeight;
	};
#define ID_CMAP 0x434d4150		/* and here too */

#pragma libcall IFFBase OpenIFF 1e 801
#pragma libcall IFFBase CloseIFF 24 901
#pragma libcall IFFBase FindChunk 2a 902
#pragma libcall IFFBase GetBMHD 30 901
#pragma libcall IFFBase GetColorTab 36 8902
#pragma libcall IFFBase DecodePic 3c 8902
#pragma libcall IFFBase SaveBitMap 42 a9804
/*#pragma libcall IFFBase SaveClip 48 210a9808*/
#pragma libcall IFFBase IFFError 4e 0
#pragma libcall IFFBase GetViewModes 54 901
#pragma libcall IFFBase NewOpenIFF 5a 802
#pragma libcall IFFBase ModifyFrame 60 8902

struct Library *GfxBase,*IntuitionBase,*IFFBase;
struct BitMap *mybitmap;
ULONG *infile;

void Fail(char *msg)
{
	if (fout) fclose(fout);
	if (msg) printf("%s\n",msg);
	if (mybitmap) FreeBitMap(mybitmap);
	if (GfxBase) CloseLibrary(GfxBase);
	if (infile) CloseIFF(infile);
	if (IFFBase) CloseLibrary(IFFBase);
	exit(0);
}


struct Library *openlib(char *name,ULONG version)
{
	struct Library *t1;
	t1=OpenLibrary(name,version);
	if (! t1)
	{
		printf("error- needs %s version %d\n",name,version);
		Fail(0l);
	}
	else return(t1);
}



UWORD cmap[256];

struct RastPort myrp;

main(argc,argv)
int argc;
char **argv;
{
	GfxBase=openlib("graphics.library",39);
	IFFBase=openlib("iff.library",0);
	if (argc==3)
	{
	if (fout=fopen(argv[2],"wb"))
	 {
		if (infile=OpenIFF(argv[1]))
		{
			ULONG scrwidth,scrheight,scrdepth;
			ULONG i,j;
			struct IFFL_BMHD *bmhd;

			ULONG *form,*chunk;
			ULONG count;
			UBYTE *ptr;

			chunk=FindChunk(infile,ID_CMAP);
			if (! chunk) Fail("no color table");
			chunk++;
			count=(*(chunk++))/3;
			ptr=chunk;
			if (count>256) count=256;

			for(i=0;i<count;i++)
				cmap[i]=(((*ptr++)&0xf0)<<4)|((*ptr++)&0xf0)|(((*ptr++)&0xf0)>>4);
 
			if(!(bmhd=GetBMHD(infile))) Fail("BitMapHeader not found");
			InitRastPort(&myrp);

			scrwidth = bmhd->w;
			scrheight = bmhd->h;
			scrdepth = bmhd->nPlanes;
			mybitmap=AllocBitMap(scrwidth,scrheight,scrdepth,BMF_CLEAR,0l);
			if (! mybitmap) Fail("no bitmap");
			if(!DecodePic(infile,mybitmap)) Fail("Can't decode picture");
			myrp.BitMap=mybitmap;
			for(i=0;i<scrwidth;i++)
				for(j=0;j<scrheight;j++)
					outb(ReadPixel(&myrp,i,j));

			flbuf();
			Fail(0);
		}
	 }
	}
}

#define BUFSZ 4096

UWORD buffer[BUFSZ];

int curout=0;

outb(c)
{
	buffer[curout++]=cmap[c];
	if (curout==BUFSZ)
		{
		if (curout!=fwrite(&buffer[0],sizeof(buffer[0]),curout,fout))
			Fail("cannot write data");
		curout=0;
		}
}

flbuf()
{
if (curout!=fwrite(&buffer[0],sizeof(buffer[0]),curout,fout))
	Fail("cannot write data");
curout=0;
}
