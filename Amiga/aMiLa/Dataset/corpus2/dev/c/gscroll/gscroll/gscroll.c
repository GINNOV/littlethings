#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <datatypes/datatypes.h>      /* Datatypes definitions we need */
#include <datatypes/pictureclass.h>

#include <intuition/intuition.h>
#include <graphics/gfxmacros.h>
#include <dos/var.h>
#include <dos/dos.h>
#include <ifflib/iff.h>
/* #include <libraries/bgui.h> */

#include <stdio.h>
#include <stdlib.h>

#include <clib/alib_protos.h>

#include <proto/exec.h>
#include <clib/intuition_protos.h>
#include <proto/datatypes.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/dos.h>
/* #include <proto/bgui.h>
#include <proto/bitmap.h> */

#include <string.h>

UBYTE Copyright[]="GScroll. Copyright (C) 1995 by Reinhard Katzmann. All Rights Reserved.";
extern struct Library *IntuitionBase;

#define TEMPLATE "IFFFONT/A,TEXTFILE/A,W=WIDTH/K,H=HEIGHT/K,D=DEPTH/K,N=NUMCROW/K,R=ROWS/K,C=CHARS"
#define OPT_IFFFONT		0
#define OPT_TEXTFILE		1
#define OPT_WIDTH			2
#define OPT_HEIGHT		3
#define OPT_DEPTH			4
#define OPT_NUMCROW		5
#define OPT_ROWS			6
#define OPT_CHAR			7
#define OPT_COUNT			8
#define ENVFILE "ENV:gscroll"
#define OSVERSION(ver)	(IntuitionBase->lib_Version >= (ver))
#define HAS_AGA			(GfxBase->ChipRevBits0 & GFXF_AA_ALICE)

typedef struct ColBMFont {
	UBYTE		cf_FontWidth;		/* Width of one Charakter 							*/
	UBYTE		cf_FontHeight;		/* Height of one Charakter 						*/
	UBYTE		cf_FontDepth;		/* Depth of Font										*/
	UBYTE		cf_CharsPerRow;	/* Number of Charakters in a row					*/
	UBYTE		cf_Rows;				/* Number of rows										*/
	UBYTE    cf_FontMap[256];	/* Array of all Charakter types in the Font	*/
										/* If NULL, ASCII is used beginning with 32 	*/
	struct BitMap *cf_FontBM;	/* Bitmap of Color Font								*/
} COLBMFONT;

struct Library	*IFFBase;		/* Nothing goes without that */
struct Window *win;
struct Screen *scr;
struct RDArgs *myrda=NULL;

void CloseAll(BOOL ec)
{
	if (win) CloseWindow(win);
	if (myrda) FreeArgs(myrda);
	exit(ec);
}

/* 
**		Print out specific IFF error
*/
static void PrintIFFError(void)
{
	char *text;

	switch (IFFL_IFFError() )
	{
		case IFFL_ERROR_OPEN:
			text = "Can't open file";
			break;

		case IFFL_ERROR_READ:
			text = "Error reading file";
			break;

		case IFFL_ERROR_NOMEM:
			text = "Not enough memory";
			break;

		case IFFL_ERROR_NOTIFF:
			text = "Not an IFF file";
			break;

		case IFFL_ERROR_NOBMHD:
			text = "No IFF BMHD found";
			break;

		case IFFL_ERROR_NOBODY:
			text = "No IFF BODY found";
			break;

		case IFFL_ERROR_BADCOMPRESSION:
			text = "Unsupported compression mode";
			break;

		default:
			text = "Unspecified error";
			break;
	}
	printf("%s\n", text);
}

/*
** Free a allocated BitMap
*/
void MyFreeBitMap(struct BitMap *bm)
{
	if (OSVERSION(39) )
	{
		FreeBitMap(bm);
	}
	else					/* Running under V37 */
	{
		LONG	planesize = bm->BytesPerRow * bm->Rows;
		int		i;

		for (i = 0; i < bm->Depth; ++i)
		{
			if (bm->Planes[i])
			{
				FreeMem(bm->Planes[i], planesize);
			}
		}
		FreeVec(bm);
		bm=NULL;
	}
}

