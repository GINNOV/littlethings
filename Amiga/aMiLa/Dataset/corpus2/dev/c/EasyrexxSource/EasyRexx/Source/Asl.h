/*
 *	File:					ASL.h
 *	Description:	Frontend to the Asl.library
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	ASL_H
#define	ASL_H

#define ASL_V38_NAMES_ONLY

/*** PRIVATE INCLUDES ****************************************************************/
#include <libraries/asl.h>

/*** DEFINES *************************************************************************/
#define	MINSCREENWIDTH	320
#define	MINSCREENHEIGHT	200

/*** GLOBALS *************************************************************************/
extern struct FileRequester				*filereq;
extern struct FontRequester				*fontreq;
extern struct ScreenModeRequester	*screenmodereq;

/*** PROTOTYPES **********************************************************************/
BYTE GetFile(	struct Window *window,
							UBYTE					*title,
							char					*input,
							ULONG					flags1,
							ULONG					flags2,
							UBYTE					*ok);
BYTE FileRequest(	struct Window *window,
									ULONG					MSG_RQTITLE,
									char					*input,
									ULONG					flags1,
									ULONG					flags2,
									ULONG					MSG_RQOK);
BYTE FontRequest(	struct Window		*window,
									ULONG						MSG_RQTITLE,
									struct TextAttr	*textattr,
									ULONG						flags,
									ULONG						MSG_RQOK);
BYTE ScreenModeRequest(	struct Window			*window,
												ULONG							MSG_RQTITLE,
												struct ScreenInfo	*screeninfo,
												BYTE							fullmode,
												ULONG							MSG_RQOK);
void FreeAslRequesters(void);
#endif
