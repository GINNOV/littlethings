;/* execute me to compile
gcc -o ARexxExample ARexxExample.c -lauto -lraauto
quit
*/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Gadget IDs. */
#define GAD_QUIT 1

/* ARexx command IDs. */
enum
{ 
	REXX_NAME, 
	REXX_VERSION, 
	REXX_AUTHOR, 
	REXX_SEND, 
	REXX_DATE 
};


/* Protos for the reply hook and ARexx command functions. */
STATIC VOID reply_callback(struct Hook *, Object *, struct RexxMsg *);
STATIC VOID rexx_Name (struct ARexxCmd *, struct RexxMsg *);
STATIC VOID rexx_Version(struct ARexxCmd *, struct RexxMsg *);
STATIC VOID rexx_Author (struct ARexxCmd *, struct RexxMsg *);
STATIC VOID rexx_Send (struct ARexxCmd *, struct RexxMsg *);
STATIC VOID rexx_Date (struct ARexxCmd *, struct RexxMsg *);

/* Buffer for the system date.*/
STATIC UBYTE systemDate[32];

/* Our reply hook function. */
STATIC struct Hook reply_hook;

/* The following commands are valid for this demo. */
STATIC CONST struct ARexxCmd Commands[] =
{
	{ "NAME", 		REXX_NAME, 		rexx_Name, 	NULL, 		0, 	NULL, 	0, 	0, 	NULL },
	{ "VERSION", 	REXX_VERSION, 	rexx_Version, 	NULL, 		0, 	NULL, 	0, 	0, 	NULL },
	{ "AUTHOR", 	REXX_AUTHOR, 		rexx_Author, 	NULL, 		0, 	NULL, 	0, 	0, 	NULL },
	{ "SEND", 		REXX_SEND, 		rexx_Send, 	"TEXT/F", 		0, 	NULL, 	0, 	0, 	NULL },
	{ "DATE", 		REXX_DATE, 		rexx_Date, 	"SYSTEM/S", 	0, 	NULL, 	0, 	0, 	NULL },
	{ NULL, 		0, 				NULL, 		NULL, 		0, 	NULL, 	0, 	0, 	NULL }
};


/* Starting point. */
int main(void)
{
	Object *arexx_obj;

	if (!ButtonBase)
		return RETURN_FAIL;

	/* Create host object. */
	arexx_obj = ARexxObject,
		AREXX_HostName, "AREXXDEMO",
		AREXX_Commands, Commands,
		AREXX_NoSlot, TRUE,
		AREXX_ReplyHook, &reply_hook,
	End;

	if (arexx_obj)
	{
		Object *win_obj;

		/* Create the window object. */
		win_obj = WindowObject,
			WA_Title, "ReAction arexx.class Demo",
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_DepthGadget, TRUE,
			WINDOW_ParentGroup, LayoutObject,
			LAYOUT_AddChild, ButtonObject,
				GA_Text, "_Quit",
				GA_ID, GAD_QUIT,
				GA_RelVerify, TRUE,
			ButtonEnd,
		LayoutEnd,
		EndWindow;

		if (win_obj)
		{
			struct Window *window;

			/* try to open the window. */
			window = (struct Window *)RA_OpenWindow(win_obj);

			if (window)
			{
				ULONG wnsig = 0, rxsig = 0, signal, result, Code;
				BOOL running = TRUE;

				/* Setup the reply callback hook. */
				reply_hook.h_Entry = (HOOKFUNC)reply_callback;
				reply_hook.h_SubEntry = NULL;
				reply_hook.h_Data = NULL;

				/* Try to start the macro "Demo.rexx". Note that the
				* current directory and REXX: will be searched for this
				* macro. Our reply hook will get the results of our
				* efforts to start this macro. To be totally robust, we
				* should have also passed pointers for the various result
				* variables.
				*/
				IIntuition->IDoMethod(arexx_obj, AM_EXECUTE, "Demo.rexx", NULL, NULL, NULL, NULL, NULL);

				/* Obtain wait masks. */
				IIntuition->GetAttr(WINDOW_SigMask, win_obj, &wnsig);
				IIntuition->GetAttr(AREXX_SigMask, arexx_obj, &rxsig);

				/* Event loop... */
				do
				{
					signal = IExec->Wait(wnsig | rxsig | SIGBREAKF_CTRL_C);

					/* ARexx event? */
					if (signal & rxsig)
						RA_HandleRexx(arexx_obj);

					/* Window event? */
					if (signal & wnsig)
					{
						while ((result = RA_HandleInput(win_obj, &Code)) != WMHI_LASTMSG)
						{
							switch (result & WMHI_CLASSMASK)
							{
								case WMHI_CLOSEWINDOW:
									running = FALSE;
									break;

								case WMHI_GADGETUP:
									switch(result & WMHI_GADGETMASK)
									{
										case GAD_QUIT:
											running = FALSE;
											break;
									}
									break;

								default:
									break;
								}
							}
						}

					if (signal & SIGBREAKF_CTRL_C)
					{
						running = FALSE;
					}
				}
				while (running);
			}
			else
				IDOS->Printf ("Could not open the window.\n");

			IIntuition->DisposeObject(win_obj);
		}
		else
			IDOS->Printf("Could not create the window object.\n");

		IIntuition->DisposeObject(arexx_obj);
	}
	else
		IDOS->Printf("Could not create the ARexx host.\n");

	return RETURN_OK;
}