/*
** Allocate a BitMap
*/
struct BitMap *MyAllocBitMap(LONG depth, LONG width, LONG height, struct BitMap *frbm)
{
	struct BitMap *bm;

	if (OSVERSION(39) )
	{
		if (frbm) bm = AllocBitMap(width, height, depth, BMF_CLEAR | BMF_DISPLAYABLE, frbm);
		else bm = AllocBitMap(width, height, depth, BMF_CLEAR | BMF_DISPLAYABLE, NULL);
	}
	else
	{
		LONG planesize, bmsize = sizeof(struct BitMap);

		/*
		**	If the bitmap has more than 8 planes, we add the size of the
		**	additional plane pointers to the amount of memory we allocate
		**	for the bitmap structure.
		*/
		if (depth > 8)
			bmsize += sizeof(PLANEPTR) * (depth-8);

		if (bm = AllocVec(bmsize, MEMF_PUBLIC | MEMF_CLEAR) )
		{
			int i;

			InitBitMap(bm, depth, width, height);
			planesize = bm->BytesPerRow * bm->Rows;

			for (i = 0; i < depth; ++i)
			{
				if (bm->Planes[i] = AllocMem(planesize, MEMF_CHIP | MEMF_CLEAR) )
				{
				}
				else
				{
					MyFreeBitMap(bm);
					bm = NULL;
					break;
				}
			}
		}
	}
	return bm;
}

void ParseEnvFile(COLBMFONT *colfont)
{
	UBYTE co;
	FILE *fp;
	char zeile[256];
	
	fp=fopen(ENVFILE,"r");
	if (!fp) { /* Set defaults */
 		colfont->cf_FontWidth=32;
		colfont->cf_FontHeight=32;
		colfont->cf_FontDepth=3;
		colfont->cf_CharsPerRow=10;
		colfont->cf_Rows=6;
		for (co=32;co<255;co++) colfont->cf_FontMap[co]=co-32;
		return;
	}

	if (fgets(zeile,256,fp) || !(feof(fp))) colfont->cf_FontWidth=(UBYTE)atol(zeile);
	
	if (fgets(zeile,256,fp) || !(feof(fp))) colfont->cf_FontHeight=(UBYTE)atol(zeile);
	
	if (fgets(zeile,256,fp) || !(feof(fp))) colfont->cf_FontDepth=(UBYTE)atol(zeile);
	
	if (fgets(zeile,256,fp) || !(feof(fp))) colfont->cf_CharsPerRow=(UBYTE)atol(zeile);
		
	if (fgets(zeile,256,fp) || !(feof(fp))) colfont->cf_Rows=(UBYTE)atol(zeile);
	
	if (fgets(zeile,256,fp) || !(feof(fp))) {
		for (co=0;co<strlen(zeile);co++) colfont->cf_FontMap[(UBYTE)zeile[co]]=co;
	}

	fclose(fp);
}

BOOL PicLoad(char *fontfile, struct BitMap *bm)
/* Load an IFF Font file from disk */
{
	IFFL_HANDLE	ifffile;	/* IFF file handle */
	struct IFFL_BMHD		*bmhd;

	if (! (IFFBase = OpenLibrary(IFFNAME, 19L)) ) {
		printf("Could not open iff.library.\n");
		return FALSE;
	}

	if ( !(ifffile = IFFL_OpenIFF(fontfile, IFFL_MODE_READ)) )
	{
		PrintIFFError();
		return FALSE;
	}

	if ( *(((ULONG *)ifffile)+2) != ID_ILBM)
	{
		printf("Not an ILBM picture\n");
		return FALSE;
	}

	if ( !(bmhd = IFFL_GetBMHD(ifffile)) )
	{
		PrintIFFError();
		return FALSE;
	}

	/* Colortable is ignored, this is only a small example :-) */
	
	if (! (IFFL_DecodePic(ifffile, bm) ) )
	{
	  printf("FATAL: Could not decode picture.\n");
	  PrintIFFError();
	  if(ifffile) IFFL_CloseIFF(ifffile);
	  CloseAll(FALSE);
	}

	/* All went well, so we can close the file */
	if(ifffile) IFFL_CloseIFF(ifffile);	

	if (IFFBase) CloseLibrary(IFFBase);
	return TRUE;
}

