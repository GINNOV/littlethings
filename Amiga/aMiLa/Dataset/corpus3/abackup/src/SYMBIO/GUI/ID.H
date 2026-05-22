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
    id.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Oct-93
    Modified: 12-Aug-95
    NO TABS
    _______________________________________________________________________
*/
#ifndef ABACKUP_ID_H
#define ABACKUP_ID_H

#define WIN_MAIN		 0
#define WIN_LOADTREE		 1
#define WIN_INFOS		 2
#define WIN_SELECTION		 3
#define WIN_MONITOR		 4
#define WIN_ARCREQ		 5

#define WIN_COUNT		 6
#define WIN_FIRST		~0
#define WIN_LARGEST		 WIN_MONITOR
#define WIN_TALLEST		 WIN_MONITOR

#define BOX_COUNT_MAIN		 0
#define BOX_COUNT_LOADTREE	 2
#define BOX_COUNT_INFOS 	 2
#define BOX_COUNT_SELECTION	 4
#define BOX_COUNT_MONITOR	 4
#define BOX_COUNT_ARCREQ	 3

#define MAINWIN_EXTRA_SIZE     226

#define VISIBLEDEVICES		 4

//______________________ Menu IDs:

// Menu titles:
#define MENU_PROJECT		 0
#define MENU_SELECT		 1

// 'Project' menu items:
#define MENU_PROJECT_ESTIMATE	 0
#define MENU_PROJECT_PRINT	 1
#define MENU_PROJECT_ADDDIR	 2
//	BARLABEL		 3
#define MENU_PROJECT_ABOUT	 4
#define MENU_PROJECT_QUIT	 5

// 'Selection' menu items:
#define MENU_SELECT_OPEN	 0
#define MENU_SELECT_RECORD	 1
#define MENU_SELECT_SAVE	 3
#define MENU_SELECT_ABORT	 4

//___________________ NewMenu IDs:

#define NMID_PROJECT		 0
#define NMID_ITEM_PREFS 	 1
#define NMID_ITEM_PRINT 	 2
#define NMID_ITEM_ADDDIR	 3
//	BARLABEL		 4
#define NMID_ITEM_ABOUT 	 5
#define NMID_ITEM_QUIT		 6
#define NMID_SELECT		 7
#define NMID_ITEM_SELOPEN	 8
#define NMID_ITEM_SELRECORD	 9
//	BARLABEL		10
#define NMID_ITEM_SELSAVE	11
#define NMID_ITEM_SELABORT	12
//	END			13
#define NM_COUNT		14

//_______________ Main window IDs:

#define GD_BackupFilesDirs	 0
#define GD_BackupPartitions	 1
#define GD_Restore		 2
#define GD_Verify		 3
#define GD_RebuildCatalog	 4
#define GD_Preferences		 5

#define GAD_COUNT_MAIN		 6

//__ Load Tree/Catalog window IDs:

#define GD_LoadTreeStatus	 0
#define GD_LoadTree		 1
#define GD_AbortTree		 2

#define GAD_COUNT_LOADTREE	 3

//_______ Informations window IDs:

#define GD_BackupSource 	 0
#define GD_BackupFiles		 1
#define GD_BackupSize		 2
#define GD_BackupDate		 3
#define GD_BackupTime		 4
#define GD_BackupCompression	 5
#define GD_BackupComment	 6
#define GD_ContinueInfos	 7
#define GD_AbortInfos		 8

#define GAD_COUNT_INFOS 	 9

//__________ Selection window IDs:

#define GD_Files		 0
#define GD_Size 		 1
#define GD_Bytes		 2
#define GD_Directory		 3
#define GD_Recursive		 4
#define GD_Filter		 5
#define GD_All			 6
#define GD_Reverse		 7
#define GD_ByName		 8
#define GD_ByDate		 9
#define GD_ByBits		10
#define GD_Root 		11
#define GD_Parent		12
#define GD_DirList		13
#define GD_Start		14
#define GD_Prefs		15
#define GD_Cancel		16

#define GAD_COUNT_SELECTION	17

//____________ Monitor window IDs:

#define GD_SavedFiles		 0
#define GD_LeftFiles		 1
#define GD_DiskNumber		 2
#define GD_Source		 3
#define GD_SavedSize		 4
#define GD_LeftSize		 5
#define GD_Time 		 6
#define GD_SavedBytes		 7
#define GD_LeftBytes		 8
#define GD_SavedGauge		 9
#define GD_LeftGauge		10
#define GD_CrunchedGauge	11
#define GD_DiskGauge		12
#define GD_Report		13
#define GD_Pause		14
#define GD_Abort		15

#define GAD_COUNT_MONITOR	16

//_____________ ArcReq window IDs:

#define GD_ArcType		 0
#define GD_DevList		 1
#define GD_SelList		 2
#define GD_ArcFile		 3
#define GD_ArcFileReq		 4
#define GD_UseCatFile		 5
#define GD_OkArcReq		 6
#define GD_CancelArcReq 	 7

#define GAD_COUNT_ARCREQ	 8

#endif // ABACKUP_ID_H
