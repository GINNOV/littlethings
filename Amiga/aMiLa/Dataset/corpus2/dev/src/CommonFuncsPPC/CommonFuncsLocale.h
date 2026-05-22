#ifndef CommonFuncsLOCALE_H
#define CommonFuncsLOCALE_H


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

#define MSG_GAD_STRGAD 0
#define MSG_GAD_OKAY_BT 1
#define MSG_GAD_CANCEL_BT 2
#define MSG_DEFAULT_BUTTONS 3
#define MSG_YES_NO_BUTTONS 4
#define MSG_OKAY_BUTTON 5
#define MSG_TRUE_STRING 6
#define MSG_YES_STRING 7
#define MSG_OK_STRING 8
#define MSG_OKAY_STRING 9
#define MSG_SYSTEM_PROBLEM 10
#define MSG_USER_ERROR 11
#define MSG_USER_SANITY_CHECK 12
#define MSG_RQTITLE_TOOL_ERROR 13
#define MSG_FORMAT_CMD_ERR 14
#define MSG_FMT_LIB_UNOPENED 15
#define MSG_FMT_NO_INTUITION_LIBRARY 16
#define MSG_LVM_ERROR_NONE 17
#define MSG_LVM_ERROR_WRONG_SIZE 18
#define MSG_LVM_ERROR_NOMEM 19
#define MSG_RQTITLE_ERROR_REPORT 20
#define MSG_WARNING_NOTIFYUSER 21
#define MSG_FAILURE_GETACTIVEWINDOW 22

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define MSG_GAD_STRGAD_STR "Please Enter a String:"
#define MSG_GAD_OKAY_BT_STR "_OKAY!"
#define MSG_GAD_CANCEL_BT_STR "_CANCEL!"
#define MSG_DEFAULT_BUTTONS_STR "CONTINUE|ABORT!"
#define MSG_YES_NO_BUTTONS_STR "YES|MO"
#define MSG_OKAY_BUTTON_STR "OKAY"
#define MSG_TRUE_STRING_STR "TRUE"
#define MSG_YES_STRING_STR "YES"
#define MSG_OK_STRING_STR "OK"
#define MSG_OKAY_STRING_STR "OKAY"
#define MSG_SYSTEM_PROBLEM_STR "System PROBLEM:"
#define MSG_USER_ERROR_STR "User ERROR:"
#define MSG_USER_SANITY_CHECK_STR "User SANITY CHECK:"
#define MSG_RQTITLE_TOOL_ERROR_STR "Invalid ToolType?"
#define MSG_FORMAT_CMD_ERR_STR "Could NOT execute:\n\n   %s\n  Returned ERROR #%d!"
#define MSG_FMT_LIB_UNOPENED_STR "Could NOT open %s V%d library!"
#define MSG_FMT_NO_INTUITION_LIBRARY_STR "FATAL ERROR: %s found NO open Intuition library!\n"
#define MSG_LVM_ERROR_NONE_STR "No Guarded_AllocLV() error found!"
#define MSG_LVM_ERROR_WRONG_SIZE_STR "Guarded_AllocLV() sizes < 1 (Wrong Size!)"
#define MSG_LVM_ERROR_NOMEM_STR "Guarded_AllocLV() ran out of Memory!"
#define MSG_RQTITLE_ERROR_REPORT_STR "ERROR Report:"
#define MSG_WARNING_NOTIFYUSER_STR "NotifyUser() Calling GetActiveWindow()...\n"
#define MSG_FAILURE_GETACTIVEWINDOW_STR "GetActiveWindow() FAILED in NotifyUser()!\n"

#endif /* CATCOMP_STRINGS */


/****************************************************************************/



#endif /* CommonFuncsLOCALE_H */
