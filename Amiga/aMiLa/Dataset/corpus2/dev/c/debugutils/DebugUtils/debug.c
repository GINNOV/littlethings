/*                         FILE:	debug.c
 *
 *	Project:			DeBug Utilities
 *	Version:			2.1
 *
 *
 * This file contains:
 *
 *						1.	main()
 *						2. screen_list()
 *						3. send_status()
 *
 * Created:			5/24/89
 * Author:        Mark Porter (fog)
 *
 *
 * $Revision: 1.1 $
 * $Date: 92/05/05 19:56:10 $
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
 * $Log:	debug.c,v $
 * Revision 1.1  92/05/05  19:56:10  fog
 * Initial revision
 * 
 *
 *
 *----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/


#include <stdio.h>
#include <functions.h>
#include <libraries/dosextens.h>
#include <exec/types.h>

#include "trace.h"
#include "debug.h"


/* The DB_function array contains strings corresponding to functions in	*/
/* the application which is being debugged.  If DB_Screen is db_include	*/
/* the list contains function names for which we want output.  If			*/
/* DB_Screen is db_exclude the list contains functions for which we do	*/
/* not want to see output.																*/

static char DB_Function[ DB_NUM ][ DB_BUFSIZE ];

static DB_Type DB_Screen = db_none;		/* Function screening type.		*/
static int		DB_Tos	 = -1;			/* Top-of-Stack for DB_Function.	*/
static int		DB_Level	 =  0;			/* Debug Level for output.			*/
static BOOL		DB_Check	 = FALSE;		/* DB_CHECK message received.		*/


/* DB_List is used to pass a list of pointers giving tDB access to the	*/
/* DB_Function List entries.  This allows the user to check on which		*/
/* functions are currently in the list.											*/

char  *DB_List[ DB_NUM ];

/* Version string so the AmigaDOS VERSION command will work.				*/

char	*Version = "$VER: debug version 1.1 07-May-92";


/*------------ main() ---------------
 *
 *
 * FUNCTION:	Waits for messages to be received from other tasks and then
 *					prints values.
 *
 * ARGUMENTS:	Standard command line arguments.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	This program is a stand-alone program to be used with the
 *					Trace() function to debug tasks.  It allows a task to send
 *					output to the display even though DOS is not active (ie: the
 *					task is not a "process".
 *
 *					This function will not close down on its own, it will wait
 *					until it receives a message with code = DB_QUIT.  If the
 *					program using the Trace() function does not use the DB_QUIT
 *					message I have provided an option for tDB that will close
 *					this program down properly.
 *
 */

