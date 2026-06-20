/* Graphics */
#include <intuition/intuition.h>

struct IntuitionBase *IntuitionBase;
struct Window *my_window;

struct NewWindow my_new_window=
{
  50,            /* LeftEdge    pencerenin X pozisyonu */
  30,            /* TopEdge     pencerenin Y pozisyonu */
  300,           /* Width       pencerenin genisligi */
  120,            /* Height      pencerenin yuksekligi */
  0,             /* DetailPen   colour reg. 0 ile text cizilir */
  1,             /* BlockPen    colour reg. 1 ile block cizilir */
  NULL,          /* IDCMPFlags  */
  SMART_REFRESH| /* Flags       */
  WINDOWDRAG|    /*             */
  WINDOWDEPTH|   /*             */
  ACTIVATE,      /*             acildiginda pencereyi aktif hale getir*/
  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  "Graphics",	 /* Title       pencere basligi */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  0,             /* MinWidth    */
  0,             /* MinHeight   */
  0,             /* MaxWidth    */
  0,             /* MaxHeight   */
  WBENCHSCREEN   /* Type        Workbench Screen. */
};

/* Line */

SHORT my_points[]=
{
  10,30, 
  45,30,
  85,10,
  125,50,
  165,30,
  200,30
};

struct Border my_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  3,           /* FrontPen, colour register 3. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 3. */
  6,           /* mypoint 6 noktanın koordinatlari cizilecek */
  my_points,   /* koordinatlara ait dizinin pointer'i */
  NULL,        /* NextBorder */
};

/* Rectangle */

SHORT innerbox_points[]=
{
	0,0,
	60,0,
	60,30,
	0,30,
	0,0
};

SHORT outerbox_points[]=
{
	0,0,
	80,0,
	80,50,
	0,50,
	0,0
};

struct Border innerbox=
{
	8,8,
	3,
	0,
	JAM1,
	5,
	innerbox_points,
	NULL
};

struct Border outerbox=
{
	0,0,
	1,
	0,
	JAM1,
	5,
	outerbox_points,
	&innerbox
};

/* Text */

UBYTE my_text[]="Hi Amiga!";

struct TextAttr my_font=
{
  "topaz.font",                 /* Topaz font. */
  TOPAZ_EIGHTY,                 /* Size */
  FSF_BOLD | FSF_UNDERLINED,    /* Underlined bold */ 
  FPF_ROMFONT                   /* */
};

struct IntuiText my_intui_text=
{
  1,         /* FrontPen, colour register 1. */
  2,         /* BackPen, colour register 2. */
  JAM2,      /* DrawMode, colour 2'li zemin üzerine colour 1 olarak yazdir */ 
  10, 10,    /* LeftEdge, TopEdge. */
  &my_font,  /* ITextFont, my_font */
  my_text,   /* IText, text */
  NULL,      /* NextText */
};

/* Image */

USHORT my_image_data[]=
{
  0x0FF0, /* BitPlane ZERO */
  0x300C,
  0xC243,
  0xC813,
  0xC423,
  0xC3C3,
  0x300C,
  0x0FF0
};

struct Image my_image3=
{
	105, 5,
	16,
	8,
	1,
	my_image_data,
	0x0001,
	0x0002,
	NULL /* başka image yok */
};

struct Image my_image2=
{
	85, 5,
	16,
	8,
	1,
	my_image_data,
	0x0002,
	0x0001,
	&my_image3
};

struct Image my_image1=
{
	65, 5,
	16,
	8,
	1,
	my_image_data,
	0x0002,
	0x0000,
	&my_image2
};

struct Image my_image=
{
  45, 5,         /* LeftEdge, TopEdge. */
  16,             /* Width, 16 pixels/bitts wide. */
  8,              /* Height, 8 lines high. */
  1,              /* Depth, only one Bitplane. */
  my_image_data,  /* ImageData, pointer to my_image_data. */
  0x0001,         /* PickPlane, bitplane Zero affects. */
  0x0000,         /* PlaneOnOff, 0's on all other Bitplanes. */
                  /* [The pixels' colour will be either 0000 (blue) or */
                  /* 0001 (white).] */
  &my_image1       /* NextImage */
};

/* 16 renk image */
USHORT ImageData[128] = {
	0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,
	0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,
	0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,
	0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,0x0fcc,0xfc03,
	0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,
	0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,
	0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,
	0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,0xf3c3,0xccc0,
	0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,
	0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,
	0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,
	0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,0xf0c0,0x3c3f,
	0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,
	0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,
	0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,
	0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf,0xc03c,0xcccf
};

struct Image Image16 = {
	0,0,		/* relative coordinates */
	32,16,		/* width and height */
	4,		/* bitplanes */
	ImageData,		/* data pointer */
	0x00f,0x000,		/* PlanePick & PlaneOnOff */
	NULL		/* next image */
};


main()
{
	IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
	if( IntuitionBase == NULL ) exit();
	
	my_window = (struct Window *) OpenWindow( &my_new_window );
	if(my_window == NULL)
	{
		CloseLibrary( IntuitionBase );
		exit();  
	}

	/* Lines */
	DrawBorder(my_window->RPort, &my_border, 10, 12);
	
	/* Rectangle */
	DrawBorder(my_window->RPort, &outerbox, 10, 50);
	
	/* Text */
	PrintIText(my_window->RPort, &my_intui_text, 5, 5);
	
	/* Image */
	DrawImage(my_window->RPort, &my_image, 60, 10);
	
	/* Image 16 renkli */
	DrawImage(my_window->RPort, &Image16, 190, 50);

	Delay(50 * 10); // 10 saniye bekler

	CloseWindow(my_window );
	CloseLibrary(IntuitionBase );
}