/*
 * test.c 1.0
 * Test program for SFPatch.h, type "smake" to compile.
 *
 * Lee Kindness
 *
 * Public Domain
 *
 */
 
#include <exec/types.h>
#include <exec/memory.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>

#include "SFPatch.h"

/* Constants */
#define port_name "SFPatch_Example"
#define DISPLAYBEEP_OFFSET -0x60 /* From pragma/LVO */

/* types */
typedef void __asm (*DBCaller)(register __a0 struct Screen *,
                               register __a6 struct Library *);

/* Prototypes */
void __asm new_DisplayBeep(register __a0 struct Screen *,
                           register __a6 struct Library *);

/* Global vars */
SetFunc *sf;
BPTR outfile;

/* main */
void main(void)
{
	struct MsgPort *port;
	
	/* init. outfile */
	outfile = Output();
	
	/* Open libraries */
	if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 36)) {
		
		/* Look for our port */
		Forbid();
		if (port = FindPort(port_name)) {
			struct MsgPort *reply_port;
			
			/* We are already active... quit */	
			FPrintf(outfile, "We are already running... signal other to quit\n");
			/* Create a reply port */
			if (reply_port = CreateMsgPort()) {
				struct Message msg;
				msg.mn_ReplyPort = reply_port;
				msg.mn_Length = sizeof(struct Message);
				
				/* Send the message */
				PutMsg(port, &msg);
				
				/* Finished with port */
				Permit();
				
				/* Wait for a reply */
				do {
					WaitPort(reply_port);
				} while (GetMsg(reply_port) == NULL);
				
				/* Clear any messages */
				Forbid();
				while (GetMsg(reply_port));
				/* Delete the reply port */
				DeleteMsgPort(reply_port);
				Permit();
			} else {
				Permit();
			}
		} else if (port = CreateMsgPort()) {
			struct Message *msg;
		
			/* Finished with port, so stop Forbid() */
			Permit();
		
			/* Setup quitting port */
			port->mp_Node.ln_Name = port_name;
			port->mp_Node.ln_Pri = -120;
		
			/* Add quitting port to public list */
			AddPort(port);
		
			/*****************/
			
			/* Alloc our SetFunc */
			if (sf = AllocVec(sizeof(SetFunc), MEMF_CLEAR)) {
				
				/* init. sf */
				sf->sf_Func = new_DisplayBeep;
				sf->sf_Library = (struct Library *)IntuitionBase;
				sf->sf_Offset = DISPLAYBEEP_OFFSET;
				sf->sf_QuitMethod = SFQ_COUNT;
				
				/* Replace the function */
				if (SFReplace(sf)) {
					ULONG sig, sret;
					BOOL finished;
					
					finished = FALSE;
					sig = 1 << port->mp_SigBit;
					FPrintf(outfile, "DisplayBeep() Patched\n");
					
					do {
						sret = Wait(SIGBREAKF_CTRL_C | sig);
						if (sret & sig) {
							/* signaled */
							FPrintf(outfile, "Signal from another process... quit\n");
							msg = GetMsg(port);
							if (msg) {
								ReplyMsg(msg);
								finished = TRUE;
							}
						}
						if (sret & SIGBREAKF_CTRL_C) {
							FPrintf(outfile, "Ctrl-C... quit\n");
							finished = TRUE;
						}
					} while (!finished);

					/* Restore function */
					SFRestore(sf);
					FPrintf(outfile, "DisplayBeep() Restored\n");
				}
				FreeVec(sf);
			}
			
			/*****************/
		
			/* Remove port from public access */
			RemPort(port);
		
			/* Clear and Delete port Forbid() */
			Forbid();
		
			/* Clear the port of messages */
			while (msg = GetMsg(port)) {
				ReplyMsg(msg);
			}
		
			/* Closedown quitting port */
			DeleteMsgPort(port);
		
			/* Clear and Delete port stop Forbid() */
			Permit();
		}
		CloseLibrary((struct Library *)IntuitionBase);
	}
}

void __saveds __asm new_DisplayBeep(register __a0 struct Screen *screen,
                                    register __a6 struct Library *lib)
{
	DBCaller oldbeep;
	
	/* increment count */
	Forbid();
	sf->sf_Count += 1;
	Permit();
	
	/* call old beep */
	oldbeep = sf->sf_OriginalFunc;
	oldbeep(screen, lib);
	
	FPrintf(outfile, "DisplayBeep() called\n");
	
	/* decrement count */
	Forbid();
	sf->sf_Count -= 1;
	Permit();
}

