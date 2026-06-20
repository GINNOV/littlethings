	IFND	EXEC_INITIALIZERS_I
EXEC_INITIALIZERS_I	SET	1

INITBYTE MACRO	* &offset,&value
	dc.b	$E0
	dc.b	0
	dc.w	\1
	dc.b	\2
	dc.b	0
	ENDM
INITWORD MACRO	* &offset,&value
	dc.b	$D0
	dc.b	0
	dc.w	\1
	dc.w	\2
	ENDM
INITLONG MACRO	* &offset,&value
	dc.b	$C0
	dc.b	0
	dc.w	\1
	dc.l	\2
	ENDM

	ENDC ; EXEC_INITIALIZERS_I
