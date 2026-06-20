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
    display.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Apr-95
    Modified: 04-Apr-95
    _______________________________________________________________________
*/

#define GID_BITD	0	// CAUTION: doesn't correspond to position in NGadgets[]
#define GID_BITE	1
#define GID_BITW	2
#define GID_BITR	3
#define GID_BITA	4
#define GID_BITP	5
#define GID_BITS	6
#define GID_BITH	7
#define GID_OK		8
#define GID_CANCEL	9
#define NUMGAD		10

static struct IntuiText IText[] =
{
  { 1, 0, JAM2, 0, 0, NULL, "H", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "S", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "P", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "A", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "R", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "W", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "E", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "D", NULL }
} ;

static struct IntuiText VText[] =
{
  { 1, 0, JAM2, 0, 0, NULL, "+", NULL } ,
  { 1, 0, JAM2, 0, 0, NULL, "-", NULL } ,
  { 0, 0, JAM2, 0, 0, NULL, "-", NULL }
} ;

#define VAL_SET 	0
#define VAL_CLEARED	1
#define VAL_IGNORE	2

static struct Gadget *Context = NULL ;
static struct Gadget *PGadgets[NUMGAD] ;
static struct NewGadget NGadgets[NUMGAD] ;

static struct TagItem FTags[] =
{
  WA_Top,	0,
  WA_Left,	0,
  WA_Width,	0,
  WA_Height,	0,
  WA_PubScreen, 0,
  WA_Title,	NULL,
  WA_Flags,	WFLG_RMBTRAP|WFLG_CLOSEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_ACTIVATE,
  WA_IDCMP,	IDCMP_CLOSEWINDOW|IDCMP_GADGETUP|IDCMP_VANILLAKEY,
  TAG_END,	NULL
} ;

#define FTT_TOP 	0
#define FTT_LEFT	1
#define FTT_WIDTH	2
#define FTT_HEIGHT	3
#define FTT_PUBSCR	4
#define FTT_TITLE	5

static struct TagItem DBBTags[] =
{
  GT_VisualInfo, 0,
  TAG_END,	 NULL
} ;

#define DBBT_VINFO	0

static struct TagItem NGTags[] =
{
  GT_Underscore, '_',
  TAG_END,	NULL
} ;


