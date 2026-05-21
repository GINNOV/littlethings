	IFND	DEVICES_CLIPBOARD_I
DEVICES_CLIPBOARD_I	SET	1
	IFND	EXEC_NODES_I
	INCLUDE	"exec/nodes.i"
	ENDC
	IFND	EXEC_LISTS_I
	INCLUDE	"exec/lists.i"
	ENDC
	IFND	EXEC_PORTS_I
	INCLUDE	"exec/ports.i"
	ENDC
	IFND	EXEC_IO_I
	INCLUDE	"exec/io.i"
	ENDC
	DEVINIT
	DEVCMD	CBD_POST
	DEVCMD	CBD_CURRENTREADID
	DEVCMD	CBD_CURRENTWRITEID
CBERR_OBSOLETEID	EQU	1
	rsreset
ClipboardUnitPartial	rs.b	0
cu_Node	rs.b	LN_SIZE
cu_UnitNum	rs.l	1
	rsreset
IOClipReq	rs.b	0
io_Message	rs.b	MN_SIZE
io_Device	rs.l	1
io_Unit	rs.l	1
io_Command	rs.w	1
io_Flags	rs.b	1
io_Error	rs.b	1
io_Actual	rs.l	1
io_Length	rs.l	1
io_Data	rs.l	1
io_Offset	rs.l	1
io_ClipID	rs.l	1
iocr_SIZEOF	rs.w	0
PRIMARY_CLIP	EQU	0
	rsreset
SatisfyMsg	rs.b	0
sm_Msg	rs.b	MN_SIZE
sm_Unit	rs.w	1
sm_ClipID	rs.l	1
satisfyMsg_SIZEOF	rs.w	0
	ENDC

