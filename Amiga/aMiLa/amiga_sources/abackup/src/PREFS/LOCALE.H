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
#ifndef ABPREFS_LOCALE_H
#define ABPREFS_LOCALE_H


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

#define MSG_RIGHTS 0
#define MSG_TRANSLATION 1
#define MSG_WARNING 2
#define MSG_ERROR 3
#define MSG_RESUME 4
#define MSG_WARN_MEMORY 5
#define MSG_WARN_CREATE_MENUS 6
#define MSG_WARN_LOCK_PUBSCREEN 7
#define MSG_WARN_FIND_PUBSCREEN 8
#define MSG_WARN_CREATE_GADGETS 9
#define MSG_WARN_WINDOW_BACKFILL 10
#define MSG_WARN_OPEN_WINDOW 11
#define MSG_WARN_LAYOUT_MENUS 12
#define MSG_WARN_CREATE_CONTEXT 13
#define MSG_WARN_OPEN_DISKFONT 14
#define MSG_WARN_OPEN_FONT 15
#define MSG_WARN_FONT_TOO_SHORT 16
#define MSG_WARN_FONT_TOO_WIDE 17
#define MSG_WARN_INEFFECTIVE 18
#define MSG_CX_TITLE 19
#define MSG_CX_DESCR 20
#define MSG_TITLE_MAIN 21
#define MSG_TITLE_BACKUP 22
#define MSG_TITLE_RESTORE 23
#define MSG_TITLE_VERIFY 24
#define MSG_TITLE_COMPRESS 25
#define MSG_TITLE_TAPE 26
#define MSG_TITLE_GUI 27
#define MSG_TITLE_EXTERNAL 28
#define MSG_TITLE_MISC 29
#define MSG_PROJECT 30
#define MSG_PROJECT_OPEN 31
#define MSG_PROJECT_SAVEAS 32
#define MSG_PROJECT_ABOUT 33
#define MSG_PROJECT_HIDE 34
#define MSG_PROJECT_QUIT 35
#define MSG_EDIT 36
#define MSG_EDIT_DEFAULT 37
#define MSG_EDIT_LASTSAVED 38
#define MSG_EDIT_RESTORE 39
#define MSG_SETTINGS 40
#define MSG_SETTINGS_ICONS 41
#define MSG_CK_OPEN 42
#define MSG_CK_SAVEAS 43
#define MSG_CK_ABOUT 44
#define MSG_CK_HIDE 45
#define MSG_CK_QUIT 46
#define MSG_CK_DEFAULT 47
#define MSG_CK_LASTSAVED 48
#define MSG_CK_RESTORE 49
#define MSG_CK_ICONS 50
#define MSG_OK 51
#define MSG_CANCEL 52
#define MSG_REPORT 53
#define MSG_PRINTER 54
#define MSG_FILE 55
#define MSG_SHORT 56
#define MSG_LONG 57
#define MSG_BUFFER_SIZE 58
#define MSG_BACKUP 59
#define MSG_RESTORE 60
#define MSG_VERIFY 61
#define MSG_COMPRESSION 62
#define MSG_TAPE 63
#define MSG_GUI 64
#define MSG_EXTERNAL_PROGS 65
#define MSG_MISCELLANEOUS 66
#define MSG_SAVE 67
#define MSG_USE 68
#define MSG_BACKUP_TO 69
#define MSG_TO_DEVICE 70
#define MSG_TO_FILE 71
#define MSG_TO_TAPE 72
#define MSG_DEVICES 73
#define MSG_ARCHIVE_FILE 74
#define MSG_BUFFER_LEVEL_FORMAT 75
#define MSG_LOG_FILE 76
#define MSG_DEFAULT_COMMENT 77
#define MSG_BACKUP_VERIFY 78
#define MSG_CHILD_TASK 79
#define MSG_BACKUP_LINKS 80
#define MSG_ADD_COMMENT 81
#define MSG_ADD_ICON 82
#define MSG_COMPRESS 83
#define MSG_COMPRESS_CAT 84
#define MSG_ENCRYPT 85
#define MSG_SET_ARCHIVE_BIT 86
#define MSG_DUP_CATALOG 87
#define MSG_IGNORE_SKIPME 88
#define MSG_RESTORE_FROM 89
#define MSG_RESTORE_TO 90
#define MSG_EXISTING_FILES 91
#define MSG_ALWAYS_REPLACE 92
#define MSG_NEVER_REPLACE 93
#define MSG_ASK_REPLACE 94
#define MSG_REPLACE_OLDEST 95
#define MSG_RENAME_FILE 96
#define MSG_BAD_FILES 97
#define MSG_ALWAYS_DELETE 98
#define MSG_NEVER_DELETE 99
#define MSG_ASK_DELETE 100
#define MSG_TREE 101
#define MSG_RESTORE_DATE 102
#define MSG_RESTORE_LINKS 103
#define MSG_EMPTY_DIRS 104
#define MSG_USE_CAT_FILE 105
#define MSG_COMPARE_DATA 106
#define MSG_SELECT_FILES 107
#define MSG_IGNORE_DATE 108
#define MSG_COMPRESS_METHOD 109
#define MSG_INTERNAL 110
#define MSG_EXTERNAL 111
#define MSG_XPK_LIBRARY 112
#define MSG_XPK_LIBS 113
#define MSG_XPK_MODE 114
#define MSG_COMPRESS_RATIO 115
#define MSG_PACKING_SPEED 116
#define MSG_UNPACKING_SPEED 117
#define MSG_XPK_SPEED 118
#define MSG_EXTERNAL_COMP 119
#define MSG_EXTERNAL_DECOMP 120
#define MSG_FILTER 121
#define MSG_DELETE 122
#define MSG_DEVICE_DRIVER 123
#define MSG_SCSI_PORT 124
#define MSG_BLOCK_SIZE 125
#define MSG_REWIND 126
#define MSG_EJECT 127
#define MSG_AUTO_RETENTION 128
#define MSG_FASTMEM_TBUFFER 129
#define MSG_SCSI_INQUIRY 130
#define MSG_SCREEN_TYPE 131
#define MSG_CUSTOM 132
#define MSG_WORKBENCH 133
#define MSG_PUBLIC 134
#define MSG_PUBSCREEN_NAME 135
#define MSG_SCREENFONT_NAME 136
#define MSG_TEXTFONT_NAME 137
#define MSG_PALETTE 138
#define MSG_ASCII 139
#define MSG_ILBM 140
#define MSG_OTHERS 141
#define MSG_ASYNCHRO 142
#define MSG_CONFIRM 143
#define MSG_ALERT 144
#define MSG_BEEP 145
#define MSG_FLASH 146
#define MSG_BOTH 147
#define MSG_NONE 148
#define MSG_FILES_SIZE 149
#define MSG_AUTOMATIC 150
#define MSG_BYTES 151
#define MSG_KILOBYTES 152
#define MSG_MEGABYTES 153
#define MSG_TEMP_DIRECTORY 154
#define MSG_SELECTION_PATH 155
#define MSG_PRINT_LABELS 156
#define MSG_LABELS_LENGTH 157
#define MSG_WARN_OPEN_ASLV36 158
#define MSG_WARN_OPEN_ASLV38 159
#define MSG_SELECT_FILE 160
#define MSG_SELECT_DIRECTORY 161
#define MSG_SELECT_FONT 162
#define MSG_SELECT_SCREEN_MODE 163
#define MSG_LOAD_PREFS 164
#define MSG_SAVE_PREFS 165
#define MSG_SELECT_BACKUP_DESTINATION 166
#define MSG_SELECT_LOG_FILE 167
#define MSG_SELECT_RESTORE_SOURCE 168
#define MSG_SELECT_RESTORE_DESTINATION 169
#define MSG_WARN_OPEN_REQTOOLS 170
#define MSG_SELECT_PALETTE 171
#define MSG_WARN_OPEN_IFFPARSE 172
#define MSG_WARN_PREFS_VERSION 173
#define MSG_WARN_PROCESS_FILE 174
#define MSG_ERR_ACCESS_FILE 175
#define MSG_REQUEST 176
#define MSG_CREATEDIR 177
#define MSG_YES_NO 178
#define MSG_RETRY_CANCEL 179
#define MSG_SCSI_INFOS 180
#define MSG_DIRECT_ACCESS 181
#define MSG_SEQUENTIAL_ACCESS 182
#define MSG_PROCESSOR 183
#define MSG_WORM 184
#define MSG_CDROM 185
#define MSG_SCANNER 186
#define MSG_OPTICAL_DISK 187
#define MSG_MEDIUM_CHANGER 188
#define MSG_COMMUNICATION 189
#define MSG_UNKNOWN 190
#define MSG_NOT_ANSI 191
#define MSG_SCSI1 192
#define MSG_SCSI2 193
#define MSG_VENDOR_ID 194
#define MSG_PRODUCT_ID 195
#define MSG_PRODUCT_REVISION 196
#define MSG_DEVICE_TYPE 197
#define MSG_REMOVABLE_MEDIUM 198
#define MSG_YES 199
#define MSG_NO 200
#define MSG_ISO_VERSION 201
#define MSG_ECMA_VERSION 202
#define MSG_ANSI_VERSION 203
#define MSG_DATA_TRANSFERS 204

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define MSG_RIGHTS_STR "All Rights Reserved"
#define MSG_TRANSLATION_STR "English built-in strings by Reza Elghazi"
#define MSG_WARNING_STR "ABackup Prefs Warning"
#define MSG_ERROR_STR "ABackup Prefs Error"
#define MSG_RESUME_STR "Ok"
#define MSG_WARN_MEMORY_STR "Not enough memory!"
#define MSG_WARN_CREATE_MENUS_STR "Unable to create menus!"
#define MSG_WARN_LOCK_PUBSCREEN_STR "Unable to lock public screen!"
#define MSG_WARN_FIND_PUBSCREEN_STR "Unable to find public screen\n%s"
#define MSG_WARN_CREATE_GADGETS_STR "Unable to create gadgets!"
#define MSG_WARN_WINDOW_BACKFILL_STR "Unable to set window backfill!"
#define MSG_WARN_OPEN_WINDOW_STR "Unable to open window!"
#define MSG_WARN_LAYOUT_MENUS_STR "Unable to layout menus!"
#define MSG_WARN_CREATE_CONTEXT_STR "Unable to create a place for GadTools context data!"
#define MSG_WARN_OPEN_DISKFONT_STR "Requires diskfont.library V36+"
#define MSG_WARN_OPEN_FONT_STR "Unable to open font\n%s"
#define MSG_WARN_FONT_TOO_SHORT_STR "Font is too small!"
#define MSG_WARN_FONT_TOO_WIDE_STR "Font is too wide for selected screen mode!"
#define MSG_WARN_INEFFECTIVE_STR "(ineffective)"
#define MSG_CX_TITLE_STR "ABackup Preferences Program"
#define MSG_CX_DESCR_STR "Setup ABackup User Preferences"
#define MSG_TITLE_MAIN_STR "ABackup Preferences"
#define MSG_TITLE_BACKUP_STR "Backup Options"
#define MSG_TITLE_RESTORE_STR "Restore Options"
#define MSG_TITLE_VERIFY_STR "Verify Options"
#define MSG_TITLE_COMPRESS_STR "Compression Options"
#define MSG_TITLE_TAPE_STR "Tape Options"
#define MSG_TITLE_GUI_STR "GUI Options"
#define MSG_TITLE_EXTERNAL_STR "External Programs"
#define MSG_TITLE_MISC_STR "Miscellaneous Options"
#define MSG_PROJECT_STR "Project"
#define MSG_PROJECT_OPEN_STR "Open..."
#define MSG_PROJECT_SAVEAS_STR "Save As..."
#define MSG_PROJECT_ABOUT_STR "About..."
#define MSG_PROJECT_HIDE_STR "Hide"
#define MSG_PROJECT_QUIT_STR "Quit"
#define MSG_EDIT_STR "Edit"
#define MSG_EDIT_DEFAULT_STR "Reset To Defaults"
#define MSG_EDIT_LASTSAVED_STR "Last Saved"
#define MSG_EDIT_RESTORE_STR "Restore"
#define MSG_SETTINGS_STR "Settings"
#define MSG_SETTINGS_ICONS_STR "Create Icons?"
#define MSG_CK_OPEN_STR "O"
#define MSG_CK_SAVEAS_STR "A"
#define MSG_CK_ABOUT_STR "?"
#define MSG_CK_HIDE_STR "H"
#define MSG_CK_QUIT_STR "Q"
#define MSG_CK_DEFAULT_STR "D"
#define MSG_CK_LASTSAVED_STR "L"
#define MSG_CK_RESTORE_STR "R"
#define MSG_CK_ICONS_STR "I"
#define MSG_OK_STR "_Ok"
#define MSG_CANCEL_STR "_Cancel"
#define MSG_REPORT_STR "_Report"
#define MSG_PRINTER_STR "Printer"
#define MSG_FILE_STR "File"
#define MSG_SHORT_STR "Brief"
#define MSG_LONG_STR "Detailled"
#define MSG_BUFFER_SIZE_STR "_Buffer Size:"
#define MSG_BACKUP_STR "_Backup"
#define MSG_RESTORE_STR "_Restore"
#define MSG_VERIFY_STR "_Verify"
#define MSG_COMPRESSION_STR "Com_pression"
#define MSG_TAPE_STR "_Tape"
#define MSG_GUI_STR "_GUI"
#define MSG_EXTERNAL_PROGS_STR "_External"
#define MSG_MISCELLANEOUS_STR "_Miscellaneous"
#define MSG_SAVE_STR "_Save"
#define MSG_USE_STR "_Use"
#define MSG_BACKUP_TO_STR "Backup _To:"
#define MSG_TO_DEVICE_STR "Device"
#define MSG_TO_FILE_STR "File"
#define MSG_TO_TAPE_STR "Tape"
#define MSG_DEVICES_STR "Devices:"
#define MSG_ARCHIVE_FILE_STR "Archive _File:"
#define MSG_BUFFER_LEVEL_FORMAT_STR "%5lu KBytes"
#define MSG_LOG_FILE_STR "_Log File:"
#define MSG_DEFAULT_COMMENT_STR "Defa_ult Comment:"
#define MSG_BACKUP_VERIFY_STR "_Verify"
#define MSG_CHILD_TASK_STR "Use Child Tas_k"
#define MSG_BACKUP_LINKS_STR "Backup Li_nks"
#define MSG_ADD_COMMENT_STR "A_dd Comment"
#define MSG_ADD_ICON_STR "Add _Icon"
#define MSG_COMPRESS_STR "Co_mpress Data"
#define MSG_COMPRESS_CAT_STR "Compre_ss Catalog"
#define MSG_ENCRYPT_STR "_Encrypt Data"
#define MSG_SET_ARCHIVE_BIT_STR "Set _Archive Bit"
#define MSG_DUP_CATALOG_STR "Du_plicate Catalog"
#define MSG_IGNORE_SKIPME_STR "I_gnore SKIPME"
#define MSG_RESTORE_FROM_STR "Restore _From:"
#define MSG_RESTORE_TO_STR "Restore _To:"
#define MSG_EXISTING_FILES_STR "E_xisting Files:"
#define MSG_ALWAYS_REPLACE_STR "Always Replace"
#define MSG_NEVER_REPLACE_STR "Never Replace"
#define MSG_ASK_REPLACE_STR "Ask Before Replacing"
#define MSG_REPLACE_OLDEST_STR "Replace if Older"
#define MSG_RENAME_FILE_STR "Rename File"
#define MSG_BAD_FILES_STR "_Bad Files:"
#define MSG_ALWAYS_DELETE_STR "Always Delete"
#define MSG_NEVER_DELETE_STR "Never Delete"
#define MSG_ASK_DELETE_STR "Ask Before Deleting"
#define MSG_TREE_STR "D_irectory Tree"
#define MSG_RESTORE_DATE_STR "Restore _Date"
#define MSG_RESTORE_LINKS_STR "Restore _Links"
#define MSG_EMPTY_DIRS_STR "_Empty Directories"
#define MSG_USE_CAT_FILE_STR "_Use Catalog File"
#define MSG_COMPARE_DATA_STR "Compare _Data"
#define MSG_SELECT_FILES_STR "_Select Files"
#define MSG_IGNORE_DATE_STR "_Ignore Files Date"
#define MSG_COMPRESS_METHOD_STR "_Method:"
#define MSG_INTERNAL_STR "Internal"
#define MSG_EXTERNAL_STR "External"
#define MSG_XPK_LIBRARY_STR "Xpk library"
#define MSG_XPK_LIBS_STR "Xpk Libs:"
#define MSG_XPK_MODE_STR "_Xpk Mode:"
#define MSG_COMPRESS_RATIO_STR "Compression Ratio:"
#define MSG_PACKING_SPEED_STR "Packing Speed:"
#define MSG_UNPACKING_SPEED_STR "Unpacking Speed:"
#define MSG_XPK_SPEED_STR "%5lu KB/s"
#define MSG_EXTERNAL_COMP_STR "Com_pressor:"
#define MSG_EXTERNAL_DECOMP_STR "D_ecompressor:"
#define MSG_FILTER_STR "_Filter:"
#define MSG_DELETE_STR "_Delete"
#define MSG_DEVICE_DRIVER_STR "_Device Driver:"
#define MSG_SCSI_PORT_STR "SCSI _Port:"
#define MSG_BLOCK_SIZE_STR "Block _Size:"
#define MSG_REWIND_STR "_Rewind"
#define MSG_EJECT_STR "_Eject"
#define MSG_AUTO_RETENTION_STR "Au_to Retension"
#define MSG_FASTMEM_TBUFFER_STR "_FAST mem. buffer"
#define MSG_SCSI_INQUIRY_STR "SCSI _Inquiry"
#define MSG_SCREEN_TYPE_STR "Screen _Type:"
#define MSG_CUSTOM_STR "Custom"
#define MSG_WORKBENCH_STR "Workbench"
#define MSG_PUBLIC_STR "Public"
#define MSG_PUBSCREEN_NAME_STR "Public Screen _Name:"
#define MSG_SCREENFONT_NAME_STR "_Screen Font:"
#define MSG_TEXTFONT_NAME_STR "T_ext Font:"
#define MSG_PALETTE_STR "_Palette"
#define MSG_ASCII_STR "_ASCII:"
#define MSG_ILBM_STR "_ILBM:"
#define MSG_OTHERS_STR "O_thers:"
#define MSG_ASYNCHRO_STR "_Run Asynchronously"
#define MSG_CONFIRM_STR "Confirm _Each Visualization"
#define MSG_ALERT_STR "_Alert:"
#define MSG_BEEP_STR "Beep"
#define MSG_FLASH_STR "Flash screen"
#define MSG_BOTH_STR "Beep & Flash"
#define MSG_NONE_STR "None"
#define MSG_FILES_SIZE_STR "_Files Size:"
#define MSG_AUTOMATIC_STR "Automatic"
#define MSG_BYTES_STR "Bytes"
#define MSG_KILOBYTES_STR "Kilo-Bytes"
#define MSG_MEGABYTES_STR "Mega-Bytes"
#define MSG_TEMP_DIRECTORY_STR "_Temporary Directory:"
#define MSG_SELECTION_PATH_STR "_Default Selection Path:"
#define MSG_PRINT_LABELS_STR "_Print Disk Labels"
#define MSG_LABELS_LENGTH_STR "_Labels Length (lines):"
#define MSG_WARN_OPEN_ASLV36_STR "Requires asl.library V36+"
#define MSG_WARN_OPEN_ASLV38_STR "Requires asl.library V38+"
#define MSG_SELECT_FILE_STR "Select File"
#define MSG_SELECT_DIRECTORY_STR "Select Directory"
#define MSG_SELECT_FONT_STR "Select Font"
#define MSG_SELECT_SCREEN_MODE_STR "Select Screen Mode"
#define MSG_LOAD_PREFS_STR "Load ABackup Preferences"
#define MSG_SAVE_PREFS_STR "Save ABackup Preferences"
#define MSG_SELECT_BACKUP_DESTINATION_STR "Select Backup destination"
#define MSG_SELECT_LOG_FILE_STR "Select Log File"
#define MSG_SELECT_RESTORE_SOURCE_STR "Select Restore source"
#define MSG_SELECT_RESTORE_DESTINATION_STR "Select Restore destination"
#define MSG_WARN_OPEN_REQTOOLS_STR "Requires reqtools.library V38+"
#define MSG_SELECT_PALETTE_STR "Select Palette"
#define MSG_WARN_OPEN_IFFPARSE_STR "Requires iffparse.library V36+"
#define MSG_WARN_PREFS_VERSION_STR "Unknown prefs file version!"
#define MSG_WARN_PROCESS_FILE_STR "Error processing IFF file!"
#define MSG_ERR_ACCESS_FILE_STR "Error accessing file"
#define MSG_REQUEST_STR "ABackup Prefs Request"
#define MSG_CREATEDIR_STR "The %s\ndirectory does not exist.\nwould you like to create it?"
#define MSG_YES_NO_STR "Yes|No"
#define MSG_RETRY_CANCEL_STR "Retry|Cancel"
#define MSG_SCSI_INFOS_STR "SCSI Information"
#define MSG_DIRECT_ACCESS_STR "Direct-access"
#define MSG_SEQUENTIAL_ACCESS_STR "Sequential-access"
#define MSG_PROCESSOR_STR "Processor"
#define MSG_WORM_STR "WORM"
#define MSG_CDROM_STR "CD-ROM"
#define MSG_SCANNER_STR "Scanner"
#define MSG_OPTICAL_DISK_STR "Optical disk"
#define MSG_MEDIUM_CHANGER_STR "Medium Changer"
#define MSG_COMMUNICATION_STR "Communication"
#define MSG_UNKNOWN_STR "Unknown"
#define MSG_NOT_ANSI_STR "Not ANSI-approved"
#define MSG_SCSI1_STR "SCSI-1"
#define MSG_SCSI2_STR "SCSI-2"
#define MSG_VENDOR_ID_STR "Vendor identification"
#define MSG_PRODUCT_ID_STR "Product identification"
#define MSG_PRODUCT_REVISION_STR "Product revision level"
#define MSG_DEVICE_TYPE_STR "Device type"
#define MSG_REMOVABLE_MEDIUM_STR "Removable medium"
#define MSG_YES_STR "Yes"
#define MSG_NO_STR "No"
#define MSG_ISO_VERSION_STR "ISO version"
#define MSG_ECMA_VERSION_STR "ECMA version"
#define MSG_ANSI_VERSION_STR "ANSI-Approved version"
#define MSG_DATA_TRANSFERS_STR "Data transfers"

