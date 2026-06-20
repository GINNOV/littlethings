/*                         FILE:	trace.c
 *
 *	Project:			DeBug Utilities
 *	Version:			v1.1
 *
 *
 * This file contains:
 *
 *						1.	Trace()
 *						2.	write_buf()
 *
 * Created:			5/24/89
 * Author:        Mark Porter (fog)
 *
 *
 * $Revision: 1.1 $
 * $Date: 92/05/05 20:00:33 $
 * $Author: fog $
 *
 *
 *	Copyright © 1992 if...only Amiga
 *
 *	Permission is granted to distribute this program's source, executable,
 *	and documentation for non-commercial use only, provided the copyright
 *	and header information are left intact.
 *
 */


/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*
 *
 *
 * $Log:	trace.c,v $
 * Revision 1.1  92/05/05  20:00:33  fog
 * Initial revision
 * 
 *
 *
 *----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/


#include <exec/types.h>
#include <ctype.h>

#include "trace.h"
#include "debug.h"


/* Version string so the AmigaDOS VERSION command will work.				*/

char	*Version = "$VER: trace.lib version 1.1 07-May-92";

static int  DB_Count = 0;					/* Characters within DB_Buffer.	*/
static char DB_Buffer[ TDB_BUFSIZE ];	/* Formatted debug message.		*/


static int		write_buf();
static int		format();
static char	  *_fmtcvt();
static void		ftoa();




/*------------ Trace() ---------------
 *
 *
 * FUNCTION:	Sends a message to the debugging task which will then be sent
 *					to the display.
 *
 * ARGUMENTS:	1.	level:	Debug level at which we are sending message.
 *					2.	func:		Function within which Trace() was called.
 *					3.	fmt:		printf() style format string.
 *					4.	args:		Pointer to printf() style arguments.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	I have decided to create a MsgPort with each invocation of
 *					this function mainly to avoid having to write separate
 *					initialization and shutdown functions which would create
 *					and delete the MsgPort.  This allows the user to not have
 *					to worry about proper Trace() initialization.  Although
 *					the number of instructions executed by each call to Trace()
 *					increases, the major time penalty associated with this
 *					debugging technique will always be due to writing data to
 *					a window, file, serial, or parallel port, and not to the
 *					setup and shutdown code.  The final justification is that
 *					I have used this library with great success, and even if
 *					my program execution slows down somewhat, I'm so busy
 *					trying to decipher the output that a few microseconds
 *					just doesn't matter.
 *
 *					One other critical factor for the trace.lib library is that
 *					the call to format() below will only compile correctly on
 *					Manx systems.  SAS has no equivalent function and so will
 *					error out when blink is run.
 *
 *					Manx uses this function to parse calls to printf(), sprintf(),
 *					and fprintf().  I originally compiled the SAS version of
 *					the library with the source code from format() included in
 *					this file.  But since the code is copyrighted, commercial
 *					material, it had to be removed before distributing trace.lib.
 *
 *					The work-arounds for this problem if you wish to modify the
 *					source code is to write your own format(), or to purchase
 *					the commercial version of the Manx compiler, which comes
 *					with the c.lib source code.
 *
 */

void Trace( level,func,fmt,args )
	int		 level;
	char		*func,*fmt;
	unsigned	 args;
{
	struct MsgPort		*send_port,
							*reply_port;
	Debug_Msg   		 msg;

	/* Create a reply port for proper message returns.	 Even though we	*/
	/* do not do anything with the returned message, we still need to		*/
	/* wait for the reply.  Otherwise if Trace() exits before debug		*/
	/* finishes writing output, the auto variable msg will quite likely	*/
	/* get trashed on the stack...boom, boom, out go the lights.			*/

	if ( reply_port = CreatePort( "Trace.SendPort",0L ))
	{
		/* Initialize the Debug_Msg with all the nice info.					*/

		msg.DB_msg.mn_Node.ln_Type = ( UBYTE )NT_MESSAGE;
		msg.DB_msg.mn_Node.ln_Pri  = ( BYTE )0;
	   msg.DB_msg.mn_Node.ln_Name = NULL;
		msg.DB_msg.mn_ReplyPort    = reply_port;
	   msg.DB_msg.mn_Length       = ( UWORD )sizeof( Debug_Msg );
		msg.DB_code						= DB_CONTINUE;
		msg.DB_count					= ( long )format( write_buf,fmt,&args );
		msg.DB_string					= DB_Buffer;
		msg.DB_function				= func;
		msg.DB_level					= level;

      Forbid();
		send_port = FindPort( "Trace.DBPort" );
   	Permit();

		/* The only time we will generate output is if Trace() finds the	*/
		/* debug MsgPort.  If not, we simply delete our port and return.	*/

		if ( send_port )
		{
			PutMsg( send_port,&msg );
			WaitPort( reply_port );
			GetMsg( reply_port );
		}

		DeletePort( reply_port );
		DB_Count = 0;
	}
}



/*------------ write_buf() ------------
 *
 *
 * FUNCTION:	Writes characters to DB_Buffer as they are passed in
 *					by format()
 *
 * ARGUMENTS:	1.	c:	Character to write to buffer.
 *
 * RETURNS:		Cumulative number of characters written to buffer.
 *
 * COMMENTS:	This function is passed to format() and is used by
 *					that function to write data to a buffer.
 *
 */

static int write_buf( c )
	char c;
{
	DB_Buffer[ DB_Count++ 	] = c;
	DB_Buffer[ DB_Count + 1 ] = '\0';

	return( DB_Count );
}
