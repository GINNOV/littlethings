/*********************************************/
/*                                           */
/*       Designer (C) Ian OConnor 1994       */
/*                                           */
/*      Designer Produced C include file     */
/*                                           */
/*********************************************/

#include <exec/types.h>
#include <libraries/locale.h>
#include <exec/memory.h>
#include <dos/dosextens.h>
#include <intuition/screens.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <diskfont/diskfont.h>
#include <utility/utility.h>
#include <graphics/gfxbase.h>
#include <workbench/workbench.h>
#include <graphics/scale.h>
#include <proto/locale.h>
#include <proto/exec.h>
#include <proto/wb.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <string.h>
#include <proto/diskfont.h>

#include "iraGUI.h"


STATIC ULONG BevelTags[] = 
	{
	(GTBB_Recessed), TRUE,
	(GT_VisualInfo), 0,
	(TAG_DONE)
	};

STATIC struct Window *IRAPref0 = NULL;
STATIC APTR IRAPref0VisualInfo;
STATIC APTR IRAPref0DrawInfo;
STATIC struct Gadget *IRAPref0GList;
STATIC struct Gadget *IRAPref0Gadgets[18];
STATIC UBYTE IRAPref0FirstRun = 0;

STATIC CONST_STRPTR Win0_Gad0Labels[] =
{
	(CONST_STRPTR)Win0_Gad0String0,
	(CONST_STRPTR)Win0_Gad0String1,
	(CONST_STRPTR)Win0_Gad0String2,
	(CONST_STRPTR)Win0_Gad0String3,
	(CONST_STRPTR)Win0_Gad0String4,
	(CONST_STRPTR)Win0_Gad0String5,
	NULL
};

STATIC CONST_STRPTR Win0_Gad1Labels[] =
{
	(CONST_STRPTR)Win0_Gad1String0,
	(CONST_STRPTR)Win0_Gad1String1,
	NULL
};

STATIC CONST_STRPTR Win0_Gad2Labels[] =
{
	(CONST_STRPTR)Win0_Gad2String0,
	(CONST_STRPTR)Win0_Gad2String1,
	NULL
};

STATIC CONST_STRPTR IRAPref0_Gad15Labels[] =
{
	(CONST_STRPTR)IRAPref0_Gad15String0,
	(CONST_STRPTR)IRAPref0_Gad15String1,
	(CONST_STRPTR)IRAPref0_Gad15String2,
	(CONST_STRPTR)IRAPref0_Gad15String3,
	(CONST_STRPTR)IRAPref0_Gad15String4,
	(CONST_STRPTR)IRAPref0_Gad15String5,
	(CONST_STRPTR)IRAPref0_Gad15String6,
	(CONST_STRPTR)IRAPref0_Gad15String7,
	NULL
};

STATIC CONST ULONG IRAPref0GadgetTags[] =
	{
	(GTCY_Labels), (ULONG)&Win0_Gad0Labels[0],
	(TAG_END),
	(GTCY_Labels), (ULONG)&Win0_Gad1Labels[0],
	(TAG_END),
	(GTCY_Labels), (ULONG)&Win0_Gad2Labels[0],
	(TAG_END),
	(GTCB_Checked), TRUE,
	(TAG_END),
	(GTCB_Checked), TRUE,
	(TAG_END),
	(GTCB_Checked), TRUE,
	(TAG_END),
	(GTCB_Checked), TRUE,
	(TAG_END),
	(GTCB_Checked), TRUE,
	(TAG_END),
	(GTST_MaxChars), 16,
	(STRINGA_Justification), 512,
	(GA_TabCycle), FALSE,
	(TAG_END),
	(GTST_MaxChars), 16,
	(STRINGA_Justification), 512,
	(GA_TabCycle), FALSE,
	(TAG_END),
	(GTCY_Active), 7,
	(GTCY_Labels), (ULONG)&IRAPref0_Gad15Labels[0],
	(TAG_END),
	(GTST_MaxChars), 16,
	(STRINGA_Justification), 512,
	(GA_Disabled), TRUE,
	(GA_TabCycle), FALSE,
	(TAG_END),
	(GTST_MaxChars), 4,
	(STRINGA_Justification), 512,
	(GA_Disabled), TRUE,
	(GA_TabCycle), FALSE,
	(TAG_END),
	(GT_Underscore), '_',
	(TAG_END),
	(GT_Underscore), '_',
	(TAG_END),
	(GT_Underscore), '_',
	(TAG_END),
	};

CONST UWORD IRAPref0GadgetTypes[] =
	{
	CYCLE_KIND,
	CYCLE_KIND,
	CYCLE_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	STRING_KIND,
	STRING_KIND,
	CYCLE_KIND,
	STRING_KIND,
	STRING_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	};

