head	1.625;
access;
symbols;
locks
	lilja:1.625; strict;
comment	@ * @;


1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.430;

1.430
date	96.04.14.13.21.26;	author lilja;	state Exp;
branches;
next	1.150;

1.150
date	96.02.11.16.38.55;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	0.623;

0.623
date	95.09.16.10.54.30;	author lilja;	state Exp;
branches;
next	0.567;

0.567
date	95.09.11.17.15.13;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Contains all global data definitions for AmiFTP
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@/* RCS Id: $Id: data.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
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

@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Locked version: $Revision$
d5 1
a5 1
#include "ftpwin.h"
d7 1
a7 1
struct   sockaddr_in data_addr;
d68 1
a68 1
BOOL MenuNeedsUpdate=FALSE; // Tells main idcmp routine to update the menus when it's safe to do so */
@


1.531
log
@Lots of stuff
@
text
@d1 4
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d15 1
a15 1
int      remote_sort_mode;
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@a5 1
int      abrtflag;
a6 1
int      debug;
a10 1
int      runique;
a18 1
int      ignore_case;
a20 2
int      abort_transfer;
int      unique_local_names;
a24 1
int      ftp_passthru_port;
@


1.124
log
@AmiTCP and AS225r2 support in the same binary.
ARexx-command VIEW added.
New option to SETATTR, QUIET.
SETATTR LOCALDIR didn't update the download dir-gadget.
GETATTR STEM=bar didn't work since bar is in lowercase.
Enforcer hits when trying to open AmiFTP on a non-existing screen removed.
Moved 'Show dot-files?' to the Settings-menu.
Icelandic and Spanish catalogs added.
@
text
@a27 1
#ifdef SOCKIO
a28 4
#else
FILE    *commandfp;
FILE    *responsefp;
#endif
a46 1
//struct Library          *GadToolsBase;
a59 5

#ifdef AS225
struct Library *SockBase;
#endif

@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@a2 1
struct   sockaddr_in hisctladdr;
d70 1
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@a44 1
BOOL    V39;
d53 1
a53 1
struct Library          *GadToolsBase;
d65 1
d73 2
@


0.623
log
@Added menuitem TransferMode->Binary/ASCII
@
text
@d65 3
d73 1
@


0.567
log
@Fixed busy loop caused by badly timed SetMenuStrip() (In the NextSelect-loop)
@
text
@d77 1
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d76 2
@


0.371
log
@Localized source.
@
text
@d49 2
a50 1
char    *unix_dir_pattern;
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d63 1
@


0.284
log
@First RCS version.
@
text
@d63 3
@
