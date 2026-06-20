/*
**	Cx.c
**
**	(C) 1994,1995 Bernardo Innocenti
**
**	Commodity support functions
*/


#include <exec/memory.h>
#include <libraries/commodities.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/commodities_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/commodities_pragmas.h>

#include "XModule.h"
#include "Gui.h"


#define CX_POPKEY	'POP!'


BYTE CxPri = 0;
UBYTE CxPopKey[32] = "control alt x";
BOOL CxPopup = TRUE;
ULONG CxSig = 0;


struct MsgPort *CxPort = NULL;
CxObj *MyBroker = NULL;

static struct NewBroker MyNewBroker =
{
	NB_VERSION,
	PRGNAME,
	Version+6,
	"Module Processing Utility",
	NBU_DUPLICATE,
	COF_SHOW_HIDE,
	0,
	NULL,
	0
};



void HandleCx (void)
{
	CxMsg	*cxm;
	ULONG	 type;
	LONG	 id;

	while (cxm = (CxMsg *) GetMsg (CxPort))
	{
		type = CxMsgType (cxm);
		id = CxMsgID (cxm);

		switch (type)
		{
			case CXM_IEVENT:
				if (id == CX_POPKEY) DeIconify();
				break;

			case CXM_COMMAND:
				switch (id)
				{
					case CXCMD_DISABLE:
						ActivateCxObj (MyBroker, FALSE);
						break;

					case CXCMD_ENABLE:
						ActivateCxObj (MyBroker, TRUE);
						break;

					case CXCMD_APPEAR:
						DeIconify();
						break;

					case CXCMD_DISAPPEAR:
						CloseDownScreen();
						break;

					case CXCMD_KILL:
						Quit = TRUE;
						GuiSwitches.AskExit = FALSE;
						break;

					default:
						break;

				}	/* End Switch (id) */

			default:
				break;

		}	/* End Switch (type) */

		ReplyMsg ((struct Message *) cxm);

	}	/* End While (GetMsg()) */
}



LONG SetupCx (void)
{
	CxObj *filter, *sender;

	if (!CxPopKey[0]) return RETURN_FAIL;

	if (!(CxBase = OpenLibrary ("commodities.library", 37L)))
		return RETURN_FAIL;

	if (!(CxPort = CreateMsgPort ()))
	{
		CleanupCx();
		return ERROR_NO_FREE_STORE;
	}

	CxSig = 1 << CxPort->mp_SigBit;
	Signals |= CxSig;

	MyNewBroker.nb_Pri = CxPri;
	MyNewBroker.nb_Port = CxPort;

	if (!(MyBroker = CxBroker (&MyNewBroker, NULL)))
	{
		CleanupCx();
		return RETURN_FAIL;
	}

	/* Create PopKey Filter/Sender */

	if (filter = CxFilter (CxPopKey))
	{
		if (CxObjError (filter) & COERR_BADFILTER)
			ShowMessage (MSG_BAD_HOTKEY);

		AttachCxObj (MyBroker, filter);

		if (sender = CxSender (CxPort, CX_POPKEY))
			AttachCxObj (filter, sender);
	}

	ActivateCxObj (MyBroker, TRUE);
}



void CleanupCx (void)
{
	if (CxBase)
	{
		if (MyBroker)
			{ DeleteCxObjAll (MyBroker); MyBroker = NULL; }

		if (CxPort)
		{
			KillMsgPort (CxPort);
			CxPort = NULL;
			Signals &= ~CxSig;
			CxSig = 0;
		}

		CloseLibrary (CxBase); CxBase = NULL;
	}
}
