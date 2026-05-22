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
#include <clib/locale_protos.h>
#include <clib/exec_protos.h>
#include <clib/wb_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <string.h>
#include <clib/diskfont_protos.h>

#include "togbutsample.h"


UWORD aboutnColours[] =  /* Use LoadRGB4 to use this. */
	{
	1911,0,4095,1402,0,0,0,0,0,0,0,0,0,0,0,0
	};

UWORD aboutnData[256] =
	{
	0,0,0,0,0,0,0,32,16383,65535,65535,65504,16383,65535,65535,65504,16383,59263,
	65535,65504,16383,58175,65407,65504,16383,54044,27967,65504,16383,51466,9247,
	65504,16383,49441,33855,65504,16383,41249,33855,65504,16383,39956,20671,65504,
	16383,56974,14559,65504,16383,65535,65535,65504,16383,65535,65535,65504,32767,
	65535,65535,65504,0,0,0,0,0,0,0,0,32767,65535,65535,65472,32767,65535,65535,
	65472,32767,65535,65535,65472,32767,65535,65535,65472,32767,64447,65535,65472,
	32767,63487,65535,65472,32767,60830,30367,65472,32767,64949,54975,65472,32767,
	58293,54975,65472,32767,57079,57087,65472,32767,56974,14559,65472,32767,65535,
	65535,65472,32767,65535,65535,65472,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	};

UWORD aboutpColours[] =  /* Use LoadRGB4 to use this. */
	{
	1911,0,4095,1402,0,0,0,0,0,0,0,0,0,0,0,0
	};

UWORD aboutpData[256] =
	{
	0,0,0,0,32767,65535,65535,65504,32767,65535,65535,65504,32767,65535,65535,
	65504,32767,65535,65535,65504,32767,62399,65535,65504,32767,61855,65471,65504,
	32767,59790,13983,65504,32767,58501,4623,65504,32767,57488,49695,65504,32767,
	53392,49695,65504,32767,52746,10335,65504,32767,61255,7279,65504,32767,65535,
	65535,65504,32767,65535,65535,65504,0,0,0,0,0,0,0,0,0,0,0,0,16383,65535,65535,
	65472,16383,65535,65535,65472,16383,65535,65535,65472,16383,65535,65535,65472,
	16383,64991,65535,65472,16383,64511,65535,65472,16383,63183,15183,65472,16383,
	65242,60255,65472,16383,61914,60255,65472,16383,61307,61311,65472,16383,61255,
	7279,65472,16383,65535,65535,65472,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	};

struct Window *Win0 = NULL;
APTR Win0VisualInfo;
APTR Win0DrawInfo;
struct Gadget *Win0GList;
struct Gadget *Win0Gadgets[2];
UBYTE Win0FirstRun = 0;

UWORD Win0GadgetTypes[] =
	{
	GENERIC_KIND,
	BUTTON_KIND,
	};

struct NewGadget Win0NewGadgets[] =
	{
	12, 11, 68, 17, (UBYTE *)~0,NULL, tAbout, 2, NULL,  NULL,
	12, 58, 75, 22, (UBYTE*)bDegistirString, &topaz800, bDegistir, 16, NULL,  NULL,
	};
UWORD Win0ZoomInfo[4] = { 200, 0, 200, 25 };

struct Library *DiskfontBase = NULL;
struct Library *GadToolsBase = NULL;
struct GfxBase *GfxBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct LocaleBase *LocaleBase = NULL;

struct Image aboutn = { 0, 0, 60, 16, 4, NULL, 15, 0, NULL};
struct Image aboutp = { 0, 0, 60, 16, 4, NULL, 15, 0, NULL};
struct Catalog *base_Catalog = NULL;
STRPTR base_BuiltInLanguage = (STRPTR)"english";
LONG base_Version = 0;

STRPTR base_Strings[] =
{
  (STRPTR)"Degistir",
  (STRPTR)"New Window 0",
};

struct TextAttr topaz800 = { (STRPTR)"topaz.font", 8, 0, 0 };

