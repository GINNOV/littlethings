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
    display.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 06-Dec-93
    Modified: 29-Sep-94
    NO TABS
    _______________________________________________________________________
*/
#ifndef ABACKUP_DISPLAY_H
#define ABACKUP_DISPLAY_H

STATIC struct TagItem ExtSTLTags[] = {
   {SYS_Input ,NULL },
   {SYS_Output,NULL },
   {SYS_Asynch,FALSE},
   {TAG_DONE}
};

STATIC WORD TypeToID[] = {
    MSG_INFO_TYPE_LHARCARC,
    MSG_INFO_TYPE_ZOOARC,
    MSG_INFO_TYPE_PPCRUNCH,
    MSG_INFO_TYPE_PPCRYPT,
    MSG_INFO_TYPE_ABACKUP,
    MSG_INFO_TYPE_XPKF,
    MSG_INFO_TYPE_EMPTY,
    MSG_INFO_TYPE_OBJAZTEC,
    MSG_INFO_TYPE_LIBAZTEC,
    MSG_INFO_TYPE_FONTHEAD,
    MSG_INFO_TYPE_WBICON,
    MSG_INFO_TYPE_EXECPRG,
    MSG_INFO_TYPE_OBJSASC,
    MSG_INFO_TYPE_LIBSASC,
    MSG_INFO_TYPE_IFFILBM,
    MSG_INFO_TYPE_IFFTEXT,
    MSG_INFO_TYPE_IFF8SVX,
    MSG_INFO_TYPE_IFFANIM,
    MSG_INFO_TYPE_IFFOTHER,
    MSG_INFO_TYPE_BINARY,
    MSG_INFO_TYPE_ASCII
};

#define ID_ZOO		MAKE_ID('Z','O','O',' ')
#define ID_PPCRUNCH	MAKE_ID('P','P','2','0')
#define ID_PPCRYPT	MAKE_ID('P','X','2','0')
#define ID_FORM		MAKE_ID('F','O','R','M')
#define ID_ILBM		MAKE_ID('I','L','B','M')
#define ID_TEXT		MAKE_ID('T','E','X','T')
#define ID_8SVX		MAKE_ID('8','S','V','X')
#define ID_ANIM		MAKE_ID('A','N','I','M')
#define ID_XPKF		MAKE_ID('X','P','K','F')

#endif  // ABACKUP_DISPLAY_H