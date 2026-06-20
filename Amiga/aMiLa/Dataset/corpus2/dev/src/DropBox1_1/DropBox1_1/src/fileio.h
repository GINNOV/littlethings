/** DoRev Header ** Do not edit! **
*
* Name             :  fileio.h
* Copyright        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  11-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 26-Jun-93    3  Steve Anichini       Added Support for Version 1 of DropBox p
* 21-Jun-93    2  Steve Anichini       First Release.
* 12-Jun-93    1  Steve Anichini       Beta Release 1.0
* 11-Jun-93    0  Steve Anichini       None.
*
*** DoRev End **/


#define DEFPREF	"ENVARC:DropBox.prefs"

/* IFF Pref File Defines */
#define ID_DROP				MAKE_ID('D', 'R', 'O', 'P')
#define ID_GPRF				MAKE_ID('G', 'P', 'R', 'F')
#define ID_DBSE				MAKE_ID('D', 'B', 'S', 'E')
/* Version 1 */
#define ID_DENT				MAKE_ID('D', 'E', 'N', 'T')

/* FORM
 * size
 * DROP
 *
 * GPRF
 * size
 * struct GenPref
 *
 * DBSE (if version 0)
 * Really wierd here -
 * Packed strings... then a ULONG
 *
 * DENT (if version 1)
 * 1 entry (packed) strings
 * ULONG patnodes -> number of pattern nodes
 * char pat_Str[PATLEN]        \ Notice -> pattern name not packed!
 * ULONG pat_Flags             |- times patnodes
 * ULONG pat_Reserved          /
 *
 * DENT
 *
 * et al.
 */
  
#define MAX_DENT 16000




