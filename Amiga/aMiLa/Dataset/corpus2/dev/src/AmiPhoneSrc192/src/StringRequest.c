#include <stdio.h>
#include <time.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/screens.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <exec/types.h>
#include <exec/libraries.h>
#include <libraries/dos.h>			/* contains RETURN_OK, RETURN_WARN #def's */
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <string.h>
#include <errno.h>
#include <libraries/gadtools.h>

extern struct Library *GadToolsBase;

#include "codec.h"
#include "AmiPhone.h"
#include "stringrequest.h"

/* Lets the user put a string into szBuffer.  Returns TRUE if the user entered
   a string, otherwise FALSE */
BOOL GetUserString (struct Screen *Scr, struct Window *PhoneWindow, char *szBuffer, char *szTitle, char *szGadText, int nLength)
{
	ULONG winsig, signals;
	int fwindowwidth = Scr->Width/2, fwindowheight = 35 + Scr->RastPort.TxHeight;
	int fwindowleft = (PhoneWindow->LeftEdge + (PhoneWindow->Width/2) - (fwindowwidth/2));
	int fwindowtop  = (PhoneWindow->TopEdge  + (PhoneWindow->Height/2)- (fwindowheight/2));
	struct NewGadget stringGad;
	struct IntuiMessage *imsg;
	struct Gadget *newgad = NULL;
	struct Gadget *Stringgadlist = NULL;
	void *Stringvi;
	struct Window *Stringwindow;
	BOOL done=FALSE, BRet = TRUE;
	struct TextAttr topaz8 = {(STRPTR)"topaz.font", 8, 0x00, 0x00 };

	if (szTitle == NULL) szTitle = "String Requester Active";
	if (szBuffer == NULL) return(FALSE);

	/* Allow strings starting with ASCII 1 to be treated as an empty string */
	if (*szBuffer == '\1') *szBuffer = '\0';
	if (*szTitle  == '\1') *szTitle  = '\0';
	if (*szGadText== '\1') *szGadText= '\0';
	
	Stringvi = GetVisualInfo(Scr, TAG_END);

	if (Stringvi == NULL) 
	{
		return(FALSE);
	}
	
	if (fwindowleft < 0) fwindowleft = PhoneWindow->LeftEdge;
	if (fwindowheight < 0) fwindowtop = PhoneWindow->TopEdge;

	newgad = CreateContext(&Stringgadlist);
	if (newgad == NULL) return(FALSE);

	stringGad.ng_TextAttr	 = &topaz8;
	stringGad.ng_VisualInfo  = Stringvi;
	stringGad.ng_LeftEdge	 = 5;
	stringGad.ng_TopEdge   	 = 18 + Scr->RastPort.TxHeight;
	stringGad.ng_Width	 = (fwindowwidth-10);
	stringGad.ng_Height	 = 13;
	stringGad.ng_GadgetText  = szGadText;
	stringGad.ng_GadgetID	 = 35;	
	stringGad.ng_Flags	 = PLACETEXT_ABOVE;

	newgad = CreateGadget(STRING_KIND, newgad, &stringGad, 
				  GTST_String, szBuffer, 
				  STRINGA_Justification, GACT_STRINGCENTER, 
				  GA_Immediate, TRUE,
				  TAG_END);  
			  
 	if (newgad == NULL) 
	{
		FreeGadgets(Stringgadlist);
		FreeVisualInfo(Stringvi);
		return(FALSE);
	}
	
	if (GadToolsBase->lib_Version == 37)
	{
	/* Only do it the "illegal" way under v37.  GA_Immediate in the CreateGadget
	   line, above, won't work under v37 but will on later releases. */
		newgad->Activation |= GACT_IMMEDIATE; 
	}

	Stringwindow = OpenWindowTags(NULL,
		WA_Left,		fwindowleft,
		WA_Top,			fwindowtop,
		WA_Width,	   	fwindowwidth,
		WA_Height,		fwindowheight,
		WA_PubScreen,		Scr,
		WA_PubScreenFallBack, 	TRUE,
		WA_IDCMP,		STRINGIDCMP|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_ACTIVEWINDOW,
		WA_Flags,		WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
		WA_Gadgets,		Stringgadlist,
		WA_Title,	   	szTitle,
		WA_ScreenTitle,		"AmiPhone String Requester",
		TAG_DONE );

	if (Stringwindow == NULL) 
	{
		FreeVisualInfo(Stringvi);
		return(FALSE);
	}
	GT_RefreshWindow(Stringwindow, NULL); 

	SetBusyPointer(PhoneWindow);

	winsig = 1 << Stringwindow->UserPort->mp_SigBit;

	while (done==FALSE)
	{
		signals = Wait(winsig);
		if (signals&winsig)
		{
			while ((done==FALSE) && (imsg = GT_GetIMsg(Stringwindow->UserPort)))
			{
				switch(imsg->Class)
				{			
				case IDCMP_ACTIVEWINDOW:
					ActivateGadget(newgad,Stringwindow,NULL);
					break;
						
				case IDCMP_GADGETUP:
					Strncpy(szBuffer,((struct StringInfo*)newgad->SpecialInfo)->Buffer,nLength);
					done = TRUE;
					break;
		
				case IDCMP_CLOSEWINDOW:
					done = TRUE;
					BRet = FALSE;
					break;
					
				case IDCMP_REFRESHWINDOW:
					GT_BeginRefresh(Stringwindow);
					GT_EndRefresh(Stringwindow, TRUE);
					break;
				}
			GT_ReplyIMsg(imsg);
			}
		}
	}
	CloseWindow(Stringwindow);
	FreeGadgets(Stringgadlist);
	FreeVisualInfo(Stringvi); 
	Stringwindow = NULL;
	ClearPointer(PhoneWindow);
	return(BRet);
}

void SetBusyPointer(struct Window *win)
{
	static __chip UWORD waitPointer[] =
	       {0x0000, 0x0000, 0x0400, 0x07c0, 0x0000, 0x07c0, 0x0100, 0x0380,
		0x0000, 0x07e0, 0x07c0, 0x1ff8, 0x1ff0, 0x3fec, 0x3ff8, 0x7fde,
		0x3ff8, 0x7fbe, 0x7ffc, 0xff7f, 0x7efc, 0xffff, 0x7ffc, 0xffff,
		0x3ff8, 0x7ffe, 0x3ff8, 0x7ffe, 0x1ff0, 0x3ffc, 0x07c0, 0x1ff8,
		0x0000, 0x07e0, 0x0000, 0x0000};
        
	if (win != NULL) SetPointer(win, waitPointer, 16, 16, -6, 0);
}
