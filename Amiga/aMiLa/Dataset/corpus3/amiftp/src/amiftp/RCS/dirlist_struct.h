head	1.587;
access;
symbols;
locks
	lilja:1.587; strict;
comment	@ * @;


1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.430;

1.430
date	96.04.14.13.21.26;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	1.265;

1.265
date	96.03.08.18.01.38;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Structure definitions of the dirlist
@


1.587
log
@Added RCS-variables to source-files.
@
text
@/* RCS Id:  $Id$
   Locked version: $Revision$
*/

#define	DATELEN 20

struct dirlist {
    char	*name;
    char	*date;
    char	*owner;
    char	*group;
    char        *lname;
    mode_t	 mode;
    int          link:1;
    int          file:1;
    int          dir:1;
    int          adt:1;
    int          new:1;
    int          hide:1;
    int          readmelength;
    int          readmelen;
    ULONG        adtdate;
    size_t	 size;
};

#define	SORTBYNAME	0
#define	SORTBYDATE	1
#define	SORTBYSIZE	2

#define	ASCENDING	0
#define	DESCENDING	1

#define	GROUPBYTYPE 0
#define	GROUPNONE	1
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d1 4
@


1.401
log
@Started on improving the functionnames.
Added Aminet-mode, not 100% finished yet.
Reworked the prefs-window, not everything is finished.
Started using listbrowser v41-functions.
Added parsing of URL-like commandline.
@
text
@d18 1
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d14 4
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d13 1
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@a3 2
    struct Node  dl_Node;
    char        *listname;
d8 1
@


0.284
log
@First RCS version.
@
text
@d11 3
@