void RendWindowWin0( struct Window *Win, void *vi )
{
UWORD offx,offy;
offx = Win->BorderLeft;
offy = Win->BorderTop;
if (Win != NULL)
	{
	}
}

int OpenWindowWin0( void )
{
struct Screen *Scr;
UWORD offx, offy;
UWORD loop;
struct NewGadget newgad;
struct Gadget *Gad;
struct Gadget *Gad2;
APTR Cla;
if (Win0FirstRun == 0)
	{
	Win0FirstRun = 1;
	}
if (Win0 == NULL)
	{
	Scr = LockPubScreen(NULL);
	if (NULL != Scr)
		{
		offx = Scr->WBorLeft;
		offy = Scr->WBorTop + Scr->Font->ta_YSize+1;
		if (NULL != ( Win0VisualInfo = GetVisualInfoA( Scr, NULL)))
			{
			if (NULL != ( Win0DrawInfo = GetScreenDrawInfo( Scr)))
				{
				Win0GList = NULL;
				Gad = CreateContext( &Win0GList);
				for ( loop=0 ; loop<2 ; loop++ )
					if (Win0GadgetTypes[loop] != 198)
						{
						CopyMem((char * )&Win0NewGadgets[loop], ( char * )&newgad, (long)sizeof( struct NewGadget ));
						newgad.ng_VisualInfo = Win0VisualInfo;
						newgad.ng_LeftEdge += offx;
						newgad.ng_TopEdge += offy;
						if ( newgad.ng_GadgetText != (UBYTE *)~0)
							newgad.ng_GadgetText = GetString((LONG)newgad.ng_GadgetText);
						else
							newgad.ng_GadgetText = (UBYTE *)0;
						Win0Gadgets[ loop ] = NULL;
						Win0Gadgets[ newgad.ng_GadgetID - Win0FirstID ] = Gad = CreateGadgetA( Win0GadgetTypes[loop], Gad, &newgad, (struct TagItem *) newgad.ng_UserData );
						if ( Gad != NULL )
							switch (loop+Win0FirstID)
								{
								case tAbout :
									Gad->GadgetType |= GTYP_BOOLGADGET;
									Gad->GadgetRender = &aboutn;
									Gad->SelectRender = &aboutp;
									Gad->Activation = GACT_TOGGLESELECT|GACT_IMMEDIATE|GACT_RELVERIFY|GACT_FOLLOWMOUSE;
									Gad->Flags = 6;
									break;
								}
						}
				for ( loop=0 ; loop<2 ; loop++ )
					if (Win0GadgetTypes[loop] == 198)
						{
						Win0Gadgets[ loop ] = NULL;
						Cla = NULL;
						if (Gad)
							Win0Gadgets[ loop ] = Gad2 = (struct Gadget *) NewObjectA( (struct IClass *)Cla, Win0NewGadgets[ loop ].ng_GadgetText, (struct TagItem *)Win0NewGadgets[ loop ].ng_UserData );
						}
				if (Gad != NULL)
					{
					if (NULL != (Win0 = OpenWindowTags( NULL, (WA_Left), 300,
									(WA_Top), 20,
									(WA_Width), 300+offx,
									(WA_Height), 150+offy,
									(WA_Title), (LONG)GetString(Win0Title),
									(WA_MinWidth), 150,
									(WA_MinHeight), 25,
									(WA_MaxWidth), 1200,
									(WA_MaxHeight), 1200,
									(WA_SizeGadget), TRUE,
									(WA_DragBar), TRUE,
									(WA_DepthGadget), TRUE,
									(WA_CloseGadget), TRUE,
									(WA_Activate), TRUE,
									(WA_Dummy+0x30), TRUE,
									(WA_SmartRefresh), TRUE,
									(WA_AutoAdjust), TRUE,
									(WA_Gadgets), Win0GList,
									(WA_Zoom), Win0ZoomInfo,
									(WA_IDCMP),580,
									(TAG_END))))
						{
						RendWindowWin0(Win0, Win0VisualInfo );
						GT_RefreshWindow( Win0, NULL);
						RefreshGList( Win0GList, Win0, NULL, ~0);
						UnlockPubScreen( NULL, Scr);
						return( 0L );
						}
					}
				FreeGadgets( Win0GList);
				FreeScreenDrawInfo( Scr, (struct DrawInfo *) Win0DrawInfo );
				}
			FreeVisualInfo( Win0VisualInfo );
			}
		UnlockPubScreen( NULL, Scr);
		}
	}
else
	{
	WindowToFront(Win0);
	ActivateWindow(Win0);
	return( 0L );
	}
return( 1L );
}

