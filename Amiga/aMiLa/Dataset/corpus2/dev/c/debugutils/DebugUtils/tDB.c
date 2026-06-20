/*                         FILE:	tDB.c
 *
 *	Project:			DeBug Utilities
 *	Version:			v1.1
 *
 *
 * This file contains:
 *
 *						1.	main()
 *
 * Created:			5/24/89
 * Author:        Mark Porter (fog)
 *
 *
 * $Revision: 1.1 $
 * $Date: 92/05/05 19:59:42 $
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
 * $Log:	tDB.c,v $
 * Revision 1.1  92/05/05  19:59:42  fog
 * Initial revision
 * 
 *
 *
 *----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/


#include <stdio.h>
#include <libraries/dosextens.h>

#include "trace.h"


/* DB_List is an array of pointers used to communicate with debug to		*/
/* add or delete functions from the DB_Function List.							*/

char	*DB_List[ DB_NUM ];


/* Version string so the AmigaDOS VERSION command will work.				*/

char	*Version = "$VER: tDB version 1.1 07-May-92";



/*------------ main() ---------------
 *
 *
 * FUNCTION:	Allows user to change debugging parameters utilized with
 *					the trace.lib/debug utility.
 *
 * ARGUMENTS:	1.	argc:	Argument count for main().
 *					2.	argv:	Pointers to command line arguments.
 *
 * RETURNS:		Nothing.
 *
 * COMMENTS:	
 *
 */

