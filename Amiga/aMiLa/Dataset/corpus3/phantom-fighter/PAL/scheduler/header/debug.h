/****************************************
 * Header file for DEbugger
 *
 */

#ifndef DEBUGH
#define DEBUGH 
#define MAXDEBUG 127

extern char *Debug_Stack[MAXDEBUG+1];
extern int Debug_SP;

#define Set_Debug(a) Debug_Stack[Debug_SP=(Debug_SP+1)&MAXDEBUG]=a;
#define Clear_Debug() Debug_Stack[Debug_SP=(Debug_SP+1)&MAXDEBUG]="Return";

#endif