STATIC struct NewGadget IRAPref0NewGadgets[] =
	{
	37, 2, 82, 13, (UBYTE*)Win0_Gad0String, &topaz800, Win0_Gad0, 1, NULL,  (APTR)&IRAPref0GadgetTags[0],
	37, 18, 82, 13, (UBYTE*)Win0_Gad1String, &topaz800, Win0_Gad1, 1, NULL,  (APTR)&IRAPref0GadgetTags[3],
	37, 34, 82, 13, (UBYTE*)Win0_Gad2String, &topaz800, Win0_Gad2, 1, NULL,  (APTR)&IRAPref0GadgetTags[6],
	0, 75, 26, 11, (UBYTE*)IRAPref0_Gad3String, &topaz800, IRAPref0_Gad3, 2, NULL,  (APTR)&IRAPref0GadgetTags[9],
	0, 89, 26, 11, (UBYTE*)IRAPref0_Gad4String, &topaz800, IRAPref0_Gad4, 2, NULL,  (APTR)&IRAPref0GadgetTags[12],
	0, 61, 26, 11, (UBYTE*)IRAPref0_Gad5String, &topaz800, IRAPref0_Gad5, 2, NULL,  (APTR)&IRAPref0GadgetTags[15],
	0, 103, 26, 11, (UBYTE*)IRAPref0_Gad6String, &topaz800, IRAPref0_Gad6, 2, NULL,  (APTR)&IRAPref0GadgetTags[18],
	0, 117, 26, 11, (UBYTE*)IRAPref0_Gad7String, &topaz800, IRAPref0_Gad7, 2, NULL,  NULL,
	0, 131, 26, 11, (UBYTE*)IRAPref0_Gad10String, &topaz800, IRAPref0_Gad10, 2, NULL,  NULL,
	0, 145, 26, 11, (UBYTE*)IRAPref0_Gad11String, &topaz800, IRAPref0_Gad11, 2, NULL,  (APTR)&IRAPref0GadgetTags[21],
	126, 2, 107, 13, (UBYTE*)IRAPref0_Gad13String, &topaz800, IRAPref0_Gad13, 2, NULL,  (APTR)&IRAPref0GadgetTags[24],
	126, 18, 107, 13, (UBYTE*)IRAPref0_Gad14String, &topaz800, IRAPref0_Gad14, 2, NULL,  (APTR)&IRAPref0GadgetTags[31],
	3, 171, 108, 13, (UBYTE*)IRAPref0_Gad15String, &topaz800, IRAPref0_Gad15, 2, NULL,  (APTR)&IRAPref0GadgetTags[38],
	3, 186, 108, 13, (UBYTE*)IRAPref0_Gad16String, &topaz800, IRAPref0_Gad16, 2, NULL,  (APTR)&IRAPref0GadgetTags[43],
	3, 202, 108, 13, (UBYTE*)IRAPref0_Gad17String, &topaz800, IRAPref0_Gad17, 2, NULL,  (APTR)&IRAPref0GadgetTags[52],
	21, 225, 61, 13, (UBYTE*)IRAPref0_Gad18String, &topaz800, IRAPref0_Gad18, 16, NULL,  (APTR)&IRAPref0GadgetTags[61],
	189, 226, 61, 13, (UBYTE*)IRAPref0_Gad19String, &topaz800, IRAPref0_Gad19, 16, NULL,  (APTR)&IRAPref0GadgetTags[64],
	348, 225, 59, 13, (UBYTE*)IRAPref0_Gad20String, &topaz800, IRAPref0_Gad20, 16, NULL,  (APTR)&IRAPref0GadgetTags[67],
	};
STATIC CONST UWORD IRAPref0ZoomInfo[4] = { 200, 0, 200, 25 };

struct Library *DiskfontBase = NULL;
struct Library *GadToolsBase = NULL;
struct GfxBase *GfxBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;
#ifndef __MORPHOS__
struct LocaleBase *LocaleBase = NULL;
#else
struct Library *LocaleBase = NULL;
#endif
struct Catalog *base_Catalog = NULL;
STATIC CONST_STRPTR base_BuiltInLanguage = (CONST_STRPTR)"english";
STATIC LONG base_Version = 0;