main( argc,argv )
	int   argc;
	char *argv[];
{
	struct MsgPort	*send_port,				/* Pointer to debug MsgPort.		*/
						*reply_port;			/* Pointer to tDB MsgPort.			*/
	char			  **str;						/* Pointer used to pass DB_List.	*/
	Debug_Msg	 	 msg,*chk;				/* Messages sent and received.	*/
	int				 i;						/* The old loop counter.			*/

	/* Output program information.  Escape sequence set/reset bold.		*/

	printf( "\n   [1mif Software   tDB[0m  v1.1  Thursday 07-May-92 22:42:41\n\n" );

	/* If there are no other arguments passed on the command line, then	*/
	/* tDB assumes the user wants to check status of debug internal par-	*/
	/* ameters.  This is done by setting DB_CHECK code.						*/

	if ( argc < 2 )
		msg.DB_code = DB_CHECK;
	else											/* Otherwise parse command line.	*/
	{
		/* Check for addition or deletion of functions from DB_Function.	*/
		/* Set DB_code according to which option is chosen.					*/

		if ( !strcmp( argv[ 1 ],"-a" ) || !strcmp( argv[ 1 ],"-r" ))
		{
			if ( !strcmp( argv[ 1 ],"-a" ))		msg.DB_code	= DB_ADDFUNC;
			if ( !strcmp( argv[ 1 ],"-r" ))		msg.DB_code	= DB_REMFUNC;

			/* If there are no function names beyond the given flag, set	*/
			/* DB_function pointer to NULL to terminate debug search.		*/

			if ( argc < 3 )
				msg.DB_function = NULL;
			else											/* Otherwise loop through	*/
			{												/* command line arguments	*/
				for ( i = 2; i < argc; i++ )		/* and attach them to the	*/
					DB_List[ i - 2 ] = argv[ i ];	/* DB_List pointers.			*/

				DB_List[ i ] = NULL;				/* Last item terminates list.	*/

				/* Initialize DB_function to point to the list.  debug will	*/
				/* interpret the list in the same way as user programs deal	*/
				/* with command line options passed into main().				*/

				msg.DB_function = ( char * )&DB_List[ 0 ];
			}
		}

		/* Check for debug level change.  Set DB_level to 0 if no other	*/
		/* arguments follow, otherwise convert next command line argument	*/
		/* to int and set DB_level.													*/

		else if ( !strcmp( argv[ 1 ],"-l" ))
		{
			msg.DB_code		 = DB_LEVEL;
			if ( argc < 3 )	msg.DB_level = 0;
			else					msg.DB_level = atoi( argv[ 2 ] );
		}

		/* Check for option to print debug messages to file.  The file		*/
		/* name becomes 'DB.out' if there are no more command line arg's.	*/
		/* Otherwise set output file name to last command line argument.	*/

		else if ( !strcmp( argv[ 1 ],"-w" ))
		{
			msg.DB_code = DB_WRITE;
			if ( argc < 3 )	msg.DB_file = "DB.out";
			else					msg.DB_file = argv[ 2 ];
		}

		/* Check for remaining options and set DB_code appropriately.		*/

		else if ( !strcmp( argv[ 1 ],"-c"  ))			msg.DB_code = DB_CLEAR;
		else if ( !strcmp( argv[ 1 ],"-t"  ))			msg.DB_code = DB_TOGGLE;
		else if ( !strcmp( argv[ 1 ],"-we" ))			msg.DB_code = DB_ENDWRITE;
		else if ( !strcmp( argv[ 1 ],"-s"  ))			msg.DB_code = DB_SER;
		else if ( !strcmp( argv[ 1 ],"-se" ))			msg.DB_code = DB_ENDSER;
		else if ( !strcmp( argv[ 1 ],"-p"  ))			msg.DB_code = DB_PAR;
		else if ( !strcmp( argv[ 1 ],"-pe" ))			msg.DB_code = DB_ENDPAR;
		else if ( !strcmp( argv[ 1 ],"-e"  ))			msg.DB_code = DB_QUIT;

		else if ( !strcmp( argv[ 1 ],"?" ))		/* '?' gives information.	*/
		{
			printf( "tDB options  :\n" );
			printf( "   -e        :  End debug session.\n" );
			printf( "   -a <func> :  Add function <func> to debug function list.\n" );
			printf( "   -r <func> :  Remove function <func> to debug function list.\n" );
			printf( "   -c        :  Clear debug function list.\n" );
			printf( "   -t        :  Toggle between function list enable/disable.\n" );
			printf( "   -l <num>  :  Output debugging information for level <num>.\n" );
			printf( "   -w <file> :  Send debugging output to file <file>.\n" );
			printf( "   -we       :  Close debugging file now open.\n" );
			printf( "   -s        :  Send debugging output to serial port.\n" );
			printf( "   -se       :  Stop sending debugging output to serial port.\n" );
			printf( "   -p        :  Send debugging output to parallel port.\n" );
			printf( "   -pe       :  Stop sending debugging output to parallel port.\n" );
			exit( 0L );
		}

		else			/* Last, we have an unknown option.  Exit with error.	*/
		{
			fprintf( stderr,"    *** tDB Error ***  use \"tDB ?\" for options\n\n" );
			exit( 1L );
		}
	}

	/* First create a MsgPort to allow debug to communicate back to tDB.	*/

	if ( reply_port = CreatePort( "Trace.DBReplyPort",0L ))
	{
		/* If the MsgPort creation was successful, initialize msg fields	*/
		/* to appropriate values.  We have already set the necessary info	*/
		/* for debug internals above, now we need to give Exec values it	*/
		/* knows how to deal with.														*/

		msg.DB_msg.mn_Node.ln_Type = ( UBYTE )NT_MESSAGE;
   	msg.DB_msg.mn_Node.ln_Pri  = ( BYTE )0;
	   msg.DB_msg.mn_Node.ln_Name = NULL;
		msg.DB_msg.mn_ReplyPort    = reply_port;
	   msg.DB_msg.mn_Length       = ( UWORD )sizeof( Debug_Msg );

		/* Find the MsgPort used by debug.  This is known from having		*/
		/* written the code for debug.												*/

		if ( send_port = FindPort( "Trace.DBPort" ))
		{
			PutMsg( send_port,&msg );		/* Send our message.					*/
			WaitPort( reply_port );			/* Wait for debug to reply.		*/
			GetMsg( reply_port );			/* Pull message off reply_port.	*/

			/* Now we're going to output more information to the user.		*/

			switch( msg.DB_code )
			{
				/* For a DB_CHECK message tDB must wait for another message	*/
				/* from debug before printing info.  This is due to the		*/
				/* mechanism Exec employs for passing messages.  Since it	*/
				/* is only passing addresses, and not actually copying data	*/
				/* what is really happening is that one task is allowing		*/
				/* another to access its private data.  							*/

				/* In our case part of the data we are interested in is the	*/
				/* DB_Function List.  In order to be able to read the	list,	*/
				/* tDB must be granted access to debug's memory.  This can	*/
				/* be handled by having debug send tDB a message with the	*/
				/* required information attached.									*/

				case DB_CHECK:
				{
					if (( chk = ( Debug_Msg * )GetMsg( reply_port )) == NULL )
					{
						/* If the message has not yet arrived, wait for it		*/
						/* and pull it off the MsgPort.								*/

						WaitPort( reply_port );
						chk = ( Debug_Msg * )GetMsg( reply_port );
					}

					/* Set a local pointer to beginning of DB_Function List	*/
					/* and output information.											*/

					str = ( char ** )chk->DB_function;

					printf( "\t DB_Level         = %d\n",chk->DB_level );
					printf( "\t DB_Function List = %s\n",str[ 0 ] );

					/* Loop through DB_Function list by way of str[].  NULL	*/
					/* value indicates we have reached the end.					*/

					for ( i = 1; str[ i ]; i++ )
						printf( "\t                    %s\n",str[ i ] );

					/* Now give information about whether the DB_Function		*/
					/* List functions are set to print debug messages within	*/
					/* them, or ignore them.  This info is held within the	*/
					/* DB_code parameter.												*/

					printf( "\n\t Output from Function List functions is " );

					if ( chk->DB_code == db_include )	printf( "enabled\n"  );
					else											printf( "disabled\n" );

					ReplyMsg( chk );	/* Reply to debug to release message.	*/
				}
				break;

				/* For all other types of message passing, we simply output	*/
				/* a remark indicating that a message of the given type has	*/
				/* been sent to debug, and has been replied.						*/

				case DB_ADDFUNC:	printf( "\t Functions added to DB_Function List\n" );				break;
				case DB_REMFUNC:	printf( "\t Functions removed from DB_Function List\n" );		break;
				case DB_CLEAR:		printf( "\t DB_Function List cleared\n" );							break;
				case DB_TOGGLE:	printf( "\t DB_Function List output enabling toggled\n" );		break;
				case DB_LEVEL:		printf( "\t DB_Level changed to %d.\n",msg.DB_level );			break;
				case DB_WRITE:		printf( "\t Debug output to file <%s>.\n",msg.DB_file );			break;
				case DB_ENDWRITE:	printf( "\t Debug output file closed.\n" );							break;
				case DB_SER:		printf( "\t Debug output to serial port.\n" );						break;
				case DB_ENDSER:	printf( "\t Debug output to serial port stopped.\n" );			break;
				case DB_PAR:		printf( "\t Debug output to parallel port.\n" );					break;
				case DB_ENDPAR:	printf( "\t Debug output to parallel port stopped.\n" );			break;
				case DB_QUIT:		printf( "\t Trace.DBPort Deleted.\n" );								break;

				/* The next three cases are error returns from debug.  They	*/
				/* result from DB_Function List overflow, not finding a		*/
				/* function we wish to remove, or a message code unknown to	*/
				/* debug.																	*/

				case DB_OVERFLOW:	fprintf( stderr,"    *** debug Error *** DB_Function List overflow.\n" );
										break;

				/* When we have an unmatched function removal error, debug	*/
				/* will have left the unknown string pointer intact within	*/
				/* DB_List[].  All other pointers will be NULL.					*/

				case DB_UNMATCH:	fprintf( stderr,"    *** Warning *** Function(s) to remove not found:\n" );

										for ( i = 2; i < argc; i++ )
										{
											if ( DB_List[ i - 2 ] != NULL )
												fprintf( stderr,"\t                    %s\n",DB_List[ i - 2 ] );
										}
										break;

				case DB_UNKNOWN:	fprintf( stderr,"    *** debug Error *** Unknown debug option.\n" );
										break;

				default:			  	fprintf( stderr,"    *** tDB Error *** Unknown tDB Option.\n" );
										break;
			}
		}
		else
			fprintf( stderr,"    *** tDB Error *** Trace.DBPort could not be found\n" );

		DeletePort( reply_port );
	}
	else
		fprintf( stderr,"    *** tDB Error *** Trace.DBReplyPort not created\n" );

	printf( "\n" );
}
