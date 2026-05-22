	IFND	INTUITION_INTUITIONBASE_I
INTUITION_INTUITIONBASE_I	SET	1

	STRUCTURE	IntuitionBase,0
		STRUCT	ib_LibNode,34
		STRUCT	ib_ViewLord,18
		APTR	ib_ActiveWindow
		APTR	ib_ActiveScreen
		APTR	ib_FirstScreen
		ULONG	ib_Flags
		WORD	ib_MouseY
		WORD	ib_MouseX
		ULONG	ib_Seconds
		ULONG	ib_Micros
		WORD	ib_MinXMouse
		WORD	ib_MaxXMouse
		WORD	ib_MinYMouse
		WORD	ib_MaxYMouse
		ULONG	ib_StartSecs
		ULONG	ib_StartMicros
		APTR	ib_SysBase
		APTR	ib_GfxBase
		APTR	ib_LayersBase
		APTR	ib_ConsoleDevice
		APTR	ib_APointer
		BYTE	ib_APtrHeight
		BYTE	ib_APtrWidth
		BYTE	ib_AXOffset
		BYTE	ib_AYOffset
		USHORT	ib_MenuDrawn
		USHORT	ib_MenuSelected
		USHORT	ib_OptionList
		STRUCT	ib_MenuRPort,100
		STRUCT	ib_MenuTmpRas,8
		STRUCT	ib_ItemCRect,36
		STRUCT	ib_SubCRect,36
;		STRUCT	ib_IBitMap,

	ENDC ; INTUITION_INTUITIONBASE_I
