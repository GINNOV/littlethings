#include	"main.h"
#include	<graphics/videocontrol.h>		// plus all the other shit


struct TextAttr TOPAZ80 = {
	(STRPTR)"topaz.font",
	TOPAZ_EIGHTY,0,0
};

UWORD quickpens[] = { ~0 };

struct TagItem VCTags[] =
{
	{ VTAG_BORDERBLANK_SET, TRUE },
	{ VC_IntermediateCLUpdate, FALSE },		// speeds up on V40
	{ TAG_DONE, NULL },
};


struct TagItem ScreenTags[] =
{
	{ SA_Pens,		&quickpens },
	{ SA_Interleaved, 	TRUE },
	{ SA_Draggable,		FALSE },
	{ SA_Exclusive,		TRUE },
	{ SA_MinimizeISG,	TRUE },			// V40: minimize interscreen gap
	{ SA_VideoControl, 	&VCTags },
	{ TAG_DONE,		0 },
};

struct ExtNewScreen NewScreenStructure = {
	0,0,				/* screen XY origin relative to View */
	cube_screen_width, cube_screen_len,			/* screen width and height */
	cube_screen_depth,					/* screen depth (number of bitplanes) */
	1,2,				/* detail and block pens */
	HIRES,				/* display modes for this screen */
	CUSTOMSCREEN+SCREENQUIET+CUSTOMBITMAP+NS_EXTENDED,	/* screen type */
	&TOPAZ80,			/* pointer to default screen font */
	NULL,				/* screen title */
	NULL,				/* first in list of custom screen gadgets */
	NULL,			/* pointer to custom BitMap structure */
	(struct TagItem *)&ScreenTags
};