STATIC CONST CONST_STRPTR base_Strings[] =
{
  (CONST_STRPTR)"MC68000",
  (CONST_STRPTR)"MC68010",
  (CONST_STRPTR)"MC68020",
  (CONST_STRPTR)"MC68030",
  (CONST_STRPTR)"MC68040",
  (CONST_STRPTR)"MC68060",
  (CONST_STRPTR)"NO FPU",
  (CONST_STRPTR)"MC68882",
  (CONST_STRPTR)"NO MMU",
  (CONST_STRPTR)"MC68851",
  (CONST_STRPTR)"A0",
  (CONST_STRPTR)"A1",
  (CONST_STRPTR)"A2",
  (CONST_STRPTR)"A3",
  (CONST_STRPTR)"A4",
  (CONST_STRPTR)"A5",
  (CONST_STRPTR)"A6",
  (CONST_STRPTR)"No Base",
  (CONST_STRPTR)"CPU",
  (CONST_STRPTR)"FPU",
  (CONST_STRPTR)"MMU",
  (CONST_STRPTR)"Append address and data.",
  (CONST_STRPTR)"Show hunkstructure.",
  (CONST_STRPTR)"Scan for data/text and code.",
  (CONST_STRPTR)"Load configfile.",
  (CONST_STRPTR)"Put each section in its own file.",
  (CONST_STRPTR)"Keep binary data.",
  (CONST_STRPTR)"Leave empty hunks away.",
  (CONST_STRPTR)"Offset to relocate at.",
  (CONST_STRPTR)"Entry of code scanning.",
  (CONST_STRPTR)"Base register",
  (CONST_STRPTR)"Base address.",
  (CONST_STRPTR)"Base section.",
  (CONST_STRPTR)"Save",
  (CONST_STRPTR)"Use",
  (CONST_STRPTR)"Cancel",
  (CONST_STRPTR)"IRA V1.05 Preferences",
};

STATIC struct TextAttr topaz800 = { "topaz.font", 8, 0, 0 };

STATIC void RendWindowIRAPref0( struct Window *Win, void *vi )
{
UWORD offx = Win->BorderLeft;
UWORD offy = Win->BorderTop;
if (Win != NULL) 
	{
	BevelTags[3] = (ULONG)vi;
	DrawBevelBoxA( Win->RPort, 0+offx,0+offy,123,49, (struct TagItem *)(&BevelTags[2]));
	DrawBevelBoxA( Win->RPort, 123+offx,0+offy,304,49, (struct TagItem *)(&BevelTags[2]));
	DrawBevelBoxA( Win->RPort, 0+offx,169+offy,426,48, (struct TagItem *)(&BevelTags[2]));
	}
}

STATIC int OpenWindowIRAPref0( void )
{
struct Screen *Scr;
UWORD offx, offy;
UWORD loop;
struct NewGadget newgad;
struct Gadget *Gad;
struct Gadget *Gad2;
APTR Cla;
if (IRAPref0FirstRun == 0)
	{
	IRAPref0FirstRun = 1;
	for ( loop=0; loop<6; loop++)
		Win0_Gad0Labels[loop] = GetString((LONG)Win0_Gad0Labels[loop]);
	for ( loop=0; loop<2; loop++)
		Win0_Gad1Labels[loop] = GetString((LONG)Win0_Gad1Labels[loop]);
	for ( loop=0; loop<2; loop++)
		Win0_Gad2Labels[loop] = GetString((LONG)Win0_Gad2Labels[loop]);
	for ( loop=0; loop<8; loop++)
		IRAPref0_Gad15Labels[loop] = GetString((LONG)IRAPref0_Gad15Labels[loop]);
	}
if (IRAPref0 == NULL)
	{
	Scr = LockPubScreen(NULL);
	if (NULL != Scr)
		{
		offx = Scr->WBorLeft;
		offy = Scr->WBorTop + Scr->Font->ta_YSize+1;
		if (NULL != ( IRAPref0VisualInfo = GetVisualInfoA( Scr, NULL)))
			{
			if (NULL != ( IRAPref0DrawInfo = GetScreenDrawInfo( Scr)))
				{
				IRAPref0GList = NULL;
				Gad = CreateContext( &IRAPref0GList);
				for ( loop=0 ; loop<18 ; loop++ )
					if (IRAPref0GadgetTypes[loop] != 198)
						{
						CopyMem((char * )&IRAPref0NewGadgets[loop], ( char * )&newgad, (long)sizeof( struct NewGadget ));
						newgad.ng_VisualInfo = IRAPref0VisualInfo;
						newgad.ng_LeftEdge += offx;
						newgad.ng_TopEdge += offy;
						newgad.ng_GadgetText = (STRPTR)GetString((LONG)newgad.ng_GadgetText);
						IRAPref0Gadgets[ loop ] = NULL;
						IRAPref0Gadgets[ newgad.ng_GadgetID - IRAPref0FirstID ] = Gad = CreateGadgetA( IRAPref0GadgetTypes[loop], Gad, &newgad, newgad.ng_UserData );
						}
				for ( loop=0 ; loop<18 ; loop++ )
					if (IRAPref0GadgetTypes[loop] == 198)
						{
						IRAPref0Gadgets[ loop ] = NULL;
						Cla = NULL;
						if (Gad)
							IRAPref0Gadgets[ loop ] = Gad2 = (struct Gadget *) NewObjectA( (struct IClass *)Cla, IRAPref0NewGadgets[ loop ].ng_GadgetText, IRAPref0NewGadgets[ loop ].ng_UserData );
						}
				if (Gad != NULL)
					{
					if (NULL != (IRAPref0 = OpenWindowTags( NULL, (WA_Left), 47,
									(WA_Top), 176,
									(WA_Width), 431+offx,
									(WA_Height), 245+offy,
									(WA_Title), (LONG)GetString(IRAPref0Title),
									(WA_MinWidth), 150,
									(WA_MinHeight), 25,
									(WA_MaxWidth), 1200,
									(WA_MaxHeight), 1200,
									(WA_DragBar), TRUE,
									(WA_DepthGadget), TRUE,
									(WA_CloseGadget), TRUE,
									(WA_Activate), TRUE,
									(WA_Dummy+0x30), TRUE,
									(WA_SmartRefresh), TRUE,
									(WA_AutoAdjust), TRUE,
									(WA_Gadgets), (ULONG)&IRAPref0GList,
									(WA_Zoom), (ULONG)&IRAPref0ZoomInfo,
									(WA_IDCMP),580,
									(TAG_END))))
						{
						RendWindowIRAPref0(IRAPref0, IRAPref0VisualInfo );
						GT_RefreshWindow( IRAPref0, NULL);
						RefreshGList( IRAPref0GList, IRAPref0, NULL, ~0);
						UnlockPubScreen( NULL, Scr);
						return( 0L );
						}
					}
				FreeGadgets( IRAPref0GList);
				FreeScreenDrawInfo( Scr, IRAPref0DrawInfo );
				}
			FreeVisualInfo( IRAPref0VisualInfo );
			}
		UnlockPubScreen( NULL, Scr);
		}
	}
else
	{
	WindowToFront(IRAPref0);
	ActivateWindow(IRAPref0);
	return( 0L );
	}
return( 1L );
}

