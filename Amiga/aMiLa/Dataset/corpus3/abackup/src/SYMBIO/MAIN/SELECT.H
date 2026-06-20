/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    select.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 02-Nov-93
    Modified: 04-Apr-95
    _______________________________________________________________________
*/

#ifndef ABACKUP_SELECT_H
#define ABACKUP_SELECT_H

#define SEL_MATCH		0	// if name matching
#define SEL_NOMATCH		1	// if name not matching
#define SEL_BEFORE		2	// if modified before
#define SEL_AFTER		3	// if modified after
#define SEL_BIT 		4	// test protection bits
// not used (DO NOT REMOVE !)   5       // DO NOT REMOVE !
#define SEL_OBJECT		6	// one object (unconditionnal)
#define SEL_NUMFUNC		7	// number of functions

#define SEL_INCLUDE		0x10	// include functions
#define SEL_INCLMATCH		(SEL_INCLUDE|SEL_MATCH)
#define SEL_INCLNOMATCH 	(SEL_INCLUDE|SEL_NOMATCH)
#define SEL_INCLBEFORE		(SEL_INCLUDE|SEL_BEFORE)
#define SEL_INCLAFTER		(SEL_INCLUDE|SEL_AFTER)
#define SEL_INCLBIT		(SEL_INCLUDE|SEL_BIT)
#define SEL_INCLOBJECT		(SEL_INCLUDE|SEL_OBJECT)

#define SEL_EXCLUDE		0x20	// exclude function
#define SEL_EXCLMATCH		(SEL_EXCLUDE|SEL_MATCH)
#define SEL_EXCLNOMATCH 	(SEL_EXCLUDE|SEL_NOMATCH)
#define SEL_EXCLBEFORE		(SEL_EXCLUDE|SEL_BEFORE)
#define SEL_EXCLAFTER		(SEL_EXCLUDE|SEL_AFTER)
#define SEL_EXCLBIT		(SEL_EXCLUDE|SEL_BIT)
#define SEL_EXCLOBJECT		(SEL_EXCLUDE|SEL_OBJECT)

#define SEL_OTHER		0x00	// other functions
#define SEL_REVERSE		(SEL_OTHER|1)
#define SEL_PARENT		(SEL_OTHER|2)
#define SEL_ROOT		(SEL_OTHER|3)
#define SEL_ENTERDIR		(SEL_OTHER|4)
#define SEL_RECURSE		(SEL_OTHER|5)

//______________________________________________________________________________

/* $DOC Macros_Select
 *	GetFunc( v )            Get function number from action
 *	GetType( v )            Get function type from action
 *	IsRecording()           TRUE if we are recording selection
 *	IsRecursive()           TRUE if we are in recursive mode
 * $END
 */

#define GetFunc( v )            ( v & 0x0f )
#define GetType( v )            ( v & 0xf0 )
#define IsRecording()           ( SelDesc )
#define IsRecursive()           ( RecursionFlag )

#endif	// ABACKUP_SELECT_H
