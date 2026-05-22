/*
**		$PROJECT: ConfigFile.library
**		$FILE: LibBase.h
**		$DESCRIPTION: Header file for LibBase
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef LIBBASE_H
#define LIBBASE_H 1

struct CFBase
{
	struct Library				 LibNode;

	BPTR							 Segment;
};

//#define Segment			CFBase->Segment

#endif /* LIBBASE_H */
