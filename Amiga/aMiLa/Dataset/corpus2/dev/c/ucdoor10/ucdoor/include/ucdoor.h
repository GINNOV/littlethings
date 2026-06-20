/* ******************************************************************
** NAME      : UltraCeeDoor.h                                      **
** AUTHOR    : Chris De Maeyer (cdemaeyer@mmm.com)                 **
** PURPOSE   : header file MAX's BBS door functions                **
**                                                                 **
** COPYRIGHT : Sources (C)1997 Blue Heaven Software.               **
**             Header/Object file freely useable in NON-commercial **
**             programs. Distribution only on media not claiming   **
**             copyrights on the material. May not be sold.        **
**             For use in commercial/shareware products contact    **
**             us via Email/Snail (see Guide).                     **
**                                                                 **
** VERSION   : 1.0                                                 **
**                                                                 **
** HISTORY   : Date     Description                          By    **
**             -------- ------------------------------------ ---   **
** V 1.0       11/02/97 Creation                             CDM   **
**             14/02/97 Added udc_result                           **
**                      Added cd_(Get)(Put)UserIndex/Data()        **
**                      Added EFILE_xxxx codes               CDM   **
**             15/02/97 Changed dm_msg to pointer            CDM   **
** *************************************************************** */
 
/* SAS/C
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

/* AmigaDOS
*/
#include <exec/types.h>
#include <exec/ports.h>
#include <exec/tasks.h>
#include <exec/lists.h>
#include <exec/memory.h>

#include <proto/exec.h>
#include <proto/dos.h>

/* Defines
*/
#define HLEN            62
#define SLEN            80
#define PORTNAME1       "DoorControl"
#define PORTNAME2       "DoorReply"

/* commands for cd_GetNumInfo()
*/
#define UDC_ACCESS              1       /* Access level */
#define UDC_MODE                2       /* Expert mode ?        (Paragon Only !) */
#define UDC_CREDITS             3       /* Credits ?            (Paragon Only !) */
#define UDC_CALLS               4       /* Number of user calls */
#define UDC_SYSTEMCALLS         5       /* Number of BBS calls */
#define UDC_GFXMODE             6       /* Plain or ANSI */
#define UDC_TIMELEFT            7       /* Minutes online left */
#define UDC_COLUMNS             8       /* Screen columns */
#define UDC_ROWS                9       /* Screen rows */

/* commands for cd_GetStrInfo()
*/
#define UDC_USERNAME            1       /* Users name */
#define UDC_PASSWORD            2       /* Users password */
#define UDC_SUBURB              3       /* Users suburb */
#define UDC_CITY                4       /* Users city           (Paragon Only !) */
#define UDC_STATE               5       /* Users state          (Paragon Only !) */
#define UDC_ZIPCODE             6       /* Users zipcode        (Paragon Only !) */
#define UDC_PATHDOORS           7       /* Path to doors */
#define UDC_PATHBBS             8       /* Path to BBS */
#define UDC_DATE                9       /* The date */
#define UDC_TIME                10      /* The time */
#define UDC_PHONE               100     /* Users phone */
#define UDC_COMPUTER            101     /* Users computer */
#define UDC_COMMENT             102     /* Sysop comment on user */

/* More info can be gathered by reading the Users Data
   (see cd_GetUserData() function)
*/

/* ANSI support */
#define BLACK                   0
#define RED                     1
#define GREEN                   2
#define YELLOW                  3
#define BLUE                    4
#define PINK                    5
#define CYAN                    6
#define WHITE                   7

/* udc_result codes (set when exiting cd_Main() function)
*/
#define OK                      0       /* All OK, also used for EFILE_xxxx */
#define ERROR_CARRIER           -1      /* F*ck, we lost it... */
#define ERROR_CONTROLPORT       -2      /* Couldn't find MAX's controlport */
#define ERROR_REPLYPORT         -3      /* Couldn't create the doors replyport */
#define ERROR_MESSAGE           -4      /* Couldn't allocate door message */
#define ERROR_ABORTED           -5      /* Forced end */

