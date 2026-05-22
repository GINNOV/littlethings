/*
 *	File:					ASL.c
 *	Description:	Frontend to the Asl.library
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	ASL_C
#define	ASL_C

/*** PRIVATE INCLUDES ****************************************************************/
#include "System.h"
#include "Asl.h"

#include <dos/dosasl.h>
#include <clib/asl_protos.h>

/*** GLOBALS *************************************************************************/
struct FileRequester				*filereq=NULL;
struct FontRequester				*fontreq=NULL;
struct ScreenModeRequester	*screenmodereq=NULL;

/*** FUNCTIONS ***********************************************************************/
void centreASL(struct egCoords *coords, struct Window *window)
{
#ifdef MYDEBUG_H
	DebugOut("centreAsl");
#endif

	if(window && coords->Width==0)
	{
		coords->Width			=window->WScreen->Width/3;
		coords->Height		=window->WScreen->Height/2;
		coords->LeftEdge	=(window->WScreen->Width-coords->Width)/2;
		coords->TopEdge		=(window->WScreen->Height-coords->Height)/2;
	}
}

BYTE FileRequest(	struct Window *window,
									ULONG					MSG_RQTITLE,
									char					*input,
									ULONG					flags1,
									ULONG					flags2,
									ULONG					MSG_RQOK)
{
	return GetFile(	window,
									egGetString(MSG_RQTITLE),
									input,
									flags1,
									flags2,
									egGetString(MSG_RQOK));
}

BYTE GetFile(	struct Window *window,
							UBYTE					*title,
							char					*input,
							ULONG					flags1,
							ULONG					flags2,
							UBYTE					*ok)
{
	BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("FileRequest");
#endif

	if(filereq==NULL)
	{
		centreASL(&env.filerequester, window);
		filereq=AllocAslRequestTags(ASL_FileRequest, TAG_DONE);
	}

	if(filereq)
	{
		char drawer[MAXCHARS], file[MAXCHARS];

		strcpy(drawer, input);
		if(!(flags2 & FRF_DRAWERSONLY))
		{
			strcpy(file, FilePart(drawer));
			*PathPart(drawer)='\0';
		}
		if(success=(BYTE)AslRequestTags(filereq,
											ASLFR_Window,						window,
											ASLFR_TitleText,				title,
											ASLFR_InitialLeftEdge,	env.filerequester.LeftEdge,
											ASLFR_InitialTopEdge,		env.filerequester.TopEdge,
											ASLFR_InitialWidth,			env.filerequester.Width,
											ASLFR_InitialHeight,		env.filerequester.Height,
											ASLFR_Flags1,						FRF_DOPATTERNS|flags1,
											ASLFR_Flags2,						FRF_REJECTICONS|flags2,
											ASLFR_InitialDrawer,		drawer,
											ASLFR_InitialFile,			file,
											ASLFR_PositiveText,			ok,
//											ASLFR_Locale,						locale,
											TAG_DONE))
		{
			strcpy(input, filereq->fr_Drawer);
			AddPart(input, filereq->fr_File, MAXCHARS-1);
		}
	}
	env.filerequester.LeftEdge=filereq->fr_LeftEdge;
	env.filerequester.TopEdge	=filereq->fr_TopEdge;
	env.filerequester.Width		=filereq->fr_Width;
	env.filerequester.Height	=filereq->fr_Height;

	return success;
}

