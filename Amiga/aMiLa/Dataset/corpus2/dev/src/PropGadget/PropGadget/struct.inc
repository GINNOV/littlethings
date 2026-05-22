/*           Jerry J. Trantow
             1560 A. East Irving Place
             Milwaukee, Wi 53202-1460
*/ 
/*  5 May 88 Started this file to support requester input for HomeWork4  */
/*  8 May 88 Fixed some offset problems	                                 */
/*  9 May 88 Added Window to Requester                                   */
/* 10 May 88 Changed filename, Now returns LONGINT, used with CBT        */
/* 23 May 88 Linked to CUSTOMSCREEN for CBT                              */
/* 23 May 88 Changed Window IDCMP Flags	to eliminate extra messages      */
/*  1 May 88 Changed to LONG RequestHandler() to ULONG RequestHandler    */

/*  4 Dec 88 Modified this file for use in PropGadgetCalculate example   */
/* 17 Dec 88 Added a bunch of IntuiText for the prop gadget example      */
/* 28 Dec 88 Added more StringGadgets for input                          */
/* 30 Dec 88 Connected all IntuiText to proper Gadgetry                  */
/*  2 Jan 89 Deleted the Vertical Scroll Gadget                          */
/* 29 Jan 89 Deleted Dynamic Allocation of Scroll and Arrow Gadgets      */
/* 29 Jan 89 Explicitly declared Gadget TextAttribute others use default */
/*  1 Feb 89 Changed over to Harriet Tolly's names for some variables    */

struct TextAttr taPlain =
{ (STRPTR)"topaz.font",(UWORD)8, (UBYTE)FS_NORMAL,(UBYTE)FPF_ROMFONT};

SHORT ValueList[]= { 0,0,  87,0,  87,12, 0,12, 0,0 };
SHORT ChoiceList[]={ 0,0,  60,0,  60,10, 0,10, 0,0 };
struct Border ChoiceBorder=
{ (SHORT)0,			/* LeftEdge	*/
  (SHORT)0,			/* TopEdge	*/
  (SHORT)2,			/* FrontPen	*/
  (SHORT)1,			/* BackPen	*/
  (SHORT)JAM1,                  /* DrawMode	*/
  (SHORT)5,			/* Visible	*/
  (SHORT *)ChoiceList,		/* XY           */
  (struct Border *)NULL		/* NextBorder	*/
};
struct Border ValueBorder=
{ (SHORT)-3,			/* LeftEdge	*/
  (SHORT)-3,			/* TopEdge	*/
  (SHORT)2,			/* FrontPen	*/
  (SHORT)1,			/* BackPen      */
  (SHORT)JAM1,                  /* DrawMode     */
  (SHORT)5,			/* Visible	*/
  (SHORT *)ValueList,		/* XY		*/
  (struct Border *)NULL		/* NextBorder	*/
};
struct Border ValueBorder2=
{ (SHORT)-3,			/* LeftEdge	*/
  (SHORT)-3,			/* TopEdge	*/
  (SHORT)2,			/* FrontPen	*/
  (SHORT)1,                     /* BackPen	*/
  (SHORT)JAM1,                  /* DrawMode	*/
  (SHORT)5,			/* Visible	*/
  (SHORT *)ValueList,		/* XY		*/
  (struct Border *)NULL		/* NextBorder	*/
};
UBYTE HBufferPot[20];		/* These will hold the ascii values */
UBYTE HBufferBody[20];
struct IntuiText OKText=
{ (UBYTE)3,			/* FrontPen	*/
  (UBYTE)2,			/* BackPen	*/
  (UBYTE)JAM1,                  /* DrawMode	*/
  (SHORT)20,			/* LeftEdge	*/
  (SHORT)2,			/* TopEdge	*/
  (struct TextAttr *)NULL,      /* ITextFont	*/
  (UBYTE *)"OK",		/* IText	*/
  (struct IntuiText *)NULL	/* NextText	*/
};
struct IntuiText HorizTextPot=
{ (UBYTE)1,			/* FrontPen	*/
  (UBYTE)0,			/* BackPen	*/
  (UBYTE)JAM2,                  /* DrawMode	*/
  (SHORT)2,			/* LeftEdge	*/
  (SHORT)22,			/* TopEdge	*/
  (struct TextAttr *)&taPlain,	/* ITextFont	*/
  (UBYTE *)HBufferPot,		/* IText	*/
  (struct IntuiText *)NULL	/* NextText	*/
};
struct IntuiText HorizTextBody=
{ (UBYTE)1,				/* FrontPen	*/
  (UBYTE)0,				/* BackPen	*/
  (UBYTE)JAM2,                          /* DrawMode	*/
  (SHORT)2,				/* LeftEdge	*/
  (SHORT)11,				/* TopEdge	*/
  (struct TextAttr *)&taPlain,		/* ITextFont	*/
  (UBYTE *)HBufferBody,			/* IText	*/
  (struct IntuiText *)&HorizTextPot	/* NextText	*/
};
struct IntuiText HorizText=
{ (UBYTE)2,				/* FrontPen	*/
  (UBYTE)3,				/* BackPen	*/
  (UBYTE)JAM2,				/* DrawMode	*/
  (SHORT)2,				/* LeftEdge	*/
  (SHORT)1,				/* TopEdge	*/
  (struct TextAttr *)NULL,		/* ITextFont	*/
  (UBYTE *)"Horizontal Gadget",		/* IText	*/
  (struct IntuiText *)&HorizTextBody	/* NextText	*/
};

