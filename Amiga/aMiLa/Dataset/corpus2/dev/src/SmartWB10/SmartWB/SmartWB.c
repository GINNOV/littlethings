/*
**    SmartWB
**
**        © 1996 by Timo C. Nentwig
**        All Rights Reserved !
**
**        Tcn@techbase.in-berlin.de
**
**
**        Based on LeeKindness' <SFPatch.h>
**        SmartWB-Clone (by Grzegorz Calkowski)
**
**    TODO: · running as cdity
**
**
*/

#include    "SmartWB.h"

/// #define

#define    PRG_TITLE         "SmartWB"
#define    PRG_VERSION       "1.0"
#define    PRG_AUTHOR        "Timo C. Nentwig"
#define    PRG_SHORT         "Always WLFG_SMART_REFRESH"
#define    PRG_YEAR          "1996"
#define    PRG_EMAIL         "Tcn@techbase.in-berlin.de"
#define    PORTNAME          PRG_TITLE " Port"
#define    FUNC_OFFSET       -0x25e              // OpenWindowTagList(), from: pragmas/

#define    CloseLib(x)       CloseLibrary ((struct Library *) x)
#define    AllocStruct(x)    AllocVec (sizeof (struct x), MEMF_CLEAR | MEMF_PUBLIC)
#define    FreeStruct(x)     FreeVec (x)

///

STATIC BYTE    __ver[] = "$VER: " PRG_TITLE " " PRG_VERSION " " __AMIGADATE__;

	// Types

typedef struct Window * __asm (*FuncCall)(REG (a0) struct NewWindow *, REG (a1) struct TagItem *);

	// Prototypes

STATIC struct Window * __saveds __asm    NewOpenWindowTagList   (REG (a0) struct NewWindow *newWindow, REG (a1) struct TagItem *tagList);
STATIC BOOL                              EvalArgs              (VOID);


	// GLOBAL variables

struct    IntuitionBase  *IntuitionBase;
SetFunc                  *SF;
BOOL                      Quiet = FALSE;

/// main()

LONG
main (VOID)
{

	struct    MsgPort   *Port;
	LONG                 Result = RETURN_OK;

		// Open libraries

	if (DOSBase = (struct DosLibrary *) OpenLibrary (DOSNAME, LIBRARY_MINIMUM))
	{

		if (IntuitionBase = (struct IntuitionBase *) OpenLibrary ("intuition.library", LIBRARY_MINIMUM))
		{

			if (EvalArgs())
			{

				Forbid();                              // Look for our port

				if (Port = FindPort (PORTNAME))
				{

					struct    MsgPort   *Reply_Port;

						// We are already active... quit

					if ( ! (Quiet))
						FPrintf (Output(), PRG_TITLE": Already running ... quit\n");

						// Create a reply port

					if (Reply_Port = CreateMsgPort())
					{

						struct    Message    Msg;

						Msg . mn_ReplyPort = Reply_Port;
						Msg . mn_Length    = sizeof(struct Message);


						PutMsg (Port, &Msg);                           // Send the message
						Permit();                                      // Finished with port

							// Wait for a reply
						do
						{

							WaitPort (Reply_Port);

						} while ( ! (GetMsg (Reply_Port)));

						Forbid();                                      // Clear any messages

						while (GetMsg (Reply_Port));

							// Delete the reply port

						DeleteMsgPort (Reply_Port);
						Permit();

					}
					else
					{

						Permit();

					}

				}
				else if (Port = CreateMsgPort())
				{

					struct    Message   *Msg;

					Permit();                                          // Finished with port, so stop Forbid()

						// Setup quitting port

					Port -> mp_Node . ln_Name = PORTNAME;
					Port -> mp_Node . ln_Pri  = -120;

					AddPort (Port);                                    // Add quitting port to public list

						// Alloc our SetFunc

					if (SF = AllocStruct (SetFunc))
					{

						SF -> sf_Func       = NewOpenWindowTagList;
						SF -> sf_Library    = (struct Library *) IntuitionBase;
						SF -> sf_Offset     = FUNC_OFFSET;
						SF -> sf_QuitMethod = SFQ_COUNT;

							// Replace the function

						if (SFReplace (SF))
						{

							ULONG    sig, sret;
							BOOL     finished;

							finished = FALSE;
							sig      = 1 << Port -> mp_SigBit;

							if ( ! (Quiet))
								FPrintf (Output(), PRG_TITLE": Patch installed !\n");

							do
							{

								sret = Wait (SIGBREAKF_CTRL_C | sig);

								if (sret & sig)
								{

										// Signaled

									if ( ! (Quiet))
										FPrintf (Output(), PRG_TITLE": Signal from another process ... quit\n");

									Msg = GetMsg (Port);

									if (Msg)
									{

										ReplyMsg (Msg);
										finished = TRUE;

									}

								}

								if (sret & SIGBREAKF_CTRL_C)
								{

									if ( ! (Quiet))
										FPrintf (Output(), PRG_TITLE": ^C ... quit\n");

									finished = TRUE;

								}

							} while ( ! (finished));

								// Restore function

							SFRestore (SF);

							if ( ! (Quiet))
								FPrintf   (Output(), PRG_TITLE": Patch removed !\n");

						}

						FreeVec (SF);

					}


					RemPort (Port);                            // Remove port from public access
					Forbid();                                  // Clear and Delete port Forbid()

						// Clear the port of messages

					while (Msg = GetMsg (Port))
						ReplyMsg (Msg);


					DeleteMsgPort (Port);                      // Closedown quitting port
					Permit();                                  // Clear and Delete port stop Forbid()

				}
				else
				{

					Result = RETURN_ERROR;

				}

			}
			else
			{

				Result = IoErr();
				PrintFault (Result, PRG_TITLE);

			}

			CloseLib (IntuitionBase);

		}
		else
		{

			Result = RETURN_ERROR;

		}

		CloseLib (DOSBase);

	}
	else
	{

		Result = RETURN_ERROR;

	}

	exit (Result);

}

