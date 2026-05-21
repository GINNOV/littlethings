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
#ifndef ABPREFS_ID_H
#define ABPREFS_ID_H
/*      ___________________

	ABackup Prefs
	id.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 18-Jan-98
	___________________
*/

//__________________________________ Window IDs:

#define WIN_MAIN					0
#define WIN_BACKUP      				1
#define WIN_RESTORE     				2
#define WIN_VERIFY      				3
#define WIN_COMPRESS    			4
#define WIN_TAPE					5
#define WIN_GUI 					6
#define WIN_EXTERNAL    			7
#define WIN_MISC					8

#define WIN_COUNT       				9
#define WIN_TALLEST     				WIN_COMPRESS
#define WIN_WIDEST      				WIN_BACKUP

//____________________________________ Menu IDs:

// Menu titles
#define MN_PROJECT      				0
#define MN_EDIT 					1
#define MN_SETTINGS     				2

// 'Project' menu
#define MN_PROJECT_OPEN 			0
#define MN_PROJECT_SAVEAS       		1
#define MN_PROJECT_ABOUT			3
#define MN_PROJECT_HIDE 			5
#define MN_PROJECT_QUIT 			6

// 'Edit' menu
#define MN_EDIT_DEFAULT 			0
#define MN_EDIT_LASTSAVED       		1
#define MN_EDIT_RESTORE 			2

// 'Settings' menu
#define MN_SETTINGS_CREATEICONS 	0

#define MENU_COUNT      				15

//_____________________________ BevelBox counts:

#define BOX_COUNT_MAIN  			0
#define BOX_COUNT_BACKUP			3
#define BOX_COUNT_RESTORE       		4
#define BOX_COUNT_VERIFY			2
#define BOX_COUNT_COMPRESS      		4
#define BOX_COUNT_TAPE  			2
#define BOX_COUNT_GUI   			2
#define BOX_COUNT_EXTERNAL      		2
#define BOX_COUNT_MISC  			2

//__________________________________ Gadget IDs:

#define GD_Ok   					0
#define GD_Cancel       				1

// Main window:
#define GD_Save 					0
#define GD_Use  					1
#define GD_Quit 					2
#define GD_Backup       				3
#define GD_Restore      				4
#define GD_Verify       				5
#define GD_Compress     				6
#define GD_Tape 					7
#define GD_GUI  					8
#define GD_External     				9
#define GD_Misc 					10

#define GAD_COUNT_MAIN  			11

// Backup options:
#define GD_BackupTo     				 2
#define GD_BackupDeviceList     		 3
#define GD_BackupDevices			 4
#define GD_BackupArcFile			 5
#define GD_BackupArcFileLoad    	 6
#define GD_BufferSize   			 7
#define GD_LogFile      				 8
#define GD_LogFileLoad  			 9
#define GD_DefaultComment       		10
#define GD_BackupReport 			11
#define GD_BackupReportTo       		12
#define GD_BackupReportType     		13
#define GD_BackupVerify 			14
#define GD_UseChildTask 			15
#define GD_BackupLinks  			16
#define GD_AddComment   			17
#define GD_AddIcon      				18
#define GD_CompressData 			19
#define GD_CompressCatalog      		20
#define GD_Encrypt      				21
#define GD_SetArchiveBit			22
#define GD_DuplicateCatalog     		23
#define GD_IgnoreSkipme 			24

#define GAD_COUNT_BACKUP			25

// Restore options:
#define GD_RestoreFrom  			 2
#define GD_RestoreDeviceList    	 3
#define GD_RestoreDevices       		 4
#define GD_RestoreArcFile       		 5
#define GD_RestoreArcFileLoad   	 6
#define GD_RestoreTo    			 7
#define GD_RestoreToLoad			 8
#define GD_ExistingFiles			 9
#define GD_BadFiles     				10
#define GD_RestoreReport			11
#define GD_RestoreReportTo      		12
#define GD_RestoreReportType    	13
#define GD_RestoreTree  			14
#define GD_RestoreDate  			15
#define GD_RestoreLinks 			16
#define GD_RestoreEmptyDirs     		17
#define GD_UseCatalogFile       		18

#define GAD_COUNT_RESTORE       		19

// Verify options:
#define GD_VerifyReport 			2
#define GD_VerifyReportTo       		3
#define GD_VerifyReportType     		4
#define GD_CompareData  			5
#define GD_SelectFiles  			6
#define GD_IgnoreFilesDate      		7

#define GAD_COUNT_VERIFY			8

// Compression options:
#define GD_CompressMethod       		 2
#define GD_XpkLibs      				 3
#define GD_XpkMode      				 4
#define GD_XpkDescription       		 5
#define GD_XpkRatio     				 6
#define GD_XpkPackSpeed 			 7
#define GD_XpkUnpackSpeed       		 8
#define GD_ExternalComp 			 9
#define GD_ExternalDecomp       		10
#define GD_ExternalCompLoad     		11
#define GD_ExternalDecompLoad   	12
#define GD_FilterString 			13
#define GD_FilterList   			14
#define GD_FilterDelete 			15

#define GAD_COUNT_COMPRESS      		16

// Tape options:
#define GD_DeviceDriver 			 2
#define GD_SCSIPort     				 3
#define GD_BlockSize    			 4
#define GD_Rewind       				 5
#define GD_Eject					 6
#define GD_AutoRetention			 7
#define GD_FastMemBuffer			 8
#define GD_SCSIInquiry  			 9

#define GAD_COUNT_TAPE  			 10

// GUI options:
#define GD_ScreenType   			 2
#define GD_PubScreenName			 3
#define GD_ScreenMode   			 4
#define GD_ScreenModeLoad       		 5
#define GD_ScrFontName  			 6
#define GD_ScrFontSize  			 7
#define GD_ScrFontLoad  			 8
#define GD_TxtFontName  			 9
#define GD_TxtFontSize  			10
#define GD_TxtFontLoad  			11
#define GD_Palette      				12

#define GAD_COUNT_GUI   			13

// External programs options:
#define GD_ExternalASCII			2
#define GD_ExternalILBM 			3
#define GD_ExternalOthers       		4
#define GD_ExternalASCIILoad    	5
#define GD_ExternalILBMLoad     		6
#define GD_ExternalOthersLoad   	7
#define GD_ExternalAsynchro     		8
#define GD_ExternalConfirm      		9

#define GAD_COUNT_EXTERNAL      		10

// Miscellaneous options:
#define GD_Alert					2
#define GD_FilesSize    			3
#define GD_TempDirectory			4
#define GD_SelectionPath			5
#define GD_TempDirectoryLoad    	6
#define GD_SelectionPathLoad    	7
#define GD_PrintLabels  			8
#define GD_LabelsLength 			9

#define GAD_COUNT_MISC  			10

#endif  // ABPREFS_ID_H
