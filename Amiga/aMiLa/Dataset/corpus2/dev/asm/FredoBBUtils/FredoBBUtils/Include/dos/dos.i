	STRUCTURE	DosBase,LIB_SIZE
		APTR	dl_Root
		APTR	dl_GV
		LONG	dl_A2
		LONG	dl_A5
		LABEL	DOSBASESIZE

	STRUCTURE	RootNode,0
		BPTR	m_TaskArray
		BPTR	m_ConsoleSegment
		STRUCT	m_Time,DS_SIZE
		LONG	m_RestartSeg
		LONG	m_Info
		BPTR	m_FileHandlerSeg
		LABEL	m_SIZEOF

	STRUCTURE	DosInfo,0
		BPTR	di_Name
		BPTR	di_DevInfo
		BPTR	di_Devices
		BPTR	di_Handlers
		BPTR	di_NetHand
		LABEL	di_SIZEOF

	STRUCTURE	DeviceList,0
		BPTR	dl_Next
		LONG	dl_Type
		APTR	dl_Task
		BPTR	dl_Lock
		STRUCT	dl_VolumeDate,DS_SIZE
		BPTR	dl_LockList
		LONG	dl_DiskType
		LONG	dl_Unused
		BSTR	dl_Name
		LABEL	dl_SIZEOF
