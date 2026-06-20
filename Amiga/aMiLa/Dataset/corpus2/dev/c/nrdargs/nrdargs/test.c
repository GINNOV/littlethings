/*
**
**	Example code for NewReadArgs and NewFreeArgs
**	© 1997-1998 by Stephan Rupprecht, all rights reserved
**
**	Make sure that your compiler opens dos.library,
**	icon.library and intuition.library on startup !!!
**	
**	This code has been developed under MaxonDEVELOP
**
**/

#include <dos/dos.h>
#include <intuition/intuition.h>

#include <pragma/dos_lib.h>
#include <pragma/exec_lib.h>
#include <pragma/intuition_lib.h>

#include <newreadargs.h>

/****************************************************************************/

struct Library *UtilityBase;

/****************************************************************************/

void ShowDosError(LONG err, STRPTR text)
{
	struct Process *ThisTask = (struct Process *)FindTask(NULL);

	/*- Use PrintFault() when started from cli, otherwise EasyRequest() -*/
	if(ThisTask && err) 
		if(ThisTask->pr_CLI) PrintFault(err, text);
  	else 
	{
   		TEXT buffer[80];
   		struct EasyStruct es = { 
			sizeof(struct EasyStruct), 0,
	        	ThisTask->pr_Task.tc_Node.ln_Name,
            		"%s", "Okay" };

   		Fault(err, text, buffer, sizeof(buffer));

   		EasyRequest(NULL, &es, NULL, buffer);
  	}
}

/****************************************************************************/

void main(int argc, APTR argv)
{
 	struct NewRDArgs	nrda = {}; // empty structure 
	struct 	{	STRPTR	*multi;
				LONG	 _switch;
				LONG	 toggle;
			} args = { 0L, DOSFALSE, DOSFALSE };
	LONG	err;

	if(!(UtilityBase = OpenLibrary("utility.library", 0L)))
		return;

	/*- setup structure -*/
	nrda.Template	= "MULTI/M,SWITCH/S,TOGGLE/T";
	nrda.ExtHelp		= "This is an ExtHelp string!";
	nrda.Window		= "CON:////NewReadArgs - example code";
	nrda.Parameters 	= (LONG *)&args;
	nrda.FileParameter  = 0L; // we take them all
	nrda.PrgToolTypesOnly = FALSE; // parse all icons 

	if(err = NewReadArgs((struct WBStartup *)(!argc  && argv) ? argv : 0L, &nrda))
	{
		ShowDosError(err, "NewReadArgs");	
	} 
	else
	{		
		if(args.multi)
		{
			STRPTR *ptr = args.multi;
				
			Printf("MULTI\n");
			while(*ptr) Printf(" %s\n", *ptr++);
		}

		Printf("SWITCH : %s\nTOGGLE : %s\n", args._switch ? "TRUE" : "FALSE",
			args.toggle ? "YES" : "NO");

		if(!argc  && argv) 
		{
			Printf("\nPress <RETURN>");
			FGetC(Input());
		}
	}

	// NOTE: only call this function if you have used NewReadArgs before!
	// If you use an empty structure, then you can forget this note !-)
	NewFreeArgs(&nrda);

	CloseLibrary(UtilityBase);
}

/****************************************************************************/

void wbmain(struct WBStartup *wbmsg)
{
	main(0L, (APTR)wbmsg);
}

/****************************************************************************/
