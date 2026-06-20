#include <simple/inc.h>
#include <simple/reqtools.h>

extern struct Library * IntuitionBase;
extern struct Library * ReqToolsBase;

const char *DefaultReqScreenTitle = "GfxView Screen";

struct TagItem SetScreenReqTags[4] =
	{
	{ RTSC_DisplayID, NTSC_MONITOR_ID|HIRESLACE_KEY },
	{ RTSC_DisplayDepth, 2 },
	{ RTSC_AutoScroll, 0 },
	{ TAG_DONE , 0 }
	};

struct TagItem ScreenReqTags[2] =
	{
	{ RTSC_Flags,	SCREQF_DEPTHGAD|SCREQF_SIZEGADS|SCREQF_AUTOSCROLLGAD
								|SCREQF_OVERSCANGAD },
	{ TAG_DONE	,	0 }
	};

struct Screen * MakeRequestedScreen(void)
{
struct rtScreenModeRequester *ScreenReq;
struct Screen * Screen;

if ( (ScreenReq = rtAllocRequestA(RT_SCREENMODEREQ, NULL)) == NULL )
	return(NULL);

rtChangeReqAttrA(ScreenReq,SetScreenReqTags);

if ( ! rtScreenModeRequestA (ScreenReq,"Pick a screen mode:",ScreenReqTags) )
	{
	rtFreeRequest(ScreenReq);
	return(NULL);
	}

Screen = OpenScreenTags(NULL,
					SA_Width, 		ScreenReq->DisplayWidth,
					SA_Height, 		ScreenReq->DisplayHeight,
					SA_Depth,			ScreenReq->DisplayDepth,
					SA_Title,			(ulong)DefaultReqScreenTitle,
					SA_DisplayID, ScreenReq->DisplayID,
					SA_AutoScroll,ScreenReq->AutoScroll,
					SA_Overscan,  ScreenReq->OverscanType,
					SA_SysFont,	0,
					SA_FullPalette, TRUE,
					SA_Type,			CUSTOMSCREEN,
					TAG_DONE);

rtFreeRequest(ScreenReq);

return(Screen);
}
