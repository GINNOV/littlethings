	ifnd	WORKBENCH_WORKBENCH_I
WORKBENCH_WORKBENCH_I set 1
**
**	workbench/workbench.i 40.1 (26.8.93)
**	Release 3.1
**	for PhxAss
**
**	© copyright by F.Wille in 1995
**

	ifnd	EXEC_NODES_I
	include "exec/nodes.i"
	endc

	ifnd	EXEC_LISTS_I
	include "exec/lists.i"
	endc

	ifnd	EXEC_TASKS_I
	include "exec/tasks.i"
	endc

	ifnd	INTUITION_INTUITION_I
	include "intuition/intuition.i"
	endc


WBDISK		= 1
WBDRAWER	= 2
WBTOOL		= 3
WBPROJECT	= 4
WBGARBAGE	= 5
WBDEVICE	= 6
WBKICK		= 7
WBAPPICON	= 8

* DrawerData
 rsreset
dd_NewWindow		rs.b nw_SIZE
dd_CurrentX		rs.l 1
dd_CurrentY		rs.l 1
OldDrawerData_SIZEOF	rs
OLDDRAWERDATAFILESIZE	rs
dd_Flags		rs.l 1
dd_ViewModes		rs.w 1
DrawerData_SIZEOF	rs
DRAWERDATAFILESIZE	rs


** DiskObject
 rsreset
do_Magic		rs.w 1
do_Version		rs.w 1
do_Gadget		rs.b gg_SIZEOF
do_Type 		rs.b 1
do_PAD_BYTE		rs.b 1
do_DefaultTool		rs.l 1
do_ToolTypes		rs.l 1
do_CurrentX		rs.l 1
do_CurrentY		rs.l 1
do_DrawerData		rs.l 1
do_ToolWindow		rs.l 1
do_StackSize		rs.l 1
do_SIZEOF		rs

WB_DISKMAGIC		= $e310
WB_DISKVERSION		= 1
WB_DISKREVISION 	= 1
WB_DISKREVISIONMASK	= $ff


* FreeList
 rsreset
fl_NumFree		rs.w 1
fl_MemList		rs.b lh_SIZE
FreeList_SIZEOF 	rs


GFLG_GADGBACKFILL	= 1
GADGBACKFILL		= 1
NO_ICON_POSITION	= $80000000


WORKBENCH_NAME	macro
		dc.b	"workbench.library",0
		even
		endm

AM_VERSION	= 1


* AppMessage
 rsreset
am_Message		rs.b mn_SIZE
am_Type 		rs.w 1
am_UserData		rs.l 1
am_ID			rs.l 1
am_NumArgs		rs.l 1
am_ArgList		rs.l 1
am_Version		rs.w 1
am_Class		rs.w 1
am_MouseX		rs.w 1
am_MouseY		rs.w 1
am_Seconds		rs.l 1
am_Micros		rs.l 1
am_Reserved		rs.b 8
AppMessage_SIZEOF	rs

AMTYPE_APPWINDOW	= 7
AMTYPE_APPICON		= 8
AMTYPE_APPMENUITEM	= 9


* AppWindow
 rsreset
aw_PRIVATE		rs
AppWindow_SIZEOF	rs

* AppIcon
 rsreset
ai_PRIVATE		rs
AppIcon_SIZEOF		rs

* AppMenuItem
 rsreset
ami_PRIVATE		rs
AppMenuItem_SIZEOF	rs

	endc
