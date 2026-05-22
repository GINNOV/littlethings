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
#ifndef ABACKUP_LOCALE_H
#define ABACKUP_LOCALE_H


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
#define MSG_ALERT_KICK_V37PLUS 2
#define MSG_WARNING 3
#define MSG_ERROR 4
#define MSG_REQUEST 5
#define MSG_ERROR_READING_CYLINDER 6
#define MSG_ERROR_DEVICE 7
#define MSG_ERROR_SCSI_ERROR 8
#define MSG_ERROR_SCSI_DRIVER 9
#define MSG_ERROR_SCSI_SENSE 10
#define MSG_ERROR_SYNTAX 11
#define MSG_WARN_MEMORY 12
#define MSG_WARN_ALREADY_RUNNING 13
#define MSG_WARN_OPEN_RESOURCES 14
#define MSG_WARN_OPEN_IFFPARSE 15
#define MSG_WARN_GET_VISUALINFO 16
#define MSG_WARN_OPEN_SCREEN 17
#define MSG_WARN_LOCK_SCREEN 18
#define MSG_WARN_LOCK_WBSCREEN 19
#define MSG_WARN_CREATE_GADGET 20
#define MSG_WARN_OPEN_WINDOW 21
#define MSG_WARN_CREATE_MENUS 22
#define MSG_WARN_LAYOUT_MENUS 23
#define MSG_WARN_CONTEXT 24
#define MSG_WARN_PREFS_NOT_FOUND 25
#define MSG_WARN_WRITE_PROTECTED 26
#define MSG_WARN_ALLOC_WRITE_BUFFER 27
#define MSG_WARN_READ_PROTECTED 28
#define MSG_WARN_CLOSE_VISITORS 29
#define MSG_WARN_NOTHING_SELECTED 30
#define MSG_WARN_SAME_BACKUP_SET 31
#define MSG_WARN_EXTERNAL_NOT_FOUND 32
#define MSG_WARN_ARCHIVE_TOO_BIG 33
#define MSG_WARN_CHKSUM_ERROR 34
#define MSG_WARN_ENCRYPTION_DISABLED 35
#define MSG_WARN_BADCYL_OVERFLOW 36
#define MSG_WARN_BAD_CYLINDER 37
#define MSG_ABERR_CANNOT_OPEN 38
#define MSG_ABERR_DECOMP_ERROR 39
#define MSG_ABERR_WRONG_PASSWORD 40
#define MSG_ABERR_VERIFY_ERROR 41
#define MSG_ABERR_BAD_PATTERN 42
#define MSG_ABERR_BAD_DATE 43
#define MSG_ABERR_BAD_BITS 44
#define MSG_ABERR_SYNTAX_ERROR 45
#define MSG_ABERR_BACKUP_TO_ITSELF 46
#define MSG_ABERR_NOT_A_TAPE 47
#define MSG_ABERR_READ_ERROR 48
#define MSG_ABERR_COPYCAT_FAILED 49
#define MSG_ABERR_NOT_AN_ARCHIVE 50
#define MSG_ABERR_BAD_FORMAT 51
#define MSG_TDERR_NOSECHDR 52
#define MSG_TDERR_BADSECPRE 53
#define MSG_TDERR_BADSECID 54
#define MSG_TDERR_BADHDRSUM 55
#define MSG_TDERR_BADSECSUM 56
#define MSG_TDERR_TOOFEWSECS 57
#define MSG_TDERR_BADSECHDR 58
#define MSG_TDERR_SEEKERROR 59
#define MSG_WIN_TITLE_MAIN 60
#define MSG_WIN_TITLE_LOADING_TREE 61
#define MSG_WIN_TITLE_LOADING_CATALOG 62
#define MSG_WIN_TITLE_INFOS 63
#define MSG_WIN_TITLE_BACKUP_SELECTION 64
#define MSG_WIN_TITLE_RESTORE_SELECTION 65
#define MSG_WIN_TITLE_VERIFY_SELECTION 66
#define MSG_WIN_TITLE_BACKUP 67
#define MSG_WIN_TITLE_RESTORE 68
#define MSG_WIN_TITLE_VERIFY 69
#define MSG_WIN_TITLE_REBUILD 70
#define MSG_WIN_TITLE_ABOUT 71
#define MSG_WIN_TITLE_ARCREQ 72
#define MSG_PROJECT_MENU 73
#define MSG_PROJECT_ESTIMATE 74
#define MSG_PROJECT_ESTIMATE_CK 75
#define MSG_PROJECT_PRINT 76
#define MSG_PROJECT_PRINT_CK 77
#define MSG_PROJECT_ADDDIR 78
#define MSG_PROJECT_ADDDIR_CK 79
#define MSG_PROJECT_ABOUT 80
#define MSG_PROJECT_ABOUT_CK 81
#define MSG_PROJECT_QUIT 82
#define MSG_PROJECT_QUIT_CK 83
#define MSG_SELECT_MENU 84
#define MSG_SELECT_OPEN 85
#define MSG_SELECT_OPEN_CK 86
#define MSG_SELECT_RECORD 87
#define MSG_SELECT_RECORD_CK 88
#define MSG_SELECT_SAVE 89
#define MSG_SELECT_SAVE_CK 90
#define MSG_SELECT_ABORT 91
#define MSG_SELECT_ABORT_CK 92
#define MSG_BACKUP_FILES 93
#define MSG_BACKUP_PARTITIONS 94
#define MSG_RESTORE 95
#define MSG_VERIFY 96
#define MSG_REBUILD_CATALOG 97
#define MSG_PREFERENCES 98
#define MSG_LOADING_TREE 99
#define MSG_SORTING_TREE 100
#define MSG_SEARCHING_CATALOG 101
#define MSG_ANALYSING_CATALOG 102
#define MSG_CATALOG 103
#define MSG_BACKUP_DATE 104
#define MSG_BACKUP_TIME 105
#define MSG_BACKUP_SIZE 106
#define MSG_BACKUP_COMMENT 107
#define MSG_CONTINUE 108
#define MSG_DRAWER 109
#define MSG_LINK 110
#define MSG_FILES 111
#define MSG_PARTITIONS 112
#define MSG_SIZE 113
#define MSG_BYTES 114
#define MSG_KILOBYTES 115
#define MSG_KILOBYTES_SHORT 116
#define MSG_MEGABYTES 117
#define MSG_MEGABYTES_SHORT 118
#define MSG_RECURSIVE 119
#define MSG_FILTER 120
#define MSG_INCLUDE 121
#define MSG_EXCLUDE 122
#define MSG_ALL 123
#define MSG_REVERSE 124
#define MSG_BYNAME 125
#define MSG_BYDATE 126
#define MSG_BYBITS 127
#define MSG_DIRECTORY 128
#define MSG_ROOT 129
#define MSG_PARENT 130
#define MSG_START_BACKUP 131
#define MSG_START_RESTORE 132
#define MSG_START_VERIFY 133
#define MSG_CANCEL 134
#define MSG_OK 135
#define MSG_CYLINDER_SHORT 136
#define MSG_SAVED 137
#define MSG_RESTORED 138
#define MSG_VERIFIED 139
#define MSG_READ 140
#define MSG_LEFT 141
#define MSG_DISKNUMBER 142
#define MSG_COMPRESSION 143
#define MSG_SOURCE 144
#define MSG_DESTINATION 145
#define MSG_PAUSE 146
#define MSG_ABORT 147
#define MSG_RESTORING_LINKS 148
#define MSG_ARC_TYPE 149
#define MSG_ARC_FROM_DEVICE 150
#define MSG_ARC_FROM_FILE 151
#define MSG_ARC_FROM_TAPE 152
#define MSG_ARC_CATFILE 153
#define MSG_ARC_FILE 154
#define MSG_REQ_TITLE_DIR_REQUESTER 155
#define MSG_REQ_TITLE_REPORT_FILE 156
#define MSG_REQ_TITLE_SELECTION_FILE 157
#define MSG_REQ_TITLE_LOAD_CATALOG 158
#define MSG_REQ_TITLE_SAVE_CATALOG 159
#define MSG_REQ_QUIT 160
#define MSG_REQ_REPLACE 161
#define MSG_REQ_EXISTS_RENAME 162
#define MSG_REQ_DELETE_BAD_FILE 163
#define MSG_REQ_OK_CANCEL 164
#define MSG_REQ_RETRY_CANCEL 165
#define MSG_REQ_CONTINUE_ABORT 166
#define MSG_REQ_YES_NO 167
#define MSG_REQ_OK 168
#define MSG_REQ_REPLACE_SKIP 169
#define MSG_REQ_RESTORE_FAILED 170
#define MSG_REQ_BACKUP_FAILED 171
#define MSG_REQ_VERIFY_FAILED 172
#define MSG_REQ_INSERT_DISK 173
#define MSG_REQ_INSERT_LAST_DISK 174
#define MSG_REQ_INSERT_NEXT_DISK 175
#define MSG_REQ_INSERT_NEW_DISK 176
#define MSG_REQ_OVERWRITE 177
#define MSG_REQ_MISC_DISK 178
#define MSG_REQ_CRYPT_DISK 179
#define MSG_REQ_OLD_BACKUP_DISK 180
#define MSG_REQ_OVERWRITE_TAPE 181
#define MSG_REQ_FILE_EXISTS 182
#define MSG_REQ_WRONG_DISK 183
#define MSG_REQ_ABORT 184
#define MSG_REQ_FINISHED 185
#define MSG_REQ_SELECTION 186
#define MSG_REQ_PATTERN 187
#define MSG_REQ_PATTERN_GAD 188
#define MSG_REQ_DATE 189
#define MSG_REQ_DATE_GAD 190
#define MSG_REQ_BITS 191
#define MSG_REQ_PASSWORD 192
#define MSG_REQ_NEED_MEMORY 193
#define MSG_REQ_ESTIMATION 194
#define MSG_REQ_FILE_MODIFIED 195
#define MSG_REQ_FILES_NOTEQUAL 196
#define MSG_REQ_COMMENT 197
#define MSG_REQ_TAPE_NOT_READY 198
#define MSG_REQ_CHKSUM_ERROR 199
#define MSG_REQ_PREPARE_LABEL 200
#define MSG_REQ_ACCESS_DENIED 201
#define MSG_MONITOR_READING 202
#define MSG_MONITOR_WRITING 203
#define MSG_MONITOR_CRUNCHING 204
#define MSG_MONITOR_COMPARING 205
#define MSG_MONITOR_BACKEDUP 206
#define MSG_MONITOR_RESTORED 207
#define MSG_MONITOR_VERIFIED 208
#define MSG_MONITOR_SKIPPED 209
#define MSG_MONITOR_CYLINDER 210
#define MSG_MONITOR_ERROR 211
#define MSG_MONITOR_CATALOG 212
#define MSG_ARCHIVE_CLOSED 213
#define MSG_SETTING_ARCHIVE_BITS 214
#define MSG_REPORT_BREAKED 215
#define MSG_REPORT_BACKUP 216
#define MSG_REPORT_RESTORE 217
#define MSG_REPORT_VERIFY 218
#define MSG_REPORT_HEADER1 219
#define MSG_REPORT_HEADER2 220
#define MSG_REPORT_HEADER3 221
#define MSG_REPORT_FOOTER1 222
#define MSG_REPORT_FOOTER2 223
#define MSG_REPORT_BAD_CYLINDER 224
#define MSG_REPORT_BAD_FILE 225
#define MSG_REPORT_NOT_REPLACED 226
#define MSG_REPORT_RENAMED 227
#define MSG_REPORT_NOT_FOUND 228
#define MSG_REPORT_COULD_NOT_BACKUP 229
#define MSG_REPORT_COULD_NOT_RESTORE 230
#define MSG_REPORT_COULD_NOT_VERIFY 231
#define MSG_REPORT_FILE_MODIFIED 232
#define MSG_REPORT_COMPARE_FAILED 233
#define MSG_REPORT_OPENING 234
#define MSG_REPORT_ACCESS_DENIED 235
#define MSG_INFO_DEVICE 236
#define MSG_INFO_LINK 237
#define MSG_INFO_TYPE_EMPTY 238
#define MSG_INFO_TYPE_OBJAZTEC 239
#define MSG_INFO_TYPE_LIBAZTEC 240
#define MSG_INFO_TYPE_FONTHEAD 241
#define MSG_INFO_TYPE_WBICON 242
#define MSG_INFO_TYPE_LHARCARC 243
#define MSG_INFO_TYPE_EXECPRG 244
#define MSG_INFO_TYPE_OBJSASC 245
#define MSG_INFO_TYPE_LIBSASC 246
#define MSG_INFO_TYPE_ZOOARC 247
#define MSG_INFO_TYPE_PPCRUNCH 248
#define MSG_INFO_TYPE_PPCRYPT 249
#define MSG_INFO_TYPE_ABACKUP 250
#define MSG_INFO_TYPE_IFFILBM 251
#define MSG_INFO_TYPE_IFFTEXT 252
#define MSG_INFO_TYPE_IFF8SVX 253
#define MSG_INFO_TYPE_IFFANIM 254
#define MSG_INFO_TYPE_IFFOTHER 255
#define MSG_INFO_TYPE_BINARY 256
#define MSG_INFO_TYPE_ASCII 257
#define MSG_INFO_TYPE_XPKF 258
#define MSG_CTYPE_NONE 259
#define MSG_CTYPE_INTERNAL 260
#define MSG_CTYPE_EXTERNAL 261
#define MSG_CTYPE_XPKLIB 262
#define MSG_UNIT_NAME 263
#define MSG_TAPE_NAME 264
#define MSG_TAPE_END_REACHED 265
#define MSG_TAPE_REWINDING 266
#define MSG_TAPE_PROTECTED 267
#define MSG_TAPE_BSIZE_CHANGED 268
#define MSG_TAPE_READ_FAILED 269
#define MSG_TAPE_WRITE_FAILED 270
#define MSG_TAPE_INQUIRY_FAILED 271
#define MSG_TAPE_SENSE_01 272
#define MSG_TAPE_SENSE_02 273
#define MSG_TAPE_SENSE_03 274
#define MSG_TAPE_SENSE_04 275
#define MSG_TAPE_SENSE_05 276
#define MSG_TAPE_SENSE_06 277
#define MSG_TAPE_SENSE_07 278
#define MSG_TAPE_SENSE_0B 279
#define MSG_TAPE_SENSE_0D 280
#define MSG_ARCHIVE_FILE_COMMENT 281
#define MSG_NO_COMMENT 282
#define MSG_BACKUP_LOG 283
#define MSG_LABEL_FILES_BYTES 284
#define MSG_DISK 285

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define MSG_RIGHTS_STR "All Rights Reserved"
#define MSG_TRANSLATION_STR "English built-in strings by Reza Elghazi"
#define MSG_ALERT_KICK_V37PLUS_STR "ABackup requires Kickstart V37+"
#define MSG_WARNING_STR "ABackup Warning"
#define MSG_ERROR_STR "ABackup Error"
#define MSG_REQUEST_STR "ABackup Request"
#define MSG_ERROR_READING_CYLINDER_STR "FATAL ERROR\n\nTrying to read %lu Bytes\nfrom %s!\n(Cylinder %lu, Size %lu)"
#define MSG_ERROR_DEVICE_STR "Device Error #%ld"
#define MSG_ERROR_SCSI_ERROR_STR "SCSI error #%ld"
#define MSG_ERROR_SCSI_DRIVER_STR "SCSI driver error #%ld"
#define MSG_ERROR_SCSI_SENSE_STR "SCSI Sense error #%lx"
#define MSG_ERROR_SYNTAX_STR "File %s, line %ld"
#define MSG_WARN_MEMORY_STR "Not enough memory!"
#define MSG_WARN_ALREADY_RUNNING_STR "ABackup is already running!"
#define MSG_WARN_OPEN_RESOURCES_STR "Unable to open resources!"
#define MSG_WARN_OPEN_IFFPARSE_STR "Requires iffparse.library V36+"
#define MSG_WARN_GET_VISUALINFO_STR "Unable to get information GadTools needs for visuals!"
#define MSG_WARN_OPEN_SCREEN_STR "Unable to open custom screen!"
#define MSG_WARN_LOCK_SCREEN_STR "Unable to lock public screen!"
#define MSG_WARN_LOCK_WBSCREEN_STR "Unable to lock Workbench screen!"
#define MSG_WARN_CREATE_GADGET_STR "Unable to create gadgets!"
#define MSG_WARN_OPEN_WINDOW_STR "Unable to open window!"
#define MSG_WARN_CREATE_MENUS_STR "Unable to create menus!"
#define MSG_WARN_LAYOUT_MENUS_STR "Unable to layout menus!"
#define MSG_WARN_CONTEXT_STR "Unable to create a place\nfor GadTools context data!"
#define MSG_WARN_PREFS_NOT_FOUND_STR "Didn't find the Prefs program!"
#define MSG_WARN_WRITE_PROTECTED_STR "Disk in device\n%s\nis write protected"
#define MSG_WARN_ALLOC_WRITE_BUFFER_STR "Unable to allocate write buffer!\nThe child task has been disabled."
#define MSG_WARN_READ_PROTECTED_STR "%s\nis read protected"
#define MSG_WARN_CLOSE_VISITORS_STR "Please close all visitor windows."
#define MSG_WARN_NOTHING_SELECTED_STR "You must select something!"
#define MSG_WARN_SAME_BACKUP_SET_STR "DISK NOT ACCEPTED\n\nThis is disk %lu of\nthe current backup set!"
#define MSG_WARN_EXTERNAL_NOT_FOUND_STR "Unable to find external program!"
#define MSG_WARN_ARCHIVE_TOO_BIG_STR "Estimated archive size is about\n%lu percent bigger than free space on\n%s"
#define MSG_WARN_CHKSUM_ERROR_STR "checksum error!"
#define MSG_WARN_ENCRYPTION_DISABLED_STR "Encryption disabled!"
#define MSG_WARN_BADCYL_OVERFLOW_STR "Target partition has more than %ld cylinders!\n\nBackup will fail if there are write errors\nat the end of the partition."
#define MSG_WARN_BAD_CYLINDER_STR "CAUTION !\nSome cylinders on the target drive were defectives !\nAlthough ABackup handles such errors, it is recommanded\nthat you verify this backup."
#define MSG_ABERR_CANNOT_OPEN_STR "Couldn't be opened!"
#define MSG_ABERR_DECOMP_ERROR_STR "Decompression error!"
#define MSG_ABERR_WRONG_PASSWORD_STR "Wrong password!"
#define MSG_ABERR_VERIFY_ERROR_STR "Verify error!"
#define MSG_ABERR_BAD_PATTERN_STR "Bad pattern!"
#define MSG_ABERR_BAD_DATE_STR "Invalid date or time!"
#define MSG_ABERR_BAD_BITS_STR "Invalid bit specification"
#define MSG_ABERR_SYNTAX_ERROR_STR "Syntax error"
#define MSG_ABERR_BACKUP_TO_ITSELF_STR "Unable to backup a device into itself!"
#define MSG_ABERR_NOT_A_TAPE_STR "Not a tape!"
#define MSG_ABERR_READ_ERROR_STR "Read error!"
#define MSG_ABERR_COPYCAT_FAILED_STR "Couldn't duplicate catalog to specified file!"
#define MSG_ABERR_NOT_AN_ARCHIVE_STR "Not an ABackup archive!"
#define MSG_ABERR_BAD_FORMAT_STR "Not in expected format!"
#define MSG_TDERR_NOSECHDR_STR "couldn't find sector header!"
#define MSG_TDERR_BADSECPRE_STR "bad sector preample!"
#define MSG_TDERR_BADSECID_STR "bad sector ID!"
#define MSG_TDERR_BADHDRSUM_STR "bad header checksum!"
#define MSG_TDERR_BADSECSUM_STR "bad sector checksum!"
#define MSG_TDERR_TOOFEWSECS_STR "not enough sectors!"
#define MSG_TDERR_BADSECHDR_STR "bad sector header!"
#define MSG_TDERR_SEEKERROR_STR "couldn't find track zero!"
#define MSG_WIN_TITLE_MAIN_STR "ABackup Main Menu"
#define MSG_WIN_TITLE_LOADING_TREE_STR "Loading directory tree..."
#define MSG_WIN_TITLE_LOADING_CATALOG_STR "Loading catalog..."
#define MSG_WIN_TITLE_INFOS_STR "Backup Informations"
#define MSG_WIN_TITLE_BACKUP_SELECTION_STR "Backup Selection"
#define MSG_WIN_TITLE_RESTORE_SELECTION_STR "Restore Selection"
#define MSG_WIN_TITLE_VERIFY_SELECTION_STR "Verify Selection"
#define MSG_WIN_TITLE_BACKUP_STR "Backup"
#define MSG_WIN_TITLE_RESTORE_STR "Restore"
#define MSG_WIN_TITLE_VERIFY_STR "Verify"
#define MSG_WIN_TITLE_REBUILD_STR "Rebuild"
#define MSG_WIN_TITLE_ABOUT_STR "About ABackup..."
#define MSG_WIN_TITLE_ARCREQ_STR "Select the archive..."
#define MSG_PROJECT_MENU_STR "Project"
#define MSG_PROJECT_ESTIMATE_STR "Estimate"
#define MSG_PROJECT_ESTIMATE_CK_STR "E"
#define MSG_PROJECT_PRINT_STR "Print current list"
#define MSG_PROJECT_PRINT_CK_STR "P"
#define MSG_PROJECT_ADDDIR_STR "Add directory"
#define MSG_PROJECT_ADDDIR_CK_STR "N"
#define MSG_PROJECT_ABOUT_STR "About..."
#define MSG_PROJECT_ABOUT_CK_STR "?"
#define MSG_PROJECT_QUIT_STR "Quit"
#define MSG_PROJECT_QUIT_CK_STR "Q"
#define MSG_SELECT_MENU_STR "Selection"
#define MSG_SELECT_OPEN_STR "Open..."
#define MSG_SELECT_OPEN_CK_STR "O"
#define MSG_SELECT_RECORD_STR "Record"
#define MSG_SELECT_RECORD_CK_STR "R"
#define MSG_SELECT_SAVE_STR "Save..."
#define MSG_SELECT_SAVE_CK_STR "S"
#define MSG_SELECT_ABORT_STR "Abort recording"
#define MSG_SELECT_ABORT_CK_STR "A"
#define MSG_BACKUP_FILES_STR "_Backup Files & Dirs"
#define MSG_BACKUP_PARTITIONS_STR "Backup P_artitions"
#define MSG_RESTORE_STR "_Restore"
#define MSG_VERIFY_STR "_Verify"
#define MSG_REBUILD_CATALOG_STR "Rebuild _Catalog"
#define MSG_PREFERENCES_STR "_Preferences"
#define MSG_LOADING_TREE_STR "Loading..."
#define MSG_SORTING_TREE_STR "Sorting..."
#define MSG_SEARCHING_CATALOG_STR "Searching..."
#define MSG_ANALYSING_CATALOG_STR "Analysing catalog..."
#define MSG_CATALOG_STR "Backup catalog"
#define MSG_BACKUP_DATE_STR "Date:"
#define MSG_BACKUP_TIME_STR "Time:"
#define MSG_BACKUP_SIZE_STR "Bytes:"
#define MSG_BACKUP_COMMENT_STR "Comment:"
#define MSG_CONTINUE_STR "_Continue"
#define MSG_DRAWER_STR "Drawer"
#define MSG_LINK_STR "Link"
#define MSG_FILES_STR "Files:"
#define MSG_PARTITIONS_STR "Partitions:"
#define MSG_SIZE_STR "Size:"
#define MSG_BYTES_STR "Bytes"
#define MSG_KILOBYTES_STR "Kilo-Bytes"
#define MSG_KILOBYTES_SHORT_STR "KB"
#define MSG_MEGABYTES_STR "Mega-Bytes"
#define MSG_MEGABYTES_SHORT_STR "MB"
#define MSG_RECURSIVE_STR "Rec_ursive"
#define MSG_FILTER_STR "_Filter:"
#define MSG_INCLUDE_STR "Include"
#define MSG_EXCLUDE_STR "Exclude"
#define MSG_ALL_STR "_All"
#define MSG_REVERSE_STR "R_everse"
#define MSG_BYNAME_STR "By _Name"
#define MSG_BYDATE_STR "By _Date"
#define MSG_BYBITS_STR "By B_its"
#define MSG_DIRECTORY_STR "Directory:"
#define MSG_ROOT_STR "R_oot"
#define MSG_PARENT_STR "_Parent"
#define MSG_START_BACKUP_STR "_Backup"
#define MSG_START_RESTORE_STR "_Restore"
#define MSG_START_VERIFY_STR "_Verify"
#define MSG_CANCEL_STR "_Cancel"
#define MSG_OK_STR "_Ok"
#define MSG_CYLINDER_SHORT_STR "Cyls"
#define MSG_SAVED_STR "Saved:"
#define MSG_RESTORED_STR "Restored:"
#define MSG_VERIFIED_STR "Verified:"
#define MSG_READ_STR "Read:"
#define MSG_LEFT_STR "Left:"
#define MSG_DISKNUMBER_STR "Disk Number:"
#define MSG_COMPRESSION_STR "Compression:"
#define MSG_SOURCE_STR "Source:"
#define MSG_DESTINATION_STR "Destination:"
#define MSG_PAUSE_STR "_Pause"
#define MSG_ABORT_STR "_Abort"
#define MSG_RESTORING_LINKS_STR "Restoring links..."
#define MSG_ARC_TYPE_STR "_Type:"
#define MSG_ARC_FROM_DEVICE_STR "Device"
#define MSG_ARC_FROM_FILE_STR "File"
#define MSG_ARC_FROM_TAPE_STR "Tape"
#define MSG_ARC_CATFILE_STR "_Use Catalog File"
#define MSG_ARC_FILE_STR "Archive _File:"
#define MSG_REQ_TITLE_DIR_REQUESTER_STR "Select a directory"
#define MSG_REQ_TITLE_REPORT_FILE_STR "Select a report file..."
#define MSG_REQ_TITLE_SELECTION_FILE_STR "Choose a selection file..."
#define MSG_REQ_TITLE_LOAD_CATALOG_STR "Load catalog from..."
#define MSG_REQ_TITLE_SAVE_CATALOG_STR "Save catalog to..."
#define MSG_REQ_QUIT_STR "Do you really want to quit?"
#define MSG_REQ_REPLACE_STR "Do you really want to replace file\n\n%s\n(%lu Bytes, %s)\n\nby its archived version\n(%lu Bytes, %s)?"
#define MSG_REQ_EXISTS_RENAME_STR "already exists, enter new name"
#define MSG_REQ_DELETE_BAD_FILE_STR "An error occured while restoring\n%s\nDo you want to delete this file ?"
#define MSG_REQ_OK_CANCEL_STR "Ok|Cancel"
#define MSG_REQ_RETRY_CANCEL_STR "Retry|Cancel"
#define MSG_REQ_CONTINUE_ABORT_STR "Continue|Abort"
#define MSG_REQ_YES_NO_STR "Yes|No"
#define MSG_REQ_OK_STR "Ok"
#define MSG_REQ_REPLACE_SKIP_STR "Replace|Skip|Abort"
#define MSG_REQ_RESTORE_FAILED_STR "Failed to restore\n%s"
#define MSG_REQ_BACKUP_FAILED_STR "Failed to backup\n%s"
#define MSG_REQ_VERIFY_FAILED_STR "Error while verifying\n%s"
#define MSG_REQ_INSERT_DISK_STR "Please insert disk %lu\nin drive %s"
#define MSG_REQ_INSERT_LAST_DISK_STR "Please insert last disk\nin drive %s"
#define MSG_REQ_INSERT_NEXT_DISK_STR "Please insert next disk\nin drive %s"
#define MSG_REQ_INSERT_NEW_DISK_STR "Please insert a new disk\nin drive %s"
#define MSG_REQ_OVERWRITE_STR "\nDo you really want to overwrite it?"
#define MSG_REQ_MISC_DISK_STR "Volume %s\nis %lu percent full.\n%s"
#define MSG_REQ_CRYPT_DISK_STR "Volume in %s is\nan encrypted archive.\n%s"
#define MSG_REQ_OLD_BACKUP_DISK_STR "Volume in %s is disk %lu\nof a previous backup made\n%s.\n%s"
#define MSG_REQ_OVERWRITE_TAPE_STR "CAUTION!\nAll data currently on\nthe tape will be lost!"
#define MSG_REQ_FILE_EXISTS_STR "File %s\nalready exists.\n%s"
#define MSG_REQ_WRONG_DISK_STR "WRONG DISK\n\nThis is disk %lu!"
#define MSG_REQ_ABORT_STR "Do you really want to abort?"
#define MSG_REQ_FINISHED_STR "Operation finished\nDo you want to return to main menu?"
#define MSG_REQ_SELECTION_STR "File Selection"
#define MSG_REQ_PATTERN_STR "Enter Name or Pattern:"
#define MSG_REQ_PATTERN_GAD_STR "_Match|_No Match"
#define MSG_REQ_DATE_STR "Enter Date and/or Time:"
#define MSG_REQ_DATE_GAD_STR "_Before|_After"
#define MSG_REQ_BITS_STR "Select Protection Bits:"
#define MSG_REQ_PASSWORD_STR "Enter Password:"
#define MSG_REQ_NEED_MEMORY_STR "ABackup needs at least\n%lu KBytes of memory\nto continue..."
#define MSG_REQ_ESTIMATION_STR "Backup operation requires at least %lu DD disk(s)\n(archive size is estimated around %lu KBytes)\nand will last for about %s."
#define MSG_REQ_FILE_MODIFIED_STR "File %s\nhas been modified after backup!"
#define MSG_REQ_FILES_NOTEQUAL_STR "Comparison failed for\n%s!"
#define MSG_REQ_COMMENT_STR "Enter Comment:"
#define MSG_REQ_TAPE_NOT_READY_STR "Tape unit is not ready!"
#define MSG_REQ_CHKSUM_ERROR_STR "%s\nhas a checksum error!"
#define MSG_REQ_PREPARE_LABEL_STR "Please prepare your printer\nfor labels printing"
#define MSG_REQ_ACCESS_DENIED_STR "%s:\naccess denied !"
#define MSG_MONITOR_READING_STR "Reading"
#define MSG_MONITOR_WRITING_STR "Writing"
#define MSG_MONITOR_CRUNCHING_STR "Crunching"
#define MSG_MONITOR_COMPARING_STR "Comparing"
#define MSG_MONITOR_BACKEDUP_STR "Stored"
#define MSG_MONITOR_RESTORED_STR "%lu"
#define MSG_MONITOR_VERIFIED_STR "Verified"
#define MSG_MONITOR_SKIPPED_STR "Skipped"
#define MSG_MONITOR_CYLINDER_STR "%s, cylinder %lu"
#define MSG_MONITOR_ERROR_STR "Error"
#define MSG_MONITOR_CATALOG_STR "Catalog"
#define MSG_ARCHIVE_CLOSED_STR "Archive closed"
#define MSG_SETTING_ARCHIVE_BITS_STR "Setting archive bits"
#define MSG_REPORT_BREAKED_STR "\n*** Aborted by user!\n"
#define MSG_REPORT_BACKUP_STR "Backup"
#define MSG_REPORT_RESTORE_STR "Restore"
#define MSG_REPORT_VERIFY_STR "Verify"
#define MSG_REPORT_HEADER1_STR "%s %s - %s report made %s\n\n"
#define MSG_REPORT_HEADER2_STR "Root directory:"
#define MSG_REPORT_HEADER3_STR "Archive       : %s\n\n"
#define MSG_REPORT_FOOTER1_STR "\nTotal: %lu object(s), %lu byte(s)\n"
#define MSG_REPORT_FOOTER2_STR "Time : %s\n"
#define MSG_REPORT_BAD_CYLINDER_STR "%-48s cylinder %lu of disk %lu is bad (skipped)\n"
#define MSG_REPORT_BAD_FILE_STR "error during restore (deleted)"
#define MSG_REPORT_NOT_REPLACED_STR "already exists (not replaced)"
#define MSG_REPORT_RENAMED_STR "%s restored as %s\n"
#define MSG_REPORT_NOT_FOUND_STR "Not found"
#define MSG_REPORT_COULD_NOT_BACKUP_STR "not backed up"
#define MSG_REPORT_COULD_NOT_RESTORE_STR "not restored"
#define MSG_REPORT_COULD_NOT_VERIFY_STR "not verified"
#define MSG_REPORT_FILE_MODIFIED_STR "File has been modified after backup"
#define MSG_REPORT_COMPARE_FAILED_STR "Comparison failed"
#define MSG_REPORT_OPENING_STR "Opening report file..."
#define MSG_REPORT_ACCESS_DENIED_STR "access denied on a protected object"
#define MSG_INFO_DEVICE_STR "Device: %s\n\nDriver: %s\nUnit: %lu\nHeads: %lu\nBlocks/Tracks: %lu\nBlock Size: %lu\nLow Cylinder: %lu\nHigh Cylinder: %lu"
#define MSG_INFO_LINK_STR "%s\nis a link to\n%s"
#define MSG_INFO_TYPE_EMPTY_STR "Empty File"
#define MSG_INFO_TYPE_OBJAZTEC_STR "Aztec C Object File"
#define MSG_INFO_TYPE_LIBAZTEC_STR "Aztec C Link Library"
#define MSG_INFO_TYPE_FONTHEAD_STR "Font Header"
#define MSG_INFO_TYPE_WBICON_STR "Workbench Icon"
#define MSG_INFO_TYPE_LHARCARC_STR "LhA archive File"
#define MSG_INFO_TYPE_EXECPRG_STR "Executable File"
#define MSG_INFO_TYPE_OBJSASC_STR "SAS/C Object File"
#define MSG_INFO_TYPE_LIBSASC_STR "SAS/C Link Library"
#define MSG_INFO_TYPE_ZOOARC_STR "Zoo Archive"
#define MSG_INFO_TYPE_PPCRUNCH_STR "PowerPacker Crunched Data"
#define MSG_INFO_TYPE_PPCRYPT_STR "PowerPacker Crypted Data"
#define MSG_INFO_TYPE_ABACKUP_STR "ABackup Archive"
#define MSG_INFO_TYPE_IFFILBM_STR "IFF ILBM Picture"
#define MSG_INFO_TYPE_IFFTEXT_STR "IFF TEXT File"
#define MSG_INFO_TYPE_IFF8SVX_STR "IFF 8SVX Sound"
#define MSG_INFO_TYPE_IFFANIM_STR "IFF ANIM Animation"
#define MSG_INFO_TYPE_IFFOTHER_STR "IFF File"
#define MSG_INFO_TYPE_BINARY_STR "Binary File"
#define MSG_INFO_TYPE_ASCII_STR "ASCII Text File"
#define MSG_INFO_TYPE_XPKF_STR "XPK Compressed File"
#define MSG_CTYPE_NONE_STR "None"
#define MSG_CTYPE_INTERNAL_STR "Internal"
#define MSG_CTYPE_EXTERNAL_STR "External"
#define MSG_CTYPE_XPKLIB_STR "Xpk library (%s)"
#define MSG_UNIT_NAME_STR "Unit %ld of %s"
#define MSG_TAPE_NAME_STR "Tape"
#define MSG_TAPE_END_REACHED_STR "End of tape reached!"
#define MSG_TAPE_REWINDING_STR "Rewinding tape..."
#define MSG_TAPE_PROTECTED_STR "Tape is write protected!"
#define MSG_TAPE_BSIZE_CHANGED_STR "Tape block size changed to\nbuiltin value (%lu bytes)"
#define MSG_TAPE_READ_FAILED_STR "Couldn't read %ld bytes from tape\n%s"
#define MSG_TAPE_WRITE_FAILED_STR "Couldn't write %ld bytes to tape\n%s"
#define MSG_TAPE_INQUIRY_FAILED_STR "Couldn't verify device type\n%s"
#define MSG_TAPE_SENSE_01_STR "Recovered error (sense error #%lx)"
#define MSG_TAPE_SENSE_02_STR "Unit not ready (sense error #%lx)"
#define MSG_TAPE_SENSE_03_STR "Medium error (sense error #%lx)"
#define MSG_TAPE_SENSE_04_STR "Hardware error (sense error #%lx)"
#define MSG_TAPE_SENSE_05_STR "Illegal request (sense error #%lx)"
#define MSG_TAPE_SENSE_06_STR "Unit attention (sense error #%lx)"
#define MSG_TAPE_SENSE_07_STR "Data protected (sense error #%lx)"
#define MSG_TAPE_SENSE_0B_STR "Command aborted (sense error #%lx)"
#define MSG_TAPE_SENSE_0D_STR "Volume overflow (sense error #%lx)"
#define MSG_ARCHIVE_FILE_COMMENT_STR "%s %s archive file"
#define MSG_NO_COMMENT_STR "None"
#define MSG_BACKUP_LOG_STR "On %s, backed up %s (%lu files, %lu KBytes) to %s"
#define MSG_LABEL_FILES_BYTES_STR "%lu files, %lu bytes\n"
#define MSG_DISK_STR "Disk"