main( argc,argv )
	int	argc;
	char *argv[];
{
	struct FileHandle *dos_fh;					/* Pointer to CON window.		*/
	struct MsgPort		*port;					/* debug MsgPort.					*/
	Debug_Msg			*msg = NULL;			/* Pointer to message sent.	*/
	FILE					*fd;						/* Debug file if necessary.	*/
	long					 count;					/* Length of string to output.*/
	long					 clock;					/* Time stamp variable.			*/
	BOOL					 send		 = FALSE;	/* Send output to window?		*/
	BOOL					 write    = FALSE;	/* Write output to file?		*/
	BOOL					 serial   = FALSE;	/* Write to serial port?		*/
	BOOL					 parallel = FALSE;	/* Write to parallel port?		*/

	extern char			*ctime();				/* Functions used to generate	*/
	extern long			 time();					/* time stamp on output.		*/

	/* First open the Console window for primary debugging output.			*/

	dos_fh = Open( "CON:0/0/480/100/DB Output:  v1.1",MODE_NEWFILE );

	/* If there was a command line argument, set debug level to it.		*/

	DB_Level = ( argc < 2 )	? 0 :	atoi( argv[ 1 ] );

	/* Create a MsgPort for receiving data from Trace() or tDB.				*/

	if ( port = CreatePort( "Trace.DBPort",0L ))
	{
		Write( dos_fh,"Trace.DBPort opened successfully\n",34L );

		/* Now loop forever, receiving and processing messages.				*/

		while( TRUE )
		{
			/* If no current message, wait till one gets here, then pull	*/
			/* it from the MsgPort with GetMsg().									*/

			if (( msg = ( Debug_Msg * )GetMsg( port )) == NULL )
			{
				WaitPort( port );
				msg = ( Debug_Msg * )GetMsg( port );
			}

			if ( msg->DB_code == DB_QUIT )		/* Someone is telling us	*/
			{												/* to close down, so...		*/
				ReplyMsg( msg );						/* reply to sender...		*/
				break;									/* and exit forever loop.	*/
			}

			send = FALSE;		/* Disable output till we know what type of	*/
									/* message has been sent.							*/

			switch( msg->DB_code )
			{
				/* Message codes are fairly self-explanatory.  See other		*/
				/* documentation for complete description.						*/

				case DB_WRITE:		if (( fd = fopen( msg->DB_file,"a" )) == NULL )
											Write( dos_fh,"File open failed\n",18L );
										else
										{
											write = TRUE;
											clock = time( NULL );
											fprintf( fd,"\n\n\n%s\n",ctime( &clock ));
										}
										break;

				case DB_ENDWRITE:	if ( write == TRUE )
										{
											fclose( fd );
											write = FALSE;
										}
										break;

				case DB_SER:		serial = TRUE;
										clock  = time( NULL );
										kprintf( "\n\n\n%s\n",ctime( &clock ));

										break;

				case DB_PAR:		parallel = TRUE;
										clock		= time( NULL );
										dprintf( "\n\n\n%s\n",ctime( &clock ));

										break;

				case DB_TOGGLE:	if ( DB_Screen == db_include )
											DB_Screen = db_exclude;
										else if ( DB_Screen == db_exclude )
											DB_Screen = db_include;
										break;

				case DB_LEVEL:		DB_Level	 = msg->DB_level;			break;
				case DB_ENDPAR:	parallel  = FALSE;					break;
				case DB_ENDSER:	serial	 = FALSE;					break;
				case DB_CHECK:		DB_Check	 = TRUE;						break;

				case DB_ADDFUNC:	add_functions( msg );				break;
				case DB_REMFUNC:	rem_functions( msg );				break;
				case DB_CLEAR:		clear_functions();					break;

				/* DB_CONTINUE value is really the one which will have been	*/
				/* sent from the program being debugged.  All previous are	*/
				/* from tDB for adjusting debug internal parameters.  In		*/
				/* this case we allow output to be generated after having	*/
				/* looked at the DB_Function List, DB_Level, and DB_Screen.	*/
				/* All that code is handled within screen_list() below.		*/

				case DB_CONTINUE:	send = screen_list( msg );			break;

				/* The default value is an error.  In this case change the	*/
				/* DB_code value to inform the sender.								*/

				default:				msg->DB_code = DB_UNKNOWN;			break;
			}

			if ( send == TRUE )
			{
				/* If we have determined that output should be sent, then	*/
				/* we write to each of the devices indicated by the BOOL		*/
				/* variables.																*/

				count = ( long )strlen( msg->DB_function );
				Write( dos_fh,msg->DB_function,count );
				Write( dos_fh,": ",2L );
				Write( dos_fh,msg->DB_string,msg->DB_count );

				if ( write == TRUE )
					fprintf( fd,"%s: %s",msg->DB_function,msg->DB_string );

				if ( serial == TRUE )
					kprintf( "%s: %s",msg->DB_function,msg->DB_string );

				if ( parallel == TRUE )
					dprintf( "%s: %s",msg->DB_function,msg->DB_string );
			}

			ReplyMsg( msg );				/* Reply to sender.						*/
			send_status( port );			/* Send status info if necessary.	*/
		}

		/* When we exit the loop, first make sure all messages have been	*/
		/* removed from the MsgPort.  If this is not done, we guarantee	*/
		/* a system crash very quickly.  Cleanup is done within Forbid()	*/
		/* Permit() calls to prevent other message from arriving while		*/
		/* shutdown is occuring.														*/

		Forbid();
		{
			while( msg = ( Debug_Msg * )GetMsg( port ))
				ReplyMsg( msg );

			DeletePort( port );
		}
		Permit();

		/* Write info in Console window, delay so user can read it, and	*/
		/* then close the window.														*/

		Write( dos_fh,"Trace DeBugging Ending!\n",25L );
		Delay( 50L );
		Close( dos_fh );

		if ( write == TRUE )	fclose( fd );	/* Close file if necessary.	*/
	}
	else
		fprintf( stderr,"  *** debug Error *** Could not open Trace.DBPort\n" );
}



