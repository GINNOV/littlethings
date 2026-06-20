/*                         FILE:	trace.h
 *
 * This file contains definitions and includes for the trace.c, debug.c,
 *	and tDB.c files used for debugging.
 *
 *
 * Created:			5/24/89
 * Author:        Mark Porter (fog)
 *
 *
 * $Revision: 1.1 $
 * $Date: 92/05/07 05:36:29 $
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
 * $Log:	trace.h,v $
 * Revision 1.1  92/05/07  05:36:29  fog
 * Initial revision
 * 
 *
 *
 *----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/


#ifndef	TRACE_H
#define	TRACE_H

#include	<exec/ports.h>


#define	TDB_BUFSIZE		( 512 )
#define	DB_BUFSIZE		(	64 )
#define	DB_NUM			(	32 )


/*---------- Debug Code Values used to determine output values ---------*/

#define	DB_CONTINUE		(  1 )		/* Normal message sent by Trace().	*/
#define	DB_ADDFUNC		(  2 )		/* Add screening functions to list.	*/
#define	DB_REMFUNC		(  3 )		/* Remove functions from list.		*/
#define	DB_CLEAR			(  4 )		/* Clear screening function list.	*/
#define	DB_LEVEL			(  5 )		/* Set new debug enable level.		*/
#define	DB_CHECK			(  6 )		/* Request info from debug.			*/
#define	DB_WRITE			(  7 )		/* Write output to file.				*/
#define	DB_ENDWRITE		(  8 )		/* Stop file output and close file.	*/
#define	DB_SER			(  9 )		/* Write output to serial port.		*/
#define	DB_ENDSER		( 10 )		/* Stop serial port output.			*/
#define	DB_PAR			( 11 )		/* Write output to parallel port.	*/
#define	DB_ENDPAR		( 12 )		/* Stop parallel port output.			*/
#define	DB_TOGGLE		( 13 )		/* Toggle function output enable.	*/
#define	DB_QUIT			( 86 )		/* Close debug and exit.				*/
#define	DB_UNKNOWN		( 87 )		/* Unknown code value...error.		*/
#define	DB_OVERFLOW		( 88 )		/* DB_Function List overflow.			*/
#define	DB_UNMATCH		( 89 )		/* Unmatched function to remove.		*/


/*-------------- Data structures necessary for debugging ---------------*/

typedef struct _Debug_Msg				/* Message to send to debug from		*/
{												/* Trace() or tDB.						*/
	struct Message  DB_msg;				/* Exec Message to attach to port.	*/
	char				*DB_string,			/* Printable output string.			*/
						*DB_function,		/* Function list to add/remove.		*/
						*DB_file;			/* Name of output file for DB_WRITE.*/
	long				 DB_count;			/* Number of chars in DB_string.		*/
	int				 DB_code,			/* One of debug codes above.			*/
						 DB_level;			/* Debug level to enable.				*/
}	Debug_Msg;


typedef enum _DB_Type					/* Choose between enabling or dis-	*/
{												/* abling screening function output.*/
	db_none,									/* No function list available.		*/
	db_include,								/* Enable function list output.		*/
	db_exclude,								/* Disable function list output.		*/

}	DB_Type;


extern BOOL				  screen_list();
extern void				  send_status();
extern void				  add_functions();
extern void				  rem_functions();
extern void				  clear_functions();
extern struct MsgPort *FindPort(),
							 *CreatePort();


#endif