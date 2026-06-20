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
#ifndef ABPREFS_TEMPLATE_H
#define ABPREFS_TEMPLATE_H
/*	___________________

	ABackup Prefs
	template.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 09-Dec-93
	Modified: 08-May-95
	___________________
*/

// CLI template:
#define TEMPLATE "FROM,EDIT/S,USE/S,SAVE/S,PS=PUBSCREEN/K,SF=SCREENFONT/S,W=WINDOW/N"

#define OPT_FROM		0
#define OPT_EDIT		1
#define OPT_USE 		2
#define OPT_SAVE		3
#define OPT_PUBSCREEN	4
#define OPT_SCREENFONT	5
#define OPT_WINDOW		6

#define OPT_COUNT		7

// tool types:
#define TT_SAVE 		"SAVE"
#define TT_USE			"USE"
#define TT_CREATEICONS	"CREATEICONS"
#define TT_PUBSCREEN	"PUBSCREEN"
#define TT_SCREENFONT	"SCREENFONT"
#define TT_HELPPATH	"HELPPATH"

#define TT_CXPOPKEY		"CX_POPKEY"
#define TT_CXPRIORITY	"CX_PRIORITY"

#define TT_YES			"YES"

#endif	// ABPREFS_TEMPLATE_H
