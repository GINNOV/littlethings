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
/*	___________________

	ABackup Prefs
	io.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 15-Sep-93
	Modified: 20-Jun-95
	___________________
*/

#include "headers.h"
#include "icon.h"

STRPTR	_ENVNAME_ = "ENV:"PREFSNAME,
		_ARCNAME_ = "ENVARC:"PREFSNAME;

STATIC BOOL	LoadPrefs	(struct IFFHandle *);
STATIC BOOL	SavePrefs	(struct IFFHandle *,STRPTR,BOOL);

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

//______________________________________________________________________________

BOOL
ParsePrefs(STRPTR name,BOOL load,BOOL icon)
{
	struct IFFHandle	*iff;
	BOOL	rc = FALSE;

	if (iff = AllocIFF()) {
		if (iff->iff_Stream = Open(name,load? MODE_OLDFILE: MODE_NEWFILE)) {
			InitIFFasDOS(iff);
			if (NOT OpenIFF(iff,load? IFFF_READ: IFFF_WRITE)) {
				rc = load? LoadPrefs(iff): SavePrefs(iff,name,icon);
				if (NOT rc) WARNING(MSG_WARN_PROCESS_FILE);
				CloseIFF(iff);
			}
			Close(iff->iff_Stream);
		}
		else NotifyError(MSG_ERR_ACCESS_FILE,name);
		FreeIFF(iff);
	}
	return(rc);
}
//______________________________________________________________________________

__inline STATIC BOOL
LoadPrefs(struct IFFHandle *iff)
{
	struct ContextNode *p;
	LONG k, num, result;

	/*
	 * declares all data chunks
	 * NOTE: the ID_PRHD chunk is currently ignored
	 */

	for ( k = 0 ; ChunkTable[k].cd_ID ; k++ )
		if ( StopChunk(iff,ID_PREF,ChunkTable[k].cd_ID) ) return FALSE;

	// read loop
	for (num = 0 ; NOT (result = ParseIFF(iff,IFFPARSE_SCAN)) ; num++ ) {
		p = CurrentChunk(iff);

		// searches the current chunk in the table
		for ( k = 0 ; ChunkTable[k].cd_ID ; k++ )
			if ( ChunkTable[k].cd_ID == p->cn_ID ) break;

		// found: reads chunk data
		if ( ChunkTable[k].cd_ID == p->cn_ID ) {
			if (ReadChunkBytes(iff,(BYTE *)Prefs+ChunkTable[k].cd_Start,ChunkTable[k].cd_Length) != ChunkTable[k].cd_Length)
				return FALSE;
		}
		else return FALSE;
	}

	if ( (result == IFFERR_EOF) && (num == 7) ) return TRUE;
	return FALSE;
}
//______________________________________________________________________________

STATIC BOOL
CreateChunk(struct IFFHandle *iff,LONG id,BYTE *data,LONG length)

/*
 * Standard write function:
 * - starts a new chunk
 * - writes chunk data
 * - marks the end of the chunk
 */

{
  BOOL rc = FALSE ;

  if ( NOT PushChunk(iff,ID_PREF,id,length) ) {
	length -= WriteChunkBytes(iff,data,length);
	if ( (NOT PopChunk(iff)) && (NOT length) ) rc = TRUE;
  }

  return(rc);
}

//______________________________________________________________________________

__inline STATIC BOOL
SavePrefs(struct IFFHandle *iff,STRPTR name,BOOL icon)
{
	BOOL			rc = FALSE;
	struct PrefHeader	prfhd;
	LONG			k ;

	// starts the IFF file
	if (NOT PushChunk(iff,ID_PREF,ID_FORM,IFFSIZE_UNKNOWN)) {

		prfhd.ph_Version = PREFSVERSION;
		prfhd.ph_Type	 = NULL;
		prfhd.ph_Flags	 = 0L;

		// writes the Preferences Header
		if ( CreateChunk(iff,ID_PRHD,(BYTE *)&prfhd,sizeof(struct PrefHeader)) ) {

			// write loop for all Preferences chunks
			for ( k = 0 ; ChunkTable[k].cd_ID ; k++ )
				if (NOT CreateChunk(iff,ChunkTable[k].cd_ID,(BYTE *)Prefs+ChunkTable[k].cd_Start,ChunkTable[k].cd_Length))
					break;

			// puts icon and sets return value if ok
			if (NOT ChunkTable[k].cd_ID) {
				if (icon) PutDiskObject(name,&PrefsIcon);
				rc = TRUE;
			}
		}

		if (PopChunk(iff)) rc = FALSE;
	}
	return(rc);
}

// Tab size: 4