struct IntuiText TotalText=
{ (UBYTE)2,			/* FrontPen	*/
  (UBYTE)3,			/* BackPen	*/
  (UBYTE)JAM2,			/* DrawMode	*/
  (SHORT)90,			/* LeftEdge	*/
  (SHORT)0,			/* TopEdge	*/
  (struct TextAttr *)NULL,	/* ITextFont	*/
  (UBYTE *)"Total",		/* IText	*/
  (struct IntuiText *)NULL	/* NextText	*/
};
struct IntuiText VisibleText=
{ (UBYTE)2,			/* FrontPen	*/
  (UBYTE)3,			/* BackPen	*/
  (UBYTE)JAM2,			/* DrawMode	*/
  (SHORT)90,			/* LeftEdge	*/
  (SHORT)0,			/* TopEdge	*/
  (struct TextAttr *)NULL,	/* ITextFont	*/
  (UBYTE *)"Visible",		/* IText	*/
  (struct IntuiText *)NULL	/* NextText	*/
};
struct IntuiText FirstText=
{ (UBYTE)2,			/* FrontPen	*/
  (UBYTE)3,			/* BackPen	*/
  (UBYTE)JAM2,			/* DrawMode	*/
  (SHORT)90,			/* LeftEdge	*/
  (SHORT)0,			/* TopEdge	*/
  (struct TextAttr *)NULL,	/* ITextFont	*/
  (UBYTE *)"First",		/* IText	*/
  (struct IntuiText *)NULL	/* NextText	*/
};
UBYTE TotalGadBuffer[MAXBUF];	/* Don't forget to initialize these */
UBYTE VisibleGadBuffer[MAXBUF];	/* Don't forget to initialize these */
UBYTE FirstGadBuffer[MAXBUF];	/* Don't forget to initialize these */
UBYTE GadUndoBuffer[MAXBUF];

