
#define TOPSLIDER  93
#define LEFT	   160
UBYTE SampleSIBuff[100];

UWORD chip ahi[] = {
/*-------- plane # 0 --------*/

  0x0000,  0x0000,
  0x3fff,  0xfe00,
  0x3fff,  0xf800,
  0x3e49,  0xe000,
  0x0000,  0x0000,
  0x0000,  0x0000,
  0x23fe,  0x0000,
  0x2000,  0x3000,
  0x3000,  0x7e00,
  0x3fff,  0xfe00,
  0x3fff,  0xfe00,
  0x0000,  0x0000,

/*-------- plane # 1 --------*/

  0x0000,  0x0000,
  0x0000,  0x0000,
  0x0000,  0x0600,
  0x01b6,  0x1e00,
  0xffff,  0xfe00,
  0x8c00,  0xde00,
  0xcc00,  0xc600,
  0xc7ff,  0xc200,
  0x0000,  0x8000,
  0x0000,  0x0000,
  0x0000,  0x0000,
  0x0000,  0x0000,

/*-------- plane # 2 --------*/

  0x0000,  0x0000,
  0x0000,  0x0000,
  0x0000,  0x0600,
  0x01b6,  0x1e00,
  0x3fff,  0xfe00,
  0x0c00,  0xde00,
  0x0c00,  0xc600,
  0x07ff,  0xc200,
  0x0000,  0x8000,
  0x0000,  0x0000,
  0x0000,  0x0000,
  0x0000,  0x0000
};



 struct  Image ahiimage =
 {
 0,0,
 24 , 12 , 3 ,
 &ahi[0],
 0x1f,0x00,
 NULL,
 };

// ************************************************************************

static struct Image delayImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText delayIText = {
	2,0,JAM1,
	-58,1,
	NULL,
	"Delay:",
	NULL
};

static struct PropInfo delaydelayInfo = {
	AUTOKNOB+FREEHORIZ,
	81933,-1,
	10922,-1,
};

static struct Gadget delay = {
	NULL,
	LEFT,TOPSLIDER+274,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	loop end
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&delayImage,
	NULL,
	&delayIText,
	NULL,
	(APTR)&delaydelayInfo,
	40,
	NULL
};


static SHORT EchoVectors[] = {
	0,0,
	89,0,
	89,10,
	0,10,
	0,0
};
static struct Border EchoBorder = {
	-1,-1,
	4,0,JAM1,
	5,
	EchoVectors,
	NULL
};

static struct IntuiText EchoIText = {
	4,0,JAM1,
	27,1,
	NULL,
	"Echo",
	NULL
};

static struct Gadget Echo = {
	&delay,
	432,TOPSLIDER+274,
	88,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE+TOGGLESELECT,
	BOOLGADGET,
	(APTR)&EchoBorder,                       // ECHO ON/OFF BUTTON
	NULL,
	&EchoIText,
	NULL,
	NULL,
	39,
	NULL
};


static struct Image mixImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText mixIText = {
	2,0,JAM1,
	-90,1,
	NULL,
	"Cross Mix:",
	NULL
};

static struct PropInfo mixmixInfo = {
	AUTOKNOB+FREEHORIZ,
	81933,-1,
	10922,-1,
};

static struct Gadget mix = {
	&Echo,
	LEFT,TOPSLIDER+316,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	loop end
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&mixImage,
	NULL,
	&mixIText,
	NULL,
	(APTR)&mixmixInfo,
	38,
	NULL
};

static struct Image feedbImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText feedbIText = {
	2,0,JAM1,
	-82,1,
	NULL,
	"Feedback:",
	NULL
};

static struct PropInfo feedbfeedbInfo = {
	AUTOKNOB+FREEHORIZ,
	81933,-1,
	10922,-1,
};

static struct Gadget feedb = {
	&mix,
	LEFT,TOPSLIDER+295,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	loop end
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&feedbImage,
	NULL,
	&feedbIText,
	NULL,
	(APTR)&feedbfeedbInfo,
	37,
	NULL
};


static struct Image emixImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText emixIText = {
	2,0,JAM1,
	-82,1,
	NULL,
	"Echo Mix:",
	NULL
};

