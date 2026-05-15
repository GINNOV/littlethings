/* RCS Id: $Id: data.c 1.625 1996/07/04 17:50:58 lilja Exp $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"

struct sockaddr_in data_addr;
struct sockaddr_in myctladdr;
int      data;
int      verbose;
int      code;
int      cpend;
int      curtype;
int      crflag;
int      sendport;
int      connected;
int      timedout;
int      which_up_cmd;
int      SortMode;
int      remote_sort_direction;
int      non_unix;
int      remote_os_type;
int      current_year;
int      current_month;

int      cin=-1,cout=-1;

int      ftp_port;

char	response_line[MAXLINE];
char	scratch[1024 + 1024 + 10];
LONG opts[OPT_COUNT];
struct RDArgs *argsptr;

BOOL    ConfigChanged;

char    *header_name;
char    *other_dir_pattern;
/*              "PERMS LINKS USER GROUP SIZE MONTH DAY TIME NAME" */
char    *unix_dir_pattern= "\001 \002 \003 \004 \005 \006 \007 \010 \011";
char    *defaultanonymouspw;

struct IntuitionBase    *IntuitionBase;
struct Library          *UtilityBase;
struct GfxBase          *GfxBase;
struct Library          *DiskfontBase;
struct ReqToolsBase     *ReqToolsBase;
struct Library          *AslBase;
struct Library          *IFFParseBase;
struct RexxLib          *RexxSysBase;
struct IconBase         *IconBase;
struct WorkbenchBase    *WorkbenchBase;
struct Library          *LocaleBase;
struct Library          *AmigaGuideBase;
struct Library          *TimerBase;
struct AGInfo ag;

struct MsgPort          *RexxPort;
struct MsgPort          *TimerPort;
struct timerequest *TimeRequest;
ULONG AG_Signal=NULL;

struct List *FileList;
struct List TempList;

struct CurrentState CurrentState;

BOOL MenuNeedsUpdate=FALSE; /* Tells main idcmp routine to update the menus when it's safe to do so */
int TransferMode=BINARY;

