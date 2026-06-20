#ifndef yyErrors
#define yyErrors

/* $Id: Errors.h,v 2.6 1992/08/07 15:28:42 grosch rel $ */

#include "Positions.h"

#define xxNoText		0
#define xxSyntaxError		1	/* error codes		*/
#define xxExpectedTokens	2
#define xxRestartPoint		3
#define xxTokenInserted	4

#define xxFatal		1	/* error classes	*/
#define xxRestriction		2
#define xxError		3
#define xxWarning		4
#define xxRepair		5
#define xxNote			6
#define xxInformation		7

#define xxNone			0
#define xxInteger		1	/* info classes		*/
#define xxShort		2
#define xxLong			3
#define xxReal			4
#define xxBoolean		5
#define xxCharacter		6
#define xxString		7
#define xxSet			8
#define xxIdent		9


extern void (*Errors_Exit)(void);

void ErrorMessage(short yyErrorCode, short yyErrorClass, tPosition yyPosition);
void ErrorMessageI(short yyErrorCode, short yyErrorClass, tPosition yyPosition, short yyInfoClass, char * yyInfo);
void Message(char * yyErrorText, short yyErrorClass, tPosition yyPosition);
void MessageI(char * yyErrorText, short yyErrorClass, tPosition yyPosition, short yyInfoClass, char * yyInfo);

#endif