///
/// NewOpenWindowTagList ()

	/*
	 *    FUNCTION    Replacement for OpenWindowTagList(),
	 *                drawing a 3D frame inside the window.
	 *
	 *    NOTE
	 *
	 *    EXAMPLE     NewOpenWindowTagList (newWindow, taglist);
	 *
	 */


STATIC struct Window * __saveds __asm
NewOpenWindowTagList (REG (a0) struct NewWindow *newWindow, REG (a1) struct TagItem *tagList)
{

	FuncCall    OldOpenWindowTagList;
	struct      Window   *win;

		// Increment count

	Forbid();
	SF -> sf_Count += 1;
	Permit();

		// Open the (new) window

	OldOpenWindowTagList = SF -> sf_OriginalFunc;

	newWindow -> Flags &= ~WFLG_SIMPLE_REFRESH;        // remove simple refresh bit
	newWindow -> Flags |=  WFLG_SMART_REFRESH;         // set smart refresh's bit

	if ( ! (win = OldOpenWindowTagList (newWindow, tagList)))
		Signal (FindTask (NULL), SIGBREAKF_CTRL_C);    // Failed, signal program to quit

		// decrement count

	Forbid();
	SF -> sf_Count -= 1;
	Permit();

	return (win);

}

///
/// EvalArgs ()

	/*
	 *    FUNCTION    Evaluate given shell arguments
	 *
	 *    NOTE
	 *
	 *    EXAMPLE     EvalArgs ();
	 *
	 */


STATIC BOOL
EvalArgs (VOID)
{

	#define    ARG_TEMPLATE    "QUIET/S"

	enum
	{

		ARG_QUIET,
		ARG_COUNT

	};

	STRPTR   *ArgArray;
	BOOL      result = FALSE;

	if (ArgArray = (STRPTR *) AllocVec (sizeof (STRPTR) * (ARG_COUNT), MEMF_ANY | MEMF_CLEAR))
	{

		struct    RDArgs   *ArgsPtr;

		if (ArgsPtr = (struct RDArgs *) AllocDosObject (DOS_RDARGS, TAG_END))
		{

			ArgsPtr -> RDA_ExtHelp = "[2m" PRG_TITLE " " PRG_VERSION " - " PRG_SHORT "\n"
									 "Copyright © " PRG_YEAR " by " PRG_AUTHOR "[0m\n"
									 "All Rights Reserved !\n"
									 "\n" PRG_EMAIL "\n";

			if (ReadArgs (ARG_TEMPLATE, (LONG *) ArgArray, ArgsPtr))
			{

				if (ArgArray [ARG_QUIET])    Quiet = TRUE;

				result = TRUE;

				FreeArgs (ArgsPtr);

			}

			FreeDosObject (DOS_RDARGS, ArgsPtr);

		}

		FreeVec (ArgArray);

	}

	return (result);

}

///