BYTE FontRequest(	struct Window		*window,
									ULONG						MSG_RQTITLE,
									struct TextAttr	*textattr,
									ULONG						flags,
									ULONG						MSG_RQOK)
{
	BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("FontRequest");
#endif

	if(fontreq==NULL)
	{
		centreASL(&env.fontrequester, window);
		fontreq=AllocAslRequestTags(ASL_FontRequest,
									ASLFO_MinHeight,				8,
									ASLFO_MaxHeight,				200,
									TAG_DONE);
	}

	if(fontreq)
		if(success=(BYTE)AslRequestTags(fontreq,
											ASLFO_Window,						window,
											ASLFO_TitleText,				GetString(&li, MSG_RQTITLE),
											ASLFO_InitialLeftEdge,	env.fontrequester.LeftEdge,
											ASLFO_InitialTopEdge,		env.fontrequester.TopEdge,
											ASLFO_InitialWidth,			env.fontrequester.Width,
											ASLFO_InitialHeight,		env.fontrequester.Height,
											ASLFO_InitialName,			textattr->ta_Name,
											ASLFO_InitialSize,			textattr->ta_YSize,
											ASLFO_InitialStyle,			textattr->ta_Style,
											ASLFO_InitialFlags,			textattr->ta_Flags,
											ASLFO_Flags,						flags,
											ASLFR_PositiveText,			egGetString(MSG_RQOK),
//											ASLFR_Locale,						locale,
											TAG_DONE))
		{
			if(textattr->ta_Name)
				free(textattr->ta_Name);
			textattr->ta_Name	=strdup(fontreq->fo_Attr.ta_Name);
//			strcpy(env.fontname, fontreq->fo_Attr.ta_Name);
			textattr->ta_YSize=fontreq->fo_Attr.ta_YSize;
			textattr->ta_Style=fontreq->fo_Attr.ta_Style;
			textattr->ta_Flags=fontreq->fo_Attr.ta_Flags;
		}
	env.fontrequester.LeftEdge=fontreq->fo_LeftEdge;
	env.fontrequester.TopEdge	=fontreq->fo_TopEdge;
	env.fontrequester.Width		=fontreq->fo_Width;
	env.fontrequester.Height	=fontreq->fo_Height;

	return success;
}


BYTE ScreenModeRequest(	struct Window			*window,
												ULONG							MSG_RQTITLE,
												struct ScreenInfo	*screeninfo,
												BYTE							fullmode,
												ULONG							MSG_RQOK)
{
	BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("ScreenModeRequest");
#endif

	if(screenmodereq==NULL)
	{
		centreASL(&env.screenrequester, window);
		screenmodereq=AllocAslRequestTags(ASL_ScreenModeRequest, TAG_DONE);
	}

	if(screenmodereq)
		if(success=(BYTE)AslRequestTags(screenmodereq,
											ASLSM_Window,								window,
											ASLSM_TitleText,						GetString(&li, MSG_RQTITLE),
											ASLSM_InitialLeftEdge,			env.screenrequester.LeftEdge,
											ASLSM_InitialTopEdge,				env.screenrequester.TopEdge,
											ASLSM_InitialWidth,					env.screenrequester.Width,
											ASLSM_InitialHeight,				env.screenrequester.Height,
											ASLSM_InitialDisplayID,			screeninfo->DisplayID,
											ASLSM_InitialDisplayWidth,	screeninfo->DisplayWidth,
											ASLSM_InitialDisplayHeight,	screeninfo->DisplayHeight,
											ASLSM_InitialDisplayDepth,	screeninfo->DisplayDepth,
											ASLSM_InitialOverscanType,	screeninfo->OverscanType,
											ASLSM_InitialAutoScroll,		screeninfo->AutoScroll,
											ASLSM_DoWidth,							fullmode,
											ASLSM_MinWidth,							MINSCREENWIDTH,
											ASLSM_MinHeight,						MINSCREENHEIGHT,
											ASLSM_DoHeight,							fullmode,
											ASLSM_DoDepth,							fullmode,
											ASLSM_DoOverscanType,				fullmode,
											ASLSM_DoAutoScroll,					fullmode,
											ASLSM_PositiveText,					egGetString(MSG_RQOK),
//											ASLFR_Locale,								locale,
											TAG_DONE))
		{
			screeninfo->DisplayID			=screenmodereq->sm_DisplayID;	   
			screeninfo->DisplayWidth	=screenmodereq->sm_DisplayWidth;	
			screeninfo->DisplayHeight	=screenmodereq->sm_DisplayHeight;
			screeninfo->DisplayDepth	=screenmodereq->sm_DisplayDepth;	
			screeninfo->OverscanType	=screenmodereq->sm_OverscanType;	
			screeninfo->AutoScroll		=screenmodereq->sm_AutoScroll;
		}
	env.screenrequester.LeftEdge=screenmodereq->sm_LeftEdge;
	env.screenrequester.TopEdge	=screenmodereq->sm_TopEdge;
	env.screenrequester.Width		=screenmodereq->sm_Width;
	env.screenrequester.Height	=screenmodereq->sm_Height;

	return success;
}

void FreeAslRequesters(void)
{
#ifdef MYDEBUG_H
	DebugOut("FreeAslRequesters");
#endif
	if(filereq)
		FreeAslRequest(filereq);
	if(fontreq)
		FreeAslRequest(fontreq);
	if(screenmodereq)
		FreeAslRequest(screenmodereq);

	filereq=NULL;
	fontreq=NULL;
	screenmodereq=NULL;
}
#endif
