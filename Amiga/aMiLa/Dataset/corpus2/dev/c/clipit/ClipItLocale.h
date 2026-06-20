#ifndef ClipItLOCALE_H
#define ClipItLOCALE_H


/****************************************************************************/


/* This file was created automatically by CatComp.
 * Do NOT edit by hand!
 */


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifdef CATCOMP_ARRAY
#ifndef CATCOMP_NUMBERS
#define CATCOMP_NUMBERS
#endif
#ifndef CATCOMP_STRINGS
#define CATCOMP_STRINGS
#endif
#endif

#ifdef CATCOMP_BLOCK
#ifndef CATCOMP_STRINGS
#define CATCOMP_STRINGS
#endif
#endif


/****************************************************************************/


#ifdef CATCOMP_NUMBERS

#define MSG_DBC_STITLE 0
#define MSG_DBC_WTITLE 1
#define MSG_FMT_ABOUT_PROGRAM 2
#define MSG_ABOUT_RQTITLE 3
#define MSG_CR_WTITLE 4
#define MSG_ITXT_CR0 5
#define MSG_ITXT_CR1 6
#define MSG_GAD_CN 7
#define MSG_GAD_OkayBt 8
#define MSG_GAD_CancelBt 9
#define MSG_GAD_LUTxt 10
#define MSG_DBC_TT_CLIPPATH 11
#define MSG_DBC_TT_TEXTEDITOR 12
#define MSG_DBC_TT_TEXTVIEWER 13
#define MSG_DBC_TT_IMAGEEDITOR 14
#define MSG_DBC_TT_IMAGEVIEWER 15
#define MSG_DBC_TT_PROGRAMPATH 16
#define MSG_DBC_TT_HELPVIEWER 17
#define MSG_DBC_TT_HELPFILE 18
#define MSG_SAVE_CLIP 19
#define MSG_SET_CLIP_NAME 20
#define MSG_ASL_RTITLE 21
#define MSG_ASL_OKAY_BT 22
#define MSG_ASL_CANCEL_BT 23
#define MSG_MENU_PROJECT 24
#define MSG_MENU_Load 25
#define MSG_MENU_Save 26
#define MSG_MENU_Edit_Text 27
#define MSG_MENU_Edit_Image 28
#define MSG_MENU_About 29
#define MSG_MENU_Help 30
#define MSG_MENU_Quit 31
#define MSG_MENUKEY_L 32
#define MSG_MENUKEY_S 33
#define MSG_MENUKEY_I 34
#define MSG_MENUKEY_H 35
#define MSG_MENUKEY_Q 36
#define MSG_GAD_CFName 37
#define MSG_GAD_ASL 38
#define MSG_GAD_ViewClip 39
#define MSG_GAD_MakeClip 40
#define MSG_GAD_ClipLV 41
#define MSG_GAD_ToolTypes 42
#define MSG_GAD_ClipSize 43
#define MSG_GAD_ClipType 44
#define MSG_GAD_Delete 45
#define MSG_GAD_StatusTxt 46
#define MSG_GAD_ClipNumber 47
#define MSG_GAD_UpdateBt 48
#define MSG_DEFAULT_BUTTONS 49
#define MSG_OOPS_BUTTON 50
#define MSG_WELL_OKAY_BUTTON 51
#define MSG_OUCH_BUTTON 52
#define MSG_METHOD_BUTTONS 53
#define MSG_CLIP_ACTION_BUTTONS 54
#define MSG_CLIP_TYPE_BUTTONS 55
#define MSG_REQ_NAME 56
#define MSG_SYSTEM_PROBLEM 57
#define MSG_FILING_SYSTEM_PROBLEM 58
#define MSG_NO_MEMORY_HUH 59
#define MSG_USER_ERROR 60
#define MSG_BAD_TOOLTYPE 61
#define MSG_MISSING_ICON_HUH 62
#define MSG_USER_SANITY_CHECK 63
#define MSG_FMT_NO_FILEOPEN 64
#define MSG_FMT_FILE_NOT_LOADED 65
#define MSG_FMT_LIB_UNOPENED 66
#define MSG_FILE_WRITE_ERR 67
#define MSG_FMT_NOGUI_ERR 68
#define MSG_FMT_GARBLED_COMMAND 69
#define MSG_FMT_CLIP_NOT_OPEN 70
#define MSG_ENTER_CLIP_NAME 71
#define MSG_UNKNOWN_FILE_TYPE 72
#define MSG_FMT_FILE_NOT_ASCII 73
#define MSG_WHAT_TYPE_OF_CLIP 74
#define MSG_SELECT_ACTION 75
#define MSG_HELP_ME_RQTITLE 76
#define MSG_USER_INFO_RQTITLE 77
#define MSG_FMT_WRITE_CHECK 78
#define MSG_FMT_TRANSLATION_ERROR 79
#define MSG_FMT_FILE_TRANSLATION_ERROR 80
#define MSG_EMPTY_SLOT 81
#define MSG_FMT_CLIP_SENT_OUT 82
#define MSG_FMT_FILE_SENT_OUT 83
#define MSG_FMT_DELETE_CHECK 84
#define MSG_ENTER_CLIPNUM 85
#define MSG_FMT_NO_CLIP_DATA 86
#define MSG_FMT_BAD_CLIPNUM 87
#define MSG_FMT_LOADING_CLIP 88
#define MSG_CLIP_NOT_READ_STATUS 89
#define MSG_WAITING_FOR_USER 90
#define MSG_NO_TRANSFER_DONE 91
#define MSG_FMT_TRANSLATE_SAVING 92
#define MSG_ABORTED_SAVE 93
#define MSG_CLIP_NOT_OPEN 94
#define MSG_CLIP_NOT_READ 95
#define MSG_TRANSFER_PROBLEM 96
#define MSG_TRANSFER_COMPLETE 97
#define MSG_CLIP_DELETED 98
#define MSG_USER_IS_SANE 99
#define MSG_CLIP_WRITTEN 100

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define MSG_DBC_STITLE_STR "ClipIt! ©1999 by J.T. Steichen"
#define MSG_DBC_WTITLE_STR "ClipIt! ©1999 Clipboard Manager:"
#define MSG_FMT_ABOUT_PROGRAM_STR "%s was written by\n%s using SAS C V6.58 on\na A4000T 68040 system (Updated to PowerPC via gccV3.4.4).\nIt is designed to make using the Clipboard system easier\n& more powerful.  I can be reached at:  %s"
#define MSG_ABOUT_RQTITLE_STR "About the program..."
#define MSG_CR_WTITLE_STR "ClipIt! ©1999 needs a Clip number from you:"
#define MSG_ITXT_CR0_STR "Please enter a clipboard number for the function"
#define MSG_ITXT_CR1_STR "that you have requested (0 [Default] to 255)"
#define MSG_GAD_CN_STR "Clip _Number"
#define MSG_GAD_OkayBt_STR "_OKAY"
#define MSG_GAD_CancelBt_STR "_CANCEL"
#define MSG_GAD_LUTxt_STR "Current #:"
#define MSG_DBC_TT_CLIPPATH_STR "CLIPPATH"
#define MSG_DBC_TT_TEXTEDITOR_STR "TEXTEDITOR"
#define MSG_DBC_TT_TEXTVIEWER_STR "TEXTVIEWER"
#define MSG_DBC_TT_IMAGEEDITOR_STR "IMAGEEDITOR"
#define MSG_DBC_TT_IMAGEVIEWER_STR "IMAGEVIEWER"
#define MSG_DBC_TT_PROGRAMPATH_STR "PROGRAMPATH"
#define MSG_DBC_TT_HELPVIEWER_STR "HELPVIEWER"
#define MSG_DBC_TT_HELPFILE_STR "HELPFILE"
#define MSG_SAVE_CLIP_STR "Save Clip to File..."
#define MSG_SET_CLIP_NAME_STR "Set the clip fileName..."
#define MSG_ASL_RTITLE_STR "Enter a File Name..."
#define MSG_ASL_OKAY_BT_STR " OKAY! "
#define MSG_ASL_CANCEL_BT_STR " CANCEL! "
#define MSG_MENU_PROJECT_STR "PROJECT"
#define MSG_MENU_Load_STR "Load..."
#define MSG_MENU_Save_STR "Save"
#define MSG_MENU_Edit_Text_STR "Edit Text..."
#define MSG_MENU_Edit_Image_STR "Edit Image..."
#define MSG_MENU_About_STR "About.."
#define MSG_MENU_Help_STR "Help..."
#define MSG_MENU_Quit_STR "Quit"
#define MSG_MENUKEY_L_STR "L"
#define MSG_MENUKEY_S_STR "S"
#define MSG_MENUKEY_I_STR "I"
#define MSG_MENUKEY_H_STR "H"
#define MSG_MENUKEY_Q_STR "Q"
#define MSG_GAD_CFName_STR "Clip FileName:"
#define MSG_GAD_ASL_STR "ASL "
#define MSG_GAD_ViewClip_STR "_View Clip"
#define MSG_GAD_MakeClip_STR "_Make Clip"
#define MSG_GAD_ClipLV_STR "Clip List:"
#define MSG_GAD_ToolTypes_STR "Tool Types:"
#define MSG_GAD_ClipSize_STR "Clip Size (bytes):"
#define MSG_GAD_ClipType_STR "Clip Type:"
#define MSG_GAD_Delete_STR "Delete Clip"
#define MSG_GAD_StatusTxt_STR "Status:"
#define MSG_GAD_ClipNumber_STR "Clip #:"
#define MSG_GAD_UpdateBt_STR "_Update Clip List"
#define MSG_DEFAULT_BUTTONS_STR "CONTINUE|ABORT!"
#define MSG_OOPS_BUTTON_STR "Oops, OKAY!"
#define MSG_WELL_OKAY_BUTTON_STR "Well, okay!"
#define MSG_OUCH_BUTTON_STR "Aaarrggghhh!!!"
#define MSG_METHOD_BUTTONS_STR "USE ASCII METHOD|ABORT!"
#define MSG_CLIP_ACTION_BUTTONS_STR "VIEW CLIP|EDIT CLIP|ABORT"
#define MSG_CLIP_TYPE_BUTTONS_STR "IMAGE|TEXT"
#define MSG_REQ_NAME_STR "ClipNumber requester"
#define MSG_SYSTEM_PROBLEM_STR "System PROBLEM:"
#define MSG_FILING_SYSTEM_PROBLEM_STR "Filing PROBLEM:"
#define MSG_NO_MEMORY_HUH_STR "Out of Memory perhaps??"
#define MSG_USER_ERROR_STR "User ERROR:"
#define MSG_BAD_TOOLTYPE_STR "Invalid ToolType??"
#define MSG_MISSING_ICON_HUH_STR "Icon for the program NOT Found!"
#define MSG_USER_SANITY_CHECK_STR "Are you sure that you are done?"
#define MSG_FMT_NO_FILEOPEN_STR "Could NOT open %s file!"
#define MSG_FMT_FILE_NOT_LOADED_STR "ERROR:  %ld - %s\nFile NOT loaded!"
#define MSG_FMT_LIB_UNOPENED_STR "Could NOT open %s V%d library!"
#define MSG_FILE_WRITE_ERR_STR "The file did NOT get written correctly!"
#define MSG_FMT_NOGUI_ERR_STR "Could NOT open a %s GUI (error # %d)!\n"
#define MSG_FMT_GARBLED_COMMAND_STR "%s\n   could NOT be run by the System,\ncheck your spelling!"
#define MSG_FMT_CLIP_NOT_OPEN_STR "Could NOT open Clip # %3d!"
#define MSG_ENTER_CLIP_NAME_STR "Select a Clip in the List first!"
#define MSG_UNKNOWN_FILE_TYPE_STR "Could NOT transfer the file to clipboard!\nFile might not be in IFF format.\nWant to try ASCII method?"
#define MSG_FMT_FILE_NOT_ASCII_STR "ERROR:  %ld - %s\nFile not ASCII either? "
#define MSG_WHAT_TYPE_OF_CLIP_STR "What type of clip are you making?"
#define MSG_SELECT_ACTION_STR "Select what to do with the clip:"
#define MSG_HELP_ME_RQTITLE_STR "Help me, User:"
#define MSG_USER_INFO_RQTITLE_STR "User Information:"
#define MSG_FMT_WRITE_CHECK_STR "Write Clip #%d to %s,\nAre you sure about this?"
#define MSG_FMT_TRANSLATION_ERROR_STR "Could NOT Translate Clip #%d to:\n%s file!  ERROR:\n"
#define MSG_FMT_FILE_TRANSLATION_ERROR_STR "Could NOT Translate file %s to:\nClip #%d!  ERROR:\n"
#define MSG_EMPTY_SLOT_STR "You Clicked on an EMPTY slot, using default of 0!"
#define MSG_FMT_CLIP_SENT_OUT_STR "Clip #%d sent to:\n\n%s file!"
#define MSG_FMT_FILE_SENT_OUT_STR "File %s sent to:\n\nClip #%d!"
#define MSG_FMT_DELETE_CHECK_STR "Are you sure you want %s DELETED?"
#define MSG_ENTER_CLIPNUM_STR "Enter a valid clip number first!"
#define MSG_FMT_NO_CLIP_DATA_STR "NO Clip data for %d!"
#define MSG_FMT_BAD_CLIPNUM_STR "%d is outside the range of valid clip #'s!;"
#define MSG_FMT_LOADING_CLIP_STR "Loading '%s' Clip..."
#define MSG_CLIP_NOT_READ_STATUS_STR "Did NOT read the Clip info!"
#define MSG_WAITING_FOR_USER_STR "Waiting for User input."
#define MSG_NO_TRANSFER_DONE_STR "Could NOT transfer the clipboard to file!"
#define MSG_FMT_TRANSLATE_SAVING_STR "Going to translate %d to %s..."
#define MSG_ABORTED_SAVE_STR "User aborted save operation!"
#define MSG_CLIP_NOT_OPEN_STR "Could NOT open the given Clipboard!"
#define MSG_CLIP_NOT_READ_STR "Did NOT Read the given Clipboard!"
#define MSG_TRANSFER_PROBLEM_STR "Transfer Problem."
#define MSG_TRANSFER_COMPLETE_STR "Transfer complete."
#define MSG_CLIP_DELETED_STR "Clip File DELETED!"
#define MSG_USER_IS_SANE_STR "User came to his senses."
#define MSG_CLIP_WRITTEN_STR "Clip written to file!"

#endif /* CATCOMP_STRINGS */


/****************************************************************************/



#endif /* ClipItLOCALE_H */