#endif /* CATCOMP_STRINGS */


/****************************************************************************/


#ifdef CATCOMP_BLOCK

static const char ABPrefsBlock[] =
{
    "\x00\x00\x00\x00\x00\x14"
    MSG_RIGHTS_STR "\x00"
    "\x00\x00\x00\x01\x00\x2A"
    MSG_TRANSLATION_STR "\x00\x00"
    "\x00\x00\x00\x02\x00\x16"
    MSG_WARNING_STR "\x00"
    "\x00\x00\x00\x03\x00\x14"
    MSG_ERROR_STR "\x00"
    "\x00\x00\x00\x04\x00\x04"
    MSG_RESUME_STR "\x00\x00"
    "\x00\x00\x00\x05\x00\x14"
    MSG_WARN_MEMORY_STR "\x00\x00"
    "\x00\x00\x00\x06\x00\x18"
    MSG_WARN_CREATE_MENUS_STR "\x00"
    "\x00\x00\x00\x07\x00\x1E"
    MSG_WARN_LOCK_PUBSCREEN_STR "\x00"
    "\x00\x00\x00\x08\x00\x20"
    MSG_WARN_FIND_PUBSCREEN_STR "\x00"
    "\x00\x00\x00\x09\x00\x1A"
    MSG_WARN_CREATE_GADGETS_STR "\x00"
    "\x00\x00\x00\x0A\x00\x20"
    MSG_WARN_WINDOW_BACKFILL_STR "\x00\x00"
    "\x00\x00\x00\x0B\x00\x18"
    MSG_WARN_OPEN_WINDOW_STR "\x00\x00"
    "\x00\x00\x00\x0C\x00\x18"
    MSG_WARN_LAYOUT_MENUS_STR "\x00"
    "\x00\x00\x00\x0D\x00\x34"
    MSG_WARN_CREATE_CONTEXT_STR "\x00"
    "\x00\x00\x00\x0E\x00\x20"
    MSG_WARN_OPEN_DISKFONT_STR "\x00\x00"
    "\x00\x00\x00\x0F\x00\x18"
    MSG_WARN_OPEN_FONT_STR "\x00\x00"
    "\x00\x00\x00\x10\x00\x14"
    MSG_WARN_FONT_TOO_SHORT_STR "\x00\x00"
    "\x00\x00\x00\x11\x00\x2C"
    MSG_WARN_FONT_TOO_WIDE_STR "\x00\x00"
    "\x00\x00\x00\x12\x00\x0E"
    MSG_WARN_INEFFECTIVE_STR "\x00"
    "\x00\x00\x00\x13\x00\x1C"
    MSG_CX_TITLE_STR "\x00"
    "\x00\x00\x00\x14\x00\x20"
    MSG_CX_DESCR_STR "\x00\x00"
    "\x00\x00\x00\x15\x00\x14"
    MSG_TITLE_MAIN_STR "\x00"
    "\x00\x00\x00\x16\x00\x10"
    MSG_TITLE_BACKUP_STR "\x00\x00"
    "\x00\x00\x00\x17\x00\x10"
    MSG_TITLE_RESTORE_STR "\x00"
    "\x00\x00\x00\x18\x00\x10"
    MSG_TITLE_VERIFY_STR "\x00\x00"
    "\x00\x00\x00\x19\x00\x14"
    MSG_TITLE_COMPRESS_STR "\x00"
    "\x00\x00\x00\x1A\x00\x0E"
    MSG_TITLE_TAPE_STR "\x00\x00"
    "\x00\x00\x00\x1B\x00\x0C"
    MSG_TITLE_GUI_STR "\x00"
    "\x00\x00\x00\x1C\x00\x12"
    MSG_TITLE_EXTERNAL_STR "\x00"
    "\x00\x00\x00\x1D\x00\x16"
    MSG_TITLE_MISC_STR "\x00"
    "\x00\x00\x00\x1E\x00\x08"
    MSG_PROJECT_STR "\x00"
    "\x00\x00\x00\x1F\x00\x08"
    MSG_PROJECT_OPEN_STR "\x00"
    "\x00\x00\x00\x20\x00\x0C"
    MSG_PROJECT_SAVEAS_STR "\x00\x00"
    "\x00\x00\x00\x21\x00\x0A"
    MSG_PROJECT_ABOUT_STR "\x00\x00"
    "\x00\x00\x00\x22\x00\x06"
    MSG_PROJECT_HIDE_STR "\x00\x00"
    "\x00\x00\x00\x23\x00\x06"
    MSG_PROJECT_QUIT_STR "\x00\x00"
    "\x00\x00\x00\x24\x00\x06"
    MSG_EDIT_STR "\x00\x00"
    "\x00\x00\x00\x25\x00\x12"
    MSG_EDIT_DEFAULT_STR "\x00"
    "\x00\x00\x00\x26\x00\x0C"
    MSG_EDIT_LASTSAVED_STR "\x00\x00"
    "\x00\x00\x00\x27\x00\x08"
    MSG_EDIT_RESTORE_STR "\x00"
    "\x00\x00\x00\x28\x00\x0A"
    MSG_SETTINGS_STR "\x00\x00"
    "\x00\x00\x00\x29\x00\x0E"
    MSG_SETTINGS_ICONS_STR "\x00"
    "\x00\x00\x00\x2A\x00\x02"
    MSG_CK_OPEN_STR "\x00"
    "\x00\x00\x00\x2B\x00\x02"
    MSG_CK_SAVEAS_STR "\x00"
    "\x00\x00\x00\x2C\x00\x02"
    MSG_CK_ABOUT_STR "\x00"
    "\x00\x00\x00\x2D\x00\x02"
    MSG_CK_HIDE_STR "\x00"
    "\x00\x00\x00\x2E\x00\x02"
    MSG_CK_QUIT_STR "\x00"
    "\x00\x00\x00\x2F\x00\x02"
    MSG_CK_DEFAULT_STR "\x00"
    "\x00\x00\x00\x30\x00\x02"
    MSG_CK_LASTSAVED_STR "\x00"
    "\x00\x00\x00\x31\x00\x02"
    MSG_CK_RESTORE_STR "\x00"
    "\x00\x00\x00\x32\x00\x02"
    MSG_CK_ICONS_STR "\x00"
    "\x00\x00\x00\x33\x00\x04"
    MSG_OK_STR "\x00"
    "\x00\x00\x00\x34\x00\x08"
    MSG_CANCEL_STR "\x00"
    "\x00\x00\x00\x35\x00\x08"
    MSG_REPORT_STR "\x00"
    "\x00\x00\x00\x36\x00\x08"
    MSG_PRINTER_STR "\x00"
    "\x00\x00\x00\x37\x00\x06"
    MSG_FILE_STR "\x00\x00"
    "\x00\x00\x00\x38\x00\x06"
    MSG_SHORT_STR "\x00"
    "\x00\x00\x00\x39\x00\x0A"
    MSG_LONG_STR "\x00"
    "\x00\x00\x00\x3A\x00\x0E"
    MSG_BUFFER_SIZE_STR "\x00"
    "\x00\x00\x00\x3B\x00\x08"
    MSG_BACKUP_STR "\x00"
    "\x00\x00\x00\x3C\x00\x0A"
    MSG_RESTORE_STR "\x00\x00"
    "\x00\x00\x00\x3D\x00\x08"
    MSG_VERIFY_STR "\x00"
    "\x00\x00\x00\x3E\x00\x0E"
    MSG_COMPRESSION_STR "\x00\x00"
    "\x00\x00\x00\x3F\x00\x06"
    MSG_TAPE_STR "\x00"
    "\x00\x00\x00\x40\x00\x06"
    MSG_GUI_STR "\x00\x00"
    "\x00\x00\x00\x41\x00\x0A"
    MSG_EXTERNAL_PROGS_STR "\x00"
    "\x00\x00\x00\x42\x00\x10"
    MSG_MISCELLANEOUS_STR "\x00\x00"
    "\x00\x00\x00\x43\x00\x06"
    MSG_SAVE_STR "\x00"
    "\x00\x00\x00\x44\x00\x06"
    MSG_USE_STR "\x00\x00"
    "\x00\x00\x00\x45\x00\x0C"
    MSG_BACKUP_TO_STR "\x00"
    "\x00\x00\x00\x46\x00\x08"
    MSG_TO_DEVICE_STR "\x00\x00"
    "\x00\x00\x00\x47\x00\x06"
    MSG_TO_FILE_STR "\x00\x00"
    "\x00\x00\x00\x48\x00\x06"
    MSG_TO_TAPE_STR "\x00\x00"
    "\x00\x00\x00\x49\x00\x0A"
    MSG_DEVICES_STR "\x00\x00"
    "\x00\x00\x00\x4A\x00\x10"
    MSG_ARCHIVE_FILE_STR "\x00\x00"
    "\x00\x00\x00\x4B\x00\x0C"
    MSG_BUFFER_LEVEL_FORMAT_STR "\x00"
    "\x00\x00\x00\x4C\x00\x0C"
    MSG_LOG_FILE_STR "\x00\x00"
    "\x00\x00\x00\x4D\x00\x12"
    MSG_DEFAULT_COMMENT_STR "\x00"
    "\x00\x00\x00\x4E\x00\x08"
    MSG_BACKUP_VERIFY_STR "\x00"
    "\x00\x00\x00\x4F\x00\x10"
    MSG_CHILD_TASK_STR "\x00"
    "\x00\x00\x00\x50\x00\x0E"
    MSG_BACKUP_LINKS_STR "\x00"
    "\x00\x00\x00\x51\x00\x0E"
    MSG_ADD_COMMENT_STR "\x00\x00"
    "\x00\x00\x00\x52\x00\x0A"
    MSG_ADD_ICON_STR "\x00"
    "\x00\x00\x00\x53\x00\x10"
    MSG_COMPRESS_STR "\x00\x00"
    "\x00\x00\x00\x54\x00\x12"
    MSG_COMPRESS_CAT_STR "\x00"
    "\x00\x00\x00\x55\x00\x0E"
    MSG_ENCRYPT_STR "\x00"
    "\x00\x00\x00\x56\x00\x12"
    MSG_SET_ARCHIVE_BIT_STR "\x00\x00"
    "\x00\x00\x00\x57\x00\x14"
    MSG_DUP_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x58\x00\x10"
    MSG_IGNORE_SKIPME_STR "\x00\x00"
    "\x00\x00\x00\x59\x00\x10"
    MSG_RESTORE_FROM_STR "\x00\x00"
    "\x00\x00\x00\x5A\x00\x0E"
    MSG_RESTORE_TO_STR "\x00\x00"
    "\x00\x00\x00\x5B\x00\x12"
    MSG_EXISTING_FILES_STR "\x00\x00"
    "\x00\x00\x00\x5C\x00\x10"
    MSG_ALWAYS_REPLACE_STR "\x00\x00"
    "\x00\x00\x00\x5D\x00\x0E"
    MSG_NEVER_REPLACE_STR "\x00"
    "\x00\x00\x00\x5E\x00\x16"
    MSG_ASK_REPLACE_STR "\x00\x00"
    "\x00\x00\x00\x5F\x00\x12"
    MSG_REPLACE_OLDEST_STR "\x00\x00"
    "\x00\x00\x00\x60\x00\x0C"
    MSG_RENAME_FILE_STR "\x00"
    "\x00\x00\x00\x61\x00\x0C"
    MSG_BAD_FILES_STR "\x00"
    "\x00\x00\x00\x62\x00\x0E"
    MSG_ALWAYS_DELETE_STR "\x00"
    "\x00\x00\x00\x63\x00\x0E"
    MSG_NEVER_DELETE_STR "\x00\x00"
    "\x00\x00\x00\x64\x00\x14"
    MSG_ASK_DELETE_STR "\x00"
    "\x00\x00\x00\x65\x00\x10"
    MSG_TREE_STR "\x00"
    "\x00\x00\x00\x66\x00\x0E"
    MSG_RESTORE_DATE_STR "\x00"
    "\x00\x00\x00\x67\x00\x10"
    MSG_RESTORE_LINKS_STR "\x00\x00"
    "\x00\x00\x00\x68\x00\x14"
    MSG_EMPTY_DIRS_STR "\x00\x00"
    "\x00\x00\x00\x69\x00\x12"
    MSG_USE_CAT_FILE_STR "\x00"
    "\x00\x00\x00\x6A\x00\x0E"
    MSG_COMPARE_DATA_STR "\x00"
    "\x00\x00\x00\x6B\x00\x0E"
    MSG_SELECT_FILES_STR "\x00"
    "\x00\x00\x00\x6C\x00\x14"
    MSG_IGNORE_DATE_STR "\x00\x00"
    "\x00\x00\x00\x6D\x00\x0A"
    MSG_COMPRESS_METHOD_STR "\x00\x00"
    "\x00\x00\x00\x6E\x00\x0A"
    MSG_INTERNAL_STR "\x00\x00"
    "\x00\x00\x00\x6F\x00\x0A"
    MSG_EXTERNAL_STR "\x00\x00"
    "\x00\x00\x00\x70\x00\x0C"
    MSG_XPK_LIBRARY_STR "\x00"
    "\x00\x00\x00\x71\x00\x0A"
    MSG_XPK_LIBS_STR "\x00"
    "\x00\x00\x00\x72\x00\x0C"
    MSG_XPK_MODE_STR "\x00\x00"
    "\x00\x00\x00\x73\x00\x14"
    MSG_COMPRESS_RATIO_STR "\x00\x00"
    "\x00\x00\x00\x74\x00\x10"
    MSG_PACKING_SPEED_STR "\x00\x00"
    "\x00\x00\x00\x75\x00\x12"
    MSG_UNPACKING_SPEED_STR "\x00\x00"
    "\x00\x00\x00\x76\x00\x0A"
    MSG_XPK_SPEED_STR "\x00"
    "\x00\x00\x00\x77\x00\x0E"
    MSG_EXTERNAL_COMP_STR "\x00\x00"
    "\x00\x00\x00\x78\x00\x10"
    MSG_EXTERNAL_DECOMP_STR "\x00\x00"
    "\x00\x00\x00\x79\x00\x0A"
    MSG_FILTER_STR "\x00\x00"
    "\x00\x00\x00\x7A\x00\x08"
    MSG_DELETE_STR "\x00"
    "\x00\x00\x00\x7B\x00\x10"
    MSG_DEVICE_DRIVER_STR "\x00"
    "\x00\x00\x00\x7C\x00\x0C"
    MSG_SCSI_PORT_STR "\x00"
    "\x00\x00\x00\x7D\x00\x0E"
    MSG_BLOCK_SIZE_STR "\x00\x00"
    "\x00\x00\x00\x7E\x00\x08"
    MSG_REWIND_STR "\x00"
    "\x00\x00\x00\x7F\x00\x08"
    MSG_EJECT_STR "\x00\x00"
    "\x00\x00\x00\x80\x00\x10"
    MSG_AUTO_RETENTION_STR "\x00"
    "\x00\x00\x00\x81\x00\x12"
    MSG_FASTMEM_TBUFFER_STR "\x00"
    "\x00\x00\x00\x82\x00\x0E"
    MSG_SCSI_INQUIRY_STR "\x00"
    "\x00\x00\x00\x83\x00\x0E"
    MSG_SCREEN_TYPE_STR "\x00"
    "\x00\x00\x00\x84\x00\x08"
    MSG_CUSTOM_STR "\x00\x00"
    "\x00\x00\x00\x85\x00\x0A"
    MSG_WORKBENCH_STR "\x00"
    "\x00\x00\x00\x86\x00\x08"
    MSG_PUBLIC_STR "\x00\x00"
    "\x00\x00\x00\x87\x00\x16"
    MSG_PUBSCREEN_NAME_STR "\x00\x00"
    "\x00\x00\x00\x88\x00\x0E"
    MSG_SCREENFONT_NAME_STR "\x00"
    "\x00\x00\x00\x89\x00\x0C"
    MSG_TEXTFONT_NAME_STR "\x00"
    "\x00\x00\x00\x8A\x00\x0A"
    MSG_PALETTE_STR "\x00\x00"
    "\x00\x00\x00\x8B\x00\x08"
    MSG_ASCII_STR "\x00"
    "\x00\x00\x00\x8C\x00\x08"
    MSG_ILBM_STR "\x00\x00"
    "\x00\x00\x00\x8D\x00\x0A"
    MSG_OTHERS_STR "\x00\x00"
    "\x00\x00\x00\x8E\x00\x14"
    MSG_ASYNCHRO_STR "\x00"
    "\x00\x00\x00\x8F\x00\x1C"
    MSG_CONFIRM_STR "\x00"
    "\x00\x00\x00\x90\x00\x08"
    MSG_ALERT_STR "\x00"
    "\x00\x00\x00\x91\x00\x06"
    MSG_BEEP_STR "\x00\x00"
    "\x00\x00\x00\x92\x00\x0E"
    MSG_FLASH_STR "\x00\x00"
    "\x00\x00\x00\x93\x00\x0E"
    MSG_BOTH_STR "\x00\x00"
    "\x00\x00\x00\x94\x00\x06"
    MSG_NONE_STR "\x00\x00"
    "\x00\x00\x00\x95\x00\x0E"
    MSG_FILES_SIZE_STR "\x00\x00"
    "\x00\x00\x00\x96\x00\x0A"
    MSG_AUTOMATIC_STR "\x00"
    "\x00\x00\x00\x97\x00\x06"
    MSG_BYTES_STR "\x00"
    "\x00\x00\x00\x98\x00\x0C"
    MSG_KILOBYTES_STR "\x00\x00"
    "\x00\x00\x00\x99\x00\x0C"
    MSG_MEGABYTES_STR "\x00\x00"
    "\x00\x00\x00\x9A\x00\x16"
    MSG_TEMP_DIRECTORY_STR "\x00"
    "\x00\x00\x00\x9B\x00\x1A"
    MSG_SELECTION_PATH_STR "\x00\x00"
    "\x00\x00\x00\x9C\x00\x14"
    MSG_PRINT_LABELS_STR "\x00\x00"
    "\x00\x00\x00\x9D\x00\x18"
    MSG_LABELS_LENGTH_STR "\x00"
    "\x00\x00\x00\x9E\x00\x1A"
    MSG_WARN_OPEN_ASLV36_STR "\x00"
    "\x00\x00\x00\x9F\x00\x1A"
    MSG_WARN_OPEN_ASLV38_STR "\x00"
    "\x00\x00\x00\xA0\x00\x0C"
    MSG_SELECT_FILE_STR "\x00"
    "\x00\x00\x00\xA1\x00\x12"
    MSG_SELECT_DIRECTORY_STR "\x00\x00"
    "\x00\x00\x00\xA2\x00\x0C"
    MSG_SELECT_FONT_STR "\x00"
    "\x00\x00\x00\xA3\x00\x14"
    MSG_SELECT_SCREEN_MODE_STR "\x00\x00"
    "\x00\x00\x00\xA4\x00\x1A"
    MSG_LOAD_PREFS_STR "\x00\x00"
    "\x00\x00\x00\xA5\x00\x1A"
    MSG_SAVE_PREFS_STR "\x00\x00"
    "\x00\x00\x00\xA6\x00\x1A"
    MSG_SELECT_BACKUP_DESTINATION_STR "\x00"
    "\x00\x00\x00\xA7\x00\x10"
    MSG_SELECT_LOG_FILE_STR "\x00"
    "\x00\x00\x00\xA8\x00\x16"
    MSG_SELECT_RESTORE_SOURCE_STR "\x00"
    "\x00\x00\x00\xA9\x00\x1C"
    MSG_SELECT_RESTORE_DESTINATION_STR "\x00\x00"
    "\x00\x00\x00\xAA\x00\x20"
    MSG_WARN_OPEN_REQTOOLS_STR "\x00\x00"
    "\x00\x00\x00\xAB\x00\x10"
    MSG_SELECT_PALETTE_STR "\x00\x00"
    "\x00\x00\x00\xAC\x00\x20"
    MSG_WARN_OPEN_IFFPARSE_STR "\x00\x00"
    "\x00\x00\x00\xAD\x00\x1C"
    MSG_WARN_PREFS_VERSION_STR "\x00"
    "\x00\x00\x00\xAE\x00\x1C"
    MSG_WARN_PROCESS_FILE_STR "\x00\x00"
    "\x00\x00\x00\xAF\x00\x16"
    MSG_ERR_ACCESS_FILE_STR "\x00\x00"
    "\x00\x00\x00\xB0\x00\x16"
    MSG_REQUEST_STR "\x00"
    "\x00\x00\x00\xB1\x00\x3E"
    MSG_CREATEDIR_STR "\x00"
    "\x00\x00\x00\xB2\x00\x08"
    MSG_YES_NO_STR "\x00\x00"
    "\x00\x00\x00\xB3\x00\x0E"
    MSG_RETRY_CANCEL_STR "\x00\x00"
    "\x00\x00\x00\xB4\x00\x12"
    MSG_SCSI_INFOS_STR "\x00\x00"
    "\x00\x00\x00\xB5\x00\x0E"
    MSG_DIRECT_ACCESS_STR "\x00"
    "\x00\x00\x00\xB6\x00\x12"
    MSG_SEQUENTIAL_ACCESS_STR "\x00"
    "\x00\x00\x00\xB7\x00\x0A"
    MSG_PROCESSOR_STR "\x00"
    "\x00\x00\x00\xB8\x00\x06"
    MSG_WORM_STR "\x00\x00"
    "\x00\x00\x00\xB9\x00\x08"
    MSG_CDROM_STR "\x00\x00"
    "\x00\x00\x00\xBA\x00\x08"
    MSG_SCANNER_STR "\x00"
    "\x00\x00\x00\xBB\x00\x0E"
    MSG_OPTICAL_DISK_STR "\x00\x00"
    "\x00\x00\x00\xBC\x00\x10"
    MSG_MEDIUM_CHANGER_STR "\x00\x00"
    "\x00\x00\x00\xBD\x00\x0E"
    MSG_COMMUNICATION_STR "\x00"
    "\x00\x00\x00\xBE\x00\x08"
    MSG_UNKNOWN_STR "\x00"
    "\x00\x00\x00\xBF\x00\x12"
    MSG_NOT_ANSI_STR "\x00"
    "\x00\x00\x00\xC0\x00\x08"
    MSG_SCSI1_STR "\x00\x00"
    "\x00\x00\x00\xC1\x00\x08"
    MSG_SCSI2_STR "\x00\x00"
    "\x00\x00\x00\xC2\x00\x16"
    MSG_VENDOR_ID_STR "\x00"
    "\x00\x00\x00\xC3\x00\x18"
    MSG_PRODUCT_ID_STR "\x00\x00"
    "\x00\x00\x00\xC4\x00\x18"
    MSG_PRODUCT_REVISION_STR "\x00\x00"
    "\x00\x00\x00\xC5\x00\x0C"
    MSG_DEVICE_TYPE_STR "\x00"
    "\x00\x00\x00\xC6\x00\x12"
    MSG_REMOVABLE_MEDIUM_STR "\x00\x00"
    "\x00\x00\x00\xC7\x00\x04"
    MSG_YES_STR "\x00"
    "\x00\x00\x00\xC8\x00\x04"
    MSG_NO_STR "\x00\x00"
    "\x00\x00\x00\xC9\x00\x0C"
    MSG_ISO_VERSION_STR "\x00"
    "\x00\x00\x00\xCA\x00\x0E"
    MSG_ECMA_VERSION_STR "\x00\x00"
    "\x00\x00\x00\xCB\x00\x16"
    MSG_ANSI_VERSION_STR "\x00"
    "\x00\x00\x00\xCC\x00\x10"
    MSG_DATA_TRANSFERS_STR "\x00\x00"
};

#endif /* CATCOMP_BLOCK */


/****************************************************************************/


struct LocaleInfo
{
    APTR li_LocaleBase;
    APTR li_Catalog;
};



#endif /* ABPREFS_LOCALE_H */