struct StringInfo TotalString =
{ (UBYTE *)TotalGadBuffer,	/* Buffer	*/
  (UBYTE *)GadUndoBuffer,	/* UndoBuffer	*/
  (SHORT)1,			/* BufferPos	*/
  (SHORT)MAXBUF-1,		/* MaxChars	*/
  (SHORT)0,			/* DispPos	*/
  (SHORT)0,			/* UndoPos	*/
  (SHORT)0,			/* NumChars	*/
  (SHORT)0,			/* DispVisible	*/
  (SHORT)0,			/* CLeft	*/
  (SHORT)0,			/* CTop		*/
  (struct Layer *)NULL,		/* LayerPtr	*/
  (LONG)1024L,			/* LongInt	*/
  (struct KeyMap *)NULL		/* AltKeyMap	*/
};
struct StringInfo VisibleString =
{ (UBYTE *)VisibleGadBuffer,	/* Buffer	*/
  (UBYTE *)GadUndoBuffer,	/* UndoBuffer	*/
  (SHORT)1,			/* BufferPos	*/
  (SHORT)MAXBUF-1,		/* MaxChars	*/
  (SHORT)0,			/* DispPos	*/
  (SHORT)0,			/* UndoPos	*/
  (SHORT)0,			/* NumChars	*/
  (SHORT)0,			/* DispVisible	*/
  (SHORT)0,			/* CLeft	*/
  (SHORT)0,			/* CTop		*/
  (struct Layer *)NULL,		/* LayerPtr	*/
  (LONG)256L,			/* LongInt	*/
  (struct KeyMap *)NULL		/* AltKeyMap	*/
};
struct StringInfo FirstString =
{ (UBYTE *)FirstGadBuffer,	/* Buffer	*/
  (UBYTE *)GadUndoBuffer,	/* UndoBuffer	*/
  (SHORT)1,			/* BufferPos	*/
  (SHORT)MAXBUF-1,		/* MaxChars	*/
  (SHORT)0,			/* DispPos	*/
  (SHORT)0,			/* UndoPos	*/
  (SHORT)0,			/* NumChars	*/
  (SHORT)0,			/* DispVisible	*/
  (SHORT)0,			/* CLeft	*/
  (SHORT)0,			/* CTop		*/
  (struct Layer *)NULL,		/* LayerPtr	*/
  (LONG)128L,			/* LongInt	*/
  (struct KeyMap *)NULL		/* AltKeyMap	*/
};
extern struct Gadget ScrollGadget;
struct Gadget OKGadget =
{ (struct Gadget *)NULL,		/* NextGadget	*/
  40,65,60,10,				/* dimensions	*/
  (USHORT)GADGHCOMP,			/* Flags	*/
  (USHORT)GADGIMMEDIATE|RELVERIFY,	/* Activation	*/
  (USHORT)BOOLGADGET,			/* GadgetType	*/
  (APTR)&ChoiceBorder,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)&OKText,		/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)NULL,				/* SpecialInfo	*/
  (USHORT)GAD_OK,			/* GadgetID	*/
  (APTR)&ScrollGadget			/* UserData	*/
};
struct Gadget TotalGadget =
{ (struct Gadget *)&OKGadget,		/* NextGadget	*/
  20,20,85,10,				/* dimensions	*/
  (USHORT)GADGHCOMP,			/* Flags	*/
  (USHORT)GADGIMMEDIATE|LONGINT,	/* Activation	*/
  (USHORT)STRGADGET,			/* GadgetType	*/
  (APTR)&ValueBorder,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)&TotalText,	/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)&TotalString,			/* SpecialInfo	*/
  (USHORT)GAD_Total,			/* GadgetID	*/
  (APTR)NULL				/* UserData	*/
};
struct Gadget VisibleGadget =
{ (struct Gadget *)&TotalGadget,	/* NextGadget	*/
  20,35,85,10,				/* dimensions	*/
  (USHORT)GADGHCOMP,			/* Flags	*/
  (USHORT)GADGIMMEDIATE|LONGINT,	/* Activation	*/
  (USHORT)STRGADGET,			/* GadgetType	*/
  (APTR)&ValueBorder2,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)&VisibleText,	/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)&VisibleString,			/* SpecialInfo	*/
  (USHORT)GAD_Visible,			/* GadgetID	*/
  (APTR)NULL				/* UserData	*/
};
struct Gadget FirstGadget =
{ (struct Gadget *)&VisibleGadget,	/* NextGadget	*/
  20,50,85,10,				/* dimensions	*/
  (USHORT)GADGHCOMP,			/* Flags	*/
  (USHORT)GADGIMMEDIATE|LONGINT,	/* Activation	*/
  (USHORT)STRGADGET,			/* GadgetType	*/
  (APTR)&ValueBorder,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)&FirstText,	/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)&FirstString,			/* SpecialInfo	*/
  (USHORT)GAD_First,			/* GadgetID	*/
  (APTR)NULL				/* UserData	*/
};

/* -------------------- Arrow and Scroll Bar Gadgets -------------------- */

/**************************************************************************/
/*  The following data structures contains the image data for the arrows  */
/**************************************************************************/
USHORT g_image_left_dat[]=
{
  0xFFFF,0x80F1,0x83F1,0x8FFD,0x8FFD,0x83F1,0x80F1,0xFFFF
};
USHORT g_image_right_dat[]=
{
  0xFFFF,0x8F01,0x8FC1,0xDFF1,0xDFF1,0x8FC1,0x8F01,0xFFFF
};
/***************************************************************/
/*  The following data structures define the Arrow images      */
/***************************************************************/

