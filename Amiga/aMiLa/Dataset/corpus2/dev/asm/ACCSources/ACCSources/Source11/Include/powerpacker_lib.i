	IFND	LIBRARIES_POWERPACKER_LIB_I
LIBRARIES_POWERPACKER_LIB_I SET	1
**
**	$Filename: libraries/powerpacker_lib.i $
**	$Release: 1.1 $
**
**	(C) Copyright 1990 Nico François
**	    All Rights Reserved
**

	IFND    EXEC_TYPES_I
	include "exec/types.i"
	ENDC
	IFND    EXEC_NODES_I
	include "exec/nodes.i"
	ENDC
	IFND    EXEC_LISTS_I
	include "exec/lists.i"
	ENDC
	IFND    EXEC_LIBRARIES_I
	include "exec/libraries.i"
	ENDC

	LIBINIT

	LIBDEF _LVOppLoadData
	LIBDEF _LVOppDecrunchBuffer
	LIBDEF _LVOppCalcChecksum
	LIBDEF _LVOppCalcPasskey
	LIBDEF _LVOppDecrypt
	LIBDEF _LVOppGetPassword
	LIBDEF _LVOppGetString
	LIBDEF _LVOppGetLong
	LIBDEF _LVOppDecrHdr            ; private !
	LIBDEF _LVOppCryptDecrHdr       ; private !
	LIBDEF _LVOppOverlayDecrHdr     ; private !

	ENDC	; LIBRARIES_POWERPACKER_LIB_I
