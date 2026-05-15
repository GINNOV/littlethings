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
    setup.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Nov-93
    Modified: 14-Oct-95
    _______________________________________________________________________
*/
#ifndef ABACKUP_SETUP_H
#define ABACKUP_SETUP_H

#define MINLIBVER	37L

// library bases:
struct IntuitionBase *IntuitionBase	 = NULL;
struct GfxBase		 *GfxBase		 = NULL;
struct LocaleBase	 *LocaleBase	 = NULL;
struct muBase		 *muBase		 = NULL;
struct Library		 *GadToolsBase	 = NULL,
					 *UtilityBase	 = NULL,
					 *IconBase		 = NULL,
					 *AslBase		 = NULL,
					 *DiskfontBase	 = NULL,
					 *IFFParseBase	 = NULL,
					 *WorkbenchBase  = NULL,
					 *AmigaGuideBase = NULL,
					 *XpkBase		 = NULL;

// *small* working area:
STATIC BYTE TmpBuf[MINSTR+1];

// localization:
struct Catalog *Catalog = NULL;
STATIC struct TagItem LocaleTags[] = {{OC_Version,38L},{TAG_DONE}};
#define CATNAME "abackup.catalog"

// notification:
struct NotifyRequest *NotReq = NULL;
LONG NotSig = -1L;

// memory pool:
VOID *MemPool = NULL;

// message port:
struct MsgPort *AWPort = NULL;

STATIC struct NewAmigaGuide NAGuide = {
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	"ABACKUP_HELP",
	NULL,
	HTF_CACHE_NODE,
	NAGContext,
	NULL,
	NULL,
	NULL,
	NULL
};

//______________________________________________________________________________

struct ChunkDef {
	LONG cd_ID ;		// chunk ID
	LONG cd_Start ; 	// offset if ABPREFS
	LONG cd_Length ;	// size in bytes
} ;

struct ChunkDef ChunkTable[] =
{
  { ID_GENE, ABPREFS_GENE_START, ABPREFS_GENE_LENGTH } ,
  { ID_BACK, ABPREFS_BACK_START, ABPREFS_BACK_LENGTH } ,
  { ID_REST, ABPREFS_REST_START, ABPREFS_REST_LENGTH } ,
  { ID_VERI, ABPREFS_VERI_START, ABPREFS_VERI_LENGTH } ,
  { ID_COMP, ABPREFS_COMP_START, ABPREFS_COMP_LENGTH } ,
  { ID_TAPE, ABPREFS_TAPE_START, ABPREFS_TAPE_LENGTH } ,
  { ID_GUIP, ABPREFS_GUIP_START, ABPREFS_GUIP_LENGTH } ,
  { 0 , 0 , 0 }
} ;

#endif	// ABACKUP_SETUP_H
