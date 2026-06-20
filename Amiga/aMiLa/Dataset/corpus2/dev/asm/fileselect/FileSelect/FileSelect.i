* ---------------------------------------------------------
* FileSelect V2.0 include-file (DevPac version)
* Must be included if you compile the source.
* You should use this include-file because you can use
* later versions easier in your old programs.
* AW/CLUSTER 01.09.1990
* ---------------------------------------------------------
* Filters added 03.09.1990   -AW-
* Pens added 06.09.1990   -AW-
* Error removed in FS2F_FilterElement 22.09.1990   -AW-
* Keywords added in FS2_FileSelectReturn 27.09.1990   -AW-
* Reserved added in all structures 28.09.1990   -AW-
* NFS2_NOGADGETS added 29.09.1990   -AW-
* ---------------------------------------------------------

* Struct to build FileSelect
* a0 should contain a pointer on this structure.
* If not, the indian gods will probably send their gurus...

			rsreset
NFS2_NewFileSelect	rs.b	0
NFS2_LeftEdge		rs.w	1
NFS2_TopEdge		rs.w	1
NFS2_WindowTitle	rs.l	1
NFS2_DefaultPath	rs.l	1
NFS2_DefaultFile	rs.l	1
NFS2_Screenptr		rs.l	1
NFS2_GadgetFlags	rs.w	1
NFS2_FirstFilter	rs.l	1
NFS2_BackPen		rs.b	1
NFS2_FilePen		rs.b	1
NFS2_DirPen		rs.b	1
NFS2_GadgetPen		rs.b	1
NFS2_Reserved1		rs.l	1
NFS2_Reserved2		rs.l	1
NFS2_SIZEOF		rs.w	0

* Use the following keywords to avoid those nothing-is-said-with-it numbers.

NFS2_CENTREPOS		equ	-1
NFS2_DEFAULTTITLE	equ	0
NFS2_NODEFAULT		equ	0
NFS2_ACTIVESCREEN	equ	0
NFS2_MAKEDIR		equ	1<<0
NFS2_DELETE		equ	1<<1
NFS2_RENAME		equ	1<<2
NFS2_NOGADGETS		equ	0
NFS2_NOFILTER		equ	0
NFS2_DEFAULTPEN		equ	-1

* Struct for a filter
* NFS2_NewFileSelect.NFS2_FirstFilter can optionally point on this structure.
* It can also point on another structure of this type to add another filter.

			rsreset
FS2F_FilterElement	rs.b	0
FS2F_NextFilter		rs.l	1
FS2F_FilterLength	rs.b	1
FS2F_AdjustToWord	rs.b	1
FS2F_Filter		rs.l	1
FS2F_Reserved		rs.l	1
FS2F_SIZEOF		rs.w	0

* Use the following keyword to avoid those nothing-is-said-with-it numbers.

FS2F_LASTFILTER		equ	0

* Struct which is sent back from FileSelect
* d0 points on this structure containing all important answers from
* FileSelect.

			rsreset
FS2_FileSelectReturn	rs.b	0
FS2_Status		rs.w	1
FS2_Path		rs.l	1
FS2_File		rs.l	1
FS2_FullName		rs.l	1
FS2_Reserved1		rs.l	1
FS2_Reserved2		rs.l	1
FS2_SIZEOF		rs.w	0

* Use the following keywords to avoid those nothing-is-said-with-it numbers.

FS2_OKAY		equ	0
FS2_CANCEL		equ	1
FS2_WINDOWERR		equ	2
FS2_NOPATH		equ	0
FS2_NOFILE		equ	0
FS2_NOFULLNAME		equ	0

* ----- AW/CLUSTER -----

