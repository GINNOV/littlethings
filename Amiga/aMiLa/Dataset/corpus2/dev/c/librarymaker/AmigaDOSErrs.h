/****h* AmigaDOSErrs.h [1.0] ******************************************
*
* NAME
*    AmigaDOSErrs.h
*
* DESCRIPTION
*    AmigaDOS Error message number #defines all in one file.
*
* AUTHOR
*    James T. Steichen (jimbot@rconnect.com)
*
* NOTES
*    Someday, I'm going to move all error values from every header
*    file into this file!
***********************************************************************
*
*/

#ifndef  AMIGADOSERRS_H
# define AMIGADOSERRS_H  1

# ifndef  PUBLIC

#  define PUBLIC            // Aliases for global
#  define VISIBLE

# endif

# ifndef  SUBFUNC
#  define SUBFUNC static
# endif

# ifndef  PRIVATE
#  define PRIVATE static
# endif

# ifndef  IMPORT
#  define IMPORT extern
# endif

# ifndef DOS_DOS_H  /* These are also in INCLUDE:dos/dos.h: */

#  define ERROR_NO_FREE_STORE             103
#  define ERROR_TASK_TABLE_FULL           105
#  define ERROR_BAD_TEMPLATE              114
#  define ERROR_BAD_NUMBER                115
#  define ERROR_REQUIRED_ARG_MISSING      116
#  define ERROR_KEY_NEEDS_ARG             117
#  define ERROR_TOO_MANY_ARGS             118
#  define ERROR_UNMATCHED_QUOTES          119
#  define ERROR_LINE_TOO_LONG             120
#  define ERROR_FILE_NOT_OBJECT           121
#  define ERROR_INVALID_RESIDENT_LIBRARY  122
#  define ERROR_NO_DEFAULT_DIR            201
#  define ERROR_OBJECT_IN_USE             202
#  define ERROR_OBJECT_EXISTS             203
#  define ERROR_DIR_NOT_FOUND             204
#  define ERROR_OBJECT_NOT_FOUND          205
#  define ERROR_BAD_STREAM_NAME           206
#  define ERROR_OBJECT_TOO_LARGE          207
#  define ERROR_ACTION_NOT_KNOWN          209
#  define ERROR_INVALID_COMPONENT_NAME    210
#  define ERROR_INVALID_LOCK              211
#  define ERROR_OBJECT_WRONG_TYPE         212
#  define ERROR_DISK_NOT_VALIDATED        213
#  define ERROR_DISK_WRITE_PROTECTED      214
#  define ERROR_RENAME_ACROSS_DEVICES     215
#  define ERROR_DIRECTORY_NOT_EMPTY       216
#  define ERROR_TOO_MANY_LEVELS           217
#  define ERROR_DEVICE_NOT_MOUNTED        218
#  define ERROR_SEEK_ERROR                219
#  define ERROR_COMMENT_TOO_BIG           220
#  define ERROR_DISK_FULL                 221
#  define ERROR_DELETE_PROTECTED          222
#  define ERROR_WRITE_PROTECTED           223
#  define ERROR_READ_PROTECTED            224
#  define ERROR_NOT_A_DOS_DISK            225
#  define ERROR_NO_DISK                   226
#  define ERROR_NO_MORE_ENTRIES           232

/* added for 1.4 */

#  define ERROR_IS_SOFT_LINK              233
#  define ERROR_OBJECT_LINKED             234
#  define ERROR_BAD_HUNK                  235
#  define ERROR_NOT_IMPLEMENTED           236
#  define ERROR_RECORD_NOT_LOCKED         240
#  define ERROR_LOCK_COLLISION            241
#  define ERROR_LOCK_TIMEOUT              242
#  define ERROR_UNLOCK_ERROR              243


#  define RETURN_OK              0   /* No problems, success       */
#  define RETURN_WARN            5   /* A warning only             */
#  define RETURN_ERROR           10  /* Something wrong            */
#  define RETURN_FAIL            20  /* Complete or severe failure */

# endif

# ifndef DOS_DOSEXTENS_H /* These are also in INCLUDE:dos/dosextens.h: */

#  define ABORT_DISK_ERROR                296
#  define ABORT_BUSY                      288

# endif

# ifndef DOS_DOSASL_H    /* These are also in INCLUDE:dos/dosasl.h: */

#  define ERROR_BUFFER_OVERFLOW   303 // User or internal buffer overflow
#  define ERROR_BREAK             304 // A break character was received
#  define ERROR_NOT_EXECUTABLE    305 // A file has E bit cleared

# endif

/* Error message numbers I've added: */

# define NO_UPDATE_PERFORMED      310 
# define TAPE_UNFORMATTED         311
# define TAPE_NOT_READY           312
# define TAPE_COMMAND_PROBLEM     313

# define ERROR_ON_OPENING_SCREEN  320
# define ERROR_ON_OPENING_WINDOW  321
# define ERROR_ON_GADTOOLS_INIT   322

# define ERROR_LIBRARY_NOT_OPENED 330
 
# define MENU_NUMBER_OUT_OF_RANGE 350
# define ITEM_NUMBER_OUT_OF_RANGE 351
# define  SUB_NUMBER_OUT_OF_RANGE 352
 
# define NULL_POINTER_FOUND       400
 
#endif

/* -------------- END of AmigaDOSErrs.h file! ---------------------- */