void CloseWindowWin0( void )
{
if (Win0 != NULL)
	{
	FreeScreenDrawInfo( Win0->WScreen, (struct DrawInfo *) Win0DrawInfo );
	Win0DrawInfo = NULL;
	CloseWindow( Win0);
	Win0 = NULL;
	FreeVisualInfo( Win0VisualInfo);
	FreeGadgets( Win0GList);
	}
}

int OpenLibs( void )
{
LocaleBase = (struct LocaleBase * )OpenLibrary((UBYTE *)"locale.library", 0);
if ( NULL != (DiskfontBase = OpenLibrary((UBYTE *)"diskfont.library" , 0)))
	if ( NULL != (GadToolsBase = OpenLibrary((UBYTE *)"gadtools.library" , 0)))
		if ( NULL != (GfxBase = (struct GfxBase * )OpenLibrary((UBYTE *)"graphics.library" , 0)))
			if ( NULL != (IntuitionBase = (struct IntuitionBase * )OpenLibrary((UBYTE *)"intuition.library" , 0)))
				return( 0L );
CloseLibs();
return( 1L );
}

void CloseLibs( void )
{
if (NULL != DiskfontBase )
	CloseLibrary( DiskfontBase );
if (NULL != GadToolsBase )
	CloseLibrary( GadToolsBase );
if (NULL != GfxBase )
	CloseLibrary( ( struct Library * )GfxBase );
if (NULL != IntuitionBase )
	CloseLibrary( ( struct Library * )IntuitionBase );
if (NULL != LocaleBase )
	CloseLibrary( ( struct Library * )LocaleBase );
}

int MakeImages( void )
{
UWORD failed = 0;
if (NULL != (aboutn.ImageData=(UWORD *)AllocMem( 512, MEMF_CHIP)))
	CopyMem( aboutnData, aboutn.ImageData, 512);
else
	failed = 1;
if (NULL != (aboutp.ImageData=(UWORD *)AllocMem( 512, MEMF_CHIP)))
	CopyMem( aboutpData, aboutp.ImageData, 512);
else
	failed = 1;
if (failed==0)
	return( 0L );
else
	{
	FreeImages();
	return( 1L );
	}
}

void FreeImages( void )
{
if (aboutn.ImageData != NULL)
	FreeMem(aboutn.ImageData, 512);
aboutn.ImageData = NULL;
if (aboutp.ImageData != NULL)
	FreeMem(aboutp.ImageData, 512);
aboutp.ImageData = NULL;
}

STRPTR GetString(LONG strnum)
{
	if (base_Catalog == NULL)
		return(base_Strings[strnum]);
	return(GetCatalogStr(base_Catalog, strnum, base_Strings[strnum]));
}

void ClosebaseCatalog(void)
{
	if (LocaleBase != NULL)
		CloseCatalog(base_Catalog);
	base_Catalog = NULL;
}

void OpenbaseCatalog(struct Locale *loc, STRPTR language)
{
	LONG tag, tagarg;
	if (language == NULL)
		tag=TAG_IGNORE;
	else
		{
		tag = OC_Language;
		tagarg = (LONG)language;
		}
	if (LocaleBase != NULL  &&  base_Catalog == NULL)
		base_Catalog = OpenCatalog(loc, (STRPTR) "base.catalog",
											OC_BuiltInLanguage, base_BuiltInLanguage,
											tag, tagarg,
											OC_Version, base_Version,
											TAG_DONE);
}