struct Image g_image_left =
{
  0, 0,  			/* Left, Top	*/
  16, 8,	 		/* Width, Height*/
  1,     			/* Depth 	*/ 
  (USHORT *)&g_image_left_dat, 	/* ImageData 	*/
  0x01,  			/* PlanePick 	*/
  0x00,  			/* PlaneOnOff 	*/
  NULL   			/* Next Image 	*/
}; 
struct Image g_image_right =
{
  0, 0, 			/* Left, Top	*/
  16, 8, 			/* Width, Height*/
  1,     			/* Depth 	*/ 
  (USHORT *)&g_image_right_dat, /* ImageData	*/
  0x01,  			/* PlanePick	*/
  0x00,  			/* PlaneOnOff	*/
  NULL     			/* Next Image	*/
};
struct Image scroll_image =
{
  0, 0, 		/* Left, Top	*/
  0, 0,			/* Width, Height*/
  0,    		/* Depth	*/ 
  0, 			/* ImageData	*/
  0,  			/* PlanePick	*/
  0,  			/* PlaneOnOff 	*/
  NULL     		/* Next Image 	*/
}; 
struct PropInfo ScrollPropInfo =
{
  (USHORT)AUTOKNOB|FREEHORIZ,		/* Flags	*/
  (USHORT)0x0000,			/* HorizPot	*/
  (USHORT)0x0000,			/* VertPot	*/
  (USHORT)0x0000,			/* HorizBody	*/
  (USHORT)0x0000,			/* VertBody	*/
  (USHORT)0,				/* CWidth	*/
  (USHORT)0,				/* CHeight	*/
  (USHORT)0,				/* HPotRes	*/
  (USHORT)0,				/* VPotRes	*/
  (USHORT)0,				/* LeftBorder	*/
  (USHORT)0,				/* TopBorder	*/
};
struct Gadget ScrollGadget =
{ (struct Gadget *)&FirstGadget,	/* NextGadget	*/
  16,-8,-32,9,				/* dimensions	*/
  (USHORT)GADGHCOMP|GRELBOTTOM|GRELWIDTH, /* Flags	*/
  (USHORT)GADGIMMEDIATE|FOLLOWMOUSE|RELVERIFY|BOTTOMBORDER, /* Activation */
  (USHORT)PROPGADGET,			/* GadgetType	*/
  (APTR)&scroll_image,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)NULL,		/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)&ScrollPropInfo,		/* SpecialInfo	*/
  (USHORT)HORIZSCROLLGAD,		/* GadgetID	*/
  (APTR)&ScrollGadget			/* UserData	*/
};
struct Gadget LeftArrowGadget =
{ (struct Gadget *)&ScrollGadget,	/* NextGadget	*/
  0,-8,16,8,				/* dimensions	*/
  (USHORT)GADGIMAGE|GADGHCOMP|GRELBOTTOM, /* Flags	*/
  (USHORT)GADGIMMEDIATE|RELVERIFY|BOTTOMBORDER,	/* Activation	*/
  (USHORT)BOOLGADGET,			/* GadgetType	*/
  (APTR)&g_image_left,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)NULL,		/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)NULL,				/* SpecialInfo	*/
  (USHORT)LEFTARROWGAD,			/* GadgetID	*/
  (APTR)&ScrollGadget			/* UserData	*/
};
struct Gadget RightArrowGadget =
{ (struct Gadget *)&LeftArrowGadget,	/* NextGadget	*/
  -16,-8,16,8,				/* dimensions	*/
  (USHORT)GADGIMAGE|GADGHCOMP|GRELBOTTOM|GRELRIGHT,	/* Flags	*/
  (USHORT)GADGIMMEDIATE|RELVERIFY|BOTTOMBORDER,	/* Activation	*/
  (USHORT)BOOLGADGET,			/* GadgetType	*/
  (APTR)&g_image_right,			/* GadgetRender */
  (APTR)NULL,				/* SelectRender */
  (struct IntuiText *)NULL,		/* GadgetText	*/
  0L,					/* MutualExclude*/
  (APTR)NULL,				/* SpecialInfo	*/
  (USHORT)RIGHTARROWGAD,		/* GadgetID	*/
  (APTR)&ScrollGadget			/* UserData	*/
};
struct NewWindow NewWindow=
{ (SHORT)10,				/* Left 	*/
  (SHORT)10,				/* Top 		*/
  (SHORT)350,				/* Width	*/
  (SHORT)120,				/* Height	*/
  (UBYTE)-1,				/* DetailPen	*/
  (UBYTE)-1,				/* BlockPen	*/
  (ULONG)GADGETUP|CLOSEWINDOW|MOUSEMOVE,/* IDCMPFlags	*/
  (ULONG)WINDOWDRAG|WINDOWDEPTH|WINDOWCLOSE|ACTIVATE,	/* Flags	*/
  (struct Gadget *)&RightArrowGadget,	/* Gadgets	*/
  (struct Image *)NULL,			/* CheckMark	*/
  (UBYTE *)"JJT's Proportional Gadget Example", /* Title	*/
  (struct Screen *)NULL,		/* Screen	*/			
  (struct BitMap *)NULL,		/* BitMap	*/
  (SHORT)0,				/* MinWidth	*/
  (SHORT)0,				/* MinHeight	*/
  (SHORT)0,				/* MaxWidth	*/
  (SHORT)0,				/* MaxHeight	*/
  (USHORT)WBENCHSCREEN			/* Type		*/
};