/* This function gets called whenever we get an ARexx reply. In this example,
* we will see a reply come back from the REXX server when it has finished
* attempting to start the Demo.rexx macro.
*/
STATIC VOID reply_callback(struct Hook *hook __attribute__((unused)), Object *o __attribute__((unused)), struct RexxMsg *rxm)
{
	IDOS->Printf("Args[0]: %s\nResult1: %ld Result2: %ld\n",
	rxm->rm_Args[0], rxm->rm_Result1, rxm->rm_Result2);
}

/* NAME */
STATIC VOID rexx_Name( struct ARexxCmd *ac, struct RexxMsg *rxm __attribute__((unused)))
{
	/* return the program name. */
	ac->ac_Result = "ARexxTest";
}

/* VERSION */
STATIC VOID rexx_Version( struct ARexxCmd *ac, struct RexxMsg *rxm __attribute__((unused)))
{
	/* return the program version. */
	ac->ac_Result = "1.0";
}

/* AUTHOR */
STATIC VOID rexx_Author( struct ARexxCmd *ac, struct RexxMsg *rxm __attribute__((unused)))
{
	/* return the authors name. */
	ac->ac_Result = "Reaction OS4";
}

/* SEND */
STATIC VOID rexx_Send( struct ARexxCmd *ac, struct RexxMsg *rxm __attribute__((unused)))
{
	/* Print some text */
	if (ac->ac_ArgList[0])
		IDOS->Printf("%s\n", (STRPTR)ac->ac_ArgList[0]);
}

/* DATE */
STATIC VOID rexx_Date( struct ARexxCmd *ac, struct RexxMsg *rxm __attribute__((unused)))
{
	struct DateTime dt;

	/* SYSTEM switch specified? */
	if (!ac->ac_ArgList[0])
	{
		/* return the compilation date. */
		ac->ac_Result = "11-10-95";
	}
	else
	{
		/* compute system date and store in systemDate buffer */
		IDOS->DateStamp((struct DateStamp *)&dt);

		dt.dat_Format = FORMAT_USA;
		dt.dat_Flags = 0;
		dt.dat_StrDay = NULL;
		dt.dat_StrDate = systemDate;
		dt.dat_StrTime = NULL;

		IDOS->DateToStr(&dt);

		/* return system date */
		ac->ac_Result = systemDate;
	}
}