/*------------ add_functions() ------------
 *
 *
 * FUNCTION:	Adds functions to screening function list.
 *
 * ARGUMENTS:	1.	msg:	Debug_Msg received.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	DB_function will have been set up by tDB to be an array
 *					of pointers to character strings which we wish to enter
 *					into the DB_Function list.
 *
 */

void add_functions( msg )
	Debug_Msg *msg;
{
	char **str;
	int	 i;

	str = ( char ** )msg->DB_function;

	for ( i = 0; str[ i ]; i++ )
	{
		/* If the user attempts to add more functions to the DB_Function 	*/
		/* list than there are spaces for, an error has resulted.  The		*/
		/* user is informed through the DB_OVERFLOW code returned with		*/
		/* the replied message.															*/

		if ( DB_Tos >= ( DB_NUM - 1 ))
		{
			msg->DB_code = DB_OVERFLOW;
			break;
		}

		strcpy( &DB_Function[ ++DB_Tos ][ 0 ],str[ i ] );
	}

	if ( DB_Screen == db_none )	DB_Screen = db_include;
}



/*------------ rem_functions() ------------
 *
 *
 * FUNCTION:	Removes functions to screening function list.
 *
 * ARGUMENTS:	1.	msg:	Debug_Msg received.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	DB_function will have been set up by tDB to be an array
 *					of pointers to character strings which we wish to remove
 *					from the DB_Function list.
 *
 */

void rem_functions( msg )
	Debug_Msg *msg;
{
	char **str;
	int	 i,j,k,last;

	str = ( char ** )msg->DB_function;

	for ( i = 0; str[ i ]; i++ )		/* Loop through the pointer array.	*/
	{
		for ( j = last = DB_Tos; j >= 0; j-- )		/* Loop through list.	*/
		{
			if ( !strcmp( &DB_Function[ j ][ 0 ],str[ i ] ))
			{
				/* If we find a match, we want to remove this function.		*/
				/* If the entry is the last in the list, clear all bytes		*/
				/* within that DB_Function List entry.								*/

				if ( j == last )
				{
					for ( k = 0; k < DB_BUFSIZE; k++ )
						DB_Function[ j ][ k ] = '\0';

					DB_List[ j ] = NULL;
				}

				/* Otherwise copy the last entry in DB_Function List to the	*/
				/* entry we wish to remove.											*/

				else
				{
					strcpy( &DB_Function[ j ][ 0 ],&DB_Function[ last ][ 0 ] );
					DB_List[ last ] = NULL;
				}

				str[ i ] = NULL;	/* Remove function pointer in list.			*/
				last--;				/* Decrement last for removed entry.		*/
				DB_Tos--;			/* The same for the current poition.		*/
			}
		}
	}
	/* If the entire DB_Function list has been cleared, reset DB_Screen.	*/

	if ( DB_Tos == -1 )		DB_Screen = db_none;

	/* Now loop through all str[ i ] pointers.  If any of them are not	*/
	/* NULL, then it means that a function the user wished to remove		*/
	/* from the DB_Function List was not there to begin with.  In this	*/
	/* case we send the DB_UNMATCH code back to let tDB know that an		*/
	/* error has occured.																*/

	last = i;								/* Last element in original list is	*/
												/* now given by i after above loop.	*/
	for ( i = 0; i < last; i++ )
	{
		if ( str[ i ] != NULL )
		{
			msg->DB_code = DB_UNMATCH;
			break;
		}
	}
}