BOOL CheckMsgs(APTR dto, char **line, UBYTE zz, struct BitMap *bm)
{
	UBYTE co;
	ULONG MessageClass;
	struct IntuiMessage     *botschaft;

	if ((botschaft = (struct IntuiMessage *)
		GetMsg(win->UserPort)) != NULL)
	{
		MessageClass = botschaft->Class;
		ReplyMsg((struct Message *)botschaft);
		switch (MessageClass)
		{
			case IDCMP_CLOSEWINDOW: for (co=0;co<zz;co++) if (line[co]) FreeVec(line[co]);
											if (dto) DisposeDTObject(dto);
											else if (bm) MyFreeBitMap(bm);
											CloseAll(TRUE);
											break;

			case IDCMP_NEWSIZE: RectFill(win->RPort,win->BorderLeft+1,win->BorderTop+1,win->Width-win->BorderLeft-win->BorderRight+1,win->Height-win->BorderBottom-3);
			case IDCMP_CHANGEWINDOW: return TRUE;
											 break;
		}
	}
	return FALSE;
}

void main(int argc, char **argv)
{
	COLBMFONT colfont={0,0,0,0,0,NULL,NULL};
	UBYTE zz=0,co,ca,cu=0;
	ULONG left,top,width,height,wleft,wtop;
	LONG 	 result[OPT_COUNT]={NULL,NULL},pen;
	struct ColorRegister *cmap;
	struct 		 WBStartup *startup=NULL;
	struct ViewPort *VP;
	struct dtFrameBox mydtFrameBox; /* Use this with DTM_FRAMEBOX method   */
	struct FrameInfo myFrameInfo;   /* For info returned from DTM_FRAMEBOX */
	struct gpLayout mygpLayout;     /* Use this with DTM_PROCLAYOUT method */
	char *ifffile,*textfile,*line[20],carr[256],zeile[256];
	APTR dtobject=NULL; /* Pointer to a datatypes object       */
	FILE *tfp;
  
   if (argc==0) startup = (struct WBStartup *)argv;
	if (!startup) printf("%s\n",Copyright);
   if (argc==2 && !strcmp(argv[1],"?")) {
      printf("Usage: %s %s\n",argv[0],TEMPLATE);
      exit(TRUE);
   }

   if (!(myrda=ReadArgs(TEMPLATE, result, NULL))) {
      if (!startup) puts("Could not parse arguments.");
      CloseAll(FALSE);
   }

	if (!result[OPT_IFFFONT]) {
		printf("Required argument missing.\n");
		CloseAll(FALSE);
	} else ifffile=(char *)result[OPT_IFFFONT];

	if (!result[OPT_TEXTFILE]) {
		printf("Required argument missing.\n");
		CloseAll(FALSE);
	} else textfile=(char *)result[OPT_TEXTFILE];

	ParseEnvFile(&colfont);

	if (result[OPT_WIDTH]) colfont.cf_FontWidth=(UBYTE)atol((char *)result[OPT_WIDTH]);
	
	if (result[OPT_HEIGHT]) colfont.cf_FontHeight=(UBYTE)atol((char *)result[OPT_HEIGHT]);
	
	if (result[OPT_DEPTH]) colfont.cf_FontDepth=(UBYTE)atol((char *)result[OPT_DEPTH]);
	
	if (result[OPT_NUMCROW]) colfont.cf_CharsPerRow=(UBYTE)atol((char *)result[OPT_NUMCROW]);
		
	if (result[OPT_ROWS]) colfont.cf_Rows=(UBYTE)atol((char *)result[OPT_ROWS]);
	
	if (result[OPT_CHAR]) {
		strcpy(carr,(char *)result[OPT_CHAR]);
		for (co=0;co<strlen(carr);co++) colfont.cf_FontMap[carr[co]]=co;
	}

	if (!(scr=LockPubScreen(NULL)))
   {
   	if (!startup) puts("Could not lock Public Screen.");
   	CloseAll(FALSE);
  	}

	if (OSVERSION(39) ) {
		if (!(dtobject = NewDTObject(ifffile, PDTA_Screen, scr,
                         DTA_GroupID, GID_PICTURE,
                         TAG_END) )) {
	   	printf("Couldn't create new object or not a picture file\n");
   		CloseAll(FALSE);
   	}
		mydtFrameBox.MethodID         = DTM_FRAMEBOX;
		mydtFrameBox.dtf_GInfo        = NULL;
		mydtFrameBox.dtf_ContentsInfo = NULL;
		mydtFrameBox.dtf_FrameInfo    = &myFrameInfo;
		mydtFrameBox.dtf_SizeFrameInfo= sizeof (struct FrameInfo);
		mydtFrameBox.dtf_FrameFlags   = 0L;
		DoMethodA(dtobject, (Msg)&mydtFrameBox);

		mygpLayout.MethodID   = DTM_PROCLAYOUT;
		mygpLayout.gpl_GInfo  = NULL;
		mygpLayout.gpl_Initial= 1L;

		if(!(DoMethodA(dtobject, (Msg)&mygpLayout) )) {
			printf("Couldn't perform PROC_LAYOUT\n");
			if (dtobject) DisposeDTObject(dtobject);
			CloseAll(FALSE);
		}
		GetDTAttrs(dtobject, PDTA_DestBitMap, &colfont.cf_FontBM,
									PDTA_ColorRegisters,	&cmap, 
									TAG_END);
	} else { /* Now the hard work :-( */
		colfont.cf_FontBM=MyAllocBitMap(colfont.cf_FontDepth,colfont.cf_FontWidth*colfont.cf_CharsPerRow,colfont.cf_FontHeight*colfont.cf_Rows,NULL);
		if (!colfont.cf_FontBM) {
			printf("Could not allocate BitMap\n");
			CloseAll(FALSE);
		}

  		if (!PicLoad(ifffile,colfont.cf_FontBM)) {
			printf("Could not load IFF File.\n");
			MyFreeBitMap(colfont.cf_FontBM);
			CloseAll(FALSE);
		}
	
	}

	/* Font file has now been loaded */

	tfp=fopen(textfile,"r");
	if (!tfp) {
		printf("Could not open Text file for reading.\n");
		if (dtobject) DisposeDTObject(dtobject);
		else if (colfont.cf_FontBM) MyFreeBitMap(colfont.cf_FontBM);
		CloseAll(FALSE);
	}

	VP=&scr->ViewPort;

	win = OpenWindowTags(NULL,
				WA_Flags,
               WFLG_CLOSEGADGET |
               WFLG_SIZEGADGET |
               WFLG_DRAGBAR |
               WFLG_DEPTHGADGET |
               WFLG_SMART_REFRESH |
               WFLG_ACTIVATE,
            WA_IDCMP,
               IDCMP_NEWSIZE |
               IDCMP_CHANGEWINDOW |
               IDCMP_CLOSEWINDOW,
            WA_Left, 50,
            WA_Top, 100,
            WA_InnerWidth,640,
            WA_InnerHeight,colfont.cf_FontHeight+20,
            WA_MinWidth, colfont.cf_FontWidth,
            WA_MinHeight, colfont.cf_FontHeight+20,
            WA_MaxWidth, scr->Width,
            WA_MaxHeight, scr->Height,
            WA_Title, "Scroller Demo",
            WA_PubScreen, scr,
            TAG_DONE);
   if (!win) {
   	printf("Could not open Window.\n");
		if (dtobject) DisposeDTObject(dtobject);
		else if (colfont.cf_FontBM) MyFreeBitMap(colfont.cf_FontBM);
		fclose(tfp);
   	CloseAll(FALSE);
   }

	
	width=win->Width-win->BorderLeft-win->BorderRight;
	height=colfont.cf_FontHeight;
	wleft=win->LeftEdge+win->BorderLeft;
	wtop=win->TopEdge+win->BorderTop;

	if (OSVERSION(39) ) {
		pen=ObtainBestPen(VP->ColorMap,cmap->red<<24,cmap->green<<24,cmap->blue<<24,TAG_DONE);
		SetAPen(win->RPort, pen);
		SetBPen(win->RPort, pen);
		RectFill(win->RPort,win->BorderLeft+1,win->BorderTop+1,width+1,win->Height-win->BorderBottom-3);
	}

	while (fgets(zeile,256,tfp) || !(feof(tfp)) ) {
		if (zz>=20) continue;
		if (!strcmp(zeile,"\n")) continue;
		line[zz]=AllocVec(strlen(zeile),MEMF_PUBLIC|MEMF_CLEAR);
		if (line[zz]) {
			strcpy(line[zz],zeile);
			zz++;
		}
	}
	fclose(tfp);

	/* Now we can start scrolling the text */

	for (co=0;co<zz;co++) { /* All lines */
		for (ca=0;ca<(strlen(line[co])-1);ca++) { /* All Charakters of a line */
			if (line[co][ca]=='\t') line[co][ca]=' ';
			if (!colfont.cf_FontMap[line[co][ca]]) continue;
			left=colfont.cf_FontWidth*(colfont.cf_FontMap[line[co][ca]]%colfont.cf_CharsPerRow);
			top=colfont.cf_FontHeight*(colfont.cf_FontMap[line[co][ca]]/colfont.cf_CharsPerRow);
			for(cu=0;cu<colfont.cf_FontWidth;cu++) { /* Scroll all pixels of a charakter */
				if (CheckMsgs(dtobject,line,zz,colfont.cf_FontBM)) {
					width=win->Width-win->BorderLeft-win->BorderRight;
					wleft=win->LeftEdge+win->BorderLeft;
					wtop=win->TopEdge+win->BorderTop;
				}
				BltBitMap(colfont.cf_FontBM,left+cu,top,win->RPort->BitMap,wleft+width-3,wtop+3,1,colfont.cf_FontHeight,0xC0,0xFF,NULL);
				ScrollRaster(win->RPort,1,0,win->BorderLeft+1,win->BorderTop+1,win->BorderLeft+width-3,win->BorderTop+height+1);
				/* Delay(1); */
				
			}
		}
	}
	
	/* Text has been scrolled, now lets scroll the text out of the window */

	left=colfont.cf_FontWidth*(colfont.cf_FontMap[' ']%colfont.cf_CharsPerRow);
	top=colfont.cf_FontHeight*(colfont.cf_FontMap[' ']/colfont.cf_CharsPerRow);
	/* BltBitMap(colfont.cf_FontBM,0,0,win->RPort->BitMap,wleft,wtop,colfont.cf_FontWidth*colfont.cf_CharsPerRow,colfont.cf_FontHeight*colfont.cf_Rows,0xC0,0xFF,NULL); */
	for (co=0;co<(win->Width/colfont.cf_FontWidth);co++) {
		for(cu=0;cu<colfont.cf_FontWidth;cu++) { /* Scroll all pixels of a charakter */
			if (CheckMsgs(dtobject,line,zz,colfont.cf_FontBM)) {
				width=win->Width-win->BorderLeft-win->BorderRight;
				wleft=win->LeftEdge+win->BorderLeft;
				wtop=win->TopEdge+win->BorderTop;
			}
			BltBitMap(colfont.cf_FontBM,left+cu,top,win->RPort->BitMap,wleft+width-3,wtop+3,1,colfont.cf_FontHeight,0xC0,0xFF,NULL);
			ScrollRaster(win->RPort,1,0,win->BorderLeft+1,win->BorderTop+1,win->BorderLeft+width-3,win->BorderTop+height+1);
		}
	}

	/* Clean up */
	for (co=0;co<zz;co++) if (line[co]) FreeVec(line[co]);
	if (dtobject) DisposeDTObject(dtobject);
	else if (colfont.cf_FontBM) MyFreeBitMap(colfont.cf_FontBM);
  	CloseAll(TRUE);
}