static struct PropInfo emixemixInfo = {
	AUTOKNOB+FREEHORIZ,
	81933,-1,
	10922,-1,
};

static struct Gadget emix = {
	&feedb,
	LEFT,TOPSLIDER+253,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	loop end
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&emixImage,
	NULL,
	&emixIText,
	NULL,
	(APTR)&emixemixInfo,
	36,
	NULL
};



static SHORT fendVectors[] = {
	0,0,
	39,0,
	39,10,
	0,10,
	0,0
};
static struct Border fendBorder = {
	-1,-1,
	4,0,JAM1,
	5,
	fendVectors,
	NULL
};

static struct IntuiText fendIText = {
	4,0,JAM1,
	3,1,
	NULL,
	"Find",
	NULL
};

static struct Gadget fend = {
	&emix,
	432,TOPSLIDER+231,
	38,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&fendBorder,                       // find loop
	NULL,
	&fendIText,
	NULL,
	NULL,
	35,
	NULL
};


static SHORT aboutVectors[] = {
	0,0,
	39,0,
	39,10,
	0,10,
	0,0
};
static struct Border aboutBorder = {
	-1,-1,
	4,0,JAM1,
	5,
	aboutVectors,
	NULL
};

static struct IntuiText aboutIText = {
	4,0,JAM1,
	3,1,
	NULL,
	"Find",
	NULL
};

static struct Gadget about = {
	&fend,
	432,TOPSLIDER+210,
	38,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&aboutBorder,                       /* Scratch mode Active button */
	NULL,
	&aboutIText,
	NULL,
	NULL,
	34,
	NULL
};


static struct Image loopendImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText loopendIText = {
	2,0,JAM1,
	-82,1,
	NULL,
	"Loop End:",
	NULL
};

static struct PropInfo loopendloopendInfo = {
	AUTOKNOB+FREEHORIZ,
	81933,-1,
	10922,-1,
};

static struct Gadget loopend = {
	&about,
	LEFT,TOPSLIDER+231,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	loop end
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&loopendImage,
	NULL,
	&loopendIText,
	NULL,
	(APTR)&loopendloopendInfo,
	33,
	NULL
};

static struct Image loopstImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText loopstIText = {
	2,0,JAM1,
	-97,1,
	NULL,
	"Loop Start:",
	NULL
};

static struct PropInfo loopstloopstInfo = {
	AUTOKNOB+FREEHORIZ,
	81933,-1,
	10922,-1,
};

static struct Gadget loopst = {
	&loopend,
	LEFT,TOPSLIDER+210,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	loop start
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&loopstImage,
	NULL,
	&loopstIText,
	NULL,
	(APTR)&loopstloopstInfo,
	32,
	NULL
};


static SHORT loadnBorderVectors[] = {
	0,0,
	89,0,
	89,10,
	0,10,
	0,0
};
static struct Border loadnBorder = {
	-1,-1,
	4,0,JAM1,
	5,
	loadnBorderVectors,
	NULL
};

static struct IntuiText loadnIText = {
	4,0,JAM1,
	6,1,
	NULL,
	"Load Next",
	NULL
};

static struct Gadget loadn = {
	&loopst,
	432,TOPSLIDER,
	88,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&loadnBorder,                       // Fade out sample play button
	NULL,
	&loadnIText,
	NULL,
	NULL,
	31,
	NULL
};


static SHORT freeBorderVectors[] = {
	0,0,
	54,0,
	54,10,
	0,10,
	0,0
};
static struct Border freeBorder = {
	-1,-1,
	4,0,JAM2,
	5,
	freeBorderVectors,
	NULL
};

static struct IntuiText freeIText = {
	4,0,JAM1,
	6,1,
	NULL,
	"Flush",
	NULL
};

static struct Gadget freeGadget = {
	&loadn,
	468,18,
	52,10,					 //  free sample
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&freeBorder,
	NULL,
	&freeIText,
	NULL,
	NULL,
	30,
	NULL
};


static struct Image fadinImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText fadinIText = {
	2,0,JAM1,
	-64,1,
	NULL,
	"Attack:",
	NULL
};

