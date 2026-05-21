/************************************************************************
*                                                                       *
*         The Finale Project -- Definitions for the cache stuff         *
*                                                                       *
*         Copyright 1996-97 Finale Development Inc.                     *
*                                                                       *
*************************************************************************
* $Id: cache.h,v 1.11 1997/03/20 07:11:30 alain Exp $
************************************************************************/

#ifndef TFP_INCLUDE_CACHE_H
#define TFP_INCLUDE_CACHE_H

#include	<URL.h>


/*** Definitions *******************************************************/

#define	CACHEVER		1		// Version of the cache file (structure)


/*** Structures ********************************************************/

typedef struct _CacheEnt
{
	struct _CacheEnt	*next;		/* next in this list						*/
	UWORD					Hash;			/* URL hash									*/
	UWORD					Type;			/* Data type								*/
	ULONG					FileNum;		/* FileNum in disk cache				*/
	struct _URL			*url;			/* The corresponding URL structure	*/
											/* if loaded in memory					*/
	UWORD					XSize,YSize;/* For images								*/
	ULONG					Date;			/* Last usage date						*/
	ULONG					ExpiryDate;	/* Date on which data expires			*/
	ULONG					LastAccess;	/* Date we last accessed it			*/
	ULONG					LastChanged;/* Date the data was last changed	*/
	ULONG					Size;			/* Size this URL uses on disk			*/
#ifndef UNIX
	char					URL[0];		/* Here follows the URL text			*/
#else
	char					URL[1];
#endif
} CacheEnt;


/***********************************************************************/
#endif /* TFP_INCLUDE_CACHE_H */
