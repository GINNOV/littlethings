/*                         FILE: debug.h
 *
 *	Project:			DeBug Utilities
 *	Version:			2.0
 *
 *
 * This file contains header information for debugging Applications.
 *
 *
 *
 * Created:			5/19/90
 * Last Revision:	Sunday 03-May-92 15:43:31
 * Author:			Mark Porter
 *
 *
 * $Revision: 1.1 $
 * $Date: 92/05/05 19:59:05 $
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
 * $Log:	debug.h,v $
 * Revision 1.1  92/05/05  19:59:05  fog
 * Initial revision
 * 
 *
 *
 *----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/


#ifndef	TRACE_DEBUG_H
#define	TRACE_DEBUG_H


#ifdef		DEBUG
#	define	DB( args )		args
#else
#	define	DB( args )
#endif


#define		ENTER( proc )	DB( Trace( 0,proc,"Entered\n" ))
#define		EXIT(  proc )	DB( Trace( 0,proc,"Exited\n" ))


extern void	Trace();


#endif