STATIC void CloseWindowIRAPref0( void )
{
if (IRAPref0 != NULL)
	{
	FreeScreenDrawInfo( IRAPref0->WScreen, IRAPref0DrawInfo );
	IRAPref0DrawInfo = NULL;
	CloseWindow( IRAPref0);
	IRAPref0 = NULL;
	FreeVisualInfo( IRAPref0VisualInfo);
	FreeGadgets( IRAPref0GList);
	}
}

STATIC int OpenLibs( void )
{
LocaleBase = OpenLibrary((UBYTE *)"locale.library", 38);
if ( NULL != (DiskfontBase = OpenLibrary((UBYTE *)"diskfont.library" , 36)))
	if ( NULL != (GadToolsBase = OpenLibrary((UBYTE *)"gadtools.library" , 37)))
		if ( NULL != (GfxBase = (struct GfxBase * )OpenLibrary((UBYTE *)"graphics.library" , 37)))
			if ( NULL != (IntuitionBase = (struct IntuitionBase * )OpenLibrary((UBYTE *)"intuition.library" , 37)))
				return( 0L );
CloseLibs();
return( 1L );
}

STATIC void CloseLibs( void )
{
	CloseLibrary( DiskfontBase );
	CloseLibrary( GadToolsBase );
	CloseLibrary( ( struct Library * )GfxBase );
	CloseLibrary( ( struct Library * )IntuitionBase );
	CloseLibrary( ( struct Library * )LocaleBase );
}

STATIC int OpenDiskFonts( void )
{
	int OKSoFar = 0;
if (NULL == OpenDiskFont( &topaz800 ) )
	OKSoFar = 1;
return ( OKSoFar );
}

STATIC CONST_STRPTR GetString(LONG strnum)
{
	if (base_Catalog == NULL)
		return(base_Strings[strnum]);
	return(GetCatalogStr(base_Catalog, strnum, (STRPTR)base_Strings[strnum]));
}

STATIC void ClosebaseCatalog(void)
{
	if (LocaleBase != NULL)
		CloseCatalog(base_Catalog);
	base_Catalog = NULL;
}

STATIC void OpenbaseCatalog(struct Locale *loc, CONST_STRPTR language)
{
	LONG tag, tagarg = tagarg;
	if (language == NULL)
		tag=TAG_IGNORE;
	else
		{
		tag = OC_Language;
		tagarg = (LONG)language;
		}
	if (LocaleBase != NULL  &&  base_Catalog == NULL)
		base_Catalog = OpenCatalog(loc, "base.catalog",
											OC_BuiltInLanguage, (ULONG)base_BuiltInLanguage,
											tag, tagarg,
											OC_Version, base_Version,
											TAG_DONE);
}

