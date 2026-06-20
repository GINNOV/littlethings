********************************************************************
*
*				  MemMan.i
*			     Low-memory	manager
*			Copyright (C) 1991 Bryan Ford
*
********************************************************************
	ifnd	BRY_MEMMAN_I
BRY_MEMMAN_I	set	1

	ifnd	EXEC_NODES_I
	include	"exec/nodes.i"
	endc

 STRUCTURE	MMNode,0
	STRUCT	mmn_Node,LN_SIZE
	APTR	mmn_GetRidFunc
	APTR	mmn_GetRidData
	LABEL	mmn_SIZEOF

MMNT_LINKED	equ	NT_USER

	LIBINIT
	LIBDEF	_LVOMMAddNode
	LIBDEF	_LVOMMRemNode

	endc
