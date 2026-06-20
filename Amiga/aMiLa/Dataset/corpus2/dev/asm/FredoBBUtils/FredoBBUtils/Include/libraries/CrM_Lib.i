	IFND	LIBRARIES_CRM_LIB_I
LIBRARIES_CRM_LIB_I	SET	1

	IFND	EXEC_TYPES_I
	include	exec/types.i
	ENDC
	IFND	EXEC_NODES_I
	include	exec/nodes.i
	ENDC
	IFND    EXEC_LIBRARIES_I
	include exec/libraries.i
	ENDC

	LIBINIT

	LIBDEF	_LVOcmLoadSeg		;NOT for
	LIBDEF	_LVOcmPrivate1		;public use!
	LIBDEF	_LVOcmCheckCrunched
	LIBDEF	_LVOcmDecrunch
	LIBDEF	_LVOcmProcessPW
	LIBDEF	_LVOcmCryptData
	LIBDEF	_LVOcmProcessCrunchStructA
	LIBDEF	_LVOcmCrunchData
	LIBDEF	_LVOcmAllocCrunchStructA
	LIBDEF	_LVOcmFreeCrunchStruct

	ENDC	; LIBRARIES_CRM_LIB_I
