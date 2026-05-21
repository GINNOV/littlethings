	IFND	WORKBENCH_STARTUP_I
WORKBENCH_STARTUP_I	SET	1
	IFND	EXEC_TYPES_I
	INCLUDE	"exec/types.i"
	ENDC
	IFND	EXEC_PORTS_I
	INCLUDE	"exec/ports.i"
	ENDC
	IFND	LIBRARIES_DOS_I
	INCLUDE	"libraries/dos.i"
	ENDC
	rsreset
WBStartup	rs.b	0
sm_Message	rs.b	MN_SIZE
sm_Process	rs.l	1
sm_Segment	rs.l	1
sm_NumArgs	rs.l	1
sm_ToolWindow	rs.l	1
sm_ArgList	rs.l	1
sm_SIZEOF	rs.w	0
	rsreset
WBArg	rs.b	0
wa_Lock	rs.l	1
wa_Name	rs.l	1
wa_SIZEOF	rs.w	0
	ENDC

