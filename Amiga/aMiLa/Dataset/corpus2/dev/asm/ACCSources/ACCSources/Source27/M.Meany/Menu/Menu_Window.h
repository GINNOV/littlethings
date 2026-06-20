
extern USHORT gfxData[];

static struct Gadget Gadget29 = {
	NULL,		/* next gadget */
	539,116,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	29,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget28 = {
	&Gadget29,	/* next gadget */
	487,116,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	28,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget27 = {
	&Gadget28,	/* next gadget */
	435,116,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	27,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget26 = {
	&Gadget27,	/* next gadget */
	383,116,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	26,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget25 = {
	&Gadget26,	/* next gadget */
	539,105,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	25,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget24 = {
	&Gadget25,	/* next gadget */
	487,105,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	24,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget23 = {
	&Gadget24,	/* next gadget */
	435,105,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	23,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget22 = {	/* MAIN */
	&Gadget23,	/* next gadget */
	383,105,	/* origin XY of hit box relative to window TopLeft */
	52,11,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	22,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget21 = {
	&Gadget22,	/* next gadget */
	363,72,	/* origin XY of hit box relative to window TopLeft */
	247,30,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	21,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct PropInfo Gadget20SInfo = {
	AUTOKNOB+FREEVERT+PROPBORDERLESS,	/* PROPINFO flags */
	0,0,	/* horizontal and vertical pot values */
	-1,13107,	/* horizontal and vertical body values */
};

static struct Image Image1 = {
	0,0,	/* XY origin relative to container TopLeft */
	7,26,	/* Image width and height in pixels */
	0,	/* number of bitplanes in Image */
	NULL,	/* pointer to ImageData */
	0x0000,0x0000,	/* PlanePick and PlaneOnOff */
	NULL	/* next Image structure */
};

static struct Gadget Gadget20 = {
	&Gadget21,	/* next gadget */
	329,78,	/* origin XY of hit box relative to window TopLeft */
	7,138,	/* hit box width and height */
	NULL,	/* gadget flags */
	GADGIMMEDIATE+RELVERIFY,	/* activation flags */
	PROPGADGET,	/* gadget type flags */
	(APTR)&Image1,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	(APTR)&Gadget20SInfo,	/* SpecialInfo structure */
	20,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget19 = {
	&Gadget20,	/* next gadget */
	327,226,	/* origin XY of hit box relative to window TopLeft */
	11,8,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	GADGIMMEDIATE+RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	19,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget18 = {
	&Gadget19,	/* next gadget */
	327,218,	/* origin XY of hit box relative to window TopLeft */
	11,8,	/* hit box width and height */
	GADGHCOMP,	/* gadget flags */
	GADGIMMEDIATE+RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	18,	/* user-definable data */
	NULL	/* pointer to user-definable data */
};

static struct Gadget Gadget17 = {
	&Gadget18,	/* next gadget */
	44,224,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)16L	/* pointer to user-definable data */
};

static struct Gadget Gadget16 = {
	&Gadget17,	/* next gadget */
	44,215,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)15L	/* pointer to user-definable data */
};

static struct Gadget Gadget15 = {
	&Gadget16,	/* next gadget */
	44,206,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)14L	/* pointer to user-definable data */
};

static struct Gadget Gadget14 = {
	&Gadget15,	/* next gadget */
	44,197,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)13L	/* pointer to user-definable data */
};

static struct Gadget Gadget13 = {
	&Gadget14,	/* next gadget */
	44,188,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)12L	/* pointer to user-definable data */
};

static struct Gadget Gadget12 = {
	&Gadget13,	/* next gadget */
	44,179,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)11L	/* pointer to user-definable data */
};

static struct Gadget Gadget11 = {
	&Gadget12,	/* next gadget */
	44,170,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)10L	/* pointer to user-definable data */
};

static struct Gadget Gadget10 = {
	&Gadget11,	/* next gadget */
	44,161,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)9L	/* pointer to user-definable data */
};

static struct Gadget Gadget9 = {
	&Gadget10,	/* next gadget */
	44,152,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)8L	/* pointer to user-definable data */
};

static struct Gadget Gadget8 = {
	&Gadget9,	/* next gadget */
	44,143,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)7L	/* pointer to user-definable data */
};

static struct Gadget Gadget7 = {
	&Gadget8,	/* next gadget */
	44,134,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)6L	/* pointer to user-definable data */
};

static struct Gadget Gadget6 = {
	&Gadget7,	/* next gadget */
	44,125,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)5L	/* pointer to user-definable data */
};

static struct Gadget Gadget5 = {
	&Gadget6,	/* next gadget */
	44,116,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)4L	/* pointer to user-definable data */
};

static struct Gadget Gadget4 = {
	&Gadget5,	/* next gadget */
	44,107,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)3L	/* pointer to user-definable data */
};

static struct Gadget Gadget3 = {
	&Gadget4,	/* next gadget */
	44,98,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)2L	/* pointer to user-definable data */
};

static struct Gadget Gadget2 = {
	&Gadget3,	/* next gadget */
	44,89,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)1L	/* pointer to user-definable data */
};

static struct Gadget Gadget1 = {
	&Gadget2,	/* next gadget */
	44,80,	/* origin XY of hit box relative to window TopLeft */
	270,8,	/* hit box width and height */
	NULL,	/* gadget flags */
	RELVERIFY,	/* activation flags */
	BOOLGADGET,	/* gadget type flags */
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	NULL,	/* SpecialInfo structure */
	0,	/* user-definable data */
	(APTR)0L	/* pointer to user-definable data */
};

static struct IntuiText WinText = {
	1,0,JAM2,	/* front and back text pens, drawmode and fill byte */
	47,80,	/* XY origin relative to container TopLeft */
	NULL,	/* font pointer or NULL for default */
	NULL,	/* pointer to text */
	NULL	/* next IntuiText structure */
};

static struct IntuiText DataText = {
	1,3,JAM2,	/* front and back text pens, drawmode and fill byte */
	0,0,	/* XY origin relative to container TopLeft */
	NULL,	/* font pointer or NULL for default */
	NULL,	/* pointer to text */
	NULL	/* next IntuiText structure */
};

#define IntuiTextList1 IText1

static struct NewWindow MenuWindow = {
	0,0,	/* window XY origin relative to TopLeft of screen */
	640,256,	/* window width and height */
	0,1,	/* detail and block pens */
	GADGETDOWN+GADGETUP+VANILLAKEY+INTUITICKS,	/* IDCMP flags */
	BORDERLESS+ACTIVATE+NOCAREREFRESH+RMBTRAP,	/* other window flags */
	NULL,	/* first gadget in gadget list */
	NULL,	/* custom CHECKMARK imagery */
	NULL,	/* window title */
	NULL,	/* custom screen pointer */
	NULL,	/* custom bitmap */
	5,5,	/* minimum width and height */
	640,256,	/* maximum width and height */
	WBENCHSCREEN	/* destination screen type */
};

struct Image gfxImage = {
	0,0,	/* XY origin relative to container TopLeft */
	640,256,	/* Image width and height in pixels */
	2,	/* number of bitplanes in Image */
	gfxData,	/* pointer to ImageData */
	0x0003,0x0000,	/* PlanePick and PlaneOnOff */
	NULL	/* next Image structure */
};

/* end of PowerWindows source generation */
