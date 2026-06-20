#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/types.h>
#include <exec/interrupts.h>
#include <devices/input.h>
#include <intuition/intuition.h>
#include <proto/all.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>


#include "headers/global.h"
#include "headers/deamon.h"
#include "headers/talkto_proto.h"
#include "headers/login.h"
#include "headers/error_proto.h"

#define MAXPOS	100
#define MAXDISP	22
#define BS	'\b'
#define CR	0xa
#define NL	0xd

static const char __Version[]=LOGINVERST;

extern void 	ButtonSwap(void);
void		INITKillButtons(void);
void		KillButtons(void);
void		FINALRestoreButtons(void);
void		RestoreButtons(void);

struct IOStdReq		*inputReqBlk;
struct MsgPort		*inputPort;
struct Interrupt	*inputHandler;
UBYTE			device;

void KillButtons() 
{
	inputHandler->is_Code = ButtonSwap;
	inputHandler->is_Data=NULL;
	inputHandler->is_Node.ln_Pri=100;
	inputHandler->is_Node.ln_Name=LOGINVER;
	inputReqBlk->io_Data=(APTR)inputHandler;
	inputReqBlk->io_Command=IND_ADDHANDLER;
	DoIO((struct IORequest *)inputReqBlk);
	
}

void INITKillButtons() 
{
	if (inputPort = CreatePort(NULL,NULL)) {
		if (inputHandler=AllocMem(sizeof(struct Interrupt),MEMF_PUBLIC+MEMF_CLEAR)){
			if (inputReqBlk=(struct IOStdReq *)CreateExtIO(inputPort,sizeof(struct IOStdReq))) {
				if (!(device = OpenDevice("input.device",NULL,(struct IORequest *)inputReqBlk,NULL))) {
					inputHandler->is_Code = ButtonSwap;
					inputHandler->is_Data=NULL;
					inputHandler->is_Node.ln_Pri=100;
					inputHandler->is_Node.ln_Name=LOGINVER;
					inputReqBlk->io_Data=(APTR)inputHandler;
					inputReqBlk->io_Command=IND_ADDHANDLER;
					DoIO((struct IORequest *)inputReqBlk);
				}
				else {
					Error("Could not open input.device");
					DeleteExtIO((struct IORequest *)inputReqBlk);
					exit(10);
				}
			}
			else {
				Error("Could not create IORequest");
				FreeMem(inputHandler,sizeof(struct Interrupt));
				exit(10);
			}
		}
		else {
			Error("could not allocate interrupt struct Memory");
			DeletePort(inputPort);	
			exit(10);
		}
		
	}
	else {
		Error("could not create message port");
		exit (10);
	}
}

void RestoreButtons()
{
	inputReqBlk->io_Data=(APTR)inputHandler;
	inputReqBlk->io_Command=IND_REMHANDLER;
	DoIO((struct IORequest *)inputReqBlk);
}

void FINALRestoreButtons()
{
	inputReqBlk->io_Data=(APTR)inputHandler;
	inputReqBlk->io_Command=IND_REMHANDLER;
	DoIO((struct IORequest *)inputReqBlk);
	DeleteExtIO((struct IORequest*)inputReqBlk);
	FreeMem(inputHandler,sizeof(struct Interrupt));
	DeletePort(inputPort);
}

#if (DEBUG)
	void main()
#else 
	void __main(argv) 
	char	*argv;
#endif
{
	char			Pass[MAXPOS+1];
	char			DispPass[MAXDISP+1]="                      ";
	char			PPos=0,PPDisp=0;
	unsigned long		Status=-1;
	struct IntuitionBase 	*IntuiBase;
	struct Window		*window=NULL;
	void*			address;
	ULONG			class;
	USHORT			key1,key2;
	struct IntuiMessage *	my_message;
	BOOL			accept = FALSE;
	BOOL			PassWord=FALSE;

	if (!(IntuiBase = (struct IntuitionBase *)OpenLibrary("intuition.library",NULL))) {
		Error("Cannot Open Intuition.library");
		exit(10);
	}
	
	if (!(window = OpenWindow(&NewWindowStructure1))) {
		Error("cannot Open the Window");
		exit(15);
	}

	INITKillButtons();

	Gadget2.GadgetText->IText = DispPass;

	do {
		SetWindowTitles(window,NULL,LOGINVER);
		PrintIText(window->RPort,&IntuiTextList1,0,0);

		ActivateGadget(&Gadget1,window,NULL);
		Gadget1.Flags |= SELECTED;
		RefreshGadgets(&Gadget1,window,NULL);

		while (!accept) {
			Wait(1<<window->UserPort->mp_SigBit);
	    		while (my_message = (struct IntuiMessage *) GetMsg(window->UserPort )) {
	      			class = my_message->Class;      /* Save the IDCMP flag. */
	      			address = my_message->IAddress; /* Save the address. */
	  
				key1 = my_message->Code;
				my_message->Code = 0;
				key2 = my_message->Qualifier;
				my_message->Qualifier = 0;
	      			ReplyMsg((struct Message*) my_message );
				
				if (class==IDCMP_GADGETUP) {
					if (address == &Gadget2) {
						PassWord = !PassWord;
						Gadget1.Flags &= ~SELECTED;
						RefreshGadgets(&Gadget1,window,NULL);
					}
					else if (address == &Gadget1) {
						PassWord = TRUE;
						Gadget2.Flags |= SELECTED;
						Gadget1.Flags &= ~SELECTED;
						RefreshGadgets(&Gadget1,window,NULL);
					}
				}
				else if (class == IDCMP_GADGETDOWN) {
					if (address == &Gadget1) {
						Gadget1.Flags |= SELECTED;
						Gadget2.Flags &= ~SELECTED;
						RefreshGadgets(&Gadget1,window,NULL);
						PassWord = FALSE;
					}
				}
				else if (class == IDCMP_RAWKEY || class == IDCMP_VANILLAKEY) {
					if (class == IDCMP_RAWKEY) {
						break;
					}
					if (PassWord) {
						if ((key1 == CR)||(key1 == NL)) {
							accept = TRUE;
						}
						if (isprint(key1)) {
							if (PPos < MAXPOS) {
								Pass[PPos++] = key1;
								Pass[PPos] = NULL;
								if (PPDisp < MAXDISP) {
									DispPass[PPDisp++] = '*';
									DispPass[PPDisp] = NULL;
								}
							}
							else DisplayBeep(NULL);
						}
						if (key1 == BS) {
							if (PPos > 0) {
								Pass[--PPos] = NULL;
								if (PPDisp > PPos) {
									DispPass[--PPDisp] = NULL;
								}
							}
							else DisplayBeep(NULL);
						}
						RefreshGadgets(&Gadget1,window,NULL);
					}
				}
				else if ((class == IDCMP_MOUSEBUTTONS)||(class == IDCMP_INACTIVEWINDOW)) {
					ActivateGadget(&Gadget1,window,NULL);
					Gadget1.Flags |= SELECTED;
					RefreshGadgets(&Gadget1,window,NULL);
					WindowToFront(window);
					ActivateWindow(window);
				}
			}
		}
		RestoreButtons();
		Status = TalkTo(Gadget1SIBuff,Pass,NULL ,LOGIN);
		KillButtons();
		accept = FALSE;
		if (!(Status == OK)) DisplayBeep(NULL);
	} while (!(Status == OK));
	FINALRestoreButtons();
	CloseWindow(window);
	CloseLibrary((struct Library *) IntuiBase);
}
