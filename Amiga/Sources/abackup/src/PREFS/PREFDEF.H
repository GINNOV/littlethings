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
#ifndef ABPREFS_PREFDEF_H
#define ABPREFS_PREFDEF_H
/*      ___________________

	ABackup Prefs
	prefdef.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 08-Sep-93
	Modified: 18-Jan-98
	Tab size: 8
	___________________
*/

#ifdef PRFPTR
#  define PRF(a)	Prefs->a
#else
#  define PRF(a)	Prefs.a
#endif

// Prefs shorties:
#define PRF_FLAGS       	PRF(ab_Flags)
#define PRF_BUFSIZE     	PRF(ab_BufferSize)
#define PRF_TEMPDIR     	PRF(ab_TempDir)
#define PRF_SELECTPATH  	PRF(ab_SelectionPath)
#define PRF_EXTERNAL    	PRF(ab_External)
#define PRF_BUPFLAGS    	PRF(ab_BackupFlags)
#define PRF_BUPTO       	PRF(ab_BackupTo)
#define PRF_LOGFILE     	PRF(ab_LogFile)
#define PRF_DEFCOMMENT  	PRF(ab_DefaultComment)
#define PRF_LABELSLENGTH	PRF(ab_LabelsLength)
#define PRF_RESFLAGS    	PRF(ab_RestoreFlags)
#define PRF_RESFROM     	PRF(ab_RestoreFrom)
#define PRF_RESTO       	PRF(ab_RestoreTo)
#define PRF_VERFLAGS    	PRF(ab_VerifyFlags)
#define PRF_XPKMETHOD   	PRF(ab_XpkMethod)
#define PRF_XPKMODE     	PRF(ab_XpkMode)
#define PRF_COMP		PRF(ab_Compressor)
#define PRF_DECOMP      	PRF(ab_Decompressor)
#define PRF_FILTER      	PRF(ab_Filter)
#define PRF_TAPFLAGS    	PRF(ab_TapeFlags)
#define PRF_DEVICEDRIVER	PRF(ab_DeviceDriver)
#define PRF_SCSIPORT    	PRF(ab_SCSIPort)
#define PRF_BLOCKSIZE   	PRF(ab_BlockSize)
#define PRF_DISPLAYID   	PRF(ab_DisplayID)
#define PRF_PUBNAME     	PRF(ab_PubName)
#define PRF_COLORS      	PRF(ab_Colors)
#define PRF_SCREENFONTNAME      PRF(ab_ScreenFontName)
#define PRF_SCREENFONTSIZE      PRF(ab_ScreenFontYSize)
#define PRF_TEXTFONTNAME	PRF(ab_TextFontName)
#define PRF_TEXTFONTSIZE	PRF(ab_TextFontYSize)

// Binary tests on Prefs:
#define IS_BEEP 		AND(PRF_FLAGS,PFL_BEEP)
#define IS_FLASH		AND(PRF_FLAGS,PFL_FLASH)
#define IS_BEEPANDFLASH 	(IS_BEEP && IS_FLASH)
#define IS_BYTES		AND(PRF_FLAGS,PFL_BYTES)
#define IS_KILOBYTES    	AND(PRF_FLAGS,PFL_KILOBYTES)
#define IS_MEGABYTES    	AND(PRF_FLAGS,PFL_MEGABYTES)
#define IS_CUSTOM       	AND(PRF_FLAGS,PFL_CUSTOM)
#define IS_PUBLIC       	AND(PRF_FLAGS,PFL_PUBLIC)
#define IS_WORKBENCH    	(NOT IS_CUSTOM) && (NOT IS_PUBLIC)
#define IS_EXTERNAL     	AND(PRF_FLAGS,PFL_EXTERNAL)
#define IS_XPKLIB       	AND(PRF_FLAGS,PFL_XPKLIB)
#define IS_VISASYNCHRO  	AND(PRF_FLAGS,PFL_VISASYNCHRO)
#define IS_VISCONFIRM   	AND(PRF_FLAGS,PFL_VISCONFIRM)

