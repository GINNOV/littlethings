#ifndef MyCalcLocale_H
#define MyCalcLocale_H


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

#define MSG_FMT_INFO_RQTITLE 0
#define MSG_FMT_INFO 1
#define MSG_STITLE 2
#define MSG_WTITLE 3
#define MSG_GAD_DecTxt 4
#define MSG_GAD_HexTxt 5
#define MSG_GAD_Mem1Txt 6
#define MSG_GAD_Mem2Txt 7
#define MSG_GAD_Mem3Txt 8
#define MSG_GAD_Key0 9
#define MSG_GAD_Key1 10
#define MSG_GAD_Key2 11
#define MSG_GAD_Key3 12
#define MSG_GAD_Key4 13
#define MSG_GAD_Key5 14
#define MSG_GAD_Key6 15
#define MSG_GAD_Key7 16
#define MSG_GAD_Key8 17
#define MSG_GAD_Key9 18
#define MSG_GAD_KeyA 19
#define MSG_GAD_KeyB 20
#define MSG_GAD_KeyC 21
#define MSG_GAD_KeyD 22
#define MSG_GAD_KeyE 23
#define MSG_GAD_KeyF 24
#define MSG_GAD_KeyPlus 25
#define MSG_GAD_KeyMinus 26
#define MSG_GAD_KeyStar 27
#define MSG_GAD_KeySlash 28
#define MSG_GAD_KeyLParen 29
#define MSG_GAD_KeyRParen 30
#define MSG_GAD_KeyPeriod 31
#define MSG_GAD_KeyDollar 32
#define MSG_GAD_KeyAND 33
#define MSG_GAD_KeyOR 34
#define MSG_GAD_KeyNOT 35
#define MSG_GAD_KeyXOR 36
#define MSG_GAD_KeyLShift 37
#define MSG_GAD_KeyRShift 38
#define MSG_GAD_KeyModulo 39
#define MSG_GAD_KeyEqual 40
#define MSG_GAD_HelpKey 41
#define MSG_GAD_KeyAllClear 42
#define MSG_GAD_KeyMemClear 43
#define MSG_GAD_MemIn 44
#define MSG_GAD_MemRecall 45
#define MSG_TT_TempFile 46
#define MSG_TT_HelpFile 47
#define MSG_TT_HotKey 48
#define MSG_TT_CXPriority 49
#define MSG_TT_DoNotWait 50
#define MSG_BROKER_NAME 51
#define MSG_BROKER_TITLE 52
#define MSG_BROKER_DESCR 53
#define MSG_INVALID_CHAR_EXPR 54
#define MSG_USER_ERROR_RQTITLE 55
#define MSG_EXPR_TOO_LONG 56
#define MSG_EXPR_TOO_LONG_RQTITLE 57
#define MSG_FMT_BAD_HELP 58
#define MSG_NO_HELP_FILE_RQTITLE 59
#define MSG_COERR_ISNULL 60
#define MSG_COERR_NULLATTACH 61
#define MSG_COERR_BADFILTER 62
#define MSG_COERR_BADTYPE 63
#define MSG_CBERR_OK 64
#define MSG_FMT_CBERR_UNKNOWN 65
#define MSG_DIVIDE_ZERO_ERROR 66
#define MSG_FMT_PARSE_ERROR 67
#define MSG_FMT_NO_FILE_WRITE 68
#define MSG_FMT_NO_FILE_READ 69
#define MSG_SYSTEM_PROBLEM_RQTITLE 70
#define MSG_CHECK_EXPRESSION_RQTITLE 71
#define MSG_FMT_PARSE_RESULT 72

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define MSG_FMT_INFO_RQTITLE_STR "%s Information:"
#define MSG_FMT_INFO_STR "This GUI allows the programmer to perform some\nsimple calculations on decimal/hexadecimal numbers.\n\nMy e-mail address:  %s"
#define MSG_STITLE_STR "Programmers Calculator:"
#define MSG_WTITLE_STR "Programmers Calculator ©2002 by J.T. Steichen"
#define MSG_GAD_DecTxt_STR "Result (Decimal):"
#define MSG_GAD_HexTxt_STR "Result (Hex):"
#define MSG_GAD_Mem1Txt_STR "Mem 1:"
#define MSG_GAD_Mem2Txt_STR "Mem 2:"
#define MSG_GAD_Mem3Txt_STR "Mem 3:"
#define MSG_GAD_Key0_STR "_0"
#define MSG_GAD_Key1_STR "_1"
#define MSG_GAD_Key2_STR "_2"
#define MSG_GAD_Key3_STR "_3"
#define MSG_GAD_Key4_STR "_4"
#define MSG_GAD_Key5_STR "_5"
#define MSG_GAD_Key6_STR "_6"
#define MSG_GAD_Key7_STR "_7"
#define MSG_GAD_Key8_STR "_8"
#define MSG_GAD_Key9_STR "_9"
#define MSG_GAD_KeyA_STR "_A"
#define MSG_GAD_KeyB_STR "_B"
#define MSG_GAD_KeyC_STR "_C"
#define MSG_GAD_KeyD_STR "_D"
#define MSG_GAD_KeyE_STR "_E"
#define MSG_GAD_KeyF_STR "_F"
#define MSG_GAD_KeyPlus_STR "_+"
#define MSG_GAD_KeyMinus_STR "_-"
#define MSG_GAD_KeyStar_STR "_*"
#define MSG_GAD_KeySlash_STR "_/"
#define MSG_GAD_KeyLParen_STR "_("
#define MSG_GAD_KeyRParen_STR "_)"
#define MSG_GAD_KeyPeriod_STR "_."
#define MSG_GAD_KeyDollar_STR "_$"
#define MSG_GAD_KeyAND_STR "AND _&"
#define MSG_GAD_KeyOR_STR "OR _|"
#define MSG_GAD_KeyNOT_STR "NOT _~"
#define MSG_GAD_KeyXOR_STR "XOR _^"
#define MSG_GAD_KeyLShift_STR "_L SHIFT"
#define MSG_GAD_KeyRShift_STR "_R SHIFT"
#define MSG_GAD_KeyModulo_STR "_MODULO"
#define MSG_GAD_KeyEqual_STR "EVAL _="
#define MSG_GAD_HelpKey_STR "_Help!"
#define MSG_GAD_KeyAllClear_STR "ALL CLEAR"
#define MSG_GAD_KeyMemClear_STR "MEM CLEAR"
#define MSG_GAD_MemIn_STR "M in"
#define MSG_GAD_MemRecall_STR "M out"
#define MSG_TT_TempFile_STR "TEMPFILE"
#define MSG_TT_HelpFile_STR "HELPFILE"
#define MSG_TT_HotKey_STR "HOTKEY"
#define MSG_TT_CXPriority_STR "CX_PRIORITY"
#define MSG_TT_DoNotWait_STR "DONOTWAIT"
#define MSG_BROKER_NAME_STR "ProgrammersCalculator"
#define MSG_BROKER_TITLE_STR "Programmers Calculator"
#define MSG_BROKER_DESCR_STR "Perform HexaDecimal Calculations."
#define MSG_INVALID_CHAR_EXPR_STR "Invalid character in Expression String!"
#define MSG_USER_ERROR_RQTITLE_STR "User ERROR:"
#define MSG_EXPR_TOO_LONG_STR "Expression length is limited to 256 characters!"
#define MSG_EXPR_TOO_LONG_RQTITLE_STR "Expression Limit EXCEEDED: "
#define MSG_FMT_BAD_HELP_STR "System either could NOT find Multiview or %s."
#define MSG_NO_HELP_FILE_RQTITLE_STR "Did you install the Help file??"
#define MSG_COERR_ISNULL_STR "cx filter was == NULL!\n"
#define MSG_COERR_NULLATTACH_STR "someone attached NULL to my list!\n"
#define MSG_COERR_BADFILTER_STR "bad filter description!\n"
#define MSG_COERR_BADTYPE_STR "unmatched type-specific operation!\n"
#define MSG_CBERR_OK_STR "No error!\n"
#define MSG_FMT_CBERR_UNKNOWN_STR "Unknown error value from CxObjError() = %d"
#define MSG_DIVIDE_ZERO_ERROR_STR "Divide by Zero ERROR!\n"
#define MSG_FMT_PARSE_ERROR_STR "Could NOT parse:\n\n   '%s'\n"
#define MSG_FMT_NO_FILE_WRITE_STR "Could NOT open %s for writing!"
#define MSG_FMT_NO_FILE_READ_STR "Could NOT open %s for reading!"
#define MSG_SYSTEM_PROBLEM_RQTITLE_STR "System PROBLEM:"
#define MSG_CHECK_EXPRESSION_RQTITLE_STR "CHECK YOUR EXPRESSION:"
#define MSG_FMT_PARSE_RESULT_STR "Parser Result:  %d"

#endif /* CATCOMP_STRINGS */


/****************************************************************************/



#endif /* MyCalcLocale_H */
