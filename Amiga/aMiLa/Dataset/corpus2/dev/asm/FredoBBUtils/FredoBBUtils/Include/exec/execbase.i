	IFND	EXEC_EXECBASE_I
EXEC_EXECBASE_I	SET	1

	IFND	EXEC_TYPES_I
	include	exec/types.i
	ENDC

	IFND	EXEC_NODES_I
	include	exec/nodes.i
	ENDC

	IFND	EXEC_LIBRARIES_I
	include	exec/libraries.i
	ENDC

	STRUCTURE	ExecBase,LIB_SIZE
		UWORD	SoftVer
		WORD	LowMemChkSum
		ULONG	ChkBase
		APTR	ColdCapture
		APTR	CoolCapture
		APTR	WarmCapture
		APTR	SysStkUpper
		APTR	SysStkLower
		ULONG	MaxLocMem
		APTR	DebugEntry
		APTR	DebugData
		APTR	AlertData
		APTR	MaxExtMem
		WORD	ChkSum
		STRUCT	IntVects,16*12
		APTR	ThisTask
		ULONG	IdleCount
		ULONG	DispCount
		UWORD	Quantum
		UWORD	Elapsed
		UWORD	SysFlags
		BYTE	IDNestCnt
		BYTE	TDNestCnt
		UWORD	AttnFlags
		UWORD	AttnResched
		APTR	ResModules
		APTR	TaskTrapCode
		APTR	TaskExceptCode
		APTR	TaskExitCode
		ULONG	TaskSigAlloc
		UWORD	TaskTrapAlloc
		STRUCT	MemList,14
		STRUCT	ResourceList,14
		STRUCT	DeviceList,14
		STRUCT	IntrList,14
		STRUCT	LibList,14
		STRUCT	PortList,14
		STRUCT	TaskReady,14
		STRUCT	TaskWait,14
		STRUCT	SoftInts,5*16
		STRUCT	LastAlert,4*4
		UBYTE	VBlankFrequency
		UBYTE	PowerSupplyFrequency
		STRUCT	SemaphoreList,14
		APTR	KickMemPtr
		APTR	KickTagPtr
		APTR	KickCheckSum
		STRUCT	ExecBaseReserved,10
		STRUCT	ExecBaseNewReserved,20
		LABEL	SYSBASESIZE

AFB_68010	EQU	0
AFB_68020	EQU	1
AFB_68881	EQU	4

AFF_68010	EQU	1<<0
AFF_68020	EQU	1<<1
AFF_68881	EQU	1<<4

AFB_RESERVED8	EQU	8
AFB_RESERVED9	EQU	9

	ENDC ; EXEC_EXECBASE_I