static struct PropInfo fadinfadinInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget fadin = {
	&freeGadget,
	LEFT,TOPSLIDER+147,
	200,9,
	GADGHBOX+GADGHIMAGE,		//    fade in speed
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&fadinImage,
	NULL,
	&fadinIText,
	NULL,
	(APTR)&fadinfadinInfo,
	29,
	NULL
};

static struct Image bendrgImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText bendrgIText = {
	2,0,JAM1,
	-144,1,
	NULL,
	"Pitch Bend Range:",
	NULL
};

static struct PropInfo bendrgbendrgInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget bendrg = {
	&fadin, 			// Point to Next gadget in list
	LEFT,TOPSLIDER+189,
	200,9,
	GADGHBOX+GADGHIMAGE,		//    Bend range
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&bendrgImage,
	NULL,
	&bendrgIText,
	NULL,
	(APTR)&bendrgbendrgInfo,
	28,
	NULL
};

static struct Image fadesImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText fadesIText = {
	2,0,JAM1,
	-56,1,
	NULL,
	"Decay:",
	NULL
};

static struct PropInfo fadesfadesInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget fades = {
	&bendrg,
	LEFT,TOPSLIDER+168,
	200,9,
	GADGHBOX+GADGHIMAGE,		//    Fadespeed
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&fadesImage,
	NULL,
	&fadesIText,
	NULL,
	(APTR)&fadesfadesInfo,
	27,
	NULL
};


static SHORT centerBorderVectors[] = {
	0,0,
	89,0,
	89,10,
	0,10,
	0,0
};
static struct Border centerBorder = {
	-1,-1,
	4,0,JAM1,
	5,
	centerBorderVectors,
	NULL
};

static struct IntuiText centerIText = {
	4,0,JAM1,
	25,1,
	NULL,
	"Reset",
	NULL
};

static struct Gadget center = {
	&fades,
	432,TOPSLIDER+42,
	88,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&centerBorder,                       // Fade out sample play button
	NULL,
	&centerIText,
	NULL,
	NULL,
	26,
	NULL
};


static SHORT loopBorderVectors[] = {
	0,0,
	37,0,
	37,32,
	0,32,
	0,0
};
static struct Border loopBorder = {
	-1,-1,
	4,0,JAM1,
	5,
	loopBorderVectors,
	NULL
};

static struct IntuiText loopIText = {
	4,0,JAM1,
	2,12,
	NULL,
	"Loop",
	NULL
};

static struct Gadget loop = {
	&center,
	481,TOPSLIDER+210,
	36,32,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE+TOGGLESELECT,
	BOOLGADGET,
	(APTR)&loopBorder,                       // LOOP ON/OFF BUTTON
	NULL,
	&loopIText,
	NULL,
	NULL,
	25,
	NULL
};


static struct Image ScStartImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ScStartIText = {
	2,0,JAM1,
	-120,1,
	NULL,
	"Scratch Start:",
	NULL
};

static struct PropInfo scstartscstartInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget ScStart = {
	&loop,
	LEFT,TOPSLIDER+126,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	Scratch Start
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&ScStartImage,
	NULL,
	&ScStartIText,
	NULL,
	(APTR)&scstartscstartInfo,
	24,
	NULL
};


static struct Image ScRangeImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ScRangeIText = {
	2,0,JAM1,
	-120,1,
	NULL,
	"Scratch Range:",
	NULL
};

static struct PropInfo scrangescrangeInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget ScRange = {
	&ScStart,
	LEFT,TOPSLIDER+105,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	Scratch Length
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&ScRangeImage,
	NULL,
	&ScRangeIText,
	NULL,
	(APTR)&scrangescrangeInfo,
	23,
	NULL
};

static struct Image ScLengthImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ScLengthIText = {
	2,0,JAM1,
	-128,1,
	NULL,
	"Scratch Length:",
	NULL
};

static struct PropInfo sclengthsclengthInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget ScLength = {
	&ScRange,
	LEFT,TOPSLIDER+84,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	Scratch Length
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&ScLengthImage,
	NULL,
	&ScLengthIText,
	NULL,
	(APTR)&sclengthsclengthInfo,
	22,
	NULL
};


static struct Image ChannelImage = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ChannelText = {
	2,0,JAM1,
	-71,1,
	NULL,
	"Channel:",
	NULL
};

