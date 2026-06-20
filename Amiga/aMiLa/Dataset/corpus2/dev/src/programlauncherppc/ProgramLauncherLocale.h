#ifndef ProgramLauncherLOCALE_H
#define ProgramLauncherLOCALE_H


/****************************************************************************/


/* This file was created automatically by CatComp.
 * Do NOT edit by hand!
 */


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifdef CATCOMP_ARRAY
#undef CATCOMP_NUMBERS
#undef CATCOMP_STRINGS
#define CATCOMP_NUMBERS
#define CATCOMP_STRINGS
#endif

#ifdef CATCOMP_BLOCK
#undef CATCOMP_STRINGS
#define CATCOMP_STRINGS
#endif


/****************************************************************************/


#ifdef CATCOMP_NUMBERS

#define MSG_PL_STITLE 0
#define MSG_PL_WTITLE 1
#define MSG_FMT_PL_ABOUT 2
#define MSG_FMT_PL_ABOUT_RQTITLE 3
#define MSG_TT_STARTUPFILE 4
#define MSG_TT_AMIPREFSFILE 5
#define MSG_TT_TOOLEDITOR 6
#define MSG_TT_HELPVIEWER 7
#define MSG_ASL_RTITLE 8
#define MSG_ASL_OKAY_BT 9
#define MSG_ASL_CANCEL_BT 10
#define MSG_MENU_PROJECT 11
#define MSG_MENU_Add 12
#define MSG_MENU_Remove 13
#define MSG_MENU_Import_AmiDock 14
#define MSG_MENU_Edit_ToolTypes 15
#define MSG_MENU_About 16
#define MSG_MENU_Help 17
#define MSG_MENU_Quit 18
#define MSG_MENU_PROGRAMS 19
#define MSG_MENU_Launch_Shell 20
#define MSG_MENUKEY_A 21
#define MSG_MENUKEY_R 22
#define MSG_MENUKEY_T 23
#define MSG_MENUKEY_I 24
#define MSG_MENUKEY_H 25
#define MSG_MENUKEY_Q 26
#define MSG_GAD_ProgramsLV 27
#define MSG_GAD_DeleteBt 28
#define MSG_ADD_MENU_RQTITLE 29
#define MSG_ADD_MENU_INST 30
#define MSG_REM_MENU_RQTITLE 31
#define MSG_REM_MENU_INST 32
#define MSG_SYSTEM_PROBLEM 33
#define MSG_USER_ERROR 34
#define MSG_SPELLING_ERROR 35
#define MSG_BAD_TOOLTYPE 36
#define MSG_FMT_BAD_STARTUPFILE 37
#define MSG_FMT_NO_FILEOPEN 38
#define MSG_FMT_NO_READ_FILEOPEN 39
#define MSG_FMT_EMPTY_FILE_FOUND 40
#define MSG_FMT_NO_ROOM_AMIDOCK 41
#define MSG_FMT_AMIDOCK_ERROR 42
#define MSG_AMIDOCK_FILE_PROBLEM 43
#define MSG_FMT_LIB_UNOPENED 44
#define MSG_FILE_WRITE_ERR 45
#define MSG_FMT_NOGUI_ERR 46
#define MSG_FMT_NO_COMMAND 47
#define MSG_FMT_MENU_FAILED 48

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define MSG_PL_STITLE_STR "GadToolsBox V2.0b © 1991-1993"
#define MSG_PL_WTITLE_STR "Program Launcher ©2005 by J.T. Steichen:"
#define MSG_FMT_PL_ABOUT_STR "%s is a GUI for launching programs from a ListView Gadget.\nIt was written using gcc V2.95.3 for AmigaOS4.\nThe Author of the program %s, can be reached at:\n\n   %s (EMail)"
#define MSG_FMT_PL_ABOUT_RQTITLE_STR "About the %s V%s program:"
#define MSG_TT_STARTUPFILE_STR "STARTUPFILE"
#define MSG_TT_AMIPREFSFILE_STR "AMIPREFSFILENAME"
#define MSG_TT_TOOLEDITOR_STR "TOOLTYPESEDITOR"
#define MSG_TT_HELPVIEWER_STR "HELPVIEWER"
#define MSG_ASL_RTITLE_STR "Enter a File Name..."
#define MSG_ASL_OKAY_BT_STR " OKAY! "
#define MSG_ASL_CANCEL_BT_STR " CANCEL! "
#define MSG_MENU_PROJECT_STR "PROJECT"
#define MSG_MENU_Add_STR "Add Menu..."
#define MSG_MENU_Remove_STR "Remove Menu..."
#define MSG_MENU_Import_AmiDock_STR "Import AmiDock"
#define MSG_MENU_Edit_ToolTypes_STR "Edit ToolTypes..."
#define MSG_MENU_About_STR "About.."
#define MSG_MENU_Help_STR "Help!"
#define MSG_MENU_Quit_STR "Quit"
#define MSG_MENU_PROGRAMS_STR "PROGRAMS"
#define MSG_MENU_Launch_Shell_STR "Launch Shell"
#define MSG_MENUKEY_A_STR "A"
#define MSG_MENUKEY_R_STR "R"
#define MSG_MENUKEY_T_STR "T"
#define MSG_MENUKEY_I_STR "I"
#define MSG_MENUKEY_H_STR "H"
#define MSG_MENUKEY_Q_STR "Q"
#define MSG_GAD_ProgramsLV_STR "Programs:"
#define MSG_GAD_DeleteBt_STR "Delete Item"
#define MSG_ADD_MENU_RQTITLE_STR "Add Another Program to ProgramLauncher Menu:"
#define MSG_ADD_MENU_INST_STR "Enter command to ADD (be exact!):"
#define MSG_REM_MENU_RQTITLE_STR "Remove a Program from ProgramLauncher Menu:"
#define MSG_REM_MENU_INST_STR "Enter command to REMOVE (be exact!):"
#define MSG_SYSTEM_PROBLEM_STR "System PROBLEM:"
#define MSG_USER_ERROR_STR "User ERROR:"
#define MSG_SPELLING_ERROR_STR "Spelling ERROR perhaps??"
#define MSG_BAD_TOOLTYPE_STR "Invalid or Missing ToolType??"
#define MSG_FMT_BAD_STARTUPFILE_STR "Startup File '%s' could NOT be opened!"
#define MSG_FMT_NO_FILEOPEN_STR "Could NOT open %s file!"
#define MSG_FMT_NO_READ_FILEOPEN_STR "Could NOT open %s file for reading!"
#define MSG_FMT_EMPTY_FILE_FOUND_STR "%s file is EMPTY!"
#define MSG_FMT_NO_ROOM_AMIDOCK_STR "AmiDock prefs file has too many Icons (> 100)!"
#define MSG_FMT_AMIDOCK_ERROR_STR "reading AmiDock prefs file returned ERROR #%d!"
#define MSG_AMIDOCK_FILE_PROBLEM_STR "Wrong File Name or EMPTY file??"
#define MSG_FMT_LIB_UNOPENED_STR "Could NOT open %s V%d library!"
#define MSG_FILE_WRITE_ERR_STR "The file did NOT get written correctly!"
#define MSG_FMT_NOGUI_ERR_STR "Could NOT open a %s GUI (error # %d)!\n"
#define MSG_FMT_NO_COMMAND_STR "System Could NOT run:\n\n   '%s'\n\n   ERROR NUMBER IS: %d"
#define MSG_FMT_MENU_FAILED_STR "Failed to reattach MenuStrip during '%s' action!"

#endif /* CATCOMP_STRINGS */


/****************************************************************************/



#endif /* ProgramLauncherLOCALE_H */
