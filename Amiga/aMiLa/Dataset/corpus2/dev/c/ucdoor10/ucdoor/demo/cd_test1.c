/* ******************************************************************
** NAME      : cd_test1.c                                          **
** AUTHOR    : Chris De Maeyer (cdemaeyer@mmm.com)                 **
** PURPOSE   : test door functions                                 **
** COPYRIGHT : Sources (C)1997 Blue Heaven Software                **
**             Header/Object file freely useable                   **
** VERSION   : 1.0                                                 **
** HISTORY   : Date     Description                          By    **
**             -------- ------------------------------------ ---   **
** V 1.0       12/02/97 Creation                             CDM   **
** *************************************************************** */
 
#include "ucdoor.h"

struct Task      *thisTask; 
struct MsgPort   *doorControl;
struct MsgPort   *doorReply;
MDDOOR           *udc_msg;
BOOL             is_CarrierLost;
int              udc_result;

int cd_Door(int node)
{
    UBYTE x;
    UBYTE str[80];
    int rc;
    BOOL test;
    
    cd_Cls();
    cd_PutStr("\nUltra Cee Door for MAX's By Chris De Maeyer",TRUE);
    
    if(cd_CarrierLost())
       return(ERROR_CARRIER);
        
    x = cd_GetCharPrompt("Getting a char with a prompt:");
    
    sprintf(str,"\nYou typed the character '%c' !",x);
    cd_PutStr(str,TRUE);    
    
    cd_PutStr("\nNow some values about current user...",TRUE);
    
    cd_SetFG(RED);
    rc = cd_GetNumInfo(UDC_ACCESS);
    sprintf(str,"Current user access  : %d",rc);
    cd_PutStr(str,TRUE);
    
    cd_SetFG(GREEN);
    rc = cd_GetNumInfo(UDC_CALLS);
    sprintf(str,"Current user calls   : %d",rc);
    cd_PutStr(str,TRUE);

    cd_SetFG(YELLOW);
    rc = cd_GetNumInfo(UDC_SYSTEMCALLS);
    sprintf(str,"Current BBS calls    : %d",rc);
    cd_PutStr(str,TRUE);

    cd_SetFG(BLUE);
    rc = cd_GetNumInfo(UDC_GFXMODE);
    sprintf(str,"Current user mode    : %d",rc);
    cd_PutStr(str,TRUE);
      
    cd_SetFG(PINK);  
    rc = cd_GetNumInfo(UDC_TIMELEFT);
    sprintf(str,"Current time left    : %d",rc);
    cd_PutStr(str,TRUE);
    
    cd_SetFG(CYAN);
    rc = cd_GetNumInfo(UDC_COLUMNS);
    sprintf(str,"Current screen cols  : %d",rc);
    cd_PutStr(str,TRUE);
    
    cd_SetFG(WHITE);
    rc = cd_GetNumInfo(UDC_ROWS);
    sprintf(str,"Current screen rows  : %d",rc);
    cd_PutStr(str,TRUE);

    cd_SetBG(RED);
    cd_PutStr("Username             : ",FALSE);
    cd_GetStrInfo(UDC_USERNAME,str);
    cd_PutStr(str,TRUE);

    cd_SetColors(CYAN,BLACK);
    cd_PutStr("Password             : ",FALSE);
    cd_GetStrInfo(UDC_PASSWORD,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("Suburb               : ",FALSE);
    cd_GetStrInfo(UDC_SUBURB,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("Doors path           : ",FALSE);
    cd_GetStrInfo(UDC_PATHDOORS,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("BBS path             : ",FALSE);
    cd_GetStrInfo(UDC_PATHBBS,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("Date                 : ",FALSE);
    cd_GetStrInfo(UDC_DATE,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("Time                 : ",FALSE);
    cd_GetStrInfo(UDC_TIME,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("Telephone            : ",FALSE);
    cd_GetStrInfo(UDC_PHONE,str);
    cd_PutStr(str,TRUE);
    
    cd_PutStr("Computer             : ",FALSE);
    cd_GetStrInfo(UDC_COMPUTER,str);
    cd_PutStr(str,TRUE);

    cd_PutStr("Sysop comment        : ",FALSE);
    cd_GetStrInfo(UDC_COMMENT,str);
    cd_PutStr(str,TRUE);

    x = cd_GetCharPrompt("Any key to continue...");

    cd_Cls();
    
    test = cd_FileHere("Test.dummy");
    if(!test)
        cd_PutStr("File Test.dummy not available...",TRUE);
        
    test = cd_FileHere("ucdoor.o");
    if(test)
        cd_PutStr("File ucdoor.o available...",TRUE);

    cd_TwitCurrent();
              
    x = cd_GetCharPrompt("Any key to return to BBS...");
 
}
    
void main(int argc,char *argv[])
{
    cd_Main(argv[1]);
}    

/* The End */
