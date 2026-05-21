	IFND	WORKBENCH_WORKBENCH_I
WORKBENCH_WORKBENCH_I	SET	1
	IFND	EXEC_TYPES_I
	INCLUDE	"exec/types.i"
	ENDC
	IFND	EXEC_NODES_I
	INCLUDE	"exec/nodes.i"
	ENDC
	IFND	EXEC_LISTS_I
	INCLUDE	"exec/lists.i"
	ENDC
	IFND	EXEC_TASKS_I
	INCLUDE	"exec/tasks.i"
	ENDC
	IFND	INTUITION_INTUITION_I
	INCLUDE	"intuition/intuition.i"
	ENDC
WBDISK	EQU	1
WBDRAWER	EQU	2
WBTOOL	EQU	3
WBPROJECT	EQU	4
WBGARBAGE	EQU	5
WBDEVICE	EQU	6
WBKICK	EQU	7
	rsreset
DrawerData	rs.b	0
dd_NewWindow	rs.b	nw_SIZE
dd_CurrentX	rs.l	1
dd_CurrentY	rs.l	1
dd_SIZEOF	rs.w	0
DRAWERDATAFILESIZE	EQU	(dd_SIZEOF)
	rsreset
DiskObject	rs.b	0
do_Magic	rs.w	1
do_Version	rs.w	1
do_Gadget	rs.b	gg_SIZEOF
do_Type	rs.w	1
do_DefaultTool	rs.l	1
do_ToolTypes	rs.l	1
do_CurrentX	rs.l	1
do_CurrentY	rs.l	1
do_DrawerData	rs.l	1
do_ToolWindow	rs.l	1
do_StackSize	rs.l	1
do_SIZEOF	rs.w	0
WB_DISKMAGIC	EQU	$e310
WB_DISKVERSION	EQU	1
	rsreset
FreeList	rs.b	0
fl_NumFree	rs.w	1
fl_MemList	rs.b	LH_SIZE
FreeList_SIZEOF	rs.w	0
MTYPE_PSTD	EQU	1
MTYPE_TOOLEXIT	EQU	2
MTYPE_DISKCHANGE	EQU	3
MTYPE_TIMER	EQU	4
MTYPE_CLOSEDOWN	EQU	5
MTYPE_IOPROC	EQU	6
GADGBACKFILL	EQU	$0001
NO_ICON_POSITION	EQU	($80000000)
	ENDC