#define IS_BFL_TOFILE   	AND(PRF_BUPFLAGS,BFL_TOFILE)
#define IS_BFL_TOTAPE   	AND(PRF_BUPFLAGS,BFL_TOTAPE)
#define IS_BFL_TODEVICE 	(NOT IS_BFL_TOFILE) && (NOT IS_BFL_TOTAPE)
#define IS_BFL_REPORT   	AND(PRF_BUPFLAGS,BFL_REPORT)
#define IS_BFL_REPTOFILE	AND(PRF_BUPFLAGS,BFL_REPTOFILE)
#define IS_BFL_REPSHORT 	AND(PRF_BUPFLAGS,BFL_REPSHORT)
#define IS_BFL_VERIFY   	AND(PRF_BUPFLAGS,BFL_VERIFY)
#define IS_BFL_CHILDTASK	AND(PRF_BUPFLAGS,BFL_CHILDTASK)
#define IS_BFL_LINKS    	AND(PRF_BUPFLAGS,BFL_LINKS)
#define IS_BFL_COMPRESS 	AND(PRF_BUPFLAGS,BFL_COMPRESS)
#define IS_BFL_CATCOMP  	AND(PRF_BUPFLAGS,BFL_CATCOMP)
#define IS_BFL_ENCRYPT  	AND(PRF_BUPFLAGS,BFL_ENCRYPT)
#define IS_BFL_SETABIT  	AND(PRF_BUPFLAGS,BFL_SETABIT)
#define IS_BFL_ADDCOMMENT       AND(PRF_BUPFLAGS,BFL_ADDCOMMENT)
#define IS_BFL_ADDICON  	AND(PRF_BUPFLAGS,BFL_ADDICON)
#define IS_BFL_DUPCATALOG       AND(PRF_BUPFLAGS,BFL_DUPCATALOG)
#define IS_BFL_PRINTLABELS      AND(PRF_BUPFLAGS,BFL_PRINTLABELS)
#define IS_BFL_IGNSKIPME	AND(PRF_BUPFLAGS,BFL_IGNSKIPME)

#define IS_RFL_FROMFILE 	AND(PRF_RESFLAGS,RFL_FROMFILE)
#define IS_RFL_FROMTAPE 	AND(PRF_RESFLAGS,RFL_FROMTAPE)
#define IS_RFL_FROMDEVICE       (NOT IS_RFL_FROMFILE) && (NOT IS_RFL_FROMTAPE)
#define IS_RFL_REPORT   	AND(PRF_RESFLAGS,RFL_REPORT)
#define IS_RFL_REPTOFILE	AND(PRF_RESFLAGS,RFL_REPTOFILE)
#define IS_RFL_REPSHORT 	AND(PRF_RESFLAGS,RFL_REPSHORT)
#define IS_RFL_DIRTREE  	AND(PRF_RESFLAGS,RFL_DIRTREE)
#define IS_RFL_DATE     	AND(PRF_RESFLAGS,RFL_DATE)
#define IS_RFL_LINKS    	AND(PRF_RESFLAGS,RFL_LINKS)
#define IS_RFL_EMPTYDIRS	AND(PRF_RESFLAGS,RFL_EMPTYDIRS)
#define IS_RFL_USECATFILE       AND(PRF_RESFLAGS,RFL_USECATFILE)
#define IS_RFL_REPLACE  	AND(PRF_RESFLAGS,RFL_REPLACE)
#define IS_RFL_ASKREPLACE       AND(PRF_RESFLAGS,RFL_ASKREPLACE)
#define IS_RFL_OLDREPLACE       AND(PRF_RESFLAGS,RFL_OLDREPLACE)
#define IS_RFL_RENAME   	AND(PRF_RESFLAGS,RFL_RENAME)
#define IS_RFL_DELBAD   	AND(PRF_RESFLAGS,RFL_DELBAD)
#define IS_RFL_ASKDELBAD	AND(PRF_RESFLAGS,RFL_ASKDELBAD)

#define IS_VFL_REPORT   	AND(PRF_VERFLAGS,VFL_REPORT)
#define IS_VFL_REPTOFILE	AND(PRF_VERFLAGS,VFL_REPTOFILE)
#define IS_VFL_REPSHORT 	AND(PRF_VERFLAGS,VFL_REPSHORT)
#define IS_VFL_COMPARE  	AND(PRF_VERFLAGS,VFL_COMPARE)
#define IS_VFL_SELECTIVE	AND(PRF_VERFLAGS,VFL_SELECTIVE)
#define IS_VFL_IGNOREDATE       AND(PRF_VERFLAGS,VFL_IGNOREDATE)

#define IS_TFL_REWIND   	AND(PRF_TAPFLAGS,TFL_REWIND)
#define IS_TFL_EJECT    	AND(PRF_TAPFLAGS,TFL_EJECT)
#define IS_TFL_RETENTION	AND(PRF_TAPFLAGS,TFL_RETENTION)
#define IS_TFL_FASTBUFFER       AND(PRF_TAPFLAGS,TFL_FASTBUFFER)

#endif  // ABPREFS_PREFDEF_H