/* result codes data functions 
*/
#define EFILE_OPEN              -100    /* File open error */
#define EFILE_SEEK              -101    /* Seek error */
#define EFILE_READ              -102    /* Read error */
#define EFILE_WRITE             -103    /* Write error */

/* Structures */

/* Door */

typedef struct md_DoorMsg
{
    struct Message      mdd_message;
    WORD                mdd_command;
    WORD                mdd_data;
    char                mdd_string[SLEN];
    WORD                mdd_carrier;
} MDDOOR;

/* Data */

/* File User.index */
   
typedef struct ui_Header 
{
        UBYTE           uih_header[HLEN];
} UIHEAD;

typedef struct ui_Data 
   {
        UBYTE           uid_name[41];
} UIDATA;

/* File User.data */

typedef struct ud_Header
{
        UBYTE           udh_header[HLEN];
        ULONG           udh_calls;
} UDHEAD;

typedef struct ud_Data 
{
        UBYTE           udd_name[41];
        UBYTE           udd_suburb[40];
        UBYTE           udd_password[21];
        UBYTE           udd_telephone[21];
        UBYTE           udd_platform[21];
        UBYTE           udd_comment[100];
        ULONG           udd_timeLeft;
        ULONG           udd_access;
        ULONG           udd_timeLimit;
        ULONG           udd_ratio;
        ULONG           udd_lastMessage;
        ULONG           udd_pageLen;
        ULONG           udd_calls;
        ULONG           udd_messages;
        ULONG           udd_uploads;
        ULONG           udd_downloads;
        ULONG           udd_lastDate;
        ULONG           udd_lastTime;
        ULONG           udd_unusedF     :19,
                        udd_fileAttachF :1,
                        udd_junkMailF   :1,
                        udd_fileDescF   :1,
                        udd_lckF        :1,
                        udd_clsF        :1,
                        udd_pauseF      :1,
                        udd_fseF        :1,
                        udd_ansiF       :1,
                        udd_bltnF       :1,
                        udd_dnF         :1,
                        udd_upF         :1,
                        udd_wrF         :1,
                        udd_rdF         :1;           
         ULONG          ud_timeBank;
         ULONG          ud_protocol;
         ULONG          ud_maxBank;
} UDDATA;   

/* Globals
   (add these in your program
*/
extern struct Task      *thisTask; 
extern struct MsgPort   *doorControl;
extern struct MsgPort   *doorReply;
extern MDDOOR           *udc_msg;
extern BOOL             is_CarrierLost;
extern int              udc_result;

/* Prototypes Door functions
*/
void            cd_Main         (UBYTE *argstr);
void            cd_End          (int errcode);
void            cd_WaitMsg      (MDDOOR *cd_msg); 
extern int      cd_Door         (int node);

/* Door support functions
*/
BOOL            cd_CarrierLost  (void);
void            cd_Cls          (void);
void            cd_SetFG        (int color);
void            cd_SetBG        (int color);
void            cd_SetColors    (int fg,int bg);
void            cd_PutStr       (UBYTE *string,BOOL nl);
void            cd_GetStr       (UBYTE *buffer,int maxchar);
UBYTE           cd_GetChar      (void);
void            cd_GetStrPrompt (UBYTE *string,UBYTE *buffer,int maxchar);
UBYTE           cd_GetCharPrompt(UBYTE *string);
void            cd_TwitCurrent  (void);
void            cd_PrintFile    (UBYTE *filenm);
BOOL            cd_FileHere     (UBYTE *filenm);
void            cd_DoFunction   (int func,int extra,UBYTE *string);
int             cd_GetNumInfo   (int func);
void            cd_GetStrInfo   (int func,UBYTE *buffer);

/* User Data functions (MAX's Only)
*/

int             cd_GetUserIndex (UBYTE *filenm,UBYTE *uname);
int             cd_GetUserData  (UBYTE *filenm,int uindex,struct ud_Data *buffer);
int             cd_PutUserData  (UBYTE *filenm,int uindex,struct ud_Data *udata);
BOOL            cd_ChangeAccess (UBYTE *fidx,UBYTE *fdat,UBYTE *uname,int newaccess);

/* The End */