#endif /* CATCOMP_STRINGS */


/****************************************************************************/


#ifdef CATCOMP_BLOCK

static const char CatCompBlock[] =
{
    "\x00\x00\x00\x00\x00\x14"
    MSG_RIGHTS_STR "\x00"
    "\x00\x00\x00\x01\x00\x2A"
    MSG_TRANSLATION_STR "\x00\x00"
    "\x00\x00\x00\x02\x00\x20"
    MSG_ALERT_KICK_V37PLUS_STR "\x00"
    "\x00\x00\x00\x03\x00\x10"
    MSG_WARNING_STR "\x00"
    "\x00\x00\x00\x04\x00\x0E"
    MSG_ERROR_STR "\x00"
    "\x00\x00\x00\x05\x00\x10"
    MSG_REQUEST_STR "\x00"
    "\x00\x00\x00\x06\x00\x48"
    MSG_ERROR_READING_CYLINDER_STR "\x00"
    "\x00\x00\x00\x07\x00\x12"
    MSG_ERROR_DEVICE_STR "\x00"
    "\x00\x00\x00\x08\x00\x10"
    MSG_ERROR_SCSI_ERROR_STR "\x00"
    "\x00\x00\x00\x09\x00\x18"
    MSG_ERROR_SCSI_DRIVER_STR "\x00\x00"
    "\x00\x00\x00\x0A\x00\x16"
    MSG_ERROR_SCSI_SENSE_STR "\x00"
    "\x00\x00\x00\x0B\x00\x12"
    MSG_ERROR_SYNTAX_STR "\x00"
    "\x00\x00\x00\x0C\x00\x14"
    MSG_WARN_MEMORY_STR "\x00\x00"
    "\x00\x00\x00\x0D\x00\x1C"
    MSG_WARN_ALREADY_RUNNING_STR "\x00"
    "\x00\x00\x00\x0E\x00\x1A"
    MSG_WARN_OPEN_RESOURCES_STR "\x00"
    "\x00\x00\x00\x0F\x00\x20"
    MSG_WARN_OPEN_IFFPARSE_STR "\x00\x00"
    "\x00\x00\x00\x10\x00\x36"
    MSG_WARN_GET_VISUALINFO_STR "\x00"
    "\x00\x00\x00\x11\x00\x1E"
    MSG_WARN_OPEN_SCREEN_STR "\x00"
    "\x00\x00\x00\x12\x00\x1E"
    MSG_WARN_LOCK_SCREEN_STR "\x00"
    "\x00\x00\x00\x13\x00\x22"
    MSG_WARN_LOCK_WBSCREEN_STR "\x00\x00"
    "\x00\x00\x00\x14\x00\x1A"
    MSG_WARN_CREATE_GADGET_STR "\x00"
    "\x00\x00\x00\x15\x00\x18"
    MSG_WARN_OPEN_WINDOW_STR "\x00\x00"
    "\x00\x00\x00\x16\x00\x18"
    MSG_WARN_CREATE_MENUS_STR "\x00"
    "\x00\x00\x00\x17\x00\x18"
    MSG_WARN_LAYOUT_MENUS_STR "\x00"
    "\x00\x00\x00\x18\x00\x34"
    MSG_WARN_CONTEXT_STR "\x00"
    "\x00\x00\x00\x19\x00\x20"
    MSG_WARN_PREFS_NOT_FOUND_STR "\x00\x00"
    "\x00\x00\x00\x1A\x00\x26"
    MSG_WARN_WRITE_PROTECTED_STR "\x00\x00"
    "\x00\x00\x00\x1B\x00\x44"
    MSG_WARN_ALLOC_WRITE_BUFFER_STR "\x00\x00"
    "\x00\x00\x00\x1C\x00\x16"
    MSG_WARN_READ_PROTECTED_STR "\x00\x00"
    "\x00\x00\x00\x1D\x00\x22"
    MSG_WARN_CLOSE_VISITORS_STR "\x00"
    "\x00\x00\x00\x1E\x00\x1C"
    MSG_WARN_NOTHING_SELECTED_STR "\x00\x00"
    "\x00\x00\x00\x1F\x00\x40"
    MSG_WARN_SAME_BACKUP_SET_STR "\x00\x00"
    "\x00\x00\x00\x20\x00\x22"
    MSG_WARN_EXTERNAL_NOT_FOUND_STR "\x00\x00"
    "\x00\x00\x00\x21\x00\x4A"
    MSG_WARN_ARCHIVE_TOO_BIG_STR "\x00\x00"
    "\x00\x00\x00\x22\x00\x10"
    MSG_WARN_CHKSUM_ERROR_STR "\x00"
    "\x00\x00\x00\x23\x00\x16"
    MSG_WARN_ENCRYPTION_DISABLED_STR "\x00\x00"
    "\x00\x00\x00\x24\x00\x78"
    MSG_WARN_BADCYL_OVERFLOW_STR "\x00\x00"
    "\x00\x00\x00\x25\x00\x94"
    MSG_WARN_BAD_CYLINDER_STR "\x00"
    "\x00\x00\x00\x26\x00\x14"
    MSG_ABERR_CANNOT_OPEN_STR "\x00"
    "\x00\x00\x00\x27\x00\x16"
    MSG_ABERR_DECOMP_ERROR_STR "\x00\x00"
    "\x00\x00\x00\x28\x00\x10"
    MSG_ABERR_WRONG_PASSWORD_STR "\x00"
    "\x00\x00\x00\x29\x00\x0E"
    MSG_ABERR_VERIFY_ERROR_STR "\x00"
    "\x00\x00\x00\x2A\x00\x0E"
    MSG_ABERR_BAD_PATTERN_STR "\x00\x00"
    "\x00\x00\x00\x2B\x00\x16"
    MSG_ABERR_BAD_DATE_STR "\x00"
    "\x00\x00\x00\x2C\x00\x1A"
    MSG_ABERR_BAD_BITS_STR "\x00"
    "\x00\x00\x00\x2D\x00\x0E"
    MSG_ABERR_SYNTAX_ERROR_STR "\x00\x00"
    "\x00\x00\x00\x2E\x00\x28"
    MSG_ABERR_BACKUP_TO_ITSELF_STR "\x00\x00"
    "\x00\x00\x00\x2F\x00\x0C"
    MSG_ABERR_NOT_A_TAPE_STR "\x00"
    "\x00\x00\x00\x30\x00\x0C"
    MSG_ABERR_READ_ERROR_STR "\x00"
    "\x00\x00\x00\x31\x00\x2E"
    MSG_ABERR_COPYCAT_FAILED_STR "\x00"
    "\x00\x00\x00\x32\x00\x18"
    MSG_ABERR_NOT_AN_ARCHIVE_STR "\x00"
    "\x00\x00\x00\x33\x00\x18"
    MSG_ABERR_BAD_FORMAT_STR "\x00"
    "\x00\x00\x00\x34\x00\x1E"
    MSG_TDERR_NOSECHDR_STR "\x00\x00"
    "\x00\x00\x00\x35\x00\x16"
    MSG_TDERR_BADSECPRE_STR "\x00\x00"
    "\x00\x00\x00\x36\x00\x10"
    MSG_TDERR_BADSECID_STR "\x00\x00"
    "\x00\x00\x00\x37\x00\x16"
    MSG_TDERR_BADHDRSUM_STR "\x00\x00"
    "\x00\x00\x00\x38\x00\x16"
    MSG_TDERR_BADSECSUM_STR "\x00\x00"
    "\x00\x00\x00\x39\x00\x14"
    MSG_TDERR_TOOFEWSECS_STR "\x00"
    "\x00\x00\x00\x3A\x00\x14"
    MSG_TDERR_BADSECHDR_STR "\x00\x00"
    "\x00\x00\x00\x3B\x00\x1A"
    MSG_TDERR_SEEKERROR_STR "\x00"
    "\x00\x00\x00\x3C\x00\x12"
    MSG_WIN_TITLE_MAIN_STR "\x00"
    "\x00\x00\x00\x3D\x00\x1A"
    MSG_WIN_TITLE_LOADING_TREE_STR "\x00"
    "\x00\x00\x00\x3E\x00\x14"
    MSG_WIN_TITLE_LOADING_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x3F\x00\x14"
    MSG_WIN_TITLE_INFOS_STR "\x00"
    "\x00\x00\x00\x40\x00\x12"
    MSG_WIN_TITLE_BACKUP_SELECTION_STR "\x00\x00"
    "\x00\x00\x00\x41\x00\x12"
    MSG_WIN_TITLE_RESTORE_SELECTION_STR "\x00"
    "\x00\x00\x00\x42\x00\x12"
    MSG_WIN_TITLE_VERIFY_SELECTION_STR "\x00\x00"
    "\x00\x00\x00\x43\x00\x08"
    MSG_WIN_TITLE_BACKUP_STR "\x00\x00"
    "\x00\x00\x00\x44\x00\x08"
    MSG_WIN_TITLE_RESTORE_STR "\x00"
    "\x00\x00\x00\x45\x00\x08"
    MSG_WIN_TITLE_VERIFY_STR "\x00\x00"
    "\x00\x00\x00\x46\x00\x08"
    MSG_WIN_TITLE_REBUILD_STR "\x00"
    "\x00\x00\x00\x47\x00\x12"
    MSG_WIN_TITLE_ABOUT_STR "\x00\x00"
    "\x00\x00\x00\x48\x00\x16"
    MSG_WIN_TITLE_ARCREQ_STR "\x00"
    "\x00\x00\x00\x49\x00\x08"
    MSG_PROJECT_MENU_STR "\x00"
    "\x00\x00\x00\x4A\x00\x0A"
    MSG_PROJECT_ESTIMATE_STR "\x00\x00"
    "\x00\x00\x00\x4B\x00\x02"
    MSG_PROJECT_ESTIMATE_CK_STR "\x00"
    "\x00\x00\x00\x4C\x00\x14"
    MSG_PROJECT_PRINT_STR "\x00\x00"
    "\x00\x00\x00\x4D\x00\x02"
    MSG_PROJECT_PRINT_CK_STR "\x00"
    "\x00\x00\x00\x4E\x00\x0E"
    MSG_PROJECT_ADDDIR_STR "\x00"
    "\x00\x00\x00\x4F\x00\x02"
    MSG_PROJECT_ADDDIR_CK_STR "\x00"
    "\x00\x00\x00\x50\x00\x0A"
    MSG_PROJECT_ABOUT_STR "\x00\x00"
    "\x00\x00\x00\x51\x00\x02"
    MSG_PROJECT_ABOUT_CK_STR "\x00"
    "\x00\x00\x00\x52\x00\x06"
    MSG_PROJECT_QUIT_STR "\x00\x00"
    "\x00\x00\x00\x53\x00\x02"
    MSG_PROJECT_QUIT_CK_STR "\x00"
    "\x00\x00\x00\x54\x00\x0A"
    MSG_SELECT_MENU_STR "\x00"
    "\x00\x00\x00\x55\x00\x08"
    MSG_SELECT_OPEN_STR "\x00"
    "\x00\x00\x00\x56\x00\x02"
    MSG_SELECT_OPEN_CK_STR "\x00"
    "\x00\x00\x00\x57\x00\x08"
    MSG_SELECT_RECORD_STR "\x00\x00"
    "\x00\x00\x00\x58\x00\x02"
    MSG_SELECT_RECORD_CK_STR "\x00"
    "\x00\x00\x00\x59\x00\x08"
    MSG_SELECT_SAVE_STR "\x00"
    "\x00\x00\x00\x5A\x00\x02"
    MSG_SELECT_SAVE_CK_STR "\x00"
    "\x00\x00\x00\x5B\x00\x10"
    MSG_SELECT_ABORT_STR "\x00"
    "\x00\x00\x00\x5C\x00\x02"
    MSG_SELECT_ABORT_CK_STR "\x00"
    "\x00\x00\x00\x5D\x00\x16"
    MSG_BACKUP_FILES_STR "\x00\x00"
    "\x00\x00\x00\x5E\x00\x14"
    MSG_BACKUP_PARTITIONS_STR "\x00\x00"
    "\x00\x00\x00\x5F\x00\x0A"
    MSG_RESTORE_STR "\x00\x00"
    "\x00\x00\x00\x60\x00\x08"
    MSG_VERIFY_STR "\x00"
    "\x00\x00\x00\x61\x00\x12"
    MSG_REBUILD_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x62\x00\x0E"
    MSG_PREFERENCES_STR "\x00\x00"
    "\x00\x00\x00\x63\x00\x0C"
    MSG_LOADING_TREE_STR "\x00\x00"
    "\x00\x00\x00\x64\x00\x0C"
    MSG_SORTING_TREE_STR "\x00\x00"
    "\x00\x00\x00\x65\x00\x0E"
    MSG_SEARCHING_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x66\x00\x16"
    MSG_ANALYSING_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x67\x00\x10"
    MSG_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x68\x00\x06"
    MSG_BACKUP_DATE_STR "\x00"
    "\x00\x00\x00\x69\x00\x06"
    MSG_BACKUP_TIME_STR "\x00"
    "\x00\x00\x00\x6A\x00\x08"
    MSG_BACKUP_SIZE_STR "\x00\x00"
    "\x00\x00\x00\x6B\x00\x0A"
    MSG_BACKUP_COMMENT_STR "\x00\x00"
    "\x00\x00\x00\x6C\x00\x0A"
    MSG_CONTINUE_STR "\x00"
    "\x00\x00\x00\x6D\x00\x08"
    MSG_DRAWER_STR "\x00\x00"
    "\x00\x00\x00\x6E\x00\x06"
    MSG_LINK_STR "\x00\x00"
    "\x00\x00\x00\x6F\x00\x08"
    MSG_FILES_STR "\x00\x00"
    "\x00\x00\x00\x70\x00\x0C"
    MSG_PARTITIONS_STR "\x00"
    "\x00\x00\x00\x71\x00\x06"
    MSG_SIZE_STR "\x00"
    "\x00\x00\x00\x72\x00\x06"
    MSG_BYTES_STR "\x00"
    "\x00\x00\x00\x73\x00\x0C"
    MSG_KILOBYTES_STR "\x00\x00"
    "\x00\x00\x00\x74\x00\x04"
    MSG_KILOBYTES_SHORT_STR "\x00\x00"
    "\x00\x00\x00\x75\x00\x0C"
    MSG_MEGABYTES_STR "\x00\x00"
    "\x00\x00\x00\x76\x00\x04"
    MSG_MEGABYTES_SHORT_STR "\x00\x00"
    "\x00\x00\x00\x77\x00\x0C"
    MSG_RECURSIVE_STR "\x00\x00"
    "\x00\x00\x00\x78\x00\x0A"
    MSG_FILTER_STR "\x00\x00"
    "\x00\x00\x00\x79\x00\x08"
    MSG_INCLUDE_STR "\x00"
    "\x00\x00\x00\x7A\x00\x08"
    MSG_EXCLUDE_STR "\x00"
    "\x00\x00\x00\x7B\x00\x06"
    MSG_ALL_STR "\x00\x00"
    "\x00\x00\x00\x7C\x00\x0A"
    MSG_REVERSE_STR "\x00\x00"
    "\x00\x00\x00\x7D\x00\x0A"
    MSG_BYNAME_STR "\x00\x00"
    "\x00\x00\x00\x7E\x00\x0A"
    MSG_BYDATE_STR "\x00\x00"
    "\x00\x00\x00\x7F\x00\x0A"
    MSG_BYBITS_STR "\x00\x00"
    "\x00\x00\x00\x80\x00\x0C"
    MSG_DIRECTORY_STR "\x00\x00"
    "\x00\x00\x00\x81\x00\x06"
    MSG_ROOT_STR "\x00"
    "\x00\x00\x00\x82\x00\x08"
    MSG_PARENT_STR "\x00"
    "\x00\x00\x00\x83\x00\x08"
    MSG_START_BACKUP_STR "\x00"
    "\x00\x00\x00\x84\x00\x0A"
    MSG_START_RESTORE_STR "\x00\x00"
    "\x00\x00\x00\x85\x00\x08"
    MSG_START_VERIFY_STR "\x00"
    "\x00\x00\x00\x86\x00\x08"
    MSG_CANCEL_STR "\x00"
    "\x00\x00\x00\x87\x00\x04"
    MSG_OK_STR "\x00"
    "\x00\x00\x00\x88\x00\x06"
    MSG_CYLINDER_SHORT_STR "\x00\x00"
    "\x00\x00\x00\x89\x00\x08"
    MSG_SAVED_STR "\x00\x00"
    "\x00\x00\x00\x8A\x00\x0A"
    MSG_RESTORED_STR "\x00"
    "\x00\x00\x00\x8B\x00\x0A"
    MSG_VERIFIED_STR "\x00"
    "\x00\x00\x00\x8C\x00\x06"
    MSG_READ_STR "\x00"
    "\x00\x00\x00\x8D\x00\x06"
    MSG_LEFT_STR "\x00"
    "\x00\x00\x00\x8E\x00\x0E"
    MSG_DISKNUMBER_STR "\x00\x00"
    "\x00\x00\x00\x8F\x00\x0E"
    MSG_COMPRESSION_STR "\x00\x00"
    "\x00\x00\x00\x90\x00\x08"
    MSG_SOURCE_STR "\x00"
    "\x00\x00\x00\x91\x00\x0E"
    MSG_DESTINATION_STR "\x00\x00"
    "\x00\x00\x00\x92\x00\x08"
    MSG_PAUSE_STR "\x00\x00"
    "\x00\x00\x00\x93\x00\x08"
    MSG_ABORT_STR "\x00\x00"
    "\x00\x00\x00\x94\x00\x14"
    MSG_RESTORING_LINKS_STR "\x00\x00"
    "\x00\x00\x00\x95\x00\x08"
    MSG_ARC_TYPE_STR "\x00\x00"
    "\x00\x00\x00\x96\x00\x08"
    MSG_ARC_FROM_DEVICE_STR "\x00\x00"
    "\x00\x00\x00\x97\x00\x06"
    MSG_ARC_FROM_FILE_STR "\x00\x00"
    "\x00\x00\x00\x98\x00\x06"
    MSG_ARC_FROM_TAPE_STR "\x00\x00"
    "\x00\x00\x00\x99\x00\x12"
    MSG_ARC_CATFILE_STR "\x00"
    "\x00\x00\x00\x9A\x00\x10"
    MSG_ARC_FILE_STR "\x00\x00"
    "\x00\x00\x00\x9B\x00\x14"
    MSG_REQ_TITLE_DIR_REQUESTER_STR "\x00\x00"
    "\x00\x00\x00\x9C\x00\x18"
    MSG_REQ_TITLE_REPORT_FILE_STR "\x00"
    "\x00\x00\x00\x9D\x00\x1C"
    MSG_REQ_TITLE_SELECTION_FILE_STR "\x00\x00"
    "\x00\x00\x00\x9E\x00\x16"
    MSG_REQ_TITLE_LOAD_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\x9F\x00\x14"
    MSG_REQ_TITLE_SAVE_CATALOG_STR "\x00\x00"
    "\x00\x00\x00\xA0\x00\x1C"
    MSG_REQ_QUIT_STR "\x00"
    "\x00\x00\x00\xA1\x00\x62"
    MSG_REQ_REPLACE_STR "\x00\x00"
    "\x00\x00\x00\xA2\x00\x20"
    MSG_REQ_EXISTS_RENAME_STR "\x00\x00"
    "\x00\x00\x00\xA3\x00\x46"
    MSG_REQ_DELETE_BAD_FILE_STR "\x00"
    "\x00\x00\x00\xA4\x00\x0A"
    MSG_REQ_OK_CANCEL_STR "\x00"
    "\x00\x00\x00\xA5\x00\x0E"
    MSG_REQ_RETRY_CANCEL_STR "\x00\x00"
    "\x00\x00\x00\xA6\x00\x10"
    MSG_REQ_CONTINUE_ABORT_STR "\x00\x00"
    "\x00\x00\x00\xA7\x00\x08"
    MSG_REQ_YES_NO_STR "\x00\x00"
    "\x00\x00\x00\xA8\x00\x04"
    MSG_REQ_OK_STR "\x00\x00"
    "\x00\x00\x00\xA9\x00\x14"
    MSG_REQ_REPLACE_SKIP_STR "\x00\x00"
    "\x00\x00\x00\xAA\x00\x16"
    MSG_REQ_RESTORE_FAILED_STR "\x00\x00"
    "\x00\x00\x00\xAB\x00\x14"
    MSG_REQ_BACKUP_FAILED_STR "\x00"
    "\x00\x00\x00\xAC\x00\x1A"
    MSG_REQ_VERIFY_FAILED_STR "\x00\x00"
    "\x00\x00\x00\xAD\x00\x24"
    MSG_REQ_INSERT_DISK_STR "\x00\x00"
    "\x00\x00\x00\xAE\x00\x24"
    MSG_REQ_INSERT_LAST_DISK_STR "\x00"
    "\x00\x00\x00\xAF\x00\x24"
    MSG_REQ_INSERT_NEXT_DISK_STR "\x00"
    "\x00\x00\x00\xB0\x00\x26"
    MSG_REQ_INSERT_NEW_DISK_STR "\x00\x00"
    "\x00\x00\x00\xB1\x00\x26"
    MSG_REQ_OVERWRITE_STR "\x00\x00"
    "\x00\x00\x00\xB2\x00\x22"
    MSG_REQ_MISC_DISK_STR "\x00"
    "\x00\x00\x00\xB3\x00\x2A"
    MSG_REQ_CRYPT_DISK_STR "\x00\x00"
    "\x00\x00\x00\xB4\x00\x3A"
    MSG_REQ_OLD_BACKUP_DISK_STR "\x00"
    "\x00\x00\x00\xB5\x00\x36"
    MSG_REQ_OVERWRITE_TAPE_STR "\x00"
    "\x00\x00\x00\xB6\x00\x1C"
    MSG_REQ_FILE_EXISTS_STR "\x00\x00"
    "\x00\x00\x00\xB7\x00\x1E"
    MSG_REQ_WRONG_DISK_STR "\x00"
    "\x00\x00\x00\xB8\x00\x1E"
    MSG_REQ_ABORT_STR "\x00\x00"
    "\x00\x00\x00\xB9\x00\x38"
    MSG_REQ_FINISHED_STR "\x00\x00"
    "\x00\x00\x00\xBA\x00\x10"
    MSG_REQ_SELECTION_STR "\x00\x00"
    "\x00\x00\x00\xBB\x00\x18"
    MSG_REQ_PATTERN_STR "\x00\x00"
    "\x00\x00\x00\xBC\x00\x12"
    MSG_REQ_PATTERN_GAD_STR "\x00\x00"
    "\x00\x00\x00\xBD\x00\x18"
    MSG_REQ_DATE_STR "\x00"
    "\x00\x00\x00\xBE\x00\x10"
    MSG_REQ_DATE_GAD_STR "\x00\x00"
    "\x00\x00\x00\xBF\x00\x18"
    MSG_REQ_BITS_STR "\x00"
    "\x00\x00\x00\xC0\x00\x10"
    MSG_REQ_PASSWORD_STR "\x00"
    "\x00\x00\x00\xC1\x00\x3C"
    MSG_REQ_NEED_MEMORY_STR "\x00\x00"
    "\x00\x00\x00\xC2\x00\x7C"
    MSG_REQ_ESTIMATION_STR "\x00"
    "\x00\x00\x00\xC3\x00\x28"
    MSG_REQ_FILE_MODIFIED_STR "\x00"
    "\x00\x00\x00\xC4\x00\x1A"
    MSG_REQ_FILES_NOTEQUAL_STR "\x00"
    "\x00\x00\x00\xC5\x00\x10"
    MSG_REQ_COMMENT_STR "\x00\x00"
    "\x00\x00\x00\xC6\x00\x18"
    MSG_REQ_TAPE_NOT_READY_STR "\x00"
    "\x00\x00\x00\xC7\x00\x1A"
    MSG_REQ_CHKSUM_ERROR_STR "\x00\x00"
    "\x00\x00\x00\xC8\x00\x30"
    MSG_REQ_PREPARE_LABEL_STR "\x00"
    "\x00\x00\x00\xC9\x00\x14"
    MSG_REQ_ACCESS_DENIED_STR "\x00"
    "\x00\x00\x00\xCA\x00\x08"
    MSG_MONITOR_READING_STR "\x00"
    "\x00\x00\x00\xCB\x00\x08"
    MSG_MONITOR_WRITING_STR "\x00"
    "\x00\x00\x00\xCC\x00\x0A"
    MSG_MONITOR_CRUNCHING_STR "\x00"
    "\x00\x00\x00\xCD\x00\x0A"
    MSG_MONITOR_COMPARING_STR "\x00"
    "\x00\x00\x00\xCE\x00\x08"
    MSG_MONITOR_BACKEDUP_STR "\x00\x00"
    "\x00\x00\x00\xCF\x00\x04"
    MSG_MONITOR_RESTORED_STR "\x00"
    "\x00\x00\x00\xD0\x00\x0A"
    MSG_MONITOR_VERIFIED_STR "\x00\x00"
    "\x00\x00\x00\xD1\x00\x08"
    MSG_MONITOR_SKIPPED_STR "\x00"
    "\x00\x00\x00\xD2\x00\x12"
    MSG_MONITOR_CYLINDER_STR "\x00\x00"
    "\x00\x00\x00\xD3\x00\x06"
    MSG_MONITOR_ERROR_STR "\x00"
    "\x00\x00\x00\xD4\x00\x08"
    MSG_MONITOR_CATALOG_STR "\x00"
    "\x00\x00\x00\xD5\x00\x10"
    MSG_ARCHIVE_CLOSED_STR "\x00\x00"
    "\x00\x00\x00\xD6\x00\x16"
    MSG_SETTING_ARCHIVE_BITS_STR "\x00\x00"
    "\x00\x00\x00\xD7\x00\x18"
    MSG_REPORT_BREAKED_STR "\x00\x00"
    "\x00\x00\x00\xD8\x00\x08"
    MSG_REPORT_BACKUP_STR "\x00\x00"
    "\x00\x00\x00\xD9\x00\x08"
    MSG_REPORT_RESTORE_STR "\x00"
    "\x00\x00\x00\xDA\x00\x08"
    MSG_REPORT_VERIFY_STR "\x00\x00"
    "\x00\x00\x00\xDB\x00\x1C"
    MSG_REPORT_HEADER1_STR "\x00"
    "\x00\x00\x00\xDC\x00\x10"
    MSG_REPORT_HEADER2_STR "\x00"
    "\x00\x00\x00\xDD\x00\x16"
    MSG_REPORT_HEADER3_STR "\x00\x00"
    "\x00\x00\x00\xDE\x00\x24"
    MSG_REPORT_FOOTER1_STR "\x00"
    "\x00\x00\x00\xDF\x00\x0C"
    MSG_REPORT_FOOTER2_STR "\x00\x00"
    "\x00\x00\x00\xE0\x00\x32"
    MSG_REPORT_BAD_CYLINDER_STR "\x00\x00"
    "\x00\x00\x00\xE1\x00\x20"
    MSG_REPORT_BAD_FILE_STR "\x00\x00"
    "\x00\x00\x00\xE2\x00\x1E"
    MSG_REPORT_NOT_REPLACED_STR "\x00"
    "\x00\x00\x00\xE3\x00\x14"
    MSG_REPORT_RENAMED_STR "\x00\x00"
    "\x00\x00\x00\xE4\x00\x0A"
    MSG_REPORT_NOT_FOUND_STR "\x00"
    "\x00\x00\x00\xE5\x00\x0E"
    MSG_REPORT_COULD_NOT_BACKUP_STR "\x00"
    "\x00\x00\x00\xE6\x00\x0E"
    MSG_REPORT_COULD_NOT_RESTORE_STR "\x00\x00"
    "\x00\x00\x00\xE7\x00\x0E"
    MSG_REPORT_COULD_NOT_VERIFY_STR "\x00\x00"
    "\x00\x00\x00\xE8\x00\x24"
    MSG_REPORT_FILE_MODIFIED_STR "\x00"
    "\x00\x00\x00\xE9\x00\x12"
    MSG_REPORT_COMPARE_FAILED_STR "\x00"
    "\x00\x00\x00\xEA\x00\x18"
    MSG_REPORT_OPENING_STR "\x00\x00"
    "\x00\x00\x00\xEB\x00\x24"
    MSG_REPORT_ACCESS_DENIED_STR "\x00"
    "\x00\x00\x00\xEC\x00\x74"
    MSG_INFO_DEVICE_STR "\x00"
    "\x00\x00\x00\xED\x00\x14"
    MSG_INFO_LINK_STR "\x00\x00"
    "\x00\x00\x00\xEE\x00\x0C"
    MSG_INFO_TYPE_EMPTY_STR "\x00\x00"
    "\x00\x00\x00\xEF\x00\x14"
    MSG_INFO_TYPE_OBJAZTEC_STR "\x00"
    "\x00\x00\x00\xF0\x00\x16"
    MSG_INFO_TYPE_LIBAZTEC_STR "\x00\x00"
    "\x00\x00\x00\xF1\x00\x0C"
    MSG_INFO_TYPE_FONTHEAD_STR "\x00"
    "\x00\x00\x00\xF2\x00\x10"
    MSG_INFO_TYPE_WBICON_STR "\x00\x00"
    "\x00\x00\x00\xF3\x00\x12"
    MSG_INFO_TYPE_LHARCARC_STR "\x00\x00"
    "\x00\x00\x00\xF4\x00\x10"
    MSG_INFO_TYPE_EXECPRG_STR "\x00"
    "\x00\x00\x00\xF5\x00\x12"
    MSG_INFO_TYPE_OBJSASC_STR "\x00"
    "\x00\x00\x00\xF6\x00\x14"
    MSG_INFO_TYPE_LIBSASC_STR "\x00\x00"
    "\x00\x00\x00\xF7\x00\x0C"
    MSG_INFO_TYPE_ZOOARC_STR "\x00"
    "\x00\x00\x00\xF8\x00\x1A"
    MSG_INFO_TYPE_PPCRUNCH_STR "\x00"
    "\x00\x00\x00\xF9\x00\x1A"
    MSG_INFO_TYPE_PPCRYPT_STR "\x00\x00"
    "\x00\x00\x00\xFA\x00\x10"
    MSG_INFO_TYPE_ABACKUP_STR "\x00"
    "\x00\x00\x00\xFB\x00\x12"
    MSG_INFO_TYPE_IFFILBM_STR "\x00\x00"
    "\x00\x00\x00\xFC\x00\x0E"
    MSG_INFO_TYPE_IFFTEXT_STR "\x00"
    "\x00\x00\x00\xFD\x00\x10"
    MSG_INFO_TYPE_IFF8SVX_STR "\x00\x00"
    "\x00\x00\x00\xFE\x00\x14"
    MSG_INFO_TYPE_IFFANIM_STR "\x00\x00"
    "\x00\x00\x00\xFF\x00\x0A"
    MSG_INFO_TYPE_IFFOTHER_STR "\x00\x00"
    "\x00\x00\x01\x00\x00\x0C"
    MSG_INFO_TYPE_BINARY_STR "\x00"
    "\x00\x00\x01\x01\x00\x10"
    MSG_INFO_TYPE_ASCII_STR "\x00"
    "\x00\x00\x01\x02\x00\x14"
    MSG_INFO_TYPE_XPKF_STR "\x00"
    "\x00\x00\x01\x03\x00\x06"
    MSG_CTYPE_NONE_STR "\x00\x00"
    "\x00\x00\x01\x04\x00\x0A"
    MSG_CTYPE_INTERNAL_STR "\x00\x00"
    "\x00\x00\x01\x05\x00\x0A"
    MSG_CTYPE_EXTERNAL_STR "\x00\x00"
    "\x00\x00\x01\x06\x00\x12"
    MSG_CTYPE_XPKLIB_STR "\x00\x00"
    "\x00\x00\x01\x07\x00\x10"
    MSG_UNIT_NAME_STR "\x00\x00"
    "\x00\x00\x01\x08\x00\x06"
    MSG_TAPE_NAME_STR "\x00\x00"
    "\x00\x00\x01\x09\x00\x16"
    MSG_TAPE_END_REACHED_STR "\x00\x00"
    "\x00\x00\x01\x0A\x00\x12"
    MSG_TAPE_REWINDING_STR "\x00"
    "\x00\x00\x01\x0B\x00\x1A"
    MSG_TAPE_PROTECTED_STR "\x00\x00"
    "\x00\x00\x01\x0C\x00\x36"
    MSG_TAPE_BSIZE_CHANGED_STR "\x00\x00"
    "\x00\x00\x01\x0D\x00\x26"
    MSG_TAPE_READ_FAILED_STR "\x00\x00"
    "\x00\x00\x01\x0E\x00\x24"
    MSG_TAPE_WRITE_FAILED_STR "\x00"
    "\x00\x00\x01\x0F\x00\x20"
    MSG_TAPE_INQUIRY_FAILED_STR "\x00\x00"
    "\x00\x00\x01\x10\x00\x24"
    MSG_TAPE_SENSE_01_STR "\x00\x00"
    "\x00\x00\x01\x11\x00\x22"
    MSG_TAPE_SENSE_02_STR "\x00"
    "\x00\x00\x01\x12\x00\x20"
    MSG_TAPE_SENSE_03_STR "\x00"
    "\x00\x00\x01\x13\x00\x22"
    MSG_TAPE_SENSE_04_STR "\x00"
    "\x00\x00\x01\x14\x00\x24"
    MSG_TAPE_SENSE_05_STR "\x00\x00"
    "\x00\x00\x01\x15\x00\x22"
    MSG_TAPE_SENSE_06_STR "\x00"
    "\x00\x00\x01\x16\x00\x22"
    MSG_TAPE_SENSE_07_STR "\x00"
    "\x00\x00\x01\x17\x00\x24"
    MSG_TAPE_SENSE_0B_STR "\x00\x00"
    "\x00\x00\x01\x18\x00\x24"
    MSG_TAPE_SENSE_0D_STR "\x00\x00"
    "\x00\x00\x01\x19\x00\x14"
    MSG_ARCHIVE_FILE_COMMENT_STR "\x00\x00"
    "\x00\x00\x01\x1A\x00\x06"
    MSG_NO_COMMENT_STR "\x00\x00"
    "\x00\x00\x01\x1B\x00\x32"
    MSG_BACKUP_LOG_STR "\x00"
    "\x00\x00\x01\x1C\x00\x16"
    MSG_LABEL_FILES_BYTES_STR "\x00"
    "\x00\x00\x01\x1D\x00\x06"
    MSG_DISK_STR "\x00\x00"
};

#endif /* CATCOMP_BLOCK */


/****************************************************************************/


struct LocaleInfo
{
    APTR li_LocaleBase;
    APTR li_Catalog;
};



#endif /* ABACKUP_LOCALE_H */
