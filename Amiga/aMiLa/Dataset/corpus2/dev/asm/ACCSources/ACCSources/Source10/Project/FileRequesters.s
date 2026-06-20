;***********************************************************
;	FileRequester Structures
;***********************************************************


;------	hail text is what will appear in requesters window title	

Requesterflags	EQU	0

LoadFileStruct	dc.l		LoadText	
		dc.l		LoadFileData	
		dc.l		LoadDirData	
		dc.l		0		
		dc.b		Requesterflags	
		dc.b		0		
		dc.l		0		
		dc.l		0		

;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset

		dc.l		LoadPathName
	
SaveFileStruct	dc.l		SaveText	
		dc.l		SaveFileData	
		dc.l		SaveDirData	
		dc.l		0		
		dc.b		Requesterflags!FRF_DoColor
		dc.b		0		
		dc.l		0		
		dc.l		0		

;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset

		dc.l		SavePathName

InsertFileStruct dc.l		InsertTitle	
		dc.l		InsertFileData	
		dc.l		InsertDirData	
		dc.l		0		
		dc.b		Requesterflags	
		dc.b		0		
		dc.l		0		
		dc.l		0		

;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset

		dc.l		InsertPathName

;------	This is the text for requesters title

LoadText	dc.b	'Load File ',0

SaveText	dc.b	'Save File ',0

InsertTitle	dc.b	'Insert File ',0
		EVEN