static struct PropInfo channelchannelInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget Channel = {
	&ScLength,
	LEFT,TOPSLIDER,
	200,9,
	GADGHBOX+GADGHIMAGE,		//	MULTIPART
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,			//	CHANNEL
	(APTR)&ChannelImage,
	NULL,
	&ChannelText,
	NULL,
	(APTR)&channelchannelInfo,
	21,
	NULL
};


static struct IntuiText SampleText =
{
	1,0,JAM1,
	-63,0,
	NULL,
	"Sample:",
	NULL
};

struct StringInfo SampleSInfo = {
	SampleSIBuff,	/* buffer where text will be edited */
	NULL,	/* optional undo buffer */
	0,	/* character position in buffer */
	38,	/* maximum number of characters to allow */
	0,	/* first displayed character buffer position */
	0,0,0,0,0,	/* Intuition initialized and maintained variables */
	0,	/* Rastport of gadget */
	0,	/* initial value for integer gadgets */
	NULL	/* alternate keymap (fill in if you set the flag) */
};

SHORT BorderVectors1[] = {
	0,0,
	271,0,
	271,11,
	0,11,
	0,0
};
struct Border Border1 = {
	-2,-2,	/* XY origin relative to container TopLeft */
	2,4,JAM2,	/* front pen, back pen and drawmode */
	5,	/* number of XY vectors */
	BorderVectors1, /* pointer to XY vectors */
	NULL	/* next border in list */
};

struct Gadget Sample = {
	&Channel,   /* next gadget */
	92,20,	/* origin XY of hit box relative to window TopLeft */
	268,10, /* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY+STRINGLEFT,  /* activation flags */
	STRGADGET,	/* gadget type flags */
	(APTR)&Border1, /* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	&SampleText,   /* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	(APTR)&SampleSInfo,     /* SpecialInfo structure */
	20,   /* user-definable data */
	NULL	/* pointer to user-definable data */
};


/* static SHORT ahiBorderVectors0[] = {
	0,0,
	93,0,
	93,11,
	0,11,
	0,0
};

static struct Border ahiBorder0 = {
	-2,-2,
	4,0,JAM1,
	5,
	ahiBorderVectors0,
	NULL
};

static struct IntuiText ahiIText0 = {
	2,0,JAM1,
	-71,1,
	NULL,
	"Name:",
	NULL
};

static struct Gadget ahiGadget0 = {
	NULL,
	200,180,
	90,8,
	NULL,
	RELVERIFY+GADGIMMEDIATE,
	STRGADGET,
	NULL,
	NULL,
	&ahiIText0,
	NULL,
	NULL,
	0,
	NULL
};
*/

static struct Image ahiImage1 = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ahiIText1 = {
	2,0,JAM1,
	-87,1,
	NULL,
	"Fine Tune:",
	NULL
};

static struct PropInfo ahiahiGadget7SInfo = {
	AUTOKNOB+FREEHORIZ,
	31933,-1,
	10922,-1,
};

static struct Gadget ahiGadget7 = {
	&Sample,					/*	&quantizeGadget0, */
	LEFT,TOPSLIDER+63,
	200,9,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&ahiImage1,                  /* Fine tune Slider */
	NULL,
	&ahiIText1,
	NULL,
	(APTR)&ahiahiGadget7SInfo,
	7,
	NULL
};

static SHORT ahiBorderVectors1[] = {
	0,0,
	89,0,
	89,10,
	0,10,
	0,0
};
static struct Border ahiBorder1 = {
	-1,-1,
	4,0,JAM1,
	5,
	ahiBorderVectors1,
	NULL
};

static struct IntuiText ahiIText2 = {
	4,0,JAM1,
	17,1,
	NULL,
	"Scratch",
	NULL
};

static struct Gadget ahiGadget6 = {
	&ahiGadget7,
	432,TOPSLIDER+84,
	88,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE+TOGGLESELECT,
	BOOLGADGET,
	(APTR)&ahiBorder1,                       /* Scratch mode Active button */
	NULL,
	&ahiIText2,
	NULL,
	NULL,
	6,
	NULL
};