/*------------ clear_functions() ------------
 *
 *
 * FUNCTION:	Clears screening function list.
 *
 * ARGUMENTS:	None.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	This just loops through all bytes of DB_Function List and
 *					sets them to zero.
 *
 */

void clear_functions()
{
	int	 i,j;

	for ( i = 0; i < DB_NUM; i++ )
	{
		for ( j = 0; j < DB_BUFSIZE; j++ )
		{
			DB_Function[ i ][ j ] = '\0';
		}

		DB_List[ i ] = NULL;
	}
	DB_Tos	 = -1;
	DB_Screen = db_none;
}



/*------------ screen_list() ------------
 *
 *
 * FUNCTION:	Looks through DB_Function list to determine if output
 *					from a particular function should be enabled or disabled.
 *
 * ARGUMENTS:	1.	msg:	Pointer to Debug_Msg received.
 *
 * RETURNS:		TRUE or FALSE value determining enabled output.
 *
 * COMMENTS:	
 *
 */

BOOL screen_list( msg )
	Debug_Msg *msg;
{
	BOOL send = FALSE;
	int  i;

	/* If the functions within DB_Function List are to generate debug		*/
	/* output data, then return TRUE only if we find a match.				*/

	if ( DB_Screen == db_include )
	{
		send = FALSE;

		for( i = 0; i <= DB_Tos; i++ )
		{
			if ( !strcmp( &DB_Function[ i ][ 0 ],msg->DB_function ))
			{
				if ( msg->DB_level >= DB_Level )			send = TRUE;

				break;
			}
		}
	}

	/* If functions within DB_Function List are not to generate debug		*/
	/* output data, then return TRUE only if we do not find a match.		*/

	else if ( DB_Screen == db_exclude )
	{
		send = ( msg->DB_level >= DB_Level ) ? TRUE : FALSE;

		for( i = 0; i <= DB_Tos; i++ )
		{
			if ( !strcmp( &DB_Function[ i ][ 0 ],msg->DB_function ))
			{
				send = FALSE;
				break;
			}
		}
	}

	/* Otherwise there is no specification for allowing output specific	*/
	/* to function names.  In this case we allow debug output only if		*/
	/* the debug level is < the debug level given by the message.			*/

	else if ( msg->DB_level >= DB_Level )
		send = TRUE;

	return( send );
}



/*------------ send_status() ------------
 *
 *
 * FUNCTION:	Replies to tDB if a DB_CHECK message was received.
 *
 * ARGUMENTS:	1.	port:	Debug reply port.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	This function is invoked whenever tDB has sent a DB_CHECK
 *					message to debug to ask for its internal parameters.  In
 *					this case we initialize the DB_List array to point to
 *					entries in the DB_Function List, and send a message to
 *					tDB with the information.  At this point tDB should be
 *					waiting to receive the message.
 *
 */

void send_status( port )
	struct MsgPort *port;
{
	struct MsgPort *send_port;
	Debug_Msg		 chk;
	int				 i;

	if ( DB_Check && ( send_port = FindPort( "Trace.DBReplyPort" )))
	{
		for ( i = 0; i <= DB_Tos; i++ )
			DB_List[ i ] = &DB_Function[ i ][ 0 ];

		DB_List[ i ] = NULL;

		chk.DB_msg.mn_Node.ln_Type = ( UBYTE )NT_MESSAGE;
	  	chk.DB_msg.mn_Node.ln_Pri  = ( BYTE )0;
	   chk.DB_msg.mn_Node.ln_Name = NULL;
		chk.DB_msg.mn_ReplyPort    = port;
	   chk.DB_msg.mn_Length       = ( UWORD )sizeof( Debug_Msg );
		chk.DB_code						= DB_Screen;
		chk.DB_function				= ( char * )&DB_List[ 0 ];
		chk.DB_level					= DB_Level;

		PutMsg( send_port,&chk );
		WaitPort( port );
		GetMsg( port );

		DB_Check = FALSE;
	}
}