static SHORT ahiBorderVectors2[] = {
	0,0,
	149,0,
	149,10,
	0,10,
	0,0
};
static struct Border ahiBorder2 = {
	-1,-1,
	4,0,JAM2,
	5,
	ahiBorderVectors2,
	NULL
};

static struct IntuiText ahiIText3 = {
	4,0,JAM1,
	14,1,
	NULL,
	"Select AHI Mode",
	NULL
};

static struct Gadget ahiGadget5 = {
	&ahiGadget6,
	372,61,
	148,10, 				  /*	  AHI MODE SELECT BUTTON     */
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&ahiBorder2,
	NULL,
	&ahiIText3,
	NULL,
	NULL,
	5,
	NULL
};

static SHORT ahiBorderVectors3[] = {
	0,0,
	89,0,
	89,10,
	0,10,
	0,0
};

static struct Border ahiBorder3 = {
	-1,-1,
	4,0,JAM1,
	5,
	ahiBorderVectors3,
	NULL
};

static struct IntuiText ahiIText4 = {
	6,0,JAM1,     // Front pen, back pen, draw mode
	27,1,  // XY pos of text
	NULL,
	"Load",
	NULL
};

static struct Gadget ahiGadget4 = {
	&ahiGadget5,
	372,18,
	88,10,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	BOOLGADGET,
	(APTR)&ahiBorder3,                          /* load button */
	NULL,
	&ahiIText4,
	NULL,
	NULL,
	4,
	NULL
};

static struct IntuiText ahiIText7 = {
	2,0,JAM1,
	-151,1,
	NULL,
	"AHI Master Volume:",
	NULL
};

static struct PropInfo ahiahiGadget10SInfo = {
       AUTOKNOB+FREEHORIZ,
	 -25487,-1,
	 10922, -1,

};

static struct Image ahiImage10 = {
	61,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};


static struct Gadget ahiGadget3 = {
	&ahiGadget4,
	LEFT,TOPSLIDER+337,
	200,9,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&ahiImage10,
	NULL,				      /* Master vol */
	&ahiIText7,
	NULL,
	(APTR)&ahiahiGadget10SInfo,
	3,
	NULL
};

static struct PropInfo ahiahiGadget2SInfo = {
	AUTOKNOB+FREEHORIZ,
	-25487,-1,
	10922,-1,
};

static struct Image ahiImage2 = {
	77,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ahiIText8 = {
	2,0,JAM1,
	-39,1,
	NULL,
	"Pan:",
	NULL
};

static struct Gadget ahiGadget2 = {
	&ahiGadget3,
	LEFT,TOPSLIDER+42,
	200,9,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,				   /* PAN slider */
	(APTR)&ahiImage2,
	NULL,
	&ahiIText8,
	NULL,
	(APTR)&ahiahiGadget2SInfo,
	2,
	NULL
};

static struct PropInfo ahiahiGadget1SInfo = {
	AUTOKNOB+FREEHORIZ,
	6241,-1,
	10922,-1,
};

static struct Image ahiImage3 = {
	12,0,
	26,5,
	0,
	NULL,
	0x0000,0x0000,
	NULL
};

static struct IntuiText ahiIText9 = {
	2,0,JAM1,
	-63,1,
	NULL,
	"Volume:",
	NULL
};

static struct Gadget ahiGadget1 = {
	&ahiGadget2,
	LEFT,TOPSLIDER+21,
	200,9,
	GADGHBOX+GADGHIMAGE,
	RELVERIFY+GADGIMMEDIATE,
	PROPGADGET,
	(APTR)&ahiImage3,                    /*  Volume slider  */
	NULL,
	&ahiIText9,
	NULL,
	(APTR)&ahiahiGadget1SInfo,
	1,
	NULL
};

#define ahiGadgetList1 ahiGadget1

struct NewWindow ahiNewWindowStructure1 = {
	134,55,
	532,449,
	6,1,
	MOUSEBUTTONS+MOUSEMOVE+GADGETDOWN+GADGETUP+CLOSEWINDOW,
	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+REPORTMOUSE,
	&ahiGadget1,
	NULL,
	"AHI Output v0.91 Beta",
	NULL,
	NULL,
	5,5,
	-1,-1,
	CUSTOMSCREEN
};

